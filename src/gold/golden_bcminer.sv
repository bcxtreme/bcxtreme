
class golden_bcminer;


	bit rst_i;

	bit writeValid_i;
	bit writeReady_o;
	bit[7:0] blockData_i;

	bit resultValid_o;
	bit success_o;

	bit readReady_i;
	bit nonce_o;
	bit overflow_o;

	// Reset the output pins and the internal state
	task reset();
		writeReady_o = 1;
		resultValid_o = 0;
		success_o = 0;
		nonce_o = 0;
		overflow_o = 0;
	endtask

	// Simulate a cycle
	task cycle();
		if (rst_i) begin
			reset();
			return;
		end

		resultValid_o = writeValid_i;
		success_o = ^ (blockData_i);
	endtask

endclass


