module sha_standard_pipelined_stage #(parameter K=0)
(
input logic clk,
input logic rst,
input HashState state_i,
input logic[15:0][31:0] W_i,
output HashState state_o,
output logic[15:0][31:0] W_o
);

sha_round r(.clk, .in(state_i),.out(state_o),.K(K),.W(W_i[0]));

sha_message_expander_pipeline pl(.clk,.W_i,.W_o);

endmodule : sha_standard_pipelined_stage
