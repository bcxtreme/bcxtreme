module nonce_decoder #(parameter NUM_CORES=10, parameter BROADCAST_CNT=100)
(
	input logic clk,
	input logic rst,
	input logic valid_i,
	input logic newblock_i,
	processorResultsIfc.reader rawinput_i,
	
	output logic valid_o,
	output logic success_o,
	output logic[31:0] nonce_o
);
	// XXX: Un-implemented! This is here so it compiles....
	assign valid_o = newblock_i;
	assign success_o = 1'b1;
	assign nonce_o = rawinput_i.nonce_prefix;
endmodule
	
