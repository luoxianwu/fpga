module APB_PWM_CONTROLLER (
    input wire clk_i,         // APB clock input (system clock)
    input wire resetn_i,      // APB asynchronous active-low reset
    input wire psel_i,        // APB peripheral select (active high)
    input wire penable_i,     // APB enable (active high)
    input wire pwrite_i,      // APB write (1) / read (0) indicator
    input wire [5:0] paddr_i, // APB address bus (6 bits wide, paddr[5:0])
    input wire [31:0] pwdata_i,  // APB write data bus (32 bits)
    output reg [31:0] prdata_o,  // APB read data bus (32 bits)
    output reg pready_o,      // APB ready signal (active high)
    output reg pslverr_o,     // APB slave error (active high)
    output reg pwm_o          // PWM output signal
);

    // --- Local Parameters ---
    localparam APB_ADDR_CONTROL_STATUS  = 3'h0; // Offset 0x00: Control and Status Register
    localparam APB_ADDR_T1_DUTY_CYCLE   = 3'h1; // Offset 0x04: T1 Duty Cycle Register (0-100)
    localparam APB_ADDR_T1_PULSE_COUNT  = 3'h2; // Offset 0x08: T1 Pulse Count Register
    localparam APB_ADDR_T2_DUTY_CYCLE   = 3'h3; // Offset 0x0C: T2 Duty Cycle Register (0-100)
    localparam APB_ADDR_T2_PULSE_COUNT  = 3'h4; // Offset 0x10: T2 Pulse Count Register
    localparam APB_ADDR_T3_DUTY_CYCLE   = 3'h5; // Offset 0x14: T3 Duty Cycle Register (0-100)
    localparam APB_ADDR_T3_PULSE_COUNT  = 3'h6; // Offset 0x18: T3 Pulse Count Register

    localparam NUM_LOGICAL_REGS = 7; // 7 registers
    localparam ADDR_SELECT_BITS = 3; // log2(7) rounded up, 3 bits for 7 registers

    // PWM Core Parameters
    parameter FULL_DUTY_COUNT = 16'd100; // Adjusted for 3 MHz clock, ~33.33 µs period

    // --- Internal Registers ---
    reg [31:0] t1_duty_cycle_reg;   // T1 duty cycle (0-100)
    reg [31:0] t1_pulse_count_reg;  // T1 pulse count (0 for continuous in stage)
    reg [31:0] t2_duty_cycle_reg;   // T2 duty cycle (0-100)
    reg [31:0] t2_pulse_count_reg;  // T2 pulse count (0 for continuous in stage)
    reg [31:0] t3_duty_cycle_reg;   // T3 duty cycle (0-100)
    reg [31:0] t3_pulse_count_reg;  // T3 pulse count (0 for continuous in stage)
    reg [31:0] control_status_reg;  // Bits: [0]=pwm_enable, [1]=pwm_done_status
    reg [15:0] pwm_period_counter;  // Counts up to FULL_DUTY_COUNT
    reg [15:0] pwm_pulse_counter;   // Counts generated PWM pulses
    reg [1:0]  current_stage;       // Tracks stage: 0=T1, 1=T2, 2=T3, 3=Done
    wire duration_completed;        // Flag: set when stage or sequence completes
    reg pwm_done_int;               // Single-cycle pulse for pwm_done_status
    reg apb_reset_pulse_counter_flag; // APB-initiated pulse counter reset

    // --- Clock Divider (Divide clk_i by 6) ---
    reg [2:0] clk_div_counter;      // 3-bit counter for division by 6
    reg pwm_clk;                    // Divided clock for PWM logic
    always @(posedge clk_i or negedge resetn_i) begin
        if (!resetn_i) begin
            clk_div_counter <= 3'd0;
            pwm_clk <= 1'b0;
        end else begin
            if (clk_div_counter == 3'd5) begin // Divide by 6 (0 to 5)
                clk_div_counter <= 3'd0;
                pwm_clk <= ~pwm_clk;           // Toggle every 6 cycles
            end else begin
                clk_div_counter <= clk_div_counter + 1;
            end
        end
    end

    // --- Derived PWM Operational Values ---
    wire [ADDR_SELECT_BITS-1:0] reg_address_index;
    assign reg_address_index = paddr_i[ADDR_SELECT_BITS+1:2]; // Extracts paddr_i[4:2]

    // Select duty cycle and pulse count based on current stage
    wire [31:0] current_duty_cycle_reg;
    wire [31:0] current_pulse_count_reg;
    assign current_duty_cycle_reg = (current_stage == 2'd0) ? t1_duty_cycle_reg :
                                   (current_stage == 2'd1) ? t2_duty_cycle_reg :
                                   (current_stage == 2'd2) ? t3_duty_cycle_reg : 32'd0;
    assign current_pulse_count_reg = (current_stage == 2'd0) ? t1_pulse_count_reg :
                                    (current_stage == 2'd1) ? t2_pulse_count_reg :
                                    (current_stage == 2'd2) ? t3_pulse_count_reg : 32'd0;

    // Simplified duty high cycles (directly use duty cycle as high cycles)
    reg [15:0] current_duty_high_reg;
    always @(*) begin
        current_duty_high_reg = current_duty_cycle_reg[15:0]; // Use lower 16 bits, 0-100
    end

    wire pwm_active_enable;
    assign pwm_active_enable = control_status_reg[0];

    // APB write strobe for control_status_reg
    wire apb_write_control_status_strobe;
    wire apb_control_status_pwdata_bit0;
    assign apb_write_control_status_strobe = (psel_i && penable_i && pwrite_i && (reg_address_index == APB_ADDR_CONTROL_STATUS));
    assign apb_control_status_pwdata_bit0 = pwdata_i[0];

    // Duration completed logic
    assign duration_completed = (current_pulse_count_reg == 32'd0) ||
                               ((current_pulse_count_reg != 32'd0) && (pwm_pulse_counter == current_pulse_count_reg));

    // --- APB State Machine ---
    localparam APB_IDLE   = 1'b0;
    localparam APB_ACCESS = 1'b1;
    reg apb_current_state;

    // --- APB Slave Logic ---
    always @(posedge clk_i or negedge resetn_i) begin
        if (!resetn_i) begin
            apb_current_state <= APB_IDLE;
            pready_o <= 1'b0;
            pslverr_o <= 1'b0;
            prdata_o <= 32'd0;
            t1_duty_cycle_reg <= 32'd20;   // Default 20%
            t1_pulse_count_reg <= 32'd0;   // Default continuous
            t2_duty_cycle_reg <= 32'd20;
            t2_pulse_count_reg <= 32'd0;
            t3_duty_cycle_reg <= 32'd20;
            t3_pulse_count_reg <= 32'd0;
            apb_reset_pulse_counter_flag <= 1'b0;
        end else begin
            pready_o <= 1'b0;
            pslverr_o <= 1'b0;
            prdata_o <= 32'd0;
            apb_reset_pulse_counter_flag <= 1'b0;

            case (apb_current_state)
                APB_IDLE: begin
                    if (psel_i == 1'b1) begin
                        apb_current_state <= APB_ACCESS;
                    end
                end
                APB_ACCESS: begin
                    if (psel_i == 1'b1 && penable_i == 1'b1) begin
                        pready_o <= 1'b1;
                        if (reg_address_index < NUM_LOGICAL_REGS) begin
                            if (pwrite_i == 1'b1) begin // Write
                                case (reg_address_index)
                                    APB_ADDR_CONTROL_STATUS: begin
                                        if (pwdata_i[0] == 1'b1) begin
                                            apb_reset_pulse_counter_flag <= 1'b1;
                                        end
                                    end
                                    APB_ADDR_T1_DUTY_CYCLE:  t1_duty_cycle_reg <= pwdata_i;
                                    APB_ADDR_T1_PULSE_COUNT: t1_pulse_count_reg <= pwdata_i;
                                    APB_ADDR_T2_DUTY_CYCLE:  t2_duty_cycle_reg <= pwdata_i;
                                    APB_ADDR_T2_PULSE_COUNT: t2_pulse_count_reg <= pwdata_i;
                                    APB_ADDR_T3_DUTY_CYCLE:  t3_duty_cycle_reg <= pwdata_i;
                                    APB_ADDR_T3_PULSE_COUNT: t3_pulse_count_reg <= pwdata_i;
                                    default: pslverr_o <= 1'b1;
                                endcase
                            end else begin // Read
                                case (reg_address_index)
                                    APB_ADDR_CONTROL_STATUS: begin
                                        prdata_o[0] <= control_status_reg[0];
                                        prdata_o[1] <= pwm_done_int;
                                        prdata_o[31:2] <= 30'd0;
                                    end
                                    APB_ADDR_T1_DUTY_CYCLE:  prdata_o <= t1_duty_cycle_reg;
                                    APB_ADDR_T1_PULSE_COUNT: prdata_o <= t1_pulse_count_reg;
                                    APB_ADDR_T2_DUTY_CYCLE:  prdata_o <= t2_duty_cycle_reg;
                                    APB_ADDR_T2_PULSE_COUNT: prdata_o <= t2_pulse_count_reg;
                                    APB_ADDR_T3_DUTY_CYCLE:  prdata_o <= t3_duty_cycle_reg;
                                    APB_ADDR_T3_PULSE_COUNT: prdata_o <= t3_pulse_count_reg;
                                    default: begin
                                        pslverr_o <= 1'b1;
                                        prdata_o <= 32'hDEADBEEF;
                                    end
                                endcase
                            end
                        end else begin
                            pslverr_o <= 1'b1;
                            prdata_o <= 32'hDEADBEEF;
                        end
                        apb_current_state <= APB_IDLE;
                    end else begin
                        apb_current_state <= APB_IDLE;
                    end
                end
                default: apb_current_state <= APB_IDLE;
            endcase
        end
    end

    // --- Control Status Register Logic ---
    always @(posedge clk_i or negedge resetn_i) begin
        if (!resetn_i) begin
            control_status_reg <= 32'd0;
        end else begin
            control_status_reg <= control_status_reg;
            if (apb_write_control_status_strobe) begin
                control_status_reg[0] <= apb_control_status_pwdata_bit0;
            end else if (current_stage == 2'd3 && pwm_active_enable) begin
                control_status_reg[0] <= 1'b0; // Auto-clear when sequence completes
            end
        end
    end

    // --- PWM Core Logic ---
    always @(posedge pwm_clk or negedge resetn_i) begin
        if (!resetn_i) begin
            pwm_period_counter <= 16'd0;
            pwm_pulse_counter <= 16'd0;
            pwm_done_int <= 1'b0;
            current_stage <= 2'd0; // Start at T1
        end else begin
            pwm_done_int <= 1'b0;

            if (apb_reset_pulse_counter_flag) begin
                pwm_pulse_counter <= 16'd0;
                current_stage <= 2'd0; // Reset to T1
                pwm_period_counter <= 16'd0;
            end else if (pwm_active_enable && current_stage != 2'd3) begin
                if (pwm_period_counter == FULL_DUTY_COUNT) begin
                    pwm_period_counter <= 16'd0;
                    if (current_duty_high_reg > 0) begin
                        if (current_pulse_count_reg != 32'd0) begin
                            if (pwm_pulse_counter == current_pulse_count_reg - 1) begin
                                pwm_pulse_counter <= current_pulse_count_reg;
                                if (current_stage < 2'd2) begin
                                    current_stage <= current_stage + 1; // Move to next stage
                                    pwm_pulse_counter <= 16'd0; // Reset for next stage
                                end else begin
                                    current_stage <= 2'd3; // Sequence complete
                                    pwm_done_int <= 1'b1;
                                end
                            end else begin
                                pwm_pulse_counter <= pwm_pulse_counter + 1;
                            end
                        end
                    end
                end else begin
                    pwm_period_counter <= pwm_period_counter + 1;
                end
            end else begin
                pwm_period_counter <= 16'd0;
            end
        end
    end

    // --- PWM Output Logic ---
    always @(posedge pwm_clk or negedge resetn_i) begin
        if (!resetn_i) begin
            pwm_o <= 1'b0;
        end else begin
            if (pwm_active_enable &&
                (pwm_period_counter < current_duty_high_reg) &&
                (current_duty_high_reg > 0) &&
                (!duration_completed) &&
                (current_stage != 2'd3)) begin
                pwm_o <= 1'b1;
            end else begin
                pwm_o <= 1'b0;
            end
        end
    end

endmodule