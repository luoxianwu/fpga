`timescale 1 ps / 1 ps 

`define family_device_lfd2nx

module soc_gpio2_Top (

	input  rstn_i,

	input  rxd_i,

	output txd_o,

	inout [7:0] led_o,
	
	inout [31:0] top_gpio2_o,
	
	output top_pwm_o

);

wire sys_clk /*synthesis syn_keep = 1*/; 
`ifdef family_device_machxo2
OSCH #(.NOM_FREQ("17.73")) OSCJ (.STDBY(1'b0), .OSC(sys_clk), .SEDSTDBY());
`elsif family_device_machxo3l
OSCH #(.NOM_FREQ("17.73")) OSCJ (.STDBY(1'b0), .OSC(sys_clk), .SEDSTDBY());
`elsif family_device_machxo3lf
OSCH #(.NOM_FREQ("17.73")) OSCJ (.STDBY(1'b0), .OSC(sys_clk), .SEDSTDBY());
`elsif family_device_ecp5u
OSCG #(.DIV(17))OSCG (.OSC(sys_clk));
`elsif family_device_ecp5um
OSCG #(.DIV(17))OSCG (.OSC(sys_clk));
`elsif family_device_ecp5um5g
OSCG #(.DIV(17))OSCG (.OSC(sys_clk));
`elsif family_device_machxo3d
wire esb_oscclk; 
OSCJ #(.NOM_FREQ("17.73")) OSCJ (.STDBY(1'b0), .OSC(sys_clk), .SEDSTDBY(),.OSCESB(esb_oscclk));
`elsif family_device_latticeecp3
wire osc_clk;
GSR GSR_INST(.GSR(rstn_i));
OSCF #(.NOM_FREQ("15.0")) OSCF (.OSC(osc_clk));
wire CLKOP_t;
wire scuba_vlo;

VLO scuba_vlo_inst (.Z(scuba_vlo));

defparam PLLInst_0.FEEDBK_PATH = "CLKOP" ;
defparam PLLInst_0.CLKOK_BYPASS = "DISABLED" ;
defparam PLLInst_0.CLKOS_BYPASS = "DISABLED" ;
defparam PLLInst_0.CLKOP_BYPASS = "DISABLED" ;
defparam PLLInst_0.CLKOK_INPUT = "CLKOP" ;
defparam PLLInst_0.DELAY_PWD = "DISABLED" ;
defparam PLLInst_0.DELAY_VAL = 0 ;
defparam PLLInst_0.CLKOS_TRIM_DELAY = 0 ;
defparam PLLInst_0.CLKOS_TRIM_POL = "RISING" ;
defparam PLLInst_0.CLKOP_TRIM_DELAY = 0 ;
defparam PLLInst_0.CLKOP_TRIM_POL = "RISING" ;
defparam PLLInst_0.PHASE_DELAY_CNTL = "STATIC" ;
defparam PLLInst_0.DUTY = 8 ;
defparam PLLInst_0.PHASEADJ = "0.0" ;
defparam PLLInst_0.CLKOK_DIV = 2 ;
defparam PLLInst_0.CLKOP_DIV = 32 ;
defparam PLLInst_0.CLKFB_DIV = 6 ;
defparam PLLInst_0.CLKI_DIV = 5 ;
defparam PLLInst_0.FIN = "15.000000" ;
EHXPLLF PLLInst_0 (.CLKI(osc_clk), .CLKFB(CLKOP_t), .RST(scuba_vlo), .RSTK(scuba_vlo), 
    .WRDEL(scuba_vlo), .DRPAI3(scuba_vlo), .DRPAI2(scuba_vlo), .DRPAI1(scuba_vlo), 
    .DRPAI0(scuba_vlo), .DFPAI3(scuba_vlo), .DFPAI2(scuba_vlo), .DFPAI1(scuba_vlo), 
    .DFPAI0(scuba_vlo), .FDA3(scuba_vlo), .FDA2(scuba_vlo), .FDA1(scuba_vlo), 
    .FDA0(scuba_vlo), .CLKOP(CLKOP_t), .CLKOS(), .CLKOK(), .CLKOK2(), 
    .LOCK(LOCK), .CLKINTFB())
         /* synthesis FREQUENCY_PIN_CLKOP="18.000000" */
         /* synthesis FREQUENCY_PIN_CLKI="15.000000" */;

assign sys_clk = CLKOP_t;
`endif

soc_gpio2 soc_gpio2_inst (
`ifdef family_device_machxo2
	.clk_i(sys_clk),
`elsif family_device_machxo3l
	.clk_i(sys_clk),
`elsif family_device_machxo3lf
	.clk_i(sys_clk),
`elsif family_device_ecp5u
	.clk_i(sys_clk),
`elsif family_device_ecp5um
	.clk_i(sys_clk),
`elsif family_device_ecp5um5g
	.clk_i(sys_clk),
`elsif family_device_machxo3d
	.clk_i(sys_clk),
`elsif family_device_latticeecp3
	.clk_i(sys_clk),
`endif

	.rstn_i(rstn_i),

	.uart_rxd_00_i(rxd_i),

	.uart_txd_00_o(txd_o),

	.gpio_00_io(led_o),
	
	.gpio2_o(top_gpio2_o),
	
	.soc_gpio2_pwm_o(top_pwm_o)

);

endmodule
