`timescale 1ns / 1ps
module sampling_tick_generator#(
	parameter BAUD 			=2400,
	parameter CLOCK_IN_MHZ	=100
)
(
 input clk,
 input reset,
 input start,
 output reg tick_16_8,  // trick at every 16th of 16 times baud starting at 8th 
 output reg tick_16_16  // trick at every 16th of 16 times baud starting at 16th 
 );
 
 localparam  integer SAMPLING_RATE=16*CLOCK_IN_MHZ*1000000/(BAUD*16);
 localparam  integer SAMPLING_RATE_2x=SAMPLING_RATE/2;
 localparam  COUNTER_WIDTH=logb2(SAMPLING_RATE-1);
 
 
function integer logb2;
  input [31:0] in;
  integer i;
  begin
    i = in;
      for(logb2=1; i>0; logb2=logb2+1)
        i = i >> 1;
  end
endfunction


 reg[COUNTER_WIDTH-1:0] counter;
 always@(posedge clk)begin
	if(reset)begin
		counter<={{COUNTER_WIDTH}{1'b0}};
		tick_16_16  <=1'b0;
		tick_16_8<=1'b0;
		//$display(SAMPLING_RATE_2x);
	end
	else begin
		if(start) begin
			if(counter<SAMPLING_RATE)begin
				counter<=counter+{{{COUNTER_WIDTH-1}{1'b0}},1'b1};
				   tick_16_16   <=1'b0;				
				if(counter==SAMPLING_RATE_2x)
					tick_16_8 <=1'b1;
				else
					tick_16_8 <=1'b0;
			end
			else begin
				counter<={{COUNTER_WIDTH}{1'b0}};
				tick_16_16  <=1'b1;
			end
		end 
		else begin
			counter<={{COUNTER_WIDTH}{1'b0}};
			tick_16_16   <=1'b0;
			tick_16_8    <=1'b0;
		end
	end
 end


endmodule
