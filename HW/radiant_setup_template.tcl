set current_path "C:/lattice-fpga/HW"

cd $current_path

set radiant_project "C:/lattice-fpga/HW/HW.rdf"

set DEVICE "LFD2NX-40-8BG256C"

set DESIGN "HW"

array set VFILE_LIST ""
set VFILE_LIST(1) "C:/lattice-fpga/HW/HW/lib/latticesemi.com/ip/uart0/1.3.0/uart0.ipx"
set VFILE_LIST(2) "C:/lattice-fpga/HW/HW/lib/latticesemi.com/module/osc0/1.4.0/osc0.ipx"
set VFILE_LIST(3) "C:/lattice-fpga/HW/HW/lib/latticesemi.com/module/pll0/1.7.0/pll0.ipx"
set VFILE_LIST(4) "C:/lattice-fpga/HW/HW/lib/latticesemi.com/ip/sysmem0/2.0.0/sysmem0.ipx"
set VFILE_LIST(5) "C:/lattice-fpga/HW/HW/lib/latticesemi.com/module/ahbl0/1.3.0/ahbl0.ipx"
set VFILE_LIST(6) "C:/lattice-fpga/HW/HW/HW.v"
set VFILE_LIST(7) "C:/lattice-fpga/HW/HW/lib/latticesemi.com/module/ahbl2apb0/1.1.0/ahbl2apb0.ipx"
set VFILE_LIST(8) "C:/lattice-fpga/HW/HW/lib/latticesemi.com/ip/gpio0/1.6.1/gpio0.ipx"
set VFILE_LIST(9) "C:/lattice-fpga/HW/HW/lib/latticesemi.com/module/apb0/1.2.0/apb0.ipx"
set VFILE_LIST(10) "C:/lattice-fpga/HW/HW/lib/latticesemi.com/ip/cpu0/2.4.0/cpu0.ipx"

set index [array names VFILE_LIST]
if { [file exists $radiant_project] == 1} {
    prj_open $radiant_project
    prj_set_device -part $DEVICE -performance 8_High-Performance_1.0V
} else {
    prj_create -name "HW" -impl "impl_1" -dev $DEVICE -performance 8_High-Performance_1.0V -synthesis "synplify"
    prj_save
}


foreach i $index {
    if { [catch {prj_add_source $VFILE_LIST($i)} fid] } {
        puts "file already exists in project."
    }
}

prj_add_source "C:/lattice-fpga/HW/HW.pdc"

prj_set_impl_opt top {HW}
prj_set_impl_opt -impl "impl_1" "include path" "."
prj_set_impl_opt -impl "impl_1" "top" "HW"
prj_set_strategy_value -strategy Strategy1 par_place_iterator=10
prj_set_strategy_value -strategy Strategy1 par_stop_zero=True
prj_set_strategy_value -strategy Strategy1 {par_cmdline_args=-exp nbrForceHoldTimeCorrection=1 }
prj_save

