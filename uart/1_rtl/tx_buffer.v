`timescale 1ns / 1ps
module tx_buffer#(
	parameter WORD_SIZE	=8,     //shoud be same as the # of data bits in UART
	parameter NO_OF_WORDS=1		  //buffer  multiple word transactions
)
(
    input clk,
    input reset,
    input[WORD_SIZE*NO_OF_WORDS-1:0] data_parallel_in,
	 input data_parallel_wr_enable,
	 input data_serial_rd_enable,
    output reg data_serial_out,
	 output empty
    );
	 
localparam WIDTH=WORD_SIZE*NO_OF_WORDS;
localparam COUNTER_WIDTH=logb2(WIDTH+1);
reg[COUNTER_WIDTH-1:0] buffer_empty_counter;
reg[WIDTH-1:0] memory;

function integer logb2;
  input [31:0] in;
  integer i;
  begin
    i = in;
      for(logb2=1; i>0; logb2=logb2+1)
        i = i >> 1;
  end
endfunction


integer j;
//write to memory parallely and read from memory serially
always@(posedge clk)begin
	if(reset)begin
		data_serial_out<=1'b0;
		for (j = 0; j <WIDTH; j = j + 1)
			memory[j] <=1'b0;
	end
	if(data_serial_rd_enable)begin
		data_serial_out<=memory[0];
		for (j = 0; j <WIDTH-1; j = j + 1) begin: SHIFT
				memory[j]<=memory[j+1];
		end
	end
	else if(data_parallel_wr_enable)begin
		memory<=data_parallel_in;
	end
end




always@(posedge clk)begin
	if(reset) 
		buffer_empty_counter<=WIDTH;
	else if(data_parallel_wr_enable)
		buffer_empty_counter<=WIDTH;
	else if(data_serial_rd_enable && buffer_empty_counter>{{COUNTER_WIDTH}{1'b0}})
		buffer_empty_counter<=buffer_empty_counter - {{{COUNTER_WIDTH-1}{1'b0}},1'b1};
end

assign empty=(buffer_empty_counter=={{{COUNTER_WIDTH-1}{1'b0}},1'b0})?1'b1:1'b0;//

endmodule
