
class golden_blockstorage;

	local bit write_ready;
	local bit currently_reading;
	local int read_index;
	local bit[43:0][7:0] block;

	local bit can_send;
	local int wrt_index;

	function new();
		write_ready = 1;
	endfunction

	function bit isWriteReady();
		if (write_ready) begin
			currently_reading = 1;
			return 1;
		end
		return 0;
	endfunction

	bit tmp_xor;
	task write_chunk(bit[7:0] chunk);
		if (!currently_reading)
			return;

		tmp_xor ^= (^ chunk);

		$display("[Wrote golden_chunk[%d] = %d (xor: %b) ]", read_index, chunk, (^ chunk) );

		write_ready = 0;
		// CheckBlockStorageIndex: assert( read_index >= 0 && read_index < 44 );
		block[read_index] = chunk;
		read_index += 1;


		if (read_index == 44) begin
			read_index = 0;
			currently_reading = 0;
			can_send = 1;
			wrt_index = 0;
		end

			
	endtask

	function bit has_data_to_send();
		return can_send;
	endfunction

	function bit is_new_block();
		// CheckHasDataToSendA: assert( can_send == 1 );
		return (wrt_index == 0) ? 1 : 0;
	endfunction

	function bit[351:0] broadcast_data();
		// CheckHasDataToSendB: assert( can_send == 1 );
		wrt_index += 1;
		if (wrt_index == 16) begin	// NOTE: Eventually this will send 2^32 / N times instead of 16
			can_send = 0;
			write_ready = 1;
			wrt_index = 0;
			tmp_xor = 0;
		end
		return block;
	endfunction

endclass
