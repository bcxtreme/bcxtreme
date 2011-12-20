

program bench #(parameter COUNTBITS=6, parameter DELAY_C = 129, parameter NUM_CORES = 1)
(
	input clk,
	minerIfc.bench chip,
	blockStoreIfc.writer blkWrt,
	nonceBufferIfc.reader nonBufRd
);

	int ix_cycle = 0;

	environ env;
	inputs inp;
	golden_bcminer #(.COUNTBITS(COUNTBITS), .DELAY_C(DELAY_C), .NUM_CORES(NUM_CORES)) gb;

	task set_rst(bit val);
		gb.rst_i = val;
		chip.cb.rst <= val;
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
		nonBufRd.cb.readReady <= val;
	endtask

	task set_inputs();
		set_rst(inp.rst);
		set_writeValid(inp.writeValid);
		set_blockData(inp.blockData);
		set_readReady(0);
	endtask

	task print_inputs();
		$display("%d %t: [rst %b] [writeValid %b] [blockData %x] [readReady %b]",
			ix_cycle,$time, gb.rst_i, gb.writeValid_i, gb.blockData_i, gb.readReady_i);
	endtask

	task print_outputs();
		$display("%d %t:                                                      [writeReady %b] [resultValid %b] [success %b] [nonce %b] [overflow %b]",
			ix_cycle,$time, blkWrt.cb.writeReady, chip.cb.resultValid, chip.cb.success, nonBufRd.cb.nonce, nonBufRd.cb.overflow);
	endtask

	function int verify_outputs();
		int err_count;
		err_count = 0;

		if (gb.writeReady_o !== blkWrt.cb.writeReady) begin
			if (env.verbose) $display("ERROR: GOLD writeReady: %b", gb.writeReady_o);
			err_count += 1;
		end
		if (gb.resultValid_o !== chip.cb.resultValid) begin
			if (env.verbose) $display("ERROR: GOLD resultValid: %b", gb.resultValid_o);
			err_count += 1;
		end
		if (gb.resultValid_o) begin
			if (gb.success_o !== chip.cb.success) begin
				if (env.verbose) $display("ERROR: GOLD success: %b", gb.success_o);
				err_count += 1;
			end
			//TODO FOR NORMAL OPERATION THESE SHOULD NOT BE INSIDE THIS IF BLOCK BUT SHOULD BE CHECKED REGARDLESS
			if (gb.nonce_o !== nonBufRd.cb.nonce) begin
				if (env.verbose) $display("ERROR: GOLD nonce: %b", gb.nonce_o);
				err_count += 1;
			end
			if (gb.overflow_o !== nonBufRd.cb.overflow) begin
				if (env.verbose) $display("ERROR: GOLD overflow: %b", gb.overflow_o);
				err_count += 1;
			end
		end

		return err_count;
	endfunction

	task do_cycle();
		@(blkWrt.cb)
		gb.cycle();
		inp.write_feedback(blkWrt.cb.writeReady);
		inp.generate_inputs();
		ix_cycle++;
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

		inp.generate_new_block();
		inp.generate_inputs();
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
				set_blockData(env.blocks[ix_block][351-ix*8 -: 8]);
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

			if (gb.writeReady_o && !is_writing) begin
				is_writing = 1;
				$display("Beginning block");
			end
			if (gb.resultValid_o) begin
				ix_result++;
				$display("* RESULT %d [GOLD]: %b", ix_result, gb.success_o);
			end
			if (chip.cb.resultValid)
				$display("* RESULT [DUT]: %b", chip.cb.success);

			if (ix_result == (1<<COUNTBITS)*$size(env.blocks)) return;
		end
	endtask

	initial begin
		
		int err_count = 0;
		env = new();
		env.initialize();
		inp = new(.density_rst(env.density_rst), .density_writeValid(env.density_writeValid));

		gb = new();
		do_reset();

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

		
