
module lattice_block_last #(parameter LOG2_NUM_CORES = 1, parameter INDEX = 0, parameter DELAY_C = 0)
(
	input clk,
	input rst,
	
	// Pipeline inputs come in....
	coreInputsIfc.reader inputs_i,

	// Pipeline outputs come in...
	processorResultsIfc.reader outputs_i,
	// Pipeline outputs leave 1 cycle later (plus any output we add)
	processorResultsIfc.writer outputs_o,
	output logic validOut,
	output logic newBlockOut
);
	processorResultsIfc #(.PARTITIONBITS(LOG2_NUM_CORES)) tmp(clk);
	
	lattice_core_last #(.COUNTBITS(LOG2_NUM_CORES), .DELAY_C(DELAY_C), .INDEX(INDEX)) core (
		.clk,
		.rst,
		.data_i(inputs_i),
		.data_o(tmp.writer),
		.validOut,
		.newBlockOut
	);

	lattice_ff_output (
		.outputs_i,
		.this_stage(tmp.reader),
		.outputs_o
	);
	

endmodule

		
