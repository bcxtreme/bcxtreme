
module sha_standard_pipelined_core  #(parameter PROCESSORINDEX=0,parameter NUMPROCESSORS=1,parameter ROUND_PIPELINE_DEPTH=1,parameter TOTAL_DELAY=ROUND_PIPELINE_DEPTH*3+1) (
input logic clk,
coreInputsIfc.reader in,
output logic[255:0] doublehash,
output logic[31:0] difficulty
);

HashState round1delayed; //The round 1 state, but delayed 64 cycles.
hash_state_delay_buffer #(.DELAY(64*ROUND_PIPELINE_DEPTH)) hsdb(.clk,.newblock(in.newblock),.in(in.hashstate),.out(round1delayed));

HashState hashstate_pipeline[64:15];
logic[15:0][31:0] W_pipeline[64:15];

logic newblock_discard;//Discard the output
logic valid_discard;
//For the first 16 rounds, feed in the data directly.  (note that we do not reset, as we ignore the output of the valid bits anyway).
sha_pipelined_pre_pipeline  #(
	.PROCESSORINDEX(PROCESSORINDEX),
	.NUMPROCESSORS(NUMPROCESSORS),
	.ROUND_PIPELINE_DEPTH(ROUND_PIPELINE_DEPTH)) pre(
		.clk,
		.rst('0),
		.in,
		.output_valid(valid_discard),
		.newblock_o(newblock_discard),
		.history(W_pipeline[15]),
		.state_out(hashstate_pipeline[15]));

//Standard sha rounds with attached message expander for the rest.
for(genvar i=15; i<64; i++) begin
  sha_standard_pipelined_stage #(.K(Kfunction(i)),.ROUND_PIPELINE_DEPTH(ROUND_PIPELINE_DEPTH)) s(.clk,.state_i(hashstate_pipeline[i]),.W_i(W_pipeline[i]),.state_o(hashstate_pipeline[i+1]),.W_o(W_pipeline[i+1]));
end

//The SHA256 hash of the block... remember, we need to double hash this to get a proper output.
HashState firsthash;
sha_add_hash_state addhs(.in1(hashstate_pipeline[64]),.in2(round1delayed),.out(firsthash));

//Pipeline for the second SHA hash.
HashState hash2_hashstate_pipeline[64:0];
logic[15:0][31:0] hash2_W_pipeline[64:0];

//An additional pipeline stage to do the final add of the first SHA round and output the
// padded message words into hash2_W_pipeline[0]
sha_standard_pipelined_pad_hash hp(.clk,.instate(firsthash),.padded(hash2_W_pipeline[0]));

HashState init;
sha_initial_hashstate is(.state(init));
assign hash2_hashstate_pipeline[0]=init;

//Apply the first 16 rounds, just rotating the history without applying the message expander function
for(i=0; i<15; i++) begin
  sha_standard_pipelined_preserve_history_stage #(
	.K(Kfunction(i)),
	.ROUND_PIPELINE_DEPTH(ROUND_PIPELINE_DEPTH)) s(
		.clk,
		.state_i(hash2_hashstate_pipeline[i]),
		.W_i(hash2_W_pipeline[i]),
		.W_o(hash2_W_pipeline[i+1]),
		.state_o(hash2_hashstate_pipeline[i+1]));
end

//The remaining rounds of the second hash.
for(i=15; i<64; i++) begin
  sha_standard_pipelined_stage #(
	.K(Kfunction(i)),
	.ROUND_PIPELINE_DEPTH(ROUND_PIPELINE_DEPTH)) s(
		.clk,
		.state_i(hash2_hashstate_pipeline[i]),
		.W_i(hash2_W_pipeline[i]),
		.W_o(hash2_W_pipeline[i+1]),
		.state_o(hash2_hashstate_pipeline[i+1]));
end

HashState doublehash_hs;

//Finally add the output state to the inital state to calculate the final state.
sha_add_hash_state ahs2(.in1(hash2_hashstate_pipeline[64]),.in2(init),.out(doublehash_hs));

assign doublehash={doublehash_hs.a,doublehash_hs.b,doublehash_hs.c,doublehash_hs.d,doublehash_hs.e,doublehash_hs.f,doublehash_hs.g,doublehash_hs.h};

`ifdef DIFFICULTY_IS_PIPELINED
	logic[$clog2(TOTAL_DELAY)-1:0] difficulty_count;
	counter #(
		.INITIALCOUNT(0),
		.INCREMENT(1),
		.WIDTH($clog2(TOTAL_DELAY))) ct(
			.clk,
			.rst(in.valid & in.newblock),
			.inc(in.valid),
			.count(difficulty_count));]
	logic[31:0] next_difficulty;
	ff #(.WIDTH(32)) dff(.clk,.data_i(next_difficulty),.data_o(difficulty));
	assign next_difficulty=(difficulty_count==(TOTAL_DELAY-2))?in.w2:difficulty;
`endif

`ifndef DIFFICULTY_IS_PIPELINED
	assign difficulty=in.w3;
`endif
endmodule : sha_standard_pipelined_core
