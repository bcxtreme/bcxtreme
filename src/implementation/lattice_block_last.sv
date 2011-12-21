
module lattice_block_last #(parameter NUM_CORES = 10, parameter INDEX = 0, parameter DELAY_C = 0, parameter ROUND_PIPELINE_DEPTH=1)
(
	input clk,
	input rst,
	
	// Pipeline inputs come in....
	coreInputsIfc.reader inputs_i,
	// Pipeline outputs come in...
	processorResultsIfc.reader outputs_i,
	// Pipeline outputs leave 1 cycle later (plus any output we add)
	processorResultsIfc.writer outputs_o,
	output validOut,
	output newBlockOut
);
	processorResultsIfc #(.NUM_CORES(NUM_CORES)) tmp(clk);
	
	lattice_core_last #(.INDEX(INDEX), .ROUND_PIPELINE_DEPTH(ROUND_PIPELINE_DEPTH)) core (
		.clk,
		.rst,
		.data_i(inputs_i),
		.data_o(tmp.writer),
		.validOut,
		.newBlockOut
	);

	lattice_ff_output #(.COUNTBITS($clog2(NUM_CORES))) ffo (
		.clk,
		.outputs_i,
		.this_stage(tmp.reader),
		.outputs_o
	);

	
/*
	// Note: Previously, we delayed the outputs for one cycle, but we no longer need to.
	wire [1:0] x; // store validOut and newBlockOut in the flip-flop
	rff #(.WIDTH(2)) f2 (
		.clk,
		.rst,
		.data_i(x),
		.data_o({validOut, newBlockOut})
	);
*/

endmodule

		
