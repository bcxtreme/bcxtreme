

module bcminer #(parameter COUNTBITS = 1, parameter DELAY_C = 0)
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

	parameter NUM_CORES = 10;
	coreInputsIfc inGlue[NUM_CORES - 2:0](clk);
	processorResultsIfc #(.PARTITIONBITS(COUNTBITS)) outGlue[NUM_CORES - 2:0](clk);

	lattice_block_first #(.LOG2_NUM_CORES(COUNTBITS), .DELAY_C(DELAY_C), .INDEX(0)) lblock_first (
		.clk,
		.rst(chip.rst),
		.inputs_i(blockData.reader),
		.inputs_o(inGlue[0].writer),
		.outputs_o(outGlue[0].writer)
	);

	generate
	for (genvar i = 1; i < NUM_CORES - 1; i++) begin
		lattice_block #(.LOG2_NUM_CORES(COUNTBITS), .DELAY_C(DELAY_C), .INDEX(i)) lblock (
			.clk,
			.rst(chip.rst),
			.inputs_i(inGlue[i - 1].reader),
			.inputs_o(inGlue[i].writer),
			.outputs_i(outGlue[i - 1].reader),
			.outputs_o(outGlue[i].writer)
		);
	end
	endgenerate
		
	lattice_block_last #(.LOG2_NUM_CORES(COUNTBITS), .DELAY_C(DELAY_C), .INDEX(NUM_CORES - 1)) lblock_last (
		.clk,
		.rst(chip.rst),
		.inputs_i(inGlue[NUM_CORES - 2].reader),
		.outputs_i(outGlue[NUM_CORES - 2].reader),
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
	
