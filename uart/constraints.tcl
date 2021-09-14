#================================================
## constraints.tcl
##================================================

create_clock -name clk_a -period 10 [get_ports clk_a] -waveform {0 5}
create_clock -name clk_b -period 10 [get_ports clk_b] -waveform {0 5}

set design_inputs [get_ports {tx_parallel_data_in* tx_data_wr_enable_in* rx_data_rd_enable_in*}]
set design_outputs [get_ports {tx_busy_out_* rx_full_* rx_parallel_data_out_* rx_parity_error_* rx_stop_bit_error_*}]

set design_inputs_a [get_ports {tx_parallel_data_in_a tx_data_wr_enable_in_a rx_data_rd_enable_in_a}]
set design_outputs_a [get_ports {tx_busy_out_a rx_full_a rx_parallel_data_out_a rx_parity_error_a rx_stop_bit_error_a}]

set design_inputs_b [get_ports {tx_parallel_data_in_b tx_data_wr_enable_in_b rx_data_rd_enable_in_b}]
set design_outputs_b [get_ports {tx_busy_out_b rx_full_a rx_parallel_data_out_b rx_parity_error_b rx_stop_bit_error_b}]

echo "IO Ports Check"

# echo $design_inputs
# echo $design_inputs

set top uart_top
set_clock_uncertainty 0.5 [all_clocks]
set_dont_touch_network [all_clocks]
set_dont_touch_network [get_ports {reset_a reset_b}]

set_input_delay  6 -clock clk_a  $design_inputs_a
set_input_delay  6 -clock clk_b  $design_inputs_b
set_output_delay 6 -clock clk_a $design_outputs_a
set_output_delay 6 -clock clk_b $design_outputs_b

set_load        0.2 $design_outputs
set_max_fanout  20  $design_inputs
set_fanout_load 2   $design_outputs

set_false_path -from [get_clocks clk_a] -to [get_clocks clk_b]
set_false_path -from [get_clocks clk_b] -to [get_clocks clk_a]

