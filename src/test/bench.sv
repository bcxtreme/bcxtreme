

program bench
(
	input clk,
	output logic rst,
	blockStoreIfc.writer blkWrt,
	input resultValid,
	input success,
	nonceBufferIfc.reader nonBufRd
);

	environ env;
	golden_bcminer gb;

	task set_rst(bit val);
		gb.rst_i = val;
		rst <= val;
	endtask

	task set_writeValid(bit val);
		gb.writeValid_i = val;
		blkWrt.writeValid <= val;
	endtask

	task set_blockData(bit[7:0] val);
		gb.blockData_i = val;
		blkWrt.blockData <= val;
	endtask

	int tmp = 0;
	task set_inputs();
		set_rst(0);
		set_blockData(tmp);
		tmp = tmp + 1;
		set_writeValid(1);
	endtask

	task print_inputs();
		$display("%t: [rst %b] [writeValid %b] [blockData %d] [readReady %b]", $time, gb.rst_i, gb.writeValid_i, gb.blockData_i, gb.readReady_i);
	endtask

	task print_outputs();
		$display("%t:                                                      [writeReady %b] [resultValid %b] [success %b] [nonce %b] [overflow %b]", $time, gb.writeReady_o, gb.resultValid_o, gb.success_o, gb.nonce_o, gb.overflow_o);
	endtask

	function int verify_outputs();
		int err_count = 0;
		if (gb.writeReady_o != blkWrt.writeReady) begin
			$display(">> DUT writeReady: %b", blkWrt.writeReady);
			err_count += 1;
		end
		if (gb.resultValid_o != resultValid) begin
			$display(">> DUT resultValid: %b", resultValid);
			err_count += 1;
		end
		if (gb.resultValid_o && (gb.success_o != success)) begin
			$display(">> DUT success: %b", success);
			err_count += 1;
		end
		if (gb.nonce_o != nonBufRd.nonce) begin
			$display(">> DUT nonce: %b", nonBufRd.nonce);
			err_count += 1;
		end
		if (gb.overflow_o != nonBufRd.overflow) begin
			$display(">> DUT overflow: %b", nonBufRd.overflow);
			err_count += 1;
		end
		return err_count;
	endfunction

	task do_cycle();
		@(posedge clk)
		gb.cycle();
	endtask

	initial begin
		
		int err_count = 0;
		env = new();
		env.initialize();

		gb = new(
			.rst(0),
			.writeValid(0),
			.blockData(0),
			.readReady(0)
		);
		
		$display("BEGIN TEST");
		$display("* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *");

		set_rst(1);
		do_cycle();

		set_rst(0);
		do_cycle();

		for (int i = 0; i < env.max_cycles; i++) begin
			set_inputs();
			print_inputs();
			do_cycle();
			print_outputs();
			err_count += verify_outputs();
		end

		$display("* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *");
		$display("TEST COMPLETE");
		$display("Errors: %d", err_count);
		if (err_count == 0)
			$display("[ PASS ]");
		else
			$display("[ FAIL ]");
	end

endprogram

		
