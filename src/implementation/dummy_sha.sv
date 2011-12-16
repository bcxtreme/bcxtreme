
module dummy_sha #(parameter COUNTBITS=6, parameter DELAY_C = 10) (
	input clk,
	input logic rst,
	input validIn,
	input newBlockIn,
	input[351:0] initialState,
	output validOut,
	output newBlockOut,
	output[255:0] hash,
	output[31:0] difficulty
);


	// XOR the initial stage on top of itself:
	wire [255:0] upper_half, lower_half;
	logic [255:0] hash_in;
	assign lower_half[255:0] = initialState[255:0];
	assign upper_half[95:0] = initialState[351:256];
	assign upper_half[255:96] = 0;
	assign hash_in = upper_half ^ lower_half;

	// Store the value for DELAY_C cycles
	wire [255:0] trans[DELAY_C + 1];
	wire trans_valid[DELAY_C + 1];
	wire trans_new[DELAY_C + 1];
	assign trans[0] = hash_in;
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
	assign validOut = trans_valid[DELAY_C];
	assign newBlockOut = trans_new[DELAY_C];

	assign difficulty = 0;

endmodule

	
