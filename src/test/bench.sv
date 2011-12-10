

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

	task do_cycle();
		@(posedge clk)
		gb.cycle();
	endtask

	initial begin
		
		env = new();
		env.initialize();

		gb = new(
			.rst(0),
			.writeValid(0),
			.blockData(0),
			.readReady(0)
		);
		
		set_rst(1);
		do_cycle();
		set_rst(0);

		set_writeValid(1);

		set_blockData(1);
		do_cycle();
		$display("ResultValid: %b; Success: %b", resultValid, success);

		set_blockData(3);
		do_cycle();
		$display("ResultValid: %b; Success: %b", resultValid, success);

		set_blockData(7);
		do_cycle();
		$display("ResultValid: %b; Success: %b", resultValid, success);

		set_blockData(15);
		do_cycle();
		$display("ResultValid: %b; Success: %b", resultValid, success);

		set_blockData(31);
		do_cycle();
		$display("ResultValid: %b; Success: %b", resultValid, success);

		set_blockData(2);
		do_cycle();
		$display("ResultValid: %b; Success: %b", resultValid, success);
	end
		


endprogram
