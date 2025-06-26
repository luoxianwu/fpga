set current_path "C:/Users/x-luo/proj/fpga/soc_gpio2"

cd $current_path

set radiant_project "C:/Users/x-luo/proj/fpga/soc_gpio2/soc_gpio2.rdf"

set DEVICE "LFD2NX-40-8BG256C"

set DESIGN "soc_gpio2"

array set VFILE_LIST ""
set VFILE_LIST(1) "C:/Users/x-luo/proj/fpga/soc_gpio2/soc_gpio2/lib/latticesemi.com/module/pll0/1.9.0/pll0.ipx"
set VFILE_LIST(2) "C:/Users/x-luo/proj/fpga/soc_gpio2/soc_gpio2/soc_gpio2_Top.v"
set VFILE_LIST(3) "C:/Users/x-luo/proj/fpga/soc_gpio2/soc_gpio2/lib/latticesemi.com/ip/gpio2/1.7.0/gpio2.ipx"
set VFILE_LIST(4) "C:/Users/x-luo/proj/fpga/soc_gpio2/soc_gpio2/lib/latticesemi.com/module/apb0/1.2.1/apb0.ipx"
set VFILE_LIST(5) "C:/Users/x-luo/proj/fpga/soc_gpio2/soc_gpio2/lib/latticesemi.com/module/ahbl2apb0/1.1.2/ahbl2apb0.ipx"
set VFILE_LIST(6) "C:/Users/x-luo/proj/fpga/soc_gpio2/soc_gpio2/lib/latticesemi.com/module/ahbl0/1.3.3/ahbl0.ipx"
set VFILE_LIST(7) "C:/Users/x-luo/proj/fpga/soc_gpio2/soc_gpio2/lib/latticesemi.com/ip/gpio0/1.7.0/gpio0.ipx"
set VFILE_LIST(8) "C:/Users/x-luo/proj/fpga/soc_gpio2/soc_gpio2/lib/latticesemi.com/ip/uart0/1.4.0/uart0.ipx"
set VFILE_LIST(9) "C:/Users/x-luo/proj/fpga/soc_gpio2/soc_gpio2/lib/latticesemi.com/ip/cpu0/2.7.0/cpu0.ipx"
set VFILE_LIST(10) "C:/Users/x-luo/proj/fpga/soc_gpio2/soc_gpio2/lib/gluelogics/APB_REG_MODULE.v"
set VFILE_LIST(11) "C:/Users/x-luo/proj/fpga/soc_gpio2/soc_gpio2/soc_gpio2.v"
set VFILE_LIST(12) "C:/Users/x-luo/proj/fpga/soc_gpio2/soc_gpio2/lib/latticesemi.com/module/osc0/1.4.0/osc0.ipx"
set VFILE_LIST(13) "C:/Users/x-luo/proj/fpga/soc_gpio2/soc_gpio2/lib/latticesemi.com/ip/system0/2.3.1/system0.ipx"

set index [array names VFILE_LIST]
if { [file exists $radiant_project] == 1} {
    prj_open $radiant_project
    prj_set_device -part $DEVICE -performance 8_High-Performance_1.0V
} else {
    prj_create -name "soc_gpio2" -impl "impl_1" -dev $DEVICE -performance 8_High-Performance_1.0V -synthesis "synplify"
    prj_save
}


foreach i $index {
    if { [catch {prj_add_source $VFILE_LIST($i)} fid] } {
        puts "file already exists in project."
    }
}

prj_save

