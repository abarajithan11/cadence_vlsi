`timescale 1ns / 1ps
module tx_wrapper#
(
	parameter  NO_OF_WORDS_IN_BUFFER =1,  //>=1
	
	parameter  NO_OF_DATA_BITS =8, 		 //6,7,8
	parameter  PARITY_ENABLED  ="FALSE",  //"FALSE", "TRUE"
	parameter  PARITY_TYPE     ="ODD",   // "ODD", "EVEN"
	parameter  NO_OF_STOP_BITS	="1",		 //"0" "1" "1.5" "2"
	
	parameter  BAUD 			=230400,     //2400 4800 9600 19200 38400  57600 115200  230400
	parameter  CLOCK_IN_MHZ	=100         //1-100MHz
)
(
	input 														clk,    //system clock
   input 														reset,
	input[NO_OF_WORDS_IN_BUFFER*NO_OF_DATA_BITS-1:0] data_parallel_in,
	input 														data_parallel_wr_enable,	
	output 														tx_busy,	
	output 														tx_data
);


wire sampling_tick_middle,sampling_tick_end;
wire tick_start,data_serial_rd_enable,data_serial_out;
wire empty;

tx_buffer#
(
	.WORD_SIZE(NO_OF_DATA_BITS),
	.NO_OF_WORDS(NO_OF_WORDS_IN_BUFFER)
) ins_tx_buffer (
    .clk(clk), 
    .reset(reset), 
    .data_parallel_in(data_parallel_in), 
    .data_parallel_wr_enable(data_parallel_wr_enable), 
    .data_serial_rd_enable(data_serial_rd_enable), 
    .data_serial_out(data_serial_out),
    .empty(empty)
    );
	 
	 

tx_fsm#(
	.NO_OF_DATA_BITS(NO_OF_DATA_BITS),
	.PARITY_ENABLED(PARITY_ENABLED),
	.PARITY_TYPE(PARITY_TYPE),
	.NO_OF_STOP_BITS(NO_OF_STOP_BITS)
) ins_tx_fsm (
    .clk(clk), 
    .reset(reset), 
	 .empty(empty),
    .sampling_tick_middle(sampling_tick_middle), 
    .sampling_tick_end(sampling_tick_end), 
    .tick_start(tick_start), 
    .data_parallel_wr_enable(data_parallel_wr_enable),
	 .tx_busy(tx_busy),	 
    .tx_data(tx_data), 
    .buffer_rd_enable(data_serial_rd_enable), 
    .buffer_data(data_serial_out)	 
    );
	 
sampling_tick_generator#(	
	.BAUD(BAUD),
	.CLOCK_IN_MHZ(CLOCK_IN_MHZ)
) ins_sampling_tick_generator(
    .clk(clk), 
    .reset(reset), 
    .start(tick_start), 
    .tick_16_8(sampling_tick_middle), 
    .tick_16_16(sampling_tick_end)
    );

endmodule
