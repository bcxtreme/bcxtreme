
module lattice_block_first #(parameter LOG2_NUM_CORES = 1, parameter INDEX = 0, parameter DELAY_C = 0)
(
	input clk,
	input rst,
	
	// Pipeline inputs come in....
	coreInputsIfc.reader inputs_i,
	// Pipeline inputs leave 1 cycle later
	coreInputsIfc.writer inputs_o,
	// Pipeline outputs: NONE! We're the first!
	// Pipeline outputs leave: Make sure to delay 1 cycle still
	processorResultsIfc.writer outputs_o
);

	lattice_core #(.COUNTBITS(LOG2_NUM_CORES), .INDEX(INDEX), .DELAY_C(DELAY_C)) core (
		.clk,
		.rst,
		.data_i(inputs_i),
		.data_o(outputs_o)
	);

	lattice_ff_input ffi (
		.inputs_i,
		.inputs_o
	);

endmodule

		
