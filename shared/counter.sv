//reset signal resets the counter to zero for the *next* cycle.
module counter (
input logic clk,
input logic rst,
output logic[31:0] count);

logic[31:0] prev;
logic[31:0] n;

ff #(.WIDTH(32)) f(.clk,.data_i(n),.data_o(prev));

assign count=prev;

assign n=rst?0:prev+1;
endmodule
