module sha_standard_pipelined_preserve_history_stage #(parameter K=0)
(
input logic clk,
input HashState state_i,
input logic[15:0][31:0] W_i,
output HashState state_o,
output logic[15:0][31:0] W_o
);


sha_round r(.clk,.in(state_i),.out(state_o),.K(K),.W(W_i[0]));

for(genvar i=0; i<15; i++) begin
  ff #(.WIDTH(32)) W(.clk,.data_i(W_i[i]),.data_o(W_o[i+1]));
end
 ff #(.WIDTH(32)) W(.clk,.data_i(W_i[15]),.data_o(W_o[0]));

endmodule : sha_standard_pipelined_preserve_history_stage
