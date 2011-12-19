

module bcminer #(parameter COUNTBITS = 6)
(
	input clk,
	minerIfc.dut chip,
	blockStoreIfc.reader blkRd,
	nonceBufferIfc.writer nonBufWrt
);
	coreInputsIfc core_inputs;

	logic bs_valid, bs_new;
	logic [351:0] bs_state;

	logic sha_valid, sha_new;
	logic [255:0] sha_hash;
	logic [31:0] sha_difficulty;

	logic hval_success;



	block_storage  #(.LOGNCYCLES(COUNTBITS)) bs(
		.clk,
		.rst(chip.rst),
		.blkRd,
		.outputValid(bs_valid),
		.newBlock(bs_new),
		.initialState(bs_state)
	);
	


	sha_last_pipelined_core #(.ROUND_PIPELINE_DEPTH(1)) sha (
		.clk,
		.rst(chip.rst),
		.in(core_inputs),
		.validOut(sha_valid),
		.newBlockOut(sha_new),
		.doublehash(sha_hash),
		.difficulty(sha_difficulty)
	);

	final_hash_validator hval (
		.clk,
		.rst(chip.rst),
		.valid_i(sha_valid),
		.valid_o(chip.resultValid),
		.newblock_i(sha_new),
		.newblock_o(nonBufWrt.nonce),
		.hash(sha_hash),
		.difficulty(sha_difficulty),
		.success(hval_success)
	);

	assign chip.success = hval_success;
	//assign chip.resultValid = sha_valid;
	//assign nonBufWrt.nonce = sha_new;
	assign nonBufWrt.overflow = 1'b0;

endmodule
	
