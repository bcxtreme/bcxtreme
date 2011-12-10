

module bcminer
(
	input clk,
	input rst,
	blockStoreIfc.reader blkRd,
	output resultValid,
	output success,
	nonceBufferIfc.writer nonBufWrt
);

	assign blkRd.writeReady = 0;

	assign resultValid = blkRd.writeValid;
	assign success = ^ (blkRd.blockData);



endmodule
	
