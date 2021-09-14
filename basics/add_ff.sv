module add_ff (clk, rstn, a, b, c);

input logic clk, rstn;
input logic [3:0] a, b;
output logic [3:0] c;

always @(posedge clk or negedge rstn) begin
  if (~rstn) c <= 0;
  else c <= a + b;
end

endmodule
