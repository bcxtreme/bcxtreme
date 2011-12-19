
module lattice_block #(parameter LOG2_NUM_CORES, parameter INDEX)
(
	input clk,
	input rst,
	
	// Pipeline inputs come in....
	input validIn_i,
	input newBlockIn_i,
	input [351:0] initialStateIn_i,
	// Pipeline inputs leave 1 cycle later
	output validIn_o,
	output newBlockIn_o,
	output [351:0] initialStateIn_o,

	// Pipeline outputs come in...
	input validOut_i,
	input newBlockOut_i,
	input success_i,
	input [LOG2_NUM_CORES - 1 : 0] nonce_index_i,
	input [31:0] difficulty_i,
	// Pipeline outputs leave 1 cycle later (plus any output we add)
	output logic validOut_o,
	output logic newBlockOut_o,
	output logic success_o,
	output logic [LOG2_NUM_CORES - 1 : 0] nonce_index_o,
	output logic [31:0] difficulty_o
);
	// IN = [validIn 1] [newBlockIn 1] [InitialState 352]
	parameter IN_DATA_WIDTH = 1 + 1 + 352;
	// OUT = [validOut 1] [newBlockOut 1] [success 1] [nonce_index LOG2_NUM_CORES] [difficulty 32]
	parameter OUT_DATA_WIDTH = 1 + 1 + 1 + LOG2_NUM_CORES + 32;

	logic sha_valid, sha_new;
	logic [255:0] sha_hash;
	logic [31:0] sha_difficulty;
	
	logic validOut, newBlockOut, success;

	dummy_sha_core #(.DELAY_C(8)) sha (
		.clk,
		.rst,
		.validIn(validIn_i),
		.newBlockIn(newBlockIn_i),
		.initialState(initialState_i),
		.validOut(sha_valid),
		.newBlockOut(sha_new),
		.hash(sha_hash),
		.difficulty(sha_difficulty)
	);

	final_hash_validator hval (
		.clk,
		.rst,
		.valid_i(sha_valid),
		.valid_o(validOut),
		.newblock_i(sha_new),
		.newblock_o(newBlockOut),
		.hash(sha_hash),
		.difficulty(sha_difficulty),
		.success
	);

	// Pass along the outputs we recieved.
	// If our hash validator reports a success, then we should
	// replace the previous success with 1, and we should send out
	// our personal Index.
	/*
	rff #(.WIDTH()) outFF (
		.clk,
		.rst,
		.data_i()
		.data_o()
	);
	*/
endmodule

		
