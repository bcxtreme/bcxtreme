module sha_super_pipelined_core(
input logic clk,
input logic rst,
input logic input_valid,
input logic newblock_i,
input HashState round1, //The hash state after 1 round has been applied.
input HashState round1delayed, //The round 1 state, but delayed 64 cycles.
input logic[31:0] w1, //last 32 bits of the merkle root
input logic[31:0] w2, //timestamp
input logic[31:0] w3, //difficulty target
output logic output_valid,
output logic newblock_o,
output HashState doublehash
);

logic valid_pipeline[64:15];
logic newblock_pipeline[64:15];
HashState hashstate_pipeline[64:15];
logic[15:0][31:0] W_pipeline[64:15];

//For the first 16 rounds, feed in the data directly.
sha_super_pipelined_pre_pipeline pre(.clk,.rst,.input_valid,.newblock_i,state_in(round1),.w1,.w2,.w3,.output_valid(valid_pipeline[15]),.newblock_o(newblock_pipeline[15]),.history(W_pipeline[15]),.state_out(hashstate_pipeline[15]));

//Standard sha rounds with attached message expander for the rest.
for(i=15; i<64; i++) begin
  super_pipelined_stage #(.K(Kfunction(i))) s(.clk,.rst,.state_i(hashstate_pipeline[i]),.W_i(W_pipeline[i]),.valid_i(valid_pipeline[i]),.newblock_i(newblock_pipeline[i]),.state_o(hashstate_pipeline[i+1]),.W_o(W_pipeline[i+1]),.valid_o(valid_pipeline[i+1]),.newblock_o(newblock_pipeline[i+1]));
end

//The SHA256 hash of the block... remember, we need to double hash this to get a proper output.
HashState firsthash;
sha_add_hash_state(.in1(hashstate_pipeline[64]),.in2(round1delayed),.out(firsthash));

//Pipeline for the second SHA hash.
logic hash2_valid_pipeline[64:0];
logic hash2_newblock_pipeline[64:0];
HashState hash2_hashstate_pipeline[64:0];
logic[15:0][31:0] hash2_W_pipeline[64:0];

//An additional pipeline stage to do the final add of the first SHA round and output the
// padded message words into hash2_W_pipeline[0]
sha_super_pipelined_pad_hash(.clk,.rst,.instate(firsthash),.valid_i(valid_pipeline[64]),.newblock_i(newblock_pipeline[64]),.valid_o(hash2_valid_pipeline[0]),.newblock_o(hash2_newblock_pipeline[0]),.padded(hash2_W_pipeline[0]));

HashState initial;
sha_initial_hashstate is(.state(initial));
assign hash2_hashstate_pipeline[0]=initial;

//Apply the first 16 rounds, just rotating the history without applying the message expander function
for(i=0; i<15; i++) begin
  sha_super_pipelined_preserve_history_stage #(.K(Kfunction(i))) s(.clk,.rst,.state_i(hash2_hashstate_pipeline[i]),.valid_i(hash2_valid_pipeline[i]),.newblock_i(hash2_newblock_pipeline[i]),.W_i(hash2_W_pipeline[i]),.W_o(hash2_W_pipeline[i+1]),.valid_o(hash2_valid_pipeline[i+1]),.newblock_o(hash2_newblock_pipeline[i+1]),.state_o(hash2_hashstate_pipeline[i+1]));
end

//The remaining rounds of the second hash.
for(i=15; i<64; i++) begin
  sha_super_pipelined_stage #(.K(Kfunction(i))) s(.clk,.rst,.state_i(hash2_hashstate_pipeline[i]),.valid_i(hash2_valid_pipeline[i]),.newblock_i(hash2_newblock_pipeline[i]),.W_i(hash2_W_pipeline[i]),.W_o(hash2_W_pipeline[i+1]),.valid_o(hash2_valid_pipeline[i+1]),.newblock_o(hash2_newblock_pipeline[i+1]),.state_o(hash2_hashstate_pipeline[i+1]));
end

//Finally add the output state to the inital state to calculate the final state.
sha_add_hash_state(.in1(hash2_hashstate_pipeline[64]),.in2(initial),.out(doublehash));
assign output_valid=hash2_valid_pipeline[64];
assign newblock_o=hash2_newblock_pipeline[64];

endmodule:super_pipelined_core