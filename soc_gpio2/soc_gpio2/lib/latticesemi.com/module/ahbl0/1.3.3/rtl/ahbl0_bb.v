/*******************************************************************************
    Verilog netlist generated by IPGEN Lattice Propel (64-bit)
    2024.2.2503210206_sp1
    Soft IP Version: 1.3.3
    2025 06 25 14:03:26
*******************************************************************************/
/*******************************************************************************
    Wrapper Module generated per user settings.
*******************************************************************************/
module ahbl0 (ahbl_hclk_i, ahbl_hresetn_i, ahbl_m01_hready_mstr_i,
    ahbl_m01_hresp_mstr_i, ahbl_m01_hrdata_mstr_i, ahbl_m01_hsel_mstr_o,
    ahbl_m01_haddr_mstr_o, ahbl_m01_hburst_mstr_o, ahbl_m01_hsize_mstr_o,
    ahbl_m01_hmastlock_mstr_o, ahbl_m01_hprot_mstr_o, ahbl_m01_htrans_mstr_o,
    ahbl_m01_hwdata_mstr_o, ahbl_m01_hwrite_mstr_o, ahbl_m01_hready_mstr_o,
    ahbl_s00_hsel_slv_i, ahbl_s00_haddr_slv_i, ahbl_s00_hburst_slv_i,
    ahbl_s00_hsize_slv_i, ahbl_s00_hmastlock_slv_i, ahbl_s00_hprot_slv_i,
    ahbl_s00_htrans_slv_i, ahbl_s00_hwdata_slv_i, ahbl_s00_hwrite_slv_i,
    ahbl_s00_hready_slv_i, ahbl_s00_hreadyout_slv_o, ahbl_s00_hresp_slv_o,
    ahbl_s00_hrdata_slv_o, ahbl_m00_hready_mstr_i, ahbl_m00_hresp_mstr_i,
    ahbl_m00_hrdata_mstr_i, ahbl_m00_hsel_mstr_o, ahbl_m00_haddr_mstr_o,
    ahbl_m00_hburst_mstr_o, ahbl_m00_hsize_mstr_o, ahbl_m00_hmastlock_mstr_o,
    ahbl_m00_hprot_mstr_o, ahbl_m00_htrans_mstr_o, ahbl_m00_hwdata_mstr_o,
    ahbl_m00_hwrite_mstr_o, ahbl_m00_hready_mstr_o)/* synthesis syn_black_box syn_declare_black_box=1 */;
    input  ahbl_hclk_i;
    input  ahbl_hresetn_i;
    input  [0:0]  ahbl_m01_hready_mstr_i;
    input  [0:0]  ahbl_m01_hresp_mstr_i;
    input  [31:0]  ahbl_m01_hrdata_mstr_i;
    output  [0:0]  ahbl_m01_hsel_mstr_o;
    output  [31:0]  ahbl_m01_haddr_mstr_o;
    output  [2:0]  ahbl_m01_hburst_mstr_o;
    output  [2:0]  ahbl_m01_hsize_mstr_o;
    output  [0:0]  ahbl_m01_hmastlock_mstr_o;
    output  [3:0]  ahbl_m01_hprot_mstr_o;
    output  [1:0]  ahbl_m01_htrans_mstr_o;
    output  [31:0]  ahbl_m01_hwdata_mstr_o;
    output  [0:0]  ahbl_m01_hwrite_mstr_o;
    output  [0:0]  ahbl_m01_hready_mstr_o;
    input  [0:0]  ahbl_s00_hsel_slv_i;
    input  [31:0]  ahbl_s00_haddr_slv_i;
    input  [2:0]  ahbl_s00_hburst_slv_i;
    input  [2:0]  ahbl_s00_hsize_slv_i;
    input  [0:0]  ahbl_s00_hmastlock_slv_i;
    input  [3:0]  ahbl_s00_hprot_slv_i;
    input  [1:0]  ahbl_s00_htrans_slv_i;
    input  [31:0]  ahbl_s00_hwdata_slv_i;
    input  [0:0]  ahbl_s00_hwrite_slv_i;
    input  [0:0]  ahbl_s00_hready_slv_i;
    output  [0:0]  ahbl_s00_hreadyout_slv_o;
    output  [0:0]  ahbl_s00_hresp_slv_o;
    output  [31:0]  ahbl_s00_hrdata_slv_o;
    input  [0:0]  ahbl_m00_hready_mstr_i;
    input  [0:0]  ahbl_m00_hresp_mstr_i;
    input  [31:0]  ahbl_m00_hrdata_mstr_i;
    output  [0:0]  ahbl_m00_hsel_mstr_o;
    output  [31:0]  ahbl_m00_haddr_mstr_o;
    output  [2:0]  ahbl_m00_hburst_mstr_o;
    output  [2:0]  ahbl_m00_hsize_mstr_o;
    output  [0:0]  ahbl_m00_hmastlock_mstr_o;
    output  [3:0]  ahbl_m00_hprot_mstr_o;
    output  [1:0]  ahbl_m00_htrans_mstr_o;
    output  [31:0]  ahbl_m00_hwdata_mstr_o;
    output  [0:0]  ahbl_m00_hwrite_mstr_o;
    output  [0:0]  ahbl_m00_hready_mstr_o;
endmodule