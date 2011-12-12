
module blockStorage
(
	input clk,
	input rst,
	blockStoreIfc.reader blkRd,
	output validOut,
	output newBlock,
	output [351:0] initialState
);

	assign validOut = blkRd.writeValid;
	assign newBlock = ^ (blkRd.blockData);

endmodule
