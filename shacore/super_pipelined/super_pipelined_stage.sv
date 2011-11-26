module sha_super_pipelined_stage #(parameter K)
(
input logic clk,
input HashState state_i,
input logic[31:0] W_i[15:0],
input logic valid_i,
input logic newblock_i,
output HashState state_o,
output logic[31:0] W_o[15:0],
output logic valid_o,
output logic newblock_o
);

ff #(.WIDTH(1)) valid(.clk,.data_i(valid_i),.data_o(valid_o));
ff #(.WIDTH(1)) newblock(.clk,.data_i(newblock_i),.data_o(newblock_o));

HashState appliedstate;

sha_round r(.in(state_i),.state_o(appliedstate),.K(K),.W(W_i[0]));

sha_message_expander_pipeline(.clk,.W_i,.W_o);

endmodule : sha_super_pipelined_stage
