set_db init_lib_search_path [list ../libs/gsclib045/lef ../libs/gsclib045/timing ../libs/gsclib045/qrc/qx]
set_db library fast_vdd1v0_basicCells.lib
set_db lef_library {gsclib045_tech.lef gsclib045_macro.lef gsclib045_multibitsDFF.lef}
set_db qrc_tech_file gpdk045.tch

read_hdl -sv ${DESIGN}.sv
elaborate
synthesize -to_mapped
write -mapped > ${DESIGN}_synth.v
report_timing
report_area
