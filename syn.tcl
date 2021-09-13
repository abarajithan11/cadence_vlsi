set_db init_lib_search_path [list ./libs]
set_db library saed32hvt_ss0p7v125c.lib
read_hdl -sv add.sv
elaborate
synthesize -to_mapped
write -mapped > add_synth.v
