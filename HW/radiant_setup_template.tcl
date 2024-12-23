set current_path "C:/Users/x-luo/proj/hw4/HW"

cd $current_path

set radiant_project "C:/Users/x-luo/proj/hw4/HW/HW.rdf"

set DEVICE "LFD2NX-40-8BG256C"

set DESIGN "HW"

array set VFILE_LIST ""
set VFILE_LIST(1) "C:/Users/x-luo/proj/hw4/HW/HW/lib/latticesemi.com/ip/uart0/1.3.0/uart0.ipx"
set VFILE_LIST(2) "C:/Users/x-luo/proj/hw4/HW/HW/lib/latticesemi.com/module/pll0/1.7.0/pll0.ipx"
set VFILE_LIST(3) "C:/Users/x-luo/proj/hw4/HW/HW/lib/latticesemi.com/module/osc0/1.4.0/osc0.ipx"
set VFILE_LIST(4) "C:/Users/x-luo/proj/hw4/HW/HW/lib/latticesemi.com/module/apb0/1.2.1/apb0.ipx"
set VFILE_LIST(5) "C:/Users/x-luo/proj/hw4/HW/HW/lib/latticesemi.com/ip/sysmem0/2.0.0/sysmem0.ipx"
set VFILE_LIST(6) "C:/Users/x-luo/proj/hw4/HW/HW/lib/latticesemi.com/module/ahbl2apb0/1.1.0/ahbl2apb0.ipx"
set VFILE_LIST(7) "C:/Users/x-luo/proj/hw4/HW/HW/lib/latticesemi.com/ip/gpio0/1.6.1/gpio0.ipx"
set VFILE_LIST(8) "C:/Users/x-luo/proj/hw4/HW/HW/HW.v"
set VFILE_LIST(9) "C:/Users/x-luo/proj/hw4/HW/HW/lib/latticesemi.com/ip/SPI/2.1.0/SPI.ipx"
set VFILE_LIST(10) "C:/Users/x-luo/proj/hw4/HW/HW/lib/latticesemi.com/ip/cpu0/2.6.0/cpu0.ipx"
set VFILE_LIST(11) "C:/Users/x-luo/proj/hw4/HW/HW/lib/latticesemi.com/module/ahbl0/1.3.0/ahbl0.ipx"

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

prj_add_source "C:/Users/x-luo/proj/hw4/HW/HW.pdc"

prj_save

