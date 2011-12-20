
`timescale 1ns/1ns

module top();
	bit clk = 0;
	always #5 clk = ~clk;

	parameter COUNTBITS = 4;
	parameter ROUND_PIPELINE_DEPTH = 3;
	parameter NUM_CORES = 10;

	initial $vcdpluson;

	minerIfc miner(clk);
	blockStoreIfc blkStore(clk);
	nonceBufferIfc nonBuf(clk);

	bcminer #(.COUNTBITS(COUNTBITS), .ROUND_PIPELINE_DEPTH(ROUND_PIPELINE_DEPTH), .NUM_CORES(NUM_CORES)) dut (
		.clk,
		.chip(miner.dut),
		.blkRd(blkStore.reader),
		.nonBufWrt(nonBuf.writer)
	);

	bench #(.COUNTBITS(COUNTBITS),.DELAY_C(ROUND_PIPELINE_DEPTH*128+1), .NUM_CORES(NUM_CORES) ) tb (
		.clk,
		.chip(miner.bench),
		.blkWrt(blkStore.writer),
		.nonBufRd(nonBuf.reader)
	);

endmodule
