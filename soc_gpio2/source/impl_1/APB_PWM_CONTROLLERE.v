// File: apb_pwm_controller.v
// Description: An APB-controlled Pulse Width Modulation (PWM) generator module.
//              It features 3 configurable registers:
//              1. Status and Control Register: Enables PWM, indicates completion.
//              2. PWM Duty Cycle Register: Sets PWM duty cycle (0-100%).
//              3. PWM Pulse Count Register: Sets number of pulses (0 for continuous).
//              Connects via a 6-bit APB address bus (paddr[5:0]).

module APB_PWM_CONTROLLER (
    // System Signals
    input wire clk_i,         // APB clock input (system clock for PWM)
    input wire resetn_i,      // APB asynchronous active-low reset (system reset for PWM)

    // APB Slave Interface
    input wire psel_i,        // APB peripheral select (active high)
    input wire penable_i,     // APB enable (active high, indicates active transfer)
    input wire pwrite_i,      // APB write (1) / read (0) indicator
    input wire [5:0] paddr_i,   // APB address bus (6 bits wide, paddr[5:0])
    input wire [31:0] pwdata_i,  // APB write data bus (32 bits)
    output reg [31:0] prdata_o,  // APB read data bus (32 bits)
    output reg pready_o,      // APB ready signal (active high)
    output reg pslverr_o,     // APB slave error (active high for unsupported addresses)

    // PWM Output
    output reg pwm_o          // PWM output signal
);


    // --- Local Parameters ---
    // APB Register Address Map
    // These offsets are based on a 4-byte word alignment.
    localparam APB_ADDR_CONTROL_STATUS = 2'h0; // Offset 0x00: Control and Status Register
    localparam APB_ADDR_PWM_DUTY_CYCLE = 2'h1; // Offset 0x04: PWM Duty Cycle Register (0-100%)
    localparam APB_ADDR_PWM_PULSE_COUNT = 2'h2; // Offset 0x08: PWM Pulse Count Register (0 for continuous)

    // Total number of addressable registers (for address decoding logic)
    localparam NUM_LOGICAL_REGS = 3; // We have 3 distinct registers
    localparam ADDR_SELECT_BITS = 2; // log2(NUM_LOGICAL_REGS) rounded up to power of 2, 2 bits (00, 01, 10) for 3 registers

    // PWM Core Parameters
//  parameter FULL_DUTY_COUNT = 16'd9999; // Base resolution of the PWM (e.g., 10,000 counts)
	parameter FULL_DUTY_COUNT = 16'd611;//ase resolution of the PWM (e.g., 10,000 counts)

    // --- Internal Registers ---
    // APB-accessible registers
    reg [31:0] pwm_duty_cycle_reg;  // Stores desired duty cycle (0-100)
    reg [31:0] pwm_pulse_count_reg; // Stores target number of pulses (0 for continuous)

    // Control Status Register - all assignments consolidated into its own always block
    reg [31:0] control_status_reg;  // Bits: [0]=pwm_enable, [1]=pwm_done_status

    // PWM state-related registers
    reg [15:0] pwm_period_counter;  // Counts up to FULL_DUTY_COUNT
    reg [15:0] pwm_pulse_counter;   // Counts generated PWM pulses
    
    // Changed duration_completed to a wire as its value is always combinatorial
    wire duration_completed;         // Flag: set when target pulses reached (combinatorial)
    reg pwm_done_int;               // Internal single-cycle pulse for pwm_done_status

    // --- Derived PWM Operational Values ---
    // The APB paddr_i is 6 bits (paddr_i[5:0]).
    // Assuming 4-byte aligned registers, the internal register index comes from paddr_i[3:2].
    // This allows for 4 unique 4-byte aligned addresses (0x00, 0x04, 0x08, 0x0C).
    // Our 3 registers fit within these 4 addresses.
    wire [ADDR_SELECT_BITS-1:0] reg_address_index;
    assign reg_address_index = paddr_i[ADDR_SELECT_BITS+1:2]; // Extracts paddr_i[3:2] for 2-bit index

    // Calculated number of high cycles based on duty cycle percentage
    // Clamps duty_cycle_reg to 100% to prevent overflow or incorrect behavior
    wire [15:0] calculated_duty_high_cycles =
        (pwm_duty_cycle_reg > 100) ? ((FULL_DUTY_COUNT + 1) * 100 / 100) :
        ((FULL_DUTY_COUNT + 1) * pwm_duty_cycle_reg / 100);

    wire pwm_active_enable;
    assign pwm_active_enable = control_status_reg[0];

    // Flag to signal an APB-initiated reset of the pulse counter
    reg apb_reset_pulse_counter_flag; // Set by APB logic, read by PWM core logic

    // Wires to capture APB write data for control_status_reg
    wire apb_write_control_status_strobe; // Strobe indicating a valid write to control_status_reg
    wire apb_control_status_pwdata_bit0; // The actual bit 0 data from pwdata_i
    assign apb_write_control_status_strobe = (psel_i && penable_i && pwrite_i && (reg_address_index == APB_ADDR_CONTROL_STATUS));
    assign apb_control_status_pwdata_bit0 = pwdata_i[0];

    // The duration_completed logic is now purely combinatorial
    // It's true if in continuous mode (pwm_pulse_count_reg == 0),
    // OR if a finite count is set AND the pulse counter has reached it.
    assign duration_completed = (pwm_pulse_count_reg == 32'd0) ||
                               ((pwm_pulse_count_reg != 32'd0) && (pwm_pulse_counter == pwm_pulse_count_reg));


    // --- APB State Machine (Simplified for single-cycle access) ---
    localparam APB_IDLE   = 1'b0;
    localparam APB_ACCESS = 1'b1;

    reg apb_current_state; // Current state of the APB FSM

    // --- APB Slave Logic ---
    always @(posedge clk_i or negedge resetn_i) begin
        if (!resetn_i) begin
            // Asynchronous reset for APB interface and state machine
            apb_current_state <= APB_IDLE;
            pready_o <= 1'b0;
            pslverr_o <= 1'b0;
            prdata_o <= 32'd0;
            pwm_duty_cycle_reg <= 32'd20;      // Default 20% duty cycle
            pwm_pulse_count_reg <= 32'd0;      // Default continuous PWM
            apb_reset_pulse_counter_flag <= 1'b0; // Reset this flag too
        end else begin
            // Default assignments for outputs (will be overwritten if a valid transaction occurs)
            pready_o <= 1'b0;
            pslverr_o <= 1'b0;
            prdata_o <= 32'd0;
            apb_reset_pulse_counter_flag <= 1'b0; // Clear flag by default each cycle

            case (apb_current_state)
                APB_IDLE: begin
                    if (psel_i == 1'b1) begin // APB transaction initiated
                        apb_current_state <= APB_ACCESS; // Move to access state
                    end
                end

                APB_ACCESS: begin
                    // Check for valid APB transfer (psel_i and penable_i active)
                    if (psel_i == 1'b1 && penable_i == 1'b1) begin
                        // Transaction is active, assert pready_o for single-cycle transfer
                        pready_o <= 1'b1;

                        // Check if the accessed address is within the valid range of our defined registers
                        if (reg_address_index < NUM_LOGICAL_REGS) begin
                            if (pwrite_i == 1'b1) begin // APB Write transaction
                                case (reg_address_index)
                                    APB_ADDR_CONTROL_STATUS: begin
                                        // Flag the APB write to control_status_reg.
                                        // The actual write is handled by its dedicated always block.
                                        // If PWM is being enabled/started (bit 0 is 1), signal a reset of pulse counter
                                        if (pwdata_i[0] == 1'b1) begin
                                            apb_reset_pulse_counter_flag <= 1'b1;
                                        end
                                    end
                                    APB_ADDR_PWM_DUTY_CYCLE: begin
                                        pwm_duty_cycle_reg <= pwdata_i; // Update duty cycle setting
                                    end
                                    APB_ADDR_PWM_PULSE_COUNT: begin
                                        pwm_pulse_count_reg <= pwdata_i; // Update pulse count setting
                                        // duration_completed is now combinatorial and will update automatically
                                    end
                                    default: begin
                                        // This case should ideally not be reached due to reg_address_index check
                                        pslverr_o <= 1'b1;
                                    end
                                endcase
                            end else begin // APB Read transaction (pwrite_i == 0)
                                case (reg_address_index)
                                    APB_ADDR_CONTROL_STATUS: begin
                                        // Read control bits and current pwm_done_int status
                                        prdata_o[0] <= control_status_reg[0]; // pwm_enable status
                                        prdata_o[1] <= pwm_done_int;         // pwm_done status
                                        prdata_o[31:2] <= 30'd0;             // Clear other bits
                                    end
                                    APB_ADDR_PWM_DUTY_CYCLE: begin
                                        prdata_o <= pwm_duty_cycle_reg;
                                    end
                                    APB_ADDR_PWM_PULSE_COUNT: begin
                                        prdata_o <= pwm_pulse_count_reg;
                                    end
                                    default: begin
                                        // This case should ideally not be reached due to reg_address_index check
                                        pslverr_o <= 1'b1;
                                        prdata_o <= 32'hDEADBEEF; // Indicate invalid read data
                                    end
                                endcase
                            end
                        end else begin
                            // Handle out-of-range address (e.g., if paddr_i[3:2] corresponds to index 3 which is not used)
                            pslverr_o <= 1'b1;
                            prdata_o <= 32'hDEADBEEF; // Indicate invalid read data
                        end
                        apb_current_state <= APB_IDLE; // Return to idle after completion
                    end else begin
                        // If psel_i/penable_i drop unexpectedly, return to idle
                        apb_current_state <= APB_IDLE;
                    end
                end

                default: begin
                    // Should not happen, reset to IDLE
                    apb_current_state <= APB_IDLE;
                end
            endcase
        end
    end

    // --- Dedicated always block for control_status_reg ---
    // All assignments to control_status_reg must happen in THIS block.
    always @(posedge clk_i or negedge resetn_i) begin
        if (!resetn_i) begin
            control_status_reg <= 32'd0; // System reset initializes to 0
        end else begin
            // Default to current value, will be overridden by specific conditions
            control_status_reg <= control_status_reg;

            // Priority:
            // 1. APB write to control_status_reg[0] (enable/disable)
            // 2. Auto-stop if PWM finishes its pulse count

            // Check for APB write to control status register
            if (apb_write_control_status_strobe) begin
                control_status_reg[0] <= apb_control_status_pwdata_bit0; // Update enable bit based on APB write
            end
            // Else, if PWM finishes its pulse count, auto-stop by clearing enable bit (bit 0)
            else if (pwm_pulse_counter == pwm_pulse_count_reg && pwm_pulse_count_reg != 32'd0 && pwm_active_enable) begin
                control_status_reg[0] <= 1'b0; // Auto-clear enable
            end
        end
    end


    // --- PWM Core Logic ---
    reg [4:0] i; // Loop counter for initialization in reset (unused in this version, but kept for consistency)

    always @(posedge clk_i or negedge resetn_i) begin // Corrected: cllk_i -> clk_i (from prior error in image)
        if (!resetn_i) begin
            pwm_period_counter <= 16'd0;
            pwm_pulse_counter <= 16'd0; // System reset initializes
            // duration_completed is now a wire, so it's not reset here.
            pwm_done_int <= 1'b0;
            // pwm_o is now reset ONLY in the PWM Output Logic block.
        end else begin
            pwm_done_int <= 1'b0; // Default pwm_done to low for single-cycle pulse

            // Consolidate all assignments to pwm_pulse_counter here
            if (apb_reset_pulse_counter_flag) begin // APB initiated reset (highest priority after system reset)
                pwm_pulse_counter <= 16'd0;
                // duration_completed is now a wire, it will update based on pwm_pulse_count_reg
            end else if (pwm_active_enable && !duration_completed) begin // Only run PWM core if enabled and duration is not met
                if (pwm_period_counter == FULL_DUTY_COUNT) begin
                    pwm_period_counter <= 16'd0; // Roll over to 0

                    // Only count pulse if the duty cycle allows for a 'high' period
                    if (calculated_duty_high_cycles > 0) begin
                        // If pwm_pulse_count_reg is 0, it means continuous mode, do not increment counter
                        if (pwm_pulse_count_reg != 32'd0) begin
                            if (pwm_pulse_counter == pwm_pulse_count_reg - 1) begin
                                pwm_pulse_counter <= pwm_pulse_count_reg; // Reached target
                                pwm_done_int <= 1'b1;       // Assert done pulse for one cycle
                            end else begin
                                pwm_pulse_counter <= pwm_pulse_counter + 1'b1; // Increment pulse count
                            end
                        end
                    end
                end else begin
                    pwm_period_counter <= pwm_period_counter + 1'b1;
                end
            end else begin
                // If not enabled or duration_completed, hold period counter at 0
                pwm_period_counter <= 16'd0;
            end
            // duration_completed is now a wire, so no assignment needed here.
        end
    end

    // --- PWM Output Logic ---
    // All assignments to pwm_o are in this block.
    always @(posedge clk_i or negedge resetn_i) begin
        if (!resetn_i) begin
            pwm_o <= 1'b0; // PWM output is low during reset
        end else begin
            // pwm_o is high only if:
            // 1. PWM is enabled (via control_status_reg[0])
            // 2. The period counter is within the "ON" portion of the cycle
            // 3. The duty cycle is not effectively 0%
            // 4. The total specified number of pulses has NOT been generated yet
            if (control_status_reg[0] &&
                (pwm_period_counter < calculated_duty_high_cycles) &&
                (calculated_duty_high_cycles > 0) &&
                (!duration_completed)) begin
                pwm_o <= 1'b1;
            end else begin
                pwm_o <= 1'b0;
            end
        end
    end

endmodule
