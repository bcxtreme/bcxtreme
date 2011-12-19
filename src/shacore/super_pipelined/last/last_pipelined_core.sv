module sha_last_pipelined_core  #(parameter PROCESSORINDEX=0,parameter NUMPROCESSORS=1,parameter ROUND_PIPELINE_DEPTH=1,parameter TOTAL_DELAY=ROUND_PIPELINE_DEPTH*3+1) (
input logic clk,
input logic rst,
coreInputsIfc.reader in,
output logic output_valid,
output logic newblock_o,
output logic[255:0] doublehash,
output logic[31:0] difficulty
);

HashState round1delayed; //The round 1 state, but delayed 64 cycles.
hash_state_delay_buffer #(.DELAY(64)) hsdb(.clk,.newblock(in.newblock),.in(in.hashstate),.out(round1delayed));

logic valid_pipeline[64:15];
logic newblock_pipeline[64:15];
HashState hashstate_pipeline[64:15];
logic[15:0][31:0] W_pipeline[64:15];

//For the first 16 rounds, feed in the data directly.
sha_pipelined_pre_pipeline #(.PROCESSORINDEX(PROCESSORINDEX),.NUMPROCESSORS(NUMPROCESSORS),.ROUND_PIPELINE_DEPTH(ROUND_PIPELINE_DEPTH)) pre(.clk,.rst,.in,.output_valid(valid_pipeline[15]),.newblock_o(newblock_pipeline[15]),.history(W_pipeline[15]),.state_out(hashstate_pipeline[15]));

//Standard sha rounds with attached message expander for the rest.
for(genvar i=15; i<64; i++) begin
  sha_last_pipelined_stage #(.K(Kfunction(i)),.ROUND_PIPELINE_DEPTH(ROUND_PIPELINE_DEPTH)) s(.clk,.rst,.state_i(hashstate_pipeline[i]),.W_i(W_pipeline[i]),.valid_i(valid_pipeline[i]),.newblock_i(newblock_pipeline[i]),.state_o(hashstate_pipeline[i+1]),.W_o(W_pipeline[i+1]),.valid_o(valid_pipeline[i+1]),.newblock_o(newblock_pipeline[i+1]));
end

//The SHA256 hash of the block... remember, we need to double hash this to get a proper output.
HashState firsthash;
sha_add_hash_state addhs(.in1(hashstate_pipeline[64]),.in2(round1delayed),.out(firsthash));

//Pipeline for the second SHA hash.
logic hash2_valid_pipeline[64:0];
logic hash2_newblock_pipeline[64:0];
HashState hash2_hashstate_pipeline[64:0];
logic[15:0][31:0] hash2_W_pipeline[64:0];

//An additional pipeline stage to do the final add of the first SHA round and output the
// padded message words into hash2_W_pipeline[0]
sha_last_pipelined_pad_hash hp(.clk,.rst,.instate(firsthash),.valid_i(valid_pipeline[64]),.newblock_i(newblock_pipeline[64]),.valid_o(hash2_valid_pipeline[0]),.newblock_o(hash2_newblock_pipeline[0]),.padded(hash2_W_pipeline[0]));

HashState init;
sha_initial_hashstate is(.state(init));
assign hash2_hashstate_pipeline[0]=init;

//Apply the first 16 rounds, just rotating the history without applying the message expander function
for(i=0; i<15; i++) begin
  sha_last_pipelined_preserve_history_stage #(.K(Kfunction(i)),.ROUND_PIPELINE_DEPTH(ROUND_PIPELINE_DEPTH)) s(.clk,.rst,.state_i(hash2_hashstate_pipeline[i]),.valid_i(hash2_valid_pipeline[i]),.newblock_i(hash2_newblock_pipeline[i]),.W_i(hash2_W_pipeline[i]),.W_o(hash2_W_pipeline[i+1]),.valid_o(hash2_valid_pipeline[i+1]),.newblock_o(hash2_newblock_pipeline[i+1]),.state_o(hash2_hashstate_pipeline[i+1]));
end

//The remaining rounds of the second hash.
for(i=15; i<64; i++) begin
  sha_last_pipelined_stage #(.K(Kfunction(i)),.ROUND_PIPELINE_DEPTH(ROUND_PIPELINE_DEPTH)) s(.clk,.rst,.state_i(hash2_hashstate_pipeline[i]),.valid_i(hash2_valid_pipeline[i]),.newblock_i(hash2_newblock_pipeline[i]),.W_i(hash2_W_pipeline[i]),.W_o(hash2_W_pipeline[i+1]),.valid_o(hash2_valid_pipeline[i+1]),.newblock_o(hash2_newblock_pipeline[i+1]),.state_o(hash2_hashstate_pipeline[i+1]));
end

HashState doublehash_hs;

//Finally add the output state to the inital state to calculate the final state.
sha_add_hash_state ahs2(.in1(hash2_hashstate_pipeline[64]),.in2(init),.out(doublehash_hs));

assign doublehash={doublehash_hs.a,doublehash_hs.b,doublehash_hs.c,doublehash_hs.d,doublehash_hs.e,doublehash_hs.f,doublehash_hs.g,doublehash_hs.h};

assign output_valid=hash2_valid_pipeline[64];
assign newblock_o=hash2_newblock_pipeline[64];


`ifdef DIFFICULTY_IS_PIPELINED
//And output the difficulty, delayed to be synchronous with the output of the hashstate
logic[31:0] nextdifficultyout;
ff #(.WIDTH(32)) difficultyff(.clk,.data_i(nextdifficultyout),.data_o(difficulty));
//If next round is a (valid) newblock, then we sample the difficulty word being input.  Otherwise we use the same difficulty we used last cycle.
assign nextdifficultyout=(hash2_valid_pipeline[63] && hash2_newblock_pipeline[64])?in.w3:difficulty;
`endif

`ifndef DIFFICULTY_IS_PIPELINED
assign difficulty=in.w3;
`endif

endmodule:sha_last_pipelined_core
