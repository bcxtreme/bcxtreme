
`timescale 1ns/1ns

module top #(parameter COUNTBITS=10,parameter ROUND_PIPELINE_DEPTH=2);
	bit clk = 0;
	always #5 clk = ~clk;

	initial $vcdpluson;

	minerIfc miner(clk);
	blockStoreIfc blkStore(clk);
	nonceBufferIfc nonBuf(clk);

	bcminer #(.COUNTBITS(COUNTBITS),.ROUND_PIPELINE_DEPTH(ROUND_PIPELINE_DEPTH)) dut (
		.clk,
		.chip(miner.dut),
		.blkRd(blkStore.reader),
		.nonBufWrt(nonBuf.writer)
	);

	bench #(.COUNTBITS(COUNTBITS),.DELAY_C(ROUND_PIPELINE_DEPTH*128+1)) tb (
		.clk,
		.chip(miner.bench),
		.blkWrt(blkStore.writer),
		.nonBufRd(nonBuf.reader)
	);

endmodule
