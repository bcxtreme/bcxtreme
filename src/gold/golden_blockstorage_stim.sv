
module golden_blockstorage_stim();

	golden_blockstorage gb;
	bit isWriteReady;
	bit[7:0] chunk;

	initial begin
		
		gb = new();

		// Check that writeReady is 1
		isWriteReady = gb.isWriteReady();
		$display("Checking isWriteReady: %b", isWriteReady);
		if (isWriteReady != 1) begin
			$display("ERROR: expected writeReady to be 1");
			$exit;
		end

		// Write 43 values of 31. Each time, check can_write is 0
		chunk = 31;
		for (int i = 0; i < 43; i++) begin
			$display("Writing %d...", chunk);
			gb.write_chunk(chunk);
			if (gb.has_data_to_send()) begin
				$display("ERROR: has_data_to_send before 44 chunks were written");
				$exit;
			end
		end

		// Write the 44th value of 3
		$display("Writing %d...", 3);
		gb.write_chunk(3);

		// Check has_data_to_send is now true
		if (!gb.has_data_to_send()) begin
			$display("ERROR: has_data_to_send didn't go high on the 44th write");
			$exit;
		end

		// Check 1st broadcast has is_new_block true, and others are false
		$display("Broadcasting data...");
		if (!gb.is_new_block()) begin
			$display("ERROR: is_new_block wasn't high");
			$exit;
		end
		gb.broadcast_data();

		for (int i = 1; i < 16; i++) begin
			bit[351:0] data;

			// Evil attempt to write
			gb.write_chunk(19);

			if (!gb.has_data_to_send()) begin
				$display("ERROR: has_data_to_send wasn't high at i=%d", i);
				$exit;
			end

			// Evil attempt to write
			gb.write_chunk(20);

			$display("Broadcasting data...");
			if (gb.is_new_block()) begin
				$display("ERROR: is_new_block was high");
				$exit;
			end

			// Evil attempt to write
			gb.write_chunk(21);

			data = gb.broadcast_data();

			// Evil attempt to write
			gb.write_chunk(22);

			$display("Checking isWriteReady: %b", gb.isWriteReady());

		end
			
		// This write should work.
		gb.write_chunk(23);

		// Check that writeReady is 0 again
		isWriteReady = gb.isWriteReady();
		$display("Checking isWriteReady: %b", isWriteReady);
		if (isWriteReady == 1) begin
			$display("ERROR: expected writeReady to be 0 because we just wrote 23");
			$exit;
		end
		
		// Write the remaining chunks
		for (int i = 1; i < 44; i++)
			gb.write_chunk(i);

		// Check we have data to send
		if (!gb.has_data_to_send()) begin
			$display("ERROR: has_data_to_send wasn't high");
			$exit;
		end

		for (int i = 0; i < 16; i++) begin
			bit[43:0][7:0] data;
			data = gb.broadcast_data();
			$display("Checking the broadcast data... [%d]", i);
			for (int j = 1; j < 44; j++) begin
				if (data[j] != j) begin
					$display("ERROR: data[%d] was %d instead of %d", j, data[j], j);
					$exit;
				end
			end
		end
			

		


		
			

	end
endmodule
	
