module uart_top #(
	parameter  CLOCK_IN_MHZ  =100,
	parameter  TX_WORD_LENGTH =8,   // # of UART-tramsmit data bits ; 6,7,8
	parameter  TX_NO_OF_WORDS =1,   // Transmitter buffer size in words.
					// Actual buffer size= 'TX_WORD_LENGTH'*'TX_WORD_LENGTH' ; 1,2...
	parameter  RX_WORD_LENGTH =8,   // # of UART-receive data bits ; 6,7,8
	parameter  RX_NO_OF_WORDS =1    // Receiver buffer size in words.
					// Actual buffer size= 'RX_WORD_LENGTH'*'RX_NO_OF_WORDS'  ; 1,2.....
)
(
		
	// Interface of 'A'
	input clk_a,
    	input reset_a,
	 	
 	input [TX_WORD_LENGTH*TX_NO_OF_WORDS-1:0] tx_parallel_data_in_a,
 	input  tx_data_wr_enable_in_a,
 	output tx_busy_out_a,
	 	
 	output rx_full_a,
 	output [RX_WORD_LENGTH*RX_NO_OF_WORDS-1:0] rx_parallel_data_out_a,
 	input  rx_data_rd_enable_in_a,
 	output rx_parity_error_a,
    	output rx_stop_bit_error_a,


    	// Interface of 'B'
    	input clk_b,
    	input reset_b,
	
 	input [TX_WORD_LENGTH*TX_NO_OF_WORDS-1:0] tx_parallel_data_in_b,
 	input  tx_data_wr_enable_in_b,
 	output tx_busy_out_b,
	
 	output rx_full_b,
 	output [RX_WORD_LENGTH*RX_NO_OF_WORDS-1:0] rx_parallel_data_out_b,
 	input  rx_data_rd_enable_in_b,
 	output rx_parity_error_b,
    	output rx_stop_bit_error_b
);

	wire w_a_tx_b_rx;
	wire w_b_tx_a_rx;

	uart_transceiver#(		
		.CLOCK_IN_MHZ(CLOCK_IN_MHZ),
		.TX_WORD_LENGTH(TX_WORD_LENGTH),
		.TX_NO_OF_WORDS(TX_NO_OF_WORDS),
		.RX_WORD_LENGTH(RX_WORD_LENGTH),
		.RX_NO_OF_WORDS(RX_NO_OF_WORDS)
	) ins_uart_transceiver_A
	(
	    .clk(clk_a),
	    .reset(reset_a),

		 .uart_hw_rx_pin(w_b_tx_a_rx),
		 .uart_hw_tx_pin(w_a_tx_b_rx),
		 
		 .tx_parallel_data_in(tx_parallel_data_in_a),
		 .tx_data_wr_enable_in(tx_data_wr_enable_in_a),
		 .tx_busy_out(tx_busy_out_a),
		 
		 .rx_full(rx_full_a),
		 .rx_parallel_data_out(rx_parallel_data_out_a),
		 .rx_data_rd_enable_in(rx_data_rd_enable_in_a),
		 .rx_parity_error(rx_parity_error_a),
	    .rx_stop_bit_error(rx_stop_bit_error_a)		 
	);


	uart_transceiver#(	
		.CLOCK_IN_MHZ(CLOCK_IN_MHZ),	
		.TX_WORD_LENGTH(TX_WORD_LENGTH),
		.TX_NO_OF_WORDS(TX_NO_OF_WORDS),
		.RX_WORD_LENGTH(RX_WORD_LENGTH),
		.RX_NO_OF_WORDS(RX_NO_OF_WORDS)
	) ins_uart_transceiver_B
	(
	    .clk(clk_b),
	    .reset(reset_b),

		 .uart_hw_rx_pin(w_a_tx_b_rx),
		 .uart_hw_tx_pin(w_b_tx_a_rx),
		 
		 .tx_parallel_data_in(tx_parallel_data_in_b),
		 .tx_data_wr_enable_in(tx_data_wr_enable_in_b),
		 .tx_busy_out(tx_busy_out_b),
		 
		 .rx_full(rx_full_b),
		 .rx_parallel_data_out(rx_parallel_data_out_b),
		 .rx_data_rd_enable_in(rx_data_rd_enable_in_b),
		 .rx_parity_error(rx_parity_error_b),
	    .rx_stop_bit_error(rx_stop_bit_error_b)		 
	);


endmodule
