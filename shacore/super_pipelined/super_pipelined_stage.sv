module sha_super_pipelined_stage #(parameter K=0)
(
input logic clk,
input logic rst,
input HashState state_i,
input logic[15:0][31:0] W_i,
input logic valid_i,
input logic newblock_i,
output HashState state_o,
output logic[15:0][31:0] W_o,
output logic valid_o,
output logic newblock_o
);

ff #(.WIDTH(1)) valid(.clk,.data_i(valid_i),.data_o(valid_o));
ff #(.WIDTH(1)) newblock(.clk,.data_i(newblock_i),.data_o(newblock_o));

HashState appliedstate;

sha_round r(.clk, .in(state_i),.out(appliedstate),.K(K),.W(W_i[0]));

HashStateFF hsff(.clk,.in(appliedstate),.out(state_o));

sha_message_expander_pipeline pl(.clk,.W_i,.W_o);

endmodule : sha_super_pipelined_stage
