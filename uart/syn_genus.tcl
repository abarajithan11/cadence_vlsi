# 1. Link Technology Library
set_db init_lib_search_path [list ../libs]
set_db library saed32hvt_ss0p7v125c.lib

# 2. Read HDLs
read_hdl [glob 1_rtl/*.v]

# 3. Elaborate the top module
elaborate uart_top

# 4. Check Design
check_design > log/3.check_design.log

uniquify uart_top

# 5. Set constraints
source constraints.tcl

# 6. Synthesize 
synthesize -to_mapped -effort h

# 7. Write netlist
write -mapped > 2_syn_out/$top.v
write_sdc > 2_syn_out/$top.sdc

# 8. Reports
report_area > report/area.log
report_timing  -nworst 10 > report/timing.log
report_constraint > report/constraint.log
report_port * > report/ports_final.log
