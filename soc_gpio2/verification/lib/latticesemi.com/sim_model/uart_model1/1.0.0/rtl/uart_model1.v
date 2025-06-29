/*******************************************************************************
    Verilog netlist generated by IPGEN Lattice Propel (64-bit)
    2024.2.2503210206_sp1
    Soft IP Version: 1.0.0
    2025 06 25 14:02:35
*******************************************************************************/
/*******************************************************************************
    Wrapper Module generated per user settings.
*******************************************************************************/
module uart_model1 (clk, rstn, uart_rxd, uart_txd, uart_rx_data_debug,
    uart_rx_valid_debug, uart_rx_break_debug, uart_tx_data_debug,
    uart_tx_en_debug, uart_tx_busy_debug)/* synthesis ORIG_MODULE_NAME="uart_model1" */ /* synthesis LATTICE_IP_GENERATED="1" */;
    input  clk;
    input  rstn;
    input  uart_rxd;
    output  uart_txd;
    output  [7:0]  uart_rx_data_debug;
    output  uart_rx_valid_debug;
    output  uart_rx_break_debug;
    output  [7:0]  uart_tx_data_debug;
    output  uart_tx_en_debug;
    output  uart_tx_busy_debug;
    uart_model #(.CLK_MHZ(18),
        .BIT_RATE(115200),
        .PAYLOAD_BITS(8),
        .STACK_DEPTH(128),
        .STIMULUS_GEN(0),
        .STIMULUS_FILE_NAME(""),
        .DEBUG_PINS_EN(1))
    uart_model_inst(.clk(clk),
        .rstn(rstn),
        .uart_rxd(uart_rxd),
        .uart_txd(uart_txd),
        .uart_rx_data_debug(uart_rx_data_debug[7:0]),
        .uart_rx_valid_debug(uart_rx_valid_debug),
        .uart_rx_break_debug(uart_rx_break_debug),
        .uart_tx_data_debug(uart_tx_data_debug[7:0]),
        .uart_tx_en_debug(uart_tx_en_debug),
        .uart_tx_busy_debug(uart_tx_busy_debug));
endmodule