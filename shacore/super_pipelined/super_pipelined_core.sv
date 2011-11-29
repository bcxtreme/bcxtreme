function automatic int Kfunction; 
input int index;
begin
int K=0;
case (index)
	0:K=32'h428a2f98; 1:K=32'h71374491; 2:K=32'hb5c0fbcf;
	3:K=32'he9b5dba5; 4:K=32'h3956c25b; 5:K=32'h59f111f1;
	6:K=32'h923f82a4; 7:K=32'hab1c5ed5; 8:K=32'hd807aa98;
	9:K=32'h12835b01; 10:K=32'h243185be; 11:K=32'h550c7dc3;
	12:K=32'h72be5d74; 13:K=32'h80deb1fe; 14:K=32'h9bdc06a7;
	15:K=32'hc19bf174; 16:K=32'he49b69c1; 17:K=32'hefbe4786;
	18:K=32'h0fc19dc6; 19:K=32'h240ca1cc; 20:K=32'h2de92c6f;
	21:K=32'h4a7484aa; 22:K=32'h5cb0a9dc; 23:K=32'h76f988da;
	24:K=32'h983e5152; 25:K=32'ha831c66d; 26:K=32'hb00327c8;
	27:K=32'hbf597fc7; 28:K=32'hc6e00bf3; 29:K=32'hd5a79147;
	30:K=32'h06ca6351; 31:K=32'h14292967; 32:K=32'h27b70a85;
	33:K=32'h2e1b2138; 34:K=32'h4d2c6dfc; 35:K=32'h53380d13;
	36:K=32'h650a7354; 37:K=32'h766a0abb; 38:K=32'h81c2c92e;
	39:K=32'h92722c85; 40:K=32'ha2bfe8a1; 41:K=32'ha81a664b;
	42:K=32'hc24b8b70; 43:K=32'hc76c51a3; 44:K=32'hd192e819;
	45:K=32'hd6990624; 46:K=32'hf40e3585; 47:K=32'h106aa070;
	48:K=32'h19a4c116; 49:K=32'h1e376c08; 50:K=32'h2748774c;
	51:K=32'h34b0bcb5; 52:K=32'h391c0cb3; 53:K=32'h4ed8aa4a;
	54:K=32'h5b9cca4f; 55:K=32'h682e6ff3; 56:K=32'h748f82ee;
	57:K=32'h78a5636f; 58:K=32'h84c87814; 59:K=32'h8cc70208;
	60:K=32'h90befffa; 61:K=32'ha4506ceb; 62:K=32'hbef9a3f7; 
	63:K=32'hc67178f2;
endcase
Kfunction=K;
end
endfunction

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
sha_super_pipelined_pre_pipeline pre(.clk,.rst,.input_valid,.newblock_i,.state_in(round1),.w1,.w2,.w3,.output_valid(valid_pipeline[15]),.newblock_o(newblock_pipeline[15]),.history(W_pipeline[15]),.state_out(hashstate_pipeline[15]));

//Standard sha rounds with attached message expander for the rest.
for(genvar i=15; i<64; i++) begin
  sha_super_pipelined_stage #(.K(Kfunction(i))) s(.clk,.rst,.state_i(hashstate_pipeline[i]),.W_i(W_pipeline[i]),.valid_i(valid_pipeline[i]),.newblock_i(newblock_pipeline[i]),.state_o(hashstate_pipeline[i+1]),.W_o(W_pipeline[i+1]),.valid_o(valid_pipeline[i+1]),.newblock_o(newblock_pipeline[i+1]));
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
sha_super_pipelined_pad_hash hp(.clk,.rst,.instate(firsthash),.valid_i(valid_pipeline[64]),.newblock_i(newblock_pipeline[64]),.valid_o(hash2_valid_pipeline[0]),.newblock_o(hash2_newblock_pipeline[0]),.padded(hash2_W_pipeline[0]));

HashState init;
sha_initial_hashstate is(.state(init));
assign hash2_hashstate_pipeline[0]=init;

//Apply the first 16 rounds, just rotating the history without applying the message expander function
for(i=0; i<15; i++) begin
  sha_super_pipelined_preserve_history_stage #(.K(Kfunction(i))) s(.clk,.rst,.state_i(hash2_hashstate_pipeline[i]),.valid_i(hash2_valid_pipeline[i]),.newblock_i(hash2_newblock_pipeline[i]),.W_i(hash2_W_pipeline[i]),.W_o(hash2_W_pipeline[i+1]),.valid_o(hash2_valid_pipeline[i+1]),.newblock_o(hash2_newblock_pipeline[i+1]),.state_o(hash2_hashstate_pipeline[i+1]));
end

//The remaining rounds of the second hash.
for(i=15; i<64; i++) begin
  sha_super_pipelined_stage #(.K(Kfunction(i))) s(.clk,.rst,.state_i(hash2_hashstate_pipeline[i]),.valid_i(hash2_valid_pipeline[i]),.newblock_i(hash2_newblock_pipeline[i]),.W_i(hash2_W_pipeline[i]),.W_o(hash2_W_pipeline[i+1]),.valid_o(hash2_valid_pipeline[i+1]),.newblock_o(hash2_newblock_pipeline[i+1]),.state_o(hash2_hashstate_pipeline[i+1]));
end

//Finally add the output state to the inital state to calculate the final state.
sha_add_hash_state ahs2(.in1(hash2_hashstate_pipeline[64]),.in2(init),.out(doublehash));
assign output_valid=hash2_valid_pipeline[64];
assign newblock_o=hash2_newblock_pipeline[64];

endmodule:sha_super_pipelined_core
