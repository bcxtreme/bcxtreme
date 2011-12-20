

module bcminer #(parameter LOG2_BROADCAST_CNT = 4, parameter ROUND_PIPELINE_DEPTH=1, parameter NUM_CORES=10)
(
	input clk,
	minerIfc.dut chip,
	blockStoreIfc.reader blkRd,
	nonceBufferIfc.writer nonBufWrt
);
	parameter LOG2_NUM_CORES = $clog2(NUM_CORES);

	initial $display("N: %d; Log2 N: %d", NUM_CORES, LOG2_NUM_CORES);

	coreInputsIfc blockData(clk);
	processorResultsIfc outData(clk);

	logic bs_valid, bs_new;
	logic [351:0] bs_state;

	logic sha_valid, sha_new;
	HashState sha_hashout;
	logic [255:0] sha_hash;
	logic [31:0] sha_difficulty;

	logic hval_success;

	block_storage  #(.LOGNCYCLES(LOG2_BROADCAST_CNT)) bs(
		.clk,
		.rst(chip.rst),
		.blkRd,
		.broadcast(blockData.writer)
	);
	/*
	assign core_inputs.hashstate.a=bs_state[351:320];
	assign core_inputs.hashstate.b=bs_state[319:288];
	assign core_inputs.hashstate.c=bs_state[287:256];
	assign core_inputs.hashstate.d=bs_state[255:224];
	assign core_inputs.hashstate.e=bs_state[223:192];
	assign core_inputs.hashstate.f=bs_state[191:160];
	assign core_inputs.hashstate.g=bs_state[159:128];
	assign core_inputs.hashstate.h=bs_state[127:96];
	assign core_inputs.w1=bs_state[95:64];
	assign core_inputs.w2=bs_state[63:32];
	assign core_inputs.w3=bs_state[31:0];
	*/

	coreInputsIfc inGlue[NUM_CORES - 2:0](clk);
	processorResultsIfc #(.PARTITIONBITS(LOG2_NUM_CORES)) outGlue[NUM_CORES - 2:0](clk);

	lattice_block_first #(.LOG2_NUM_CORES(LOG2_NUM_CORES), .INDEX(0), .ROUND_PIPELINE_DEPTH(ROUND_PIPELINE_DEPTH)) lblock_first (
		.clk,
		.rst(chip.rst),
		.inputs_i(blockData.reader),
		.inputs_o(inGlue[0].writer),
		.outputs_o(outGlue[0].writer)
	);

	generate
	for (genvar i = 1; i < NUM_CORES - 1; i++) begin
		lattice_block #(.LOG2_NUM_CORES(LOG2_NUM_CORES), .INDEX(i), .ROUND_PIPELINE_DEPTH(ROUND_PIPELINE_DEPTH)) lblock (
			.clk,
			.rst(chip.rst),
			.inputs_i(inGlue[i - 1].reader),
			.inputs_o(inGlue[i].writer),
			.outputs_i(outGlue[i - 1].reader),
			.outputs_o(outGlue[i].writer)
		);
	end
	endgenerate
		
	lattice_block_last #(.LOG2_NUM_CORES(LOG2_NUM_CORES), .INDEX(NUM_CORES - 1), .ROUND_PIPELINE_DEPTH(ROUND_PIPELINE_DEPTH)) lblock_last (
		.clk,
		.rst(chip.rst),
		.inputs_i(inGlue[NUM_CORES - 2].reader),
		.outputs_i(outGlue[NUM_CORES - 2].reader),
		.outputs_o(outData.writer),
		.validOut(chip.resultValid),
		.newBlockOut(nonBufWrt.nonce)
	);

	/*
	 // NOTE: This is how the pins were connected to the Hash-Validator to verify the Sha Core
	assign chip.success = hval_success;
	assign chip.resultValid = hval_valid;
	assign nonBufWrt.nonce = hval_new;
	*/


	assign chip.success = outData.success;
	assign nonBufWrt.overflow = 1'b0;

endmodule
	
