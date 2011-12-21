
module lattice_ff_output #(parameter COUNTBITS = 4) (
	input clk,
	processorResultsIfc.reader outputs_i,
	processorResultsIfc.reader this_stage,
	processorResultsIfc.writer outputs_o
);

	wire success;
	wire [COUNTBITS-1 : 0] prefix;

	assign outputs_o.success = this_stage.success | success;
	assign outputs_o.processor_index = this_stage.success ? this_stage.processor_index : prefix;

	ff #(.WIDTH(1)) f1 (
		.clk,
		.data_i(outputs_i.success),
		.data_o(success)
	);
	ff #(.WIDTH(COUNTBITS)) f2 (
		.clk,
		.data_i(outputs_i.processor_index),
		.data_o(prefix)
	);

endmodule
