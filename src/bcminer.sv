

module bcminer #(parameter COUNTBITS = 6)
(
	input clk,
	minerIfc.dut chip,
	blockStoreIfc.reader blkRd,
	nonceBufferIfc.writer nonBufWrt
);

	coreInputsIfc blockData(clk);
	processorResultsIfc outData(clk);

	logic bs_valid, bs_new;
	logic [351:0] bs_state;

	logic sha_valid, sha_new;
	logic [255:0] sha_hash;
	logic [31:0] sha_difficulty;

	logic hval_success;
	
	block_storage  #(.LOGNCYCLES(COUNTBITS)) bs(
		.clk,
		.rst(chip.rst),
		.blkRd,
		.broadcast(blockData.writer)
	);


	processorResultsIfc #(.PARTITIONBITS(COUNTBITS)) outDataTmp(clk);
	assign outDataTmp.success = 0;
	assign outDataTmp.nonce_prefix = 0;

	lattice_block_last #(.LOG2_NUM_CORES(COUNTBITS), .DELAY_C(64), .INDEX(0)) core_last (
		.clk,
		.rst(chip.rst),
		.inputs_i(blockData.reader),
		.outputs_i(outDataTmp.reader),
		.outputs_o(outData.writer),
		.validOut(chip.resultValid),
		.newBlockOut(nonBufWrt.nonce)
	);

	// assign chip.success = hval_success;
	// assign chip.resultValid = sha_valid;
	// assign nonBufWrt.nonce = sha_new;
	assign chip.success = outData.success;
	assign nonBufWrt.overflow = 1'b0;

endmodule
	
