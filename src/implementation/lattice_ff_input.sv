
module lattice_ff_input (
	input clk,
	input rst,
	coreInputsIfc.reader inputs_i,
	coreInputsIfc.writer inputs_o
);
	wire [255:0] hs_in, hs_out;

	assign hs_in  = {inputs_i.hashstate.a, inputs_i.hashstate.b, inputs_i.hashstate.c, inputs_i.hashstate.d,
	                 inputs_i.hashstate.e, inputs_i.hashstate.f, inputs_i.hashstate.g, inputs_i.hashstate.h};

	assign {inputs_o.hashstate.a, inputs_o.hashstate.b, inputs_o.hashstate.c, inputs_o.hashstate.d,
	        inputs_o.hashstate.e, inputs_o.hashstate.f, inputs_o.hashstate.g, inputs_o.hashstate.h} = hs_out;
	rff #(.WIDTH(1)) valid_rff(
		.clk,
		.rst,
		.data_i(inputs_i.valid),
		.data_o(inputs_o.valid)
	);
	rff #(.WIDTH(1)) newblock_rff(
		.clk,
		.rst,
		.data_i(inputs_i.newblock),
		.data_o(inputs_o.newblock)
	);
	ff #(.WIDTH(256)) hashstate_ff(
		.clk,
		.data_i(hs_in),
		.data_o(hs_out)
	);
	ff #(.WIDTH(32)) w1_ff (
		.clk,
		.data_i(inputs_i.w1),
		.data_o(inputs_o.w1)
	);
	ff #(.WIDTH(32)) w2_ff (
		.clk,
		.data_i(inputs_i.w2),
		.data_o(inputs_o.w2)
	);
	ff #(.WIDTH(32)) w3_ff (
		.clk,
		.data_i(inputs_i.w3),
		.data_o(inputs_o.w3)
	);

endmodule
