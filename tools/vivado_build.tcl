# vivado_build.tcl - build the Enigma bitstream for the Arty S7-50 from the command line.
#
#   vivado -mode batch -source tools/vivado_build.tcl            (run from the repository root)
#   vivado -mode batch -source tools/vivado_build.tcl -tclargs program   (also program the board)
#
# Output: build/vivado/ (project), build/enigma_top.bit, build/timing.rpt, build/utilization.rpt.
# Run `python tools/gen_tables.py` first if config.yaml changed. NOT yet run on real Vivado by the
# author of this script (no Vivado on the dev machine); check build/timing.rpt for WNS >= 0 and
# review any CRITICAL WARNING before programming. See docs/BRINGUP.md.

set root      [file normalize .]
set build_dir [file join $root build]
set proj_dir  [file join $build_dir vivado]
file mkdir $build_dir

create_project -force enigma $proj_dir -part xc7s50csga324-1

# RTL: the .v files plus the generated/hand-written .vh headers (found through include_dirs)
add_files -norecurse [glob [file join $root rtl *.v]]
add_files -norecurse [glob [file join $root rtl *.vh]]
set_property file_type {Verilog Header} [get_files *.vh]
set_property include_dirs [file join $root rtl] [current_fileset]
set_property top enigma_top [current_fileset]

# Constraints
add_files -fileset constrs_1 -norecurse [file join $root constraints arty_s7_enigma.xdc]

# Synthesis and implementation
launch_runs synth_1 -jobs 4
wait_on_run synth_1
if {[get_property PROGRESS [get_runs synth_1]] != "100%"} { error "synthesis failed" }

launch_runs impl_1 -to_step write_bitstream -jobs 4
wait_on_run impl_1
if {[get_property PROGRESS [get_runs impl_1]] != "100%"} { error "implementation failed" }

open_run impl_1
report_timing_summary -delay_type min_max -max_paths 10 -file [file join $build_dir timing.rpt]
report_utilization -file [file join $build_dir utilization.rpt]
report_drc -file [file join $build_dir drc.rpt]
file copy -force [file join $proj_dir enigma.runs impl_1 enigma_top.bit] [file join $build_dir enigma_top.bit]
puts "Bitstream: [file join $build_dir enigma_top.bit]"

# Optional: program the board
if {[lsearch $argv program] >= 0} {
    open_hw_manager
    connect_hw_server
    open_hw_target
    set dev [lindex [get_hw_devices xc7s50*] 0]
    current_hw_device $dev
    set_property PROGRAM.FILE [file join $build_dir enigma_top.bit] $dev
    program_hw_devices $dev
    puts "Programmed $dev"
}
