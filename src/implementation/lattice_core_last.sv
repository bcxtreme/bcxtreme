
module lattice_core_last #(parameter COUNTBITS = 6, parameter DELAY_C = 0, parameter INDEX = 0, parameter ROUND_PIPELINE_DEPTH = 1)
(
	input clk,
	input rst,

	coreInputsIfc.reader data_i,
	processorResultsIfc.writer data_o,
	output validOut,
	output newBlockOut
);
	wire [31:0] difficulty;
	wire [255:0] hash;
	wire hash_new, hash_valid;
	
	sha_last_pipelined_core #(.ROUND_PIPELINE_DEPTH(ROUND_PIPELINE_DEPTH), .PROCESSORINDEX(INDEX)) sha (
		.clk,
		.rst,
		.in(data_i),
		.output_valid(hash_valid),
		.newblock_o(hash_new),
		.doublehash(hash),
		.difficulty
	);

	final_hash_validator havl (
		.clk,
		.rst,
		.valid_i(hash_valid),
		.valid_o(validOut),
		.newblock_i(hash_new),
		.newblock_o(newBlockOut),
		.hash,
		.difficulty,
		.success(data_o.success)
	);

	assign data_o.nonce_prefix = INDEX;

endmodule
		
