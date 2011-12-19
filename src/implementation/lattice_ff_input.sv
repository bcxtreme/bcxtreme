
module lattice_ff_input (
	coreInputsIfc.reader inputs_i,
	coreInputsIfc.writer inputs_o
);
	// TODO: Add flipflops here!!!!

	always_comb begin
		inputs_o.valid = inputs_i.valid;
		inputs_o.newblock = inputs_i.newblock;
		inputs_o.hashstate = inputs_i.hashstate;
		inputs_o.w1 = inputs_i.w1;
		inputs_o.w2 = inputs_i.w2;
		inputs_o.w3 = inputs_i.w3;
	end

endmodule
