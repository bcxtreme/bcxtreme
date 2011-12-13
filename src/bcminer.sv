

module bcminer
(
	input clk,
	input rst,
	blockStoreIfc.reader blkRd,
	output resultValid,
	output success,
	nonceBufferIfc.writer nonBufWrt
);

	logic [351:0] st;
	logic tmp1, tmp2;

	block_storage bs(
		.clk,
		.rst,
		.blkRd,
		.outputValid(resultValid),
		.newBlock(success),
		.initialState(st)
	);

	assign nonBufWrt.nonce = 0;
	assign nonBufWrt.overflow = 0;

endmodule
	
