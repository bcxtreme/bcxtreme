//reset signal resets the counter to zero for the *next* cycle.
module counter #(parameter WIDTH=32) (
input logic clk,
input logic rst,
input logic inc,
output logic[WIDTH-1:0] count);

logic[WIDTH-1:0] prev;
logic[WIDTH-1:0] n;

ff #(.WIDTH(WIDTH)) f(.clk,.data_i(n),.data_o(prev));

assign count=prev;

always_comb begin
  if(rst) n=0;
  else if (inc) n=prev+1;
  else n=prev;
end

endmodule
