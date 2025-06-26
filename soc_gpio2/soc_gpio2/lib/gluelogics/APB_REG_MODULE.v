// File: apb_reg_module.v
// Description: A simple APB (Advanced Peripheral Bus) slave module
//              with 16 (32-bit) general-purpose registers that can be
//              written to and read from by an APB master (e.g., CPU).
//              Modified to accept a 6-bit paddr input (paddr[5:0]) and
//              fixed the reset block syntax.

module APB_REG_MODULE (
    // APB Slave Interface (Port names updated as requested for clarity)
    input wire clk_i,         // APB clock input (formerly 'pclk')
    input wire resetn_i,      // APB asynchronous active-low reset (formerly 'presetn')
    input wire psel_i,        // APB peripheral select (active high)
    input wire penable_i,     // APB enable (active high, indicates active transfer)
    input wire pwrite_i,      // APB write (1) / read (0) indicator
    input wire [5:0] paddr_i,   // APB address bus (now 6 bits wide, paddr[5:0])
    input wire [31:0] pwdata_i,  // APB write data bus
    output reg [31:0] prdata_o,  // APB read data bus
    output reg pready_o,      // APB ready signal (active high)
    output reg pslverr_o      // APB slave error (active high)
);

    // --- Internal Registers ---
    // Declare 16 x 32-bit registers
    reg [31:0] reg_array [0:15]; // Array of 16 32-bit registers

    // Declare loop counter variable here for Verilog-2001 compatibility
    reg [4:0] i; // 'i' needs to be a reg or integer, and wide enough for NUM_REGISTERS (0 to 15 needs 4 bits, [4:0] gives us plenty margin)


    // --- APB Address Decoding Parameters ---
    localparam NUM_REGISTERS = 16;
    localparam ADDR_BITS = 4; // log2(NUM_REGISTERS) = 4 bits needed to index 16 registers

    // Extract the register index from the address bus
    // We assume 32-bit word-aligned accesses, so paddr[1:0] are always 0.
    // The relevant bits for indexing 16 registers are paddr[5:2].
    wire [ADDR_BITS-1:0] reg_index; // This will be [3:0]
    assign reg_index = paddr_i[ADDR_BITS+1:2]; // Equivalent to paddr_i[5:2] since ADDR_BITS=4


    // --- APB Slave Logic ---
    always @(posedge clk_i or negedge resetn_i) begin
        if (!resetn_i) begin
            // Asynchronous reset for APB interface and registers
            // All statements within this 'if' block must be enclosed in 'begin...end'
            begin
                // Loop for initialization of register array
                for (i = 0; i < NUM_REGISTERS; i = i + 1) begin // 'i' is now declared outside
                    reg_array[i] <= 32'd0;
                end
                prdata_o <= 32'd0;
                pready_o <= 1'b0;
                pslverr_o <= 1'b0;
            end
        end else begin
            // Default assignments for outputs (these will be overwritten if a valid transaction occurs)
            pready_o <= 1'b0;
            pslverr_o <= 1'b0;
            prdata_o <= 32'd0;

            // Check for valid APB transaction (psel_i and penable_i active)
            if (psel_i == 1'b1 && penable_i == 1'b1) begin
                // Transaction is active, assert pready_o for single-cycle transfer
                pready_o <= 1'b1;

                // Check if the accessed address (via reg_index) is within the valid range of our 16 registers
                if (reg_index < NUM_REGISTERS) begin
                    if (pwrite_i == 1'b1) begin // Write to the selected register
                        reg_array[reg_index] <= pwdata_i; // Update register value
                    end else begin // Read from the selected register
                        prdata_o <= reg_array[reg_index]; // Return register value
                    end
                end else begin
                    // Handle unsupported/out-of-range address with a slave error
                    pslverr_o <= 1'b1;
                    prdata_o <= 32'hDEADBEEF; // Indicate invalid read data
                end
            end
        end
    end

endmodule
