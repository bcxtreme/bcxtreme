
module dummy_sha #(parameter COUNTBITS=6, parameter DELAY_C = 0) (
	input clk,
	input rst,
	input validIn,
	input newBlockIn,
	input[351:0] initialState,
	output validOut,
	output newBlockOut,
	output[255:0] hash,
	output[31:0] difficulty
);

	wire [255:0]hash_in;
	wire [31:0]difficulty_in;

	// The "hash" is the lower 256 bits of the input. The difficulty is the final 32 bits
	assign hash_in = initialState[255:0];
	assign difficulty_in = initialState[351:320];

	// Store the value for DELAY_C cycles
	wire [255:0] trans[DELAY_C + 1];
	wire [31:0] trans_difficulty[DELAY_C + 1];
	wire trans_valid[DELAY_C + 1];
	wire trans_new[DELAY_C + 1];
	assign trans[0] = hash_in;
	assign trans_difficulty[0] = difficulty_in;
	assign trans_valid[0] = validIn;
	assign trans_new[0] = newBlockIn;
	for (genvar n = 0; n < DELAY_C; n++) begin
		eff #(.WIDTH(256)) bhash  (
			.clk,
			.rst,
			.enable(1'b1),
			.data_i(trans[n]),
			.data_o(trans[n + 1])
		);
		eff #(.WIDTH(32)) dif (
			.clk,
			.rst,
			.enable(1'b1),
			.data_i(trans_difficulty[n]),
			.data_o(trans_difficulty[n + 1])
		);
		eff bnew (
			.clk,
			.rst,
			.enable(1'b1),
			.data_i(trans_new[n]),
			.data_o(trans_new[n + 1])
		);
		eff bvalid (
			.clk,
			.rst,
			.enable(1'b1),
			.data_i(trans_valid[n]),
			.data_o(trans_valid[n + 1])
		);
	end
	assign hash = trans[DELAY_C];
	assign difficulty = trans_difficulty[DELAY_C];
	assign validOut = trans_valid[DELAY_C];
	assign newBlockOut = trans_new[DELAY_C];
//	initial $monitor("valid: %b %b %b %b", trans_valid[0], trans_valid[1], trans_valid[2], trans_valid[3]);

endmodule

	
