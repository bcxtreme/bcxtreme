program bench #(parameter LOGNCORES=3)
(
	input clk,
	output logic rst,
	coreInputsIfc.bench port,
	input logic[255:0] doublehash
);
	clocking cb2 @(posedge clk)
	output rst;
	input doublehash;
	endclocking

	environ env;
	inputs inp;
	golden_hashvalidator gb;

	task set_rst(bit val);
		gb.rst_i = val;
		cb2.reset<= val;
	endtask

	task set_valid(bit val);
		gb.valid_i = val;
		port.cb.valid <= val;
	endtask

	task set_hashstate(bit[255:0] val);
		gb.hashstate_i = val;
		port.cb.hashstate<= val;
	endtask

	task set_words(bit[31:0] w1, bit[31:0] w2, bit[31:0] w3, );
		gb.w1_i = w1;
		blkWrt.cb.w1 <= w1;
		gb.w2_i = w2;
		blkWrt.cb.w2 <= w2;
		gb.w3_i = w3;
		blkWrt.cb.w3 <= w3;
	endtask


	task set_inputs();
		set_rst(inp.rst);
		set_valid(inp.valid);
		set_hashstate(inp.hashstate);
		set_words(inp.w1,inp.w2,inp.w3);
	endtask

	task print_inputs();
		$display("%t: [rst %b] [valid %b] [hashstate %x] [w1 %b] [w2 %b] [w3 %b]", $time, gb.rst_i, gb.valid_i, gb.hashstate_i, gb.w1_i, gb.w2_i, gb.w3_i);
	endtask

	task print_outputs();
		$display("%t:                                                      [doublehash %b]", $time, gb.doublehash);
	endtask

	function int verify_outputs();
		int err_count;
		err_count = 0;

		if (gb.doublehash_o != doublehash) begin
			if (env.verbose) $display("ERROR: DUT doublehash: %b", cb2.doublehash);
			err_count += 1;
		end

		return err_count;
	endfunction

	task do_cycle();
		@(port.cb)
		gb.cycle();
		inp.generate_inputs();
	endtask

	initial begin
		
		int err_count = 0;
		env = new();
		env.initialize();
		inp = new(.density_rst(env.density_rst), .density_valid(env.density_valid));

		gb = new();
		if (env.verbose) begin
			$display("BEGIN TEST");
			$display("* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *");
		end

		set_rst(1);
		if (env.verbose) print_inputs();
		do_cycle();
		if (env.verbose) print_outputs();

		set_rst(0);
		set_inputs();
		if (env.verbose) print_inputs();
		do_cycle();
		if (env.verbose) print_outputs();

		for (int i = 0; i < env.max_cycles; i++) begin
			set_inputs();
			if (env.verbose) print_inputs();

			do_cycle();
                  	 if (env.verbose) print_outputs();
		
			err_count += verify_outputs();
		end

		if (env.verbose) begin
			$display("* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *");
			$display("TEST COMPLETE");
		end
		$display("Errors: %d", err_count);
		if (err_count == 0)
			$display("[ PASS ]");
		else
			$display("[ FAIL ]");
	end

endprogram

		
