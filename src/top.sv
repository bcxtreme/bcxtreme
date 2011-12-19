
`timescale 1ns/1ns

module top #(parameter COUNTBITS=6);
	bit clk = 0;
	always #5 clk = ~clk;

	initial $vcdpluson;

	minerIfc miner(clk);
	blockStoreIfc blkStore(clk);
	nonceBufferIfc nonBuf(clk);

	bcminer #(.DELAY_C(129), .COUNTBITS(COUNTBITS)) dut (
		.clk,
		.chip(miner.dut),
		.blkRd(blkStore.reader),
		.nonBufWrt(nonBuf.writer)
	);

	bench #(.DELAY_C(129), .COUNTBITS(COUNTBITS), .NUM_CORES(3)) tb (
		.clk,
		.chip(miner.bench),
		.blkWrt(blkStore.writer),
		.nonBufRd(nonBuf.reader)
	);

endmodule
