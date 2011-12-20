
module nonce_decoder #(parameter NUM_CORES = 10)
(
	input clk,
	input rst,
	input valid_i,
	input newblock_i,
	processorResultsIfc.reader rawinput_i,
	output valid_o,
	output success_o,
	output [31:0] nonce
);

endmodule
