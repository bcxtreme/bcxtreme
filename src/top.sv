
`timescale 1ns/1ns

module top;
	bit clk = 0;
	always #5 clk = ~clk;

	initial $vcdpluson;

	bit rst;
	blockStoreIfc blkStore();
	bit resultValid;
	bit success;
	nonceBufferIfc nonBuf();

	bcminer dut (
		.clk,
		.rst,
		.blkRd(blkStore.reader),
		.resultValid,
		.success,
		.nonBufWrt(nonBuf.writer)
	);

	bench tb (
		.clk,
		.rst,
		.blkWrt(blkStore.writer),
		.resultValid,
		.success,
		.nonBufRd(nonBuf.reader)
	);

endmodule
