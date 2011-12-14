
class golden_bcminer;


	bit rst_i;
	
	// Block Storage Interface
	bit writeValid_i;
	bit writeReady_o;
	bit[7:0] blockData_i;

	// Result Outputs
	bit resultValid_o;
	bit success_o;

	// Nonce Buffer Interface
	bit readReady_i;
	bit nonce_o;
	bit overflow_o;

	// Golden units
	local golden_blockstorage gblock;

	// Reset the output pins and the internal state
	task reset();
		writeReady_o = 0;
		resultValid_o = 0;
		success_o = 0;
		nonce_o = 0;
		overflow_o = 0;

		gblock = new();
	endtask

	// Simulate a cycle
	task cycle();
		bit newBlock;
		bit validOut;
		bit[351:0] state;

		if (rst_i) begin
			reset();
			return;
		end

		gblock.writeValid_i = writeValid_i;
		gblock.blockData_i = blockData_i;

		gblock.cycle();

		writeReady_o = gblock.writeReady_o;

		validOut = gblock.validOut_o;
		newBlock = gblock.newBlock_o;
		state = gblock.initialState_o;

		resultValid_o = validOut;
		success_o = (^ state);

	endtask

endclass


