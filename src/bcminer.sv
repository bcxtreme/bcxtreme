

module bcminer #(parameter COUNTBITS = 6,parameter ROUND_PIPELINE_DEPTH=1)
(
	input clk,
	minerIfc.dut chip,
	blockStoreIfc.reader blkRd,
	nonceBufferIfc.writer nonBufWrt
);

	logic [351:0] bs_state;

	logic sha_valid, sha_new;
	HashState sha_hashout;
	logic [255:0] sha_hash;
	logic [31:0] sha_difficulty;

	logic hval_success;
	logic hval_new;
	logic hval_valid;

	coreInputsIfc core_inputs(clk);

	block_storage  #(.LOGNCYCLES(COUNTBITS)) bs(
		.clk,
		.rst(chip.rst),
		.blkRd,
		.outputValid(core_inputs.valid),
		.newBlock(core_inputs.newblock),
		.initialState(bs_state)
	);
	assign core_inputs.hashstate.a=bs_state[351:320];
	assign core_inputs.hashstate.b=bs_state[319:288];
	assign core_inputs.hashstate.c=bs_state[287:256];
	assign core_inputs.hashstate.d=bs_state[255:224];
	assign core_inputs.hashstate.e=bs_state[223:192];
	assign core_inputs.hashstate.f=bs_state[191:160];
	assign core_inputs.hashstate.g=bs_state[159:128];
	assign core_inputs.hashstate.h=bs_state[127:96];
	assign core_inputs.w1=bs_state[95:64];
	assign core_inputs.w2=bs_state[63:32];
	assign core_inputs.w3=bs_state[31:0];

	sha_last_pipelined_core #(.ROUND_PIPELINE_DEPTH(ROUND_PIPELINE_DEPTH),.PROCESSORINDEX(32'h42a14600)) sha (
		.clk,
		.rst(chip.rst),
		.in(core_inputs),
		.output_valid(sha_valid),
		.newblock_o(sha_new),
		.doublehash(sha_hash),
		.difficulty(sha_difficulty)
	);

	final_hash_validator hval (
		.clk,
		.rst(chip.rst),
		.valid_i(sha_valid),
		.valid_o(hval_valid),
		.newblock_i(sha_new),
		.newblock_o(hval_new),
		.hash(sha_hash),
		.difficulty(sha_difficulty),
		.success(hval_success)
	);
	assign chip.success = hval_success;
	//assign chip.success= ^ (sha_hash);
	assign chip.resultValid = hval_valid;
	assign nonBufWrt.nonce = hval_new;
	assign nonBufWrt.overflow = 1'b0;

endmodule
	
