module sha_standard_pipelined_core  #(parameter PROCESSORINDEX=0,parameter NUMPROCESSORS=1) (
input logic clk,
coreInputsIfc.reader in,
output HashState doublehash
);

HashState round1delayed; //The round 1 state, but delayed 64 cycles.
hash_state_delay_buffer #(.DELAY(64)) hsdb(.clk,.newblock(in.newblock),.in(in.hashstate),.out(round1delayed));

HashState hashstate_pipeline[64:15];
logic[15:0][31:0] W_pipeline[64:15];

logic newblock_discard; //Discard the output
logic valid_discard;
//For the first 16 rounds, feed in the data directly.  (note that we do not reset, as we ignore the output of the valid bits anyway).
sha_pipelined_pre_pipeline  #(.PROCESSORINDEX(PROCESSORINDEX),.NUMPROCESSORS(NUMPROCESSORS)) pre(.clk,.rst('0),.in,.output_valid(valid_discard),.newblock_o(newblock_discard),.history(W_pipeline[15]),.state_out(hashstate_pipeline[15]));

//Standard sha rounds with attached message expander for the rest.
for(genvar i=15; i<64; i++) begin
  sha_standard_pipelined_stage #(.K(Kfunction(i))) s(.clk,.state_i(hashstate_pipeline[i]),.W_i(W_pipeline[i]),.state_o(hashstate_pipeline[i+1]),.W_o(W_pipeline[i+1]));
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
  sha_standard_pipelined_preserve_history_stage #(.K(Kfunction(i))) s(.clk,.state_i(hash2_hashstate_pipeline[i]),.W_i(hash2_W_pipeline[i]),.W_o(hash2_W_pipeline[i+1]),.state_o(hash2_hashstate_pipeline[i+1]));
end

//The remaining rounds of the second hash.
for(i=15; i<64; i++) begin
  sha_standard_pipelined_stage #(.K(Kfunction(i))) s(.clk,.state_i(hash2_hashstate_pipeline[i]),.W_i(hash2_W_pipeline[i]),.W_o(hash2_W_pipeline[i+1]),.state_o(hash2_hashstate_pipeline[i+1]));
end

//Finally add the output state to the inital state to calculate the final state.
sha_add_hash_state ahs2(.in1(hash2_hashstate_pipeline[64]),.in2(init),.out(doublehash));


endmodule : sha_standard_pipelined_core
