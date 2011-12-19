
module lattice_ff_output (
	processorResultsIfc.reader outputs_i,
	processorResultsIfc.reader this_stage,
	processorResultsIfc.writer outputs_o
);
	// TODO: Add flipflops here!!!!

	assign outputs_o.success = outputs_i.success | this_stage.success;
	assign outputs_o.nonce_prefix = this_stage.success ? this_stage.nonce_prefix : outputs_i.nonce_prefix;

endmodule
