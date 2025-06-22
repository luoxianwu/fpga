if {[catch {

# define run engine funtion
source [file join {C:/lscc/radiant/2024.1} scripts tcl flow run_engine.tcl]
# define global variables
global para
set para(gui_mode) "1"
set para(prj_dir) "C:/fpga/my_soc"
# synthesize IPs
# synthesize VMs
# propgate constraints
file delete -force -- my_soc_impl_1_cpe.ldc
::radiant::runengine::run_engine_newmsg cpe -syn synpro -f "my_soc_impl_1.cprj" "pll0.cprj" "ahbl0.cprj" "cpu0.cprj" "sysmem0.cprj" "ahbl2apb0.cprj" "gpio0.cprj" "uart0.cprj" "osc0.cprj" "apb0.cprj" -a "LFD2NX"  -o my_soc_impl_1_cpe.ldc
# synthesize top design
file delete -force -- my_soc_impl_1.vm my_soc_impl_1.ldc
if {[ catch {::radiant::runengine::run_engine synpwrap -prj "my_soc_impl_1_synplify.tcl" -log "my_soc_impl_1.srf"} result options ]} {
    file delete -force -- my_soc_impl_1.vm my_soc_impl_1.ldc
    return -options $options $result
}
::radiant::runengine::run_postsyn [list -a LFD2NX -p LFD2NX-40 -t CABGA256 -sp 8_High-Performance_1.0V -oc Commercial -top -w -o my_soc_impl_1_syn.udb my_soc_impl_1.vm] [list C:/fpga/my_soc/impl_1/my_soc_impl_1.ldc]

} out]} {
   ::radiant::runengine::runtime_log $out
   exit 1
}
