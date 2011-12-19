module sha_pipelined_pre_stage #(parameter K=0, parameter ROUND_PIPELINE_DEPTH=1)
(
input logic clk,
input logic rst,
input HashState state_i,
input logic[31:0] W,
input logic valid_i,
input logic newblock_i,
output HashState state_o,
output logic valid_o,
output logic newblock_o,
output logic next_is_newblock,  //This is an output to indicate that the next output will be newblock&valid.
output logic next_is_valid
);

logic validbuff[ROUND_PIPELINE_DEPTH:0];
logic newblockbuff[ROUND_PIPELINE_DEPTH:0];

assign validbuff[0]=valid_i;
assign newblockbuff[0]=newblock_i;

generate
	for(genvar i=0; i<ROUND_PIPELINE_DEPTH; i++) begin
		rff #(.WIDTH(1)) vff(.clk,.rst,.data_i(validbuff[i]),.data_o(validbuff[i+1]));
		ff #(.WIDTH(1)) nff(.clk,.data_i(newblockbuff[i]),.data_o(newblockbuff[i+1]));
	end
endgenerate

assign valid_o=validbuff[ROUND_PIPELINE_DEPTH];
assign newblock_o=newblockbuff[ROUND_PIPELINE_DEPTH];
assign next_is_newblock=newblockbuff[ROUND_PIPELINE_DEPTH-1];
assign next_is_valid=validbuff[ROUND_PIPELINE_DEPTH-1];

sha_round #(.PIPELINE_DEPTH(ROUND_PIPELINE_DEPTH)) r(
	.clk,
	.in(state_i),
	.out(state_o),
	.K(K),
	.W);

endmodule : sha_pipelined_pre_stage
