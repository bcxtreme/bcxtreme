module sha_super_pipelined_pre_stage #(parameter K)
(
input logic clk,
input HashState state_i,
input logic[31:0] W,
input logic valid_i,
input logic newblock_i,
output HashState state_o,
output logic valid_o,
output logic newblock_o
);

ff #(.WIDTH(1)) valid(.clk,.data_i(valid_i),.data_o(valid_o));
ff #(.WIDTH(1)) newblock(.clk,.data_i(newblock_i),.data_o(newblock_o));

HashState appliedstate;

sha_round r(.in(state_i),.state_o(appliedstate),.K(K),.W);


endmodule : sha_super_pipelined_stage
