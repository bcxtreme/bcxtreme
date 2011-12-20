
class golden_blockstorage #(parameter LOG2_BROADCAST_CNT = 6);

	// Block Storage Interface
	bit writeValid_i;
	bit[7:0] blockData_i;
	bit writeReady_o;

	// Broadcast Interface
	bit validOut_o;
	bit newBlock_o;
	bit[351:0] initialState_o;
	
	// Buffers for storing block data
	local bit[43:0][7:0] bufA;
	local bit[43:0][7:0] bufB;

	// Misc internal state
	local int bufA_next;	// points to first available chunk in bufA, or 44 if it's full
	local int bufB_broadcast_cnt;
	local bit force_write_ready;

	// Constants
	local int bufB_broadcast_max = 2 ** LOG2_BROADCAST_CNT;
	local int bufB_broadcast_last = 2 ** LOG2_BROADCAST_CNT - 1;
	
	
	function new();
		// Initialize by saying bufB has already been broadcast, so we don't send out junk
		bufB_broadcast_cnt = bufB_broadcast_max;
		force_write_ready = 1;
		bufA_next=43;
	endfunction

	task advance_buffers();
		if ((bufB_broadcast_cnt == bufB_broadcast_max) && (bufA_next == -1)) begin
			bufB = bufA;
			bufB_broadcast_cnt = 0;

			bufA = 0;
			bufA_next = 43;

			// Force writeReady to be high on this cycle
			force_write_ready = 1;
		end
	endtask

	task try_write_chunk(bit[7:0] chunk);
		if (bufA_next >=0) begin
			bufA[bufA_next] = chunk;
			//$display("Wrote chunk %x to %d now we have %x",chunk, bufA_next,bufA);
			bufA_next--;
		end
	endtask


	task try_do_broadcast();
		if (bufB_broadcast_cnt < bufB_broadcast_max) begin
			// bufB still needs to be broadcast
			validOut_o = 1;
			newBlock_o = (bufB_broadcast_cnt == 0);
			initialState_o = bufB;
			//$display("Broadcasting: %x",initialState_o);
			bufB_broadcast_cnt++;
		end else begin
			// No broadcast
			validOut_o = 0;
			newBlock_o = 0;
			initialState_o = 0;
		end
	endtask

	function bit is_write_ready();
		// WriteReady should be on whenever we are ready to accept data
		// and go off on the cycle that we accept the first chunk.
		// However, it must be on for at least one cycle.
		if (force_write_ready || (bufA_next == 43)) begin
			force_write_ready = 0;
			return 1;
		end
		return 0;
	endfunction
	
	task cycle();


		try_do_broadcast();
		advance_buffers();

		writeReady_o = is_write_ready();
		if (writeValid_i)
			try_write_chunk(blockData_i);

	endtask
endclass

