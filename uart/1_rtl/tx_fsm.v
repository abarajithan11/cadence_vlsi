`timescale 1ns / 1ps
module tx_fsm#
(	
		parameter  NO_OF_DATA_BITS =8, 		 //6,7,8
		parameter  PARITY_ENABLED  ="FALSE",  //"FALSE", "TRUE"
		parameter  PARITY_TYPE     ="EVEN",   // "ODD", "EVEN"
		parameter  NO_OF_STOP_BITS	="1"		 //"0" "1" "1.5" "2"
)
(
	 input 		clk,
    input 		reset,
	 
    input      empty,
	 input  		sampling_tick_middle,
    input  		sampling_tick_end,
	 output reg tick_start,
	 
	 input      data_parallel_wr_enable,
	 output reg tx_busy,
	 output reg tx_data,
	 output reg buffer_rd_enable,
	 input      buffer_data
    
);


   reg tem_buffer_data;
	reg delay_data_parallel_wr_enable;
	always@(posedge clk) begin
		delay_data_parallel_wr_enable<=data_parallel_wr_enable;
	end
	
	localparam IDLE 					= 4'b0000;
   localparam START_BIT 			= 4'b0001;
   localparam _GET_DATA_PRE0		= 4'b0010;
   localparam _GET_DATA_PRE1		= 4'b0011;
   localparam DATA_BITS 			= 4'b0100;
   localparam PARITY	   			= 4'b0101;
   localparam STOP_BITS 			= 4'b0110;
   localparam STOP_BITSx 			= 4'b0111;
   localparam DONE      			= 4'b1000;
   localparam CHECK_BUFFER_EMPTY = 4'b1001;
	
	reg[2:0]   data_bit_counter; 
	reg        parity;
	reg [3:0]  state;
	
   always@(posedge clk) begin	
      if (reset) begin
			tx_data<=1'b1;
			parity<=1'b0;
			buffer_rd_enable<=1'b0;
			tick_start<=1'b0;
			tem_buffer_data<=1'b0;
			data_bit_counter<=3'b000;
			tx_busy<=1'b0;
			state <= IDLE;
		end
		else begin
			case(state)
				IDLE:begin					
					if(delay_data_parallel_wr_enable)begin
						tick_start<=1'b1;
						state <=START_BIT;
						tx_busy<=1'b1;
					end
					else begin
						tick_start<=1'b0;
						tx_busy<=1'b0;
						state <=IDLE;
					end
					tx_data<=1'b1;
					parity<=1'b0;
					tem_buffer_data<=1'b0;
					data_bit_counter<=3'b000;					
				end
				START_BIT:begin
						if(sampling_tick_middle)begin
							tx_data<=1'b0;
							state<=_GET_DATA_PRE0;
							buffer_rd_enable<=1'b1;
						end
						else begin
							state<=START_BIT;
						end
					end
				_GET_DATA_PRE0:begin
						buffer_rd_enable<=1'b0;
						//tem_buffer_data <=buffer_data;
						state<=_GET_DATA_PRE1;
					end
				_GET_DATA_PRE1:begin
						buffer_rd_enable<=1'b0;
						tem_buffer_data <=buffer_data;
						state<=DATA_BITS;
						if(PARITY_ENABLED=="TRUE")
							parity<=parity^buffer_data;
					end
				DATA_BITS:begin
						if(sampling_tick_middle && data_bit_counter<(NO_OF_DATA_BITS-1) )begin
							tx_data<=tem_buffer_data;
							state<=_GET_DATA_PRE0;
							buffer_rd_enable<=1'b1;
							data_bit_counter<=data_bit_counter+3'b001;
						end
						else if (sampling_tick_middle && data_bit_counter==(NO_OF_DATA_BITS-1))begin
							tx_data<=tem_buffer_data;
							//buffer_rd_enable<=1'b1;	
							if(PARITY_ENABLED=="TRUE")begin
								state <= PARITY;
								//parity<=parity^buffer_data;
							end
							else if(NO_OF_STOP_BITS=="0")
								state <=DONE;//
							else
								state <= STOP_BITS;
							end
						else begin
							state<=DATA_BITS;
						end
					end
				PARITY   :begin
						if (sampling_tick_middle)begin
								tx_data<=(PARITY_TYPE!="ODD")?parity:~parity;//parity;
								if(NO_OF_STOP_BITS=="0")
									state <=DONE;//
								else
									state  <=STOP_BITS;
						end
						else begin
							state <= PARITY;
						end						
					end
				STOP_BITS: begin
						if (sampling_tick_middle)begin
							tx_data<=1'b1;
							if (NO_OF_STOP_BITS=="1")begin
								state <= DONE;//							
							end
							else if (NO_OF_STOP_BITS=="1.5" || NO_OF_STOP_BITS=="2")
								state <= STOP_BITSx;
						end
						else begin
							state <=STOP_BITS;
						end				
					end
				STOP_BITSx:begin
					if(sampling_tick_middle)begin
						state <= DONE;//
					end
					else begin
						state <=STOP_BITSx;
					end
				end
				DONE:begin
						if(NO_OF_STOP_BITS!="1.5" && sampling_tick_middle)
							state <= CHECK_BUFFER_EMPTY;
						else if(NO_OF_STOP_BITS=="1.5" && sampling_tick_end)
							state <= CHECK_BUFFER_EMPTY;
						else  begin
							state <=DONE;
						end
					end
            CHECK_BUFFER_EMPTY:begin
						if(empty)
							state<=IDLE;
						else begin
							tick_start<=1'b1;
							state <=START_BIT;
							tx_data<=1'b1;
							parity<=1'b0;
							tem_buffer_data<=1'b0;
							data_bit_counter<=3'b000;	
						end
							
					end
			endcase
		end	
	end

	
endmodule
