
class golden_blockstorage;

	local bit is_reading;
	local int read_index;
	local bit[43:0][7:0] block;

	local bit can_send;
	local int wrt_index;

	function new();
		is_reading = 1;
	endfunction

	function bit isWriteReady();
		return (is_reading && read_index == 0);
	endfunction

	task write_chunk(bit[7:0] chunk);
		if (!is_reading)
			return;

		block[read_index] = chunk;
		read_index += 1;

		if (read_index == 44) begin
			is_reading = 0;
		end

	endtask

	function bit has_data_to_send();
		return (is_reading == 0);
	endfunction

	function bit is_new_block();
		return (is_reading == 0 && wrt_index == 0);
	endfunction

	function bit[351:0] broadcast_data();
		// CheckHasDataToSendB: assert( can_send == 1 );
		wrt_index += 1;
		if (wrt_index == 16) begin	// NOTE: Eventually this will send 2^32 / N times instead of 16
			is_reading = 1;
			read_index = 0;
			wrt_index = 0;
		end
		return block;
	endfunction

endclass
