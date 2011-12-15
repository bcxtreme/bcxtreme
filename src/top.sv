
`timescale 1ns/1ns

module top #(parameter COUNTBITS=8);
	bit clk = 0;
	always #5 clk = ~clk;

	initial $vcdpluson;

	bit rst;
	blockStoreIfc blkStore(clk);
	bit resultValid;
	bit success;
	nonceBufferIfc nonBuf();

	bcminer #(.COUNTBITS(COUNTBITS)) dut (
		.clk,
		.rst,
		.blkRd(blkStore.reader),
		.resultValid,
		.success,
		.nonBufWrt(nonBuf.writer)
	);

	bench #(.COUNTBITS(COUNTBITS)) tb (
		.clk,
		.rst,
		.blkWrt(blkStore.writer),
		.resultValid,
		.success,
		.nonBufRd(nonBuf.reader)
	);

endmodule
