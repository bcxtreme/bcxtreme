

program bench #(parameter COUNTBITS=6) 
(
	input clk,
	output logic rst,
	blockStoreIfc.writer blkWrt,
	input resultValid,
	input success,
	nonceBufferIfc.reader nonBufRd
);

	environ env;
	inputs inp;
	golden_bcminer #(.COUNTBITS(COUNTBITS)) gb;

	task set_rst(bit val);
		gb.rst_i = val;
		rst = val;
	endtask

	task set_writeValid(bit val);
		gb.writeValid_i = val;
		blkWrt.cb.writeValid <= val;
	endtask

	task set_blockData(bit[7:0] val);
		gb.blockData_i = val;
		blkWrt.cb.blockData <= val;
	endtask

	task set_readReady(bit val);
		gb.readReady_i = val;
		nonBufRd.readReady <= val;
	endtask

	task set_inputs();
		set_rst(inp.rst);
		set_writeValid(inp.writeValid);
		set_blockData(inp.blockData);
		set_readReady(0);
	endtask

	task print_inputs();
		$display("%t: [rst %b] [writeValid %b] [blockData %x] [readReady %b]", $time, gb.rst_i, gb.writeValid_i, gb.blockData_i, gb.readReady_i);
	endtask

	task print_outputs();
		$display("%t:                                                      [writeReady %b] [resultValid %b] [success %b] [nonce %b] [overflow %b]", $time, gb.writeReady_o, gb.resultValid_o, gb.success_o, gb.nonce_o, gb.overflow_o);
	endtask

	function int verify_outputs();
		int err_count;
		err_count = 0;

		if (gb.writeReady_o != blkWrt.cb.writeReady) begin
			if (env.verbose) $display("ERROR: DUT writeReady: %b", blkWrt.cb.writeReady);
			err_count += 1;
		end
		if (gb.resultValid_o != resultValid) begin
			if (env.verbose) $display("ERROR: DUT resultValid: %b", resultValid);
			err_count += 1;
		end
		if (gb.resultValid_o && (gb.success_o != success)) begin
			if (env.verbose) $display("ERROR: DUT success: %b", success);
			err_count += 1;
		end
		if (gb.nonce_o != nonBufRd.nonce) begin
			if (env.verbose) $display("ERROR: DUT nonce: %b", nonBufRd.nonce);
			err_count += 1;
		end
		if (gb.overflow_o != nonBufRd.overflow) begin
			if (env.verbose) $display("ERROR: DUT overflow: %b", nonBufRd.overflow);
			err_count += 1;
		end
		return err_count;
	endfunction

	task do_cycle();
		@(blkWrt.cb)
		gb.cycle();
		inp.generate_inputs();
	endtask

	initial begin
		
		int err_count = 0;
		env = new();
		env.initialize();
		inp = new(.density_rst(env.density_rst), .density_writeValid(env.density_writeValid));

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
                        bit is_resetting;
                        is_resetting = inp.rst;
 

			set_inputs();
			if (env.verbose) print_inputs();

			do_cycle();
                 	if (env.verbose) print_outputs();
		
			if (!is_resetting) err_count += verify_outputs();
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

		
