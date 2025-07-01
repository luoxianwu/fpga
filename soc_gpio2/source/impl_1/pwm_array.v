module PWM_ARRAY #(
    parameter NUM_PWM_INST = 32, // Number of PWM instances
    parameter ADDR_WIDTH = 15,   // APB address width (matches PADDR[14:0])
    parameter INST_ADDR_BITS = 5 // Bits to select PWM instance (log2(32))
) (
    input wire clk_i,                    // 18 MHz APB clock input
    input wire resetn_i,                 // Active-low reset
    input wire psel_i,                   // APB peripheral select
    input wire penable_i,                // APB enable
    input wire pwrite_i,                 // APB write/read indicator
    input wire [ADDR_WIDTH-1:0] paddr_i, // APB address bus
    input wire [31:0] pwdata_i,          // APB write data bus
    output reg [31:0] prdata_o,          // APB read data bus
    output reg pready_o,                 // APB ready signal
    output reg pslverr_o,                // APB slave error
    output wire [NUM_PWM_INST-1:0] pwm_out // PWM output signals
);

    // Local parameters for APB address decoding
    localparam REG_ADDR_BITS = 3; // 3 bits for 8 registers per PWM instance
    localparam NUM_LOGICAL_REGS = 8;

    // Clock divider signals
    reg [2:0] clk_div_counter; // 3-bit counter for divide-by-6
    reg pwm_clk;               // 3 MHz PWM clock output

    // Clock divider: Divide 18 MHz clk_i by 6 to get 3 MHz pwm_clk
    always @(posedge clk_i or negedge resetn_i) begin
        if (!resetn_i) begin
            clk_div_counter <= 3'b000;
            pwm_clk <= 1'b0;
        end else begin
            if (clk_div_counter == 3'd5) begin
                clk_div_counter <= 3'b000;
                pwm_clk <= ~pwm_clk; // Toggle every 6 cycles (3 MHz)
            end else begin
                clk_div_counter <= clk_div_counter + 1;
            end
        end
    end

    // Internal signals for each PWM instance
    wire [31:0] prdata_o_inst [NUM_PWM_INST-1:0];
    wire pready_o_inst [NUM_PWM_INST-1:0];
    wire pslverr_o_inst [NUM_PWM_INST-1:0];
    wire [INST_ADDR_BITS-1:0] inst_select;
    wire [REG_ADDR_BITS-1:0] reg_address;

    // Address decoding
    assign inst_select = paddr_i[9:5]; // paddr_i[9:5] for instance (5 bits)
    assign reg_address = paddr_i[4:2]; // paddr_i[4:2] for register (3 bits)

    // Generate PWM instances
    genvar i;
    generate
        for (i = 0; i < NUM_PWM_INST; i = i + 1) begin : pwm_instances
            // Per-instance select signal
            wire inst_psel;
            assign inst_psel = psel_i && (inst_select == i);

            APB_PWM_CONTROLLER pwm_inst (
                .clk_i(clk_i),                    // 18 MHz for APB interface
                .pwm_clk_i(pwm_clk),              // 3 MHz for PWM counter
                .resetn_i(resetn_i),
                .psel_i(inst_psel),
                .penable_i(penable_i),
                .pwrite_i(pwrite_i),
                .paddr_i(paddr_i[5:0]),           // Lower 6 bits for register access
                .pwdata_i(pwdata_i),
                .prdata_o(prdata_o_inst[i]),
                .pready_o(pready_o_inst[i]),
                .pslverr_o(pslverr_o_inst[i]),
                .pwm_o(pwm_out[i])
            );
        end
    endgenerate

    // APB output multiplexing
    always @(*) begin
        if (psel_i && (inst_select < NUM_PWM_INST)) begin
            prdata_o = prdata_o_inst[inst_select];
            pready_o = pready_o_inst[inst_select];
            pslverr_o = pslverr_o_inst[inst_select];
        end else begin
            prdata_o = 32'd0;
            pready_o = 1'b0;
            pslverr_o = 1'b1; // Error if invalid instance selected
        end
    end

endmodule