
module lattice_block #(parameter LOG2_NUM_CORES = 1, parameter INDEX = 0, parameter ROUND_PIPELINE_DEPTH = 1)
(
	input clk,
	input rst,
	
	// Pipeline inputs come in....
	coreInputsIfc.reader inputs_i,
	// Pipeline inputs leave 1 cycle later
	coreInputsIfc.writer inputs_o,
	// Pipeline outputs come in...
	processorResultsIfc.reader outputs_i,
	// Pipeline outputs leave 1 cycle later (plus any output we add)
	processorResultsIfc.writer outputs_o
);

	lattice_core #(.COUNTBITS(LOG2_NUM_CORES), .INDEX(INDEX), .ROUND_PIPELINE_DEPTH(ROUND_PIPELINE_DEPTH)) core (
		.clk,
		.rst,
		.data_i(inputs_i),
		.data_o(tmp.writer)
	);

	processorResultsIfc #(.PARTITIONBITS(LOG2_NUM_CORES)) tmp(clk);
	lattice_ff_input ffi (
		.clk,
		.rst,
		.inputs_i,
		.inputs_o
	);

	lattice_ff_output #(.COUNTBITS(LOG2_NUM_CORES)) ffo (
		.clk,
		.outputs_i,
		.this_stage(tmp.reader),
		.outputs_o
	);

endmodule

		
