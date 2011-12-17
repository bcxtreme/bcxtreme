

module bcminer #(parameter COUNTBITS = 6)
(
	input clk,
	input rst,
	blockStoreIfc.reader blkRd,
	output resultValid,
	output success,
	nonceBufferIfc.writer nonBufWrt
);

	logic bs_valid, bs_new;
	logic [351:0] bs_state;

	logic sha_valid, sha_new;
	logic [255:0] sha_hash;
	logic [31:0] sha_difficulty;


	block_storage  #(.LOGNCYCLES(COUNTBITS)) bs(
		.clk,
		.rst,
		.blkRd,
		.outputValid(bs_valid),
		.newBlock(bs_new),
		.initialState(bs_state)
	);

	dummy_sha #(.COUNTBITS(COUNTBITS), .DELAY_C(64)) sha (
		.clk,
		.rst,
		.validIn(bs_valid),
		.newBlockIn(bs_new),
		.initialState(bs_state),
		.validOut(sha_valid),
		.newBlockOut(sha_new),
		.hash(sha_hash),
		.difficulty(sha_difficulty)
	);

	assign success = sha_new;
	assign resultValid = sha_valid;
	assign nonBufWrt.nonce = (^ sha_hash);
	assign nonBufWrt.overflow = 1'b0;

endmodule
	
