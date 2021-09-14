`timescale 1ns / 1ps

module uart_transceiver#
(

  parameter  CLOCK_IN_MHZ  =100,
  parameter  TX_WORD_LENGTH =8,   // # of UART-tramsmit data bits ; 6,7,8
  parameter  TX_NO_OF_WORDS =1,	  // Transmitter buffer size in words.
				  // Actual buffer size= 'TX_WORD_LENGTH'*'TX_WORD_LENGTH' ; 1,2.....
  parameter  RX_WORD_LENGTH =8,	  // # of UART-receive data bits ; 6,7,8
  parameter  RX_NO_OF_WORDS =1	  // Receiver buffer size in words.
				  // Actual buffer size= 'RX_WORD_LENGTH'*'RX_NO_OF_WORDS'  ; 1,2.....
	
)
(
    input clk,
    input reset,
	 input uart_hw_rx_pin,
	 output uart_hw_tx_pin,
	 
	 input [TX_WORD_LENGTH*TX_NO_OF_WORDS-1:0] tx_parallel_data_in,
	 input  tx_data_wr_enable_in,
	 output tx_busy_out,
	 
	 output rx_full,
	 output [RX_WORD_LENGTH*RX_NO_OF_WORDS-1:0] rx_parallel_data_out,
	 input  rx_data_rd_enable_in,
	 output rx_parity_error,
    output rx_stop_bit_error
	 
);


rx_wrapper#(
	.NO_OF_WORS_IN_BUFFER(RX_NO_OF_WORDS),
	.NO_OF_DATA_BITS(RX_WORD_LENGTH),
	.PARITY_ENABLED("TRUE"),
	.PARITY_TYPE("ODD"),
	.NO_OF_STOP_BITS(1),
	.BAUD(115200),
	.CLOCK_IN_MHZ(CLOCK_IN_MHZ)
) ins_rx_wrapper (
    .clk(clk), 
    .reset(reset), 
    .rx_data(uart_hw_rx_pin), 
    .data_parallel_out(rx_parallel_data_out), 
    .data_parallel_rd_enable(rx_data_rd_enable_in), 
    .rx_buffer_full(rx_full), 
    .parity_error(rx_parity_error), 
    .stop_bit_error(rx_stop_bit_error)
    );

tx_wrapper#(
	.NO_OF_WORDS_IN_BUFFER(TX_NO_OF_WORDS),
	.NO_OF_DATA_BITS(TX_WORD_LENGTH),
	.PARITY_ENABLED("TRUE"),
	.PARITY_TYPE("ODD"),
	.NO_OF_STOP_BITS(1),
	.BAUD(115200),
	.CLOCK_IN_MHZ(CLOCK_IN_MHZ)
) ins_tx_wrapper (
    .clk(clk), 
    .reset(reset), 
    .data_parallel_in(tx_parallel_data_in), 
    .data_parallel_wr_enable(tx_data_wr_enable_in), 
    .tx_busy(tx_busy_out), 
    .tx_data(uart_hw_tx_pin)
    );


endmodule
