`timescale 1ns / 1ps
module rx_wrapper#(
	parameter  NO_OF_WORS_IN_BUFFER =2,
	
	parameter  NO_OF_DATA_BITS =7, 		 //6,7,8
	parameter  PARITY_ENABLED  ="TRUE",  //"FALSE", "TRUE"
	parameter  PARITY_TYPE     ="EVEN",   // "ODD", "EVEN"
	parameter  NO_OF_STOP_BITS	="2",		 //"0" "1" "1.5" "2"
	
	parameter  BAUD 			=2400,
	parameter  CLOCK_IN_MHZ	=100
)
(
		input 	clk,
      input 	reset,
		input    rx_data,	

		
		
		output[NO_OF_WORS_IN_BUFFER*NO_OF_DATA_BITS-1:0] data_parallel_out,
		input  data_parallel_rd_enable,
		output rx_buffer_full,
		output parity_error,
      output stop_bit_error
	 
    );
	 

	 
	 
wire 	 sampling_tick_middle,sampling_tick_end,tick_start;
wire   data_out_to_buffer;
wire   data_valid_to_buffer;


rx_fsm#(
	.NO_OF_DATA_BITS(NO_OF_DATA_BITS),
	.PARITY_ENABLED(PARITY_ENABLED),
	.PARITY_TYPE(PARITY_TYPE),
	.NO_OF_STOP_BITS(NO_OF_STOP_BITS)
) ins_rx_fsm (
    .clk(clk), 
    .reset(reset), 
    .sampling_tick_middle(sampling_tick_middle), 
    .sampling_tick_end(sampling_tick_end), 
    .tick_start(tick_start), 
    .rx_data(rx_data), 
    .data_out_to_buffer(data_out_to_buffer), 
    .data_valid_to_buffer(data_valid_to_buffer), 
    .parity_error(parity_error),
	 .stop_bit_error(stop_bit_error)
    );


sampling_tick_generator#
(	
	.BAUD(BAUD),
	.CLOCK_IN_MHZ(CLOCK_IN_MHZ)
)
 ins_sampling_tick_generator (
    .clk(clk), 
    .reset(reset), 
    .start(tick_start), 
    .tick_16_8(sampling_tick_middle), 
    .tick_16_16(sampling_tick_end)
    );

rx_buffer#
(
	.WORD_SIZE(NO_OF_DATA_BITS),
	.NO_OF_WORDS(NO_OF_WORS_IN_BUFFER)
) ins_rx_buffer (
    .clk(clk), 
    .reset(reset), 
    .data_serial_in(data_out_to_buffer), 
    .data_serial_wr_en(data_valid_to_buffer),
	 .buffer_full(rx_buffer_full),
    .data_parallel_out(data_parallel_out),
	 .data_parallel_rd_enable(data_parallel_rd_enable)
    );


endmodule
