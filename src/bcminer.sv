

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

	blockStorage bs(
		.clk,
		.rst,
		.blkRd,
		.validOut(resultValid),
		.newBlock(success),
		.initialState(st)
	);

	assign nonBufWrt.nonce = 0;
	assign nonBufWrt.overflow = 0;

endmodule
	
