module sha_standard_pipelined_stage #(parameter K=0,parameter ROUND_PIPELINE_DEPTH=1)
(
input logic clk,
input HashState state_i,
input logic[15:0][31:0] W_i,
output HashState state_o,
output logic[15:0][31:0] W_o
);

sha_round #(.PIPELINE_DEPTH(ROUND_PIPELINE_DEPTH)) r(.clk, .in(state_i),.out(state_o),.K(K),.W(W_i[0]));

sha_message_expander_pipeline #(.PIPELINE_DEPTH(ROUND_PIPELINE_DEPTH)) pl(.clk,.W_i,.W_o);

endmodule : sha_standard_pipelined_stage
