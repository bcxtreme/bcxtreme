
`timescale 1ns/1ns

module top();
	bit clk = 0;
	always #5 clk = ~clk;

	parameter LOG2_BROADCAST_CNT = 8;
	parameter ROUND_PIPELINE_DEPTH = 3;
	parameter NUM_CORES = 10;

	initial $vcdpluson;

	minerIfc miner(clk);
	blockStoreIfc blkStore(clk);
	nonceBufferIfc nonBuf(clk);

	bcminer #(.LOG2_BROADCAST_CNT(LOG2_BROADCAST_CNT), .ROUND_PIPELINE_DEPTH(ROUND_PIPELINE_DEPTH), .NUM_CORES(NUM_CORES)) dut (
		.clk,
		.chip(miner.dut),
		.blkRd(blkStore.reader),
		.nonBufWrt(nonBuf.writer)
	);

	bench #(.LOG2_BROADCAST_CNT(LOG2_BROADCAST_CNT),.DELAY_C(ROUND_PIPELINE_DEPTH*128+1), .NUM_CORES(NUM_CORES) ) tb (
		.clk,
		.chip(miner.bench),
		.blkWrt(blkStore.writer),
		.nonBufRd(nonBuf.reader)
	);

endmodule
