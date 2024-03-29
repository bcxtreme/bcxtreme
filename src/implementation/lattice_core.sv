
module lattice_core #(parameter INDEX = 0, parameter ROUND_PIPELINE_DEPTH = 3)
(
	input clk,
	input rst,

	coreInputsIfc.reader data_i,
	processorResultsIfc.writer data_o
);
	wire [31:0] difficulty;
	wire [255:0] hash;
	wire hash_new, hash_valid;
	
	sha_standard_pipelined_core #(.ROUND_PIPELINE_DEPTH(ROUND_PIPELINE_DEPTH), .PROCESSORINDEX(INDEX)) sha (
		.clk,
		.in(data_i),
		.doublehash(hash),
		.difficulty
	);

	standard_hash_validator havl (
		.clk,
		.hash,
		.difficulty,
		.success(data_o.success)
	);

	assign data_o.processor_index = INDEX;

endmodule
		
