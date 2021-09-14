`timescale 1ns / 1ps

module rx_buffer#(
	parameter WORD_SIZE=8,
	parameter NO_OF_WORDS=1
)
(
    input clk,
    input reset,
	 
    input data_serial_wr_en,
    input data_serial_in,	 
	 
    input  data_parallel_rd_enable,
    output reg [WORD_SIZE*NO_OF_WORDS-1:0]  data_parallel_out,
    output buffer_full
);

localparam WIDTH=WORD_SIZE*NO_OF_WORDS;
localparam COUNTER_WIDTH=logb2(WIDTH+1);

reg[COUNTER_WIDTH-1:0] buffer_full_counter;
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



always@(posedge clk)begin
	if(reset)begin
			data_parallel_out <={{WIDTH}{1'b0}};
	end
	else if(data_parallel_rd_enable) begin
		  data_parallel_out<=memory;
	end
end

integer j;
always@(posedge clk)begin
	if(reset)begin
		for (j = 0; j <WIDTH; j = j + 1)
			memory[0] <=1'b0;		
	end
	else if(data_serial_wr_en) begin
		memory[WIDTH-1] <=data_serial_in;
		for (j = WIDTH-1; j >0; j = j - 1) begin: SHIFT
            memory[j-1] <=memory[j]; 
		end
	end		
end


always@(posedge clk)
begin
	if(reset)begin
		buffer_full_counter<={{COUNTER_WIDTH}{1'b0}};
	end
	else begin
		if(data_serial_wr_en && buffer_full_counter<WIDTH)
			buffer_full_counter<=buffer_full_counter+{{{COUNTER_WIDTH-1}{1'b0}},1'b1};		
		else if(data_parallel_rd_enable)
			buffer_full_counter<={{COUNTER_WIDTH}{1'b0}};
	end
end

assign buffer_full=(buffer_full_counter==WIDTH)?1'b1:1'b0;


endmodule
