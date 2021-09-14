`timescale 1ns / 1ps
module rx_fsm#
(	
	parameter  NO_OF_DATA_BITS =8, 		 //6,7,8
	parameter  PARITY_ENABLED  ="TRUE",  //"FALSE", "TRUE"
	parameter  PARITY_TYPE     ="ODD",   // "ODD", "EVEN"
	parameter  NO_OF_STOP_BITS ="2"		 //"0" "1" "1.5" "2"
)
(  
 input 	clk,
 input 	reset,

 input  sampling_tick_middle,
 input 	sampling_tick_end,
 output reg tick_start,
	 
 input	rx_data,
 output reg data_out_to_buffer,
 output reg data_valid_to_buffer,
 output reg parity_error,
 output reg stop_bit_error
);
	 

	reg[2:0]   data_bit_counter; 
	reg parity;

   localparam IDLE 			= 4'b0000;
   localparam START_BIT 	= 4'b0001;
   localparam DATA_BITS 	= 4'b0010;
   localparam PARITY	   	= 4'b0011;
   localparam STOP_BITS 	= 4'b0100;
   localparam STOP_BITS1_5 = 4'b0101;
   localparam STOP_BITS2 	= 4'b0110;
   localparam DONE      	= 4'b0111;

   reg [3:0]  state;
	//assign debug=state;
   always@(posedge clk) begin	
      if (reset) begin
         state 				<= IDLE;
			tick_start			<=1'b0;
			data_out_to_buffer  <=1'b0;
		   data_valid_to_buffer<=1'b0;
			data_bit_counter	<=3'b000;
			parity 				<=1'b0;
			parity_error		<=1'b0;
			stop_bit_error		<=1'b0;
      end
      else begin
         case (state)
            IDLE : begin
               if (~rx_data)begin
                  state 		<= START_BIT;
						tick_start	<=1'b1;
					end
               else begin
                  state <= IDLE;
					end
					data_out_to_buffer  <=1'b0;
					data_valid_to_buffer<=1'b0;
					data_bit_counter	<=3'b000;
					parity 				<=1'b0;
					parity_error		<=1'b0;
					stop_bit_error		<=1'b0;
            end
            START_BIT : begin
               if (sampling_tick_middle)
                  state <= DATA_BITS;
               else
                  state <= START_BIT;
            end
            DATA_BITS : begin
               if (sampling_tick_middle && data_bit_counter<(NO_OF_DATA_BITS-1))begin
						data_out_to_buffer<=rx_data;
						data_valid_to_buffer<=1'b1;
                  data_bit_counter<=data_bit_counter+3'b001;
						state <=DATA_BITS;
						if(PARITY_ENABLED=="TRUE")
							parity<=parity^rx_data;
					end
               else if (sampling_tick_middle && data_bit_counter==(NO_OF_DATA_BITS-1))begin
						data_out_to_buffer<=rx_data;	
						data_valid_to_buffer<=1'b1;						
						if(PARITY_ENABLED=="TRUE")begin
							state <= PARITY;
							parity<=parity^rx_data;
						end
						else if(NO_OF_STOP_BITS=="0")
							state <=DONE;//
						else
							state <= STOP_BITS;
					end
               else begin
                  state <= DATA_BITS;
						data_valid_to_buffer<=1'b0;
					end
            end
				PARITY   :begin
					if (sampling_tick_middle)begin
						data_valid_to_buffer<=1'b0;
						parity_error<=(PARITY_TYPE!="ODD")?((parity==rx_data)?1'b0:1'b1):((~parity==rx_data)?1'b0:1'b1);
						if(NO_OF_STOP_BITS=="0")
							state <=DONE;//
						else
							state  <=STOP_BITS;
					end
					else begin
						state<=PARITY;
						data_valid_to_buffer<=1'b0;
					end
				end
            STOP_BITS: begin					
					if (sampling_tick_middle)begin
						stop_bit_error <=(rx_data)?1'b0:1'b1;
						if (NO_OF_STOP_BITS=="1")begin
							state <= DONE;//
						end
						else if (NO_OF_STOP_BITS=="1.5")
							state <= STOP_BITS1_5;
						else if (NO_OF_STOP_BITS=="2")
							state <=STOP_BITS2;
					end
               else begin
                  state <=STOP_BITS;
						data_valid_to_buffer<=1'b0;	
						parity_error<=1'b0;	
					end
            end
				STOP_BITS1_5:begin
						if(sampling_tick_end)begin
							state <= DONE;//
							stop_bit_error <=(rx_data)?1'b0:1'b1;
						end
						else begin
							state <=STOP_BITS1_5;
							stop_bit_error <=1'b0;
						end
					end
				STOP_BITS2:begin
						if(sampling_tick_middle)begin
							state <= DONE;//
							stop_bit_error <=(rx_data)?1'b0:1'b1;
						end
						else begin
							state <=STOP_BITS2;
							stop_bit_error <=1'b0;
						end
					end
				DONE:begin
						if(sampling_tick_end)
							state <= IDLE;
						else  begin
							state <=DONE;
							stop_bit_error <=1'b0;
							parity_error<=1'b0;
						end
					end
         endcase
	end

end
endmodule
