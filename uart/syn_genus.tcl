# 1. Link Technology Library
set_db init_lib_search_path [list ../libs/gsclib045/lef ../libs/gsclib045/timing ../libs/gsclib045/qrc/qx]

set_db library fast_vdd1v0_basicCells.lib
set_db lef_library {gsclib045_tech.lef gsclib045_macro.lef gsclib045_multibitsDFF.lef}
set_db qrc_tech_file gpdk045.tch

# 2. Read HDLs
read_hdl [glob 1_rtl/*.v]

# 3. Elaborate the top module
elaborate uart_top

# 4. Check Design
check_design > log/check_design.log

uniquify uart_top

# 5. Set constraints
source constraints.tcl

# 6. Synthesize 
synthesize -to_mapped -effort h

# 7. Write netlist
write -mapped > 2_syn_out/uart_top.v
write_sdc > 2_syn_out/uart_top.sdc

# 8. Reports
report_area > report/area.log
report_timing  -nworst 10 > report/timing.log
report_constraint > report/constraint.log
report_port * > report/ports_final.log
report_power > report/power.log
