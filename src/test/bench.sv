

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
		if (gb.resultValid_o) begin
			if (gb.success_o != success) begin
				if (env.verbose) $display("ERROR: DUT success: %b", success);
				err_count += 1;
			end
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

	task do_reset();
		set_rst(1);
		if (env.verbose) print_inputs();
		do_cycle();
		if (env.verbose) print_outputs();

		set_rst(0);
		set_writeValid(0);
		set_blockData(0);
		set_readReady(0);
		if (env.verbose) print_inputs();
		do_cycle();
		if (env.verbose) print_outputs();

	endtask

	task do_block_testing();
		int ix_block = 0; 		// # block we're currently sending
		int ix_result = 0;		// # result we're expecting next
		int ix = 0;			// # byte in the current block
		byte data;			// Next byte to send
		bit is_writing = 0;		// True if we're mid-block sending
		
		if (env.verbose) begin
			$display("BEGIN MANUAL BLOCK TEST");
			$display("* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *");
		end

		do_reset();
		
		while (1) begin
			if (is_writing && ix_block < $size(env.blocks)) begin
				set_writeValid(1);
				set_blockData(env.blocks[ix_block][ix*8+7 -: 8]);
				ix++;
				if (ix == 44) begin
					ix = 0;
					ix_block++;
					is_writing = 0;
					$display("Ending block");
				end
			end else begin
				set_writeValid(0);
				set_blockData(0);
			end

			if (env.verbose) print_inputs();
			do_cycle();
			verify_outputs();
                 	if (env.verbose) print_outputs();

			if (gb.writeReady_o) begin
				is_writing = 1;
				$display("Begining block");
			end
			if (gb.resultValid_o) begin
				ix_result++;
				$display("* RESULT %d [GOLD]: %b", ix_result, gb.success_o);
			end
			if (resultValid)
				$display("* RESULT [DUT]: %b", success);

			if (ix_result == $size(env.blocks)) return;
		end
	endtask

	initial begin
		
		int err_count = 0;
		env = new();
		env.initialize();
		inp = new(.density_rst(env.density_rst), .density_writeValid(env.density_writeValid));

		gb = new();

		if ($size(env.blocks) > 0) do_block_testing();

		if (env.verbose) begin
			$display("BEGIN RANDOMIZED TEST");
			$display("* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *");
		end

		do_reset();

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

		
