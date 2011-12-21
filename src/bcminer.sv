

module bcminer #(parameter BROADCAST_CNT = 1024, parameter ROUND_PIPELINE_DEPTH=3, parameter NUM_CORES=10)
(
	input clk,
	minerIfc.dut chip,
	blockStoreIfc.reader blkRd,
	nonceBufferIfc.writer nonBufWrt
);
	parameter LOG2_NUM_CORES = $clog2(NUM_CORES);

	logic validOut, newBlockOut, resultValid, success;
	logic[31:0] nonce;

	coreInputsIfc blockData(clk);
	processorResultsIfc outData(clk);

	block_storage  #(.NCYCLES(BROADCAST_CNT)) bs(
		.clk,
		.rst(chip.rst),
		.blkRd,
		.broadcast(blockData.writer)
	);

	coreInputsIfc inGlue[NUM_CORES - 2:0](clk);
	processorResultsIfc #(.NUM_CORES(NUM_CORES)) outGlue[NUM_CORES - 2:0](clk);

	lattice_block_first #(.NUM_CORES(NUM_CORES),.INDEX(0), .ROUND_PIPELINE_DEPTH(ROUND_PIPELINE_DEPTH)) lblock_first (
		.clk,
		.rst(chip.rst),
		.inputs_i(blockData.reader),
		.inputs_o(inGlue[0].writer),
		.outputs_o(outGlue[0].writer)
	);

	generate
	for (genvar i = 1; i < NUM_CORES - 1; i++) begin
		lattice_block #(.NUM_CORES(NUM_CORES),.INDEX(i), .ROUND_PIPELINE_DEPTH(ROUND_PIPELINE_DEPTH)) lblock (
			.clk,
			.rst(chip.rst),
			.inputs_i(inGlue[i - 1].reader),
			.inputs_o(inGlue[i].writer),
			.outputs_i(outGlue[i - 1].reader),
			.outputs_o(outGlue[i].writer)
		);
	end
	endgenerate
		
	lattice_block_last #(.NUM_CORES(NUM_CORES), .INDEX(NUM_CORES - 1), .ROUND_PIPELINE_DEPTH(ROUND_PIPELINE_DEPTH)) lblock_last (
		.clk,
		.rst(chip.rst),
		.inputs_i(inGlue[NUM_CORES - 2].reader),
		.outputs_i(outGlue[NUM_CORES - 2].reader),
		.outputs_o(outData.writer),
		.validOut,
		.newBlockOut
	);

	logic decoder_valid;
	logic decoder_success;
	logic[31:0] decoder_nonce;
	nonce_decoder #(.NUM_CORES(NUM_CORES), .BROADCAST_CNT(BROADCAST_CNT) ) ndecode (
		.clk,
		.rst(chip.rst),
		.valid_i(validOut),
		.newblock_i(newBlockOut),
		.rawinput_i(outData.reader),
		.valid_o(decoder_valid),
		.success_o(decoder_success),
		.nonce_o(decoder_nonce)
	);

	nonce_buffer nbuffer (
		.clk,
		.rst(chip.rst),
		.valid(decoder_valid),
		.valid_o(resultValid),
		.success(decoder_success),
		.success_o(success),
		.nonce_i(decoder_nonce),
		.readready(nonBufWrt.readReady),
		.nonce_o(nonBufWrt.nonce),
		.error(nonBufWrt.error)
	);

	assign chip.resultValid = resultValid;
	assign chip.success = success;

endmodule
	
