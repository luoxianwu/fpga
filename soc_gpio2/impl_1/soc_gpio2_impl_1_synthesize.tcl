if {[catch {

# define run engine funtion
source [file join {C:/lscc/radiant/2024.1} scripts tcl flow run_engine.tcl]
# define global variables
global para
set para(gui_mode) "1"
set para(prj_dir) "C:/Users/x-luo/proj/fpga/soc_gpio2"
# synthesize IPs
# synthesize VMs
# propgate constraints
file delete -force -- soc_gpio2_impl_1_cpe.ldc
::radiant::runengine::run_engine_newmsg cpe -syn synpro -f "soc_gpio2_impl_1.cprj" "gpio0.cprj" "system0.cprj" "gpio2.cprj" "cpu0.cprj" "uart0.cprj" "ahbl2apb0.cprj" "pll0.cprj" "osc0.cprj" "ahbl0.cprj" "apb0.cprj" -a "LFD2NX"  -o soc_gpio2_impl_1_cpe.ldc
# synthesize top design
file delete -force -- soc_gpio2_impl_1.vm soc_gpio2_impl_1.ldc
if {[ catch {::radiant::runengine::run_engine synpwrap -prj "soc_gpio2_impl_1_synplify.tcl" -log "soc_gpio2_impl_1.srf"} result options ]} {
    file delete -force -- soc_gpio2_impl_1.vm soc_gpio2_impl_1.ldc
    return -options $options $result
}
::radiant::runengine::run_postsyn [list -a LFD2NX -p LFD2NX-40 -t CABGA256 -sp 8_High-Performance_1.0V -oc Commercial -top -w -o soc_gpio2_impl_1_syn.udb soc_gpio2_impl_1.vm] [list C:/Users/x-luo/proj/fpga/soc_gpio2/impl_1/soc_gpio2_impl_1.ldc]

} out]} {
   ::radiant::runengine::runtime_log $out
   exit 1
}
