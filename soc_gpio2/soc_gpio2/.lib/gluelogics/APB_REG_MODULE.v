
module APB_REG_MODULE (
    // APB Slave Interface (Port names updated as requested)
    // APB clock input (formerly 'pclk')
    input wire clk_i, 
    // APB asynchronous active-low reset (formerly 'preset_n')
    input wire resetn_i, 
    // APB enable (active high) - indicates second cycle of transfer (formerly 'penable')
    input wire apb_penable_i, 
    // APB peripheral select (active high) (formerly 'psel')
    input wire apb_psel_i, 
    // APB write (1) / read (0) indicator (formerly 'pwrite')
    input wire apb_pwrite_i, 
    // APB address bus (formerly 'paddr')
    input wire [31:0] apb_paddr_i, 
    // APB write data bus (formerly 'pwdata')
    input wire [31:0] apb_pwdata_i, 
    // APB read data bus (formerly 'prdata')
    output reg [31:0] apb_prdata_o, 
    // APB slave error (active high) (formerly 'pslverr')
    output reg apb_pslverr_o, 
    output reg // APB ready signal (active high) (formerly 'pready')
        apb_pready_o) // File: apb_reg_module.v
// Description: A simple APB (Advanced Peripheral Bus) slave module
//              with 16 32-bit general-purpose registers that can be
//              written to and read from by an APB master (e.g., CPU).
;
    reg [31:0] reg_array [0:15] ; // --- Internal Registers ---
// Declare 16 32-bit registers.
// Array of 16 32-bit registers
// ADDED: Declare 'i' outside the always block, at the module level
    integer i ; // Loop variable for initialization
// --- APB Address Decoding Parameters ---
    localparam NUM_REGISTERS = 16 ; 
    localparam ADDR_BITS = 4 ; // log2(NUM_REGISTERS) = log2(16) = 4 bits
// Extract the register index from the address bus
    wire [(ADDR_BITS - 1):0] reg_index ; 
    assign reg_index = apb_paddr_i[(ADDR_BITS + 1):2] ; // --- APB Slave Logic ---
    always
        @(posedge clk_i or 
            negedge resetn_i)
        begin
            if ((!resetn_i)) 
                begin
                    for (i = 0 ; (i < NUM_REGISTERS) ; i = (i + 1))// Asynchronous reset for APB interface and registers
// Loop variable 'i' is now declared at module level
                        begin
                            reg_array[i] <=  32'd0 ;
                        end
                    apb_prdata_o <=  32'd0 ;
                    apb_pready_o <=  1'b0 ;
                    apb_pslverr_o <=  1'b0 ;
                end
            else
                begin
                    apb_pready_o <=  1'b0 ;// Default assignments for outputs
                    apb_pslverr_o <=  1'b0 ;
                    apb_prdata_o <=  32'd0 ;// Check for valid APB transaction (apb_psel_i and apb_penable_i active)
                    if ((apb_psel_i && apb_penable_i)) 
                        begin
                            apb_pready_o <=  1'b1 ;// Transaction is active, assert apb_pready_o for single-cycle transfer
// Check if the accessed address is within the valid range of our 16 registers
                            if ((reg_index < NUM_REGISTERS)) 
                                begin
                                    if (apb_pwrite_i) 
                                        begin
                                            reg_array[reg_index] <=  apb_pwdata_i ;// APB Write transaction
// Write to the selected register
                                        end
                                    else
                                        begin
                                            apb_prdata_o <=  reg_array[reg_index] ;// APB Read transaction
// Read from the selected register
                                        end
                                end
                            else
                                begin
                                    apb_pslverr_o <=  1'b1 ;// Handle unsupported/out-of-range address with a slave error
                                    apb_prdata_o <=  32'hDEADBEEF ;
                                end
                        end
                end
        end
// File: apb_reg_module.v
// Description: A simple APB (Advanced Peripheral Bus) slave module
//              with 16 32-bit general-purpose registers that can be
//              written to and read from by an APB master (e.g., CPU).
endmodule



