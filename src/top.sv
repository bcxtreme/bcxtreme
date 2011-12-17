
`timescale 1ns/1ns

module top #(parameter COUNTBITS=8);
	bit clk = 0;
	always #5 clk = ~clk;

	initial $vcdpluson;

	minerIfc miner(clk);
	blockStoreIfc blkStore(clk);
	nonceBufferIfc nonBuf();

	bcminer #(.COUNTBITS(COUNTBITS)) dut (
		.clk,
		.chip(miner.dut),
		.blkRd(blkStore.reader),
		.nonBufWrt(nonBuf.writer)
	);

	bench #(.COUNTBITS(COUNTBITS)) tb (
		.clk,
		.chip(miner.bench),
		.blkWrt(blkStore.writer),
		.nonBufRd(nonBuf.reader)
	);

endmodule
