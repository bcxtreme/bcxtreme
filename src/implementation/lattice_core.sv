
module lattice_core #(parameter COUNTBITS = 6, parameter DELAY_C = 0, parameter INDEX = 0)
(
	input clk,
	input rst,

	coreInputsIfc.reader data_i,
	processorResultsIfc.writer data_o
);
	wire [31:0] difficulty;
	wire [255:0] hash;
	wire hash_new, hash_valid;
	
	dummy_sha #(.DELAY_C(DELAY_C)) sha (
		.clk,
		.rst,
		.block(data_i),
		.validOut(hash_valid),
		.newBlockOut(hash_new),
		.hash,
		.difficulty
	);

	standard_hash_validator havl (
		.clk,
		.rst,
		.hash,
		.difficulty,
		.success(data_o.success)
	);

	assign data_o.nonce_prefix = INDEX;

endmodule
		
