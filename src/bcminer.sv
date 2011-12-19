

module bcminer #(parameter COUNTBITS = 6)
(
	input clk,
	minerIfc.dut chip,
	blockStoreIfc.reader blkRd,
	nonceBufferIfc.writer nonBufWrt
);

	logic bs_valid, bs_new;
	logic [351:0] bs_state;

	logic sha_valid, sha_new;
	logic [255:0] sha_hash;
	logic [31:0] sha_difficulty;

	logic hval_valid, hval_success, hval_new;

	block_storage  #(.LOGNCYCLES(COUNTBITS)) bs(
		.clk,
		.rst(chip.rst),
		.blkRd,
		.outputValid(bs_valid),
		.newBlock(bs_new),
		.initialState(bs_state)
	);


	dummy_sha #(.DELAY_C(64)) sha (
		.clk,
		.rst(chip.rst),
		.validIn(bs_valid),
		.newBlockIn(bs_new),
		.initialState(bs_state),
		.validOut(sha_valid),
		.newBlockOut(sha_new),
		.hash(sha_hash),
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

	// XXX: Nonce input is hard coded in!
	// XXX: That means we had better clock the same value out!
	// XXX: What is the newnonce pin!?
	nonce_buffer nbuf (
		.clk,
		.valid(hval_valid),
		.success(hval_success),
		.nonce_i(32'b1011001110001111),
		.read(nonBufWrt.readReady),
//		.newnonce(),
		.nonce_o(nonBufWrt.nonce),
		.overflow(nonBufWrt.overflow)
	);
		

	assign chip.success = hval_success;
	//assign chip.resultValid = sha_valid;
	//assign nonBufWrt.nonce = sha_new;

endmodule
	
