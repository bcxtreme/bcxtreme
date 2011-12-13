
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
		if (rst_i) begin
			reset();
			return;
		end

		if (writeValid_i) gblock.write_chunk(blockData_i);

		if (gblock.has_data_to_send()) begin
			bit[351:0] raw_data;
			bit new_block;

			new_block = gblock.is_new_block();
			raw_data = gblock.broadcast_data();

			resultValid_o = 1;
			success_o = ^ (raw_data);
		end else begin
			resultValid_o = 0;
			success_o = gblock.tmp_xor;
		end

		writeReady_o = gblock.isWriteReady();
	endtask

endclass


