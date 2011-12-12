
module blockStorage
(
	input clk,
	input rst,
	blockStoreIfc.reader blkRd,
	output logic validOut,
	output newBlock,
	output [351:0] initialState
);
	logic block_enable, accept_data_enable, ix_enable, wrt_enable;
	logic accept_data_next_cycle, accept_data_now;
	logic[7:0] ix_i, ix_o;
	logic[31:0] wrt_i, wrt_o;
	logic[351:0] block_i, block_o;

	// XXX: This must be removed eventually, once block data can be read in normally
	logic xor_enable, xor_i, xor_o;
	ff xor_of_block(
		.clk,
		.rst,
		.enable(xor_enable),
		.data_i(xor_i),
		.data_o(xor_o)
	);

	// is_accepting: True when we are accepting block data to be read.
	ff is_accepting(
		.clk,
		.rst,
		.enable(accept_data_enable),
		.data_i(accept_data_next_cycle),
		.data_o(accept_data_now)
	);

	// block: Store the block data
	ff #(.WIDTH(352)) block(
		.clk,
		.rst,
		.enable(block_enable),
		.data_i(block_i),
		.data_o(block_o)
	);

	// chunk_ix: the current chunk of the block we need to read in
	ff #(.WIDTH(8)) chunk_ix(
		.clk,
		.rst,
		.enable(ix_enable),
		.data_i(ix_i),
		.data_o(ix_o)
	);

	// wrt_ix: the current iteration of sending block data
	ff #(.WIDTH(32)) wrt_ix(
		.clk,
		.rst,
		.enable(wrt_enable),
		.data_i(wrt_i),
		.data_o(wrt_o)
	);

	logic need_new_block, can_broadcast, need_data, last_broadcast, currently_accepting_data;

	assign need_new_block = (ix_o == 0);
	assign can_broadcast = (ix_o == 44);

	assign need_data = !can_broadcast;
	assign last_broadcast = (wrt_o == 15);

	initial $monitor("**: chunk_ix: %d; wrt_ix: %d", ix_o, wrt_o);




	//
	// writeReady: signal the world when we're ready for a new block
	//
	assign blkRd.writeReady = (need_new_block && !accept_data_enable) || last_broadcast || (need_new_block && !currently_accepting_data);

	//
	// accept_data_now: True iff writes should be accepted
	//
	always_comb begin
		if (need_new_block) begin
			accept_data_enable = 1;
			accept_data_next_cycle = 1;
		end else if (can_broadcast) begin
			accept_data_enable = 1;
			accept_data_next_cycle = 0;
		end
	end
		
	//
	// currently_accepting_data: True when we previously sent the writeReady signal, and the writeValid is happening,
	//                           and we still have space to write the data
	//
	assign currently_accepting_data = accept_data_now && blkRd.writeValid;

	//
	// block: Read in data into the block if necessary
	//
	always_comb begin
		if (accept_data_now) begin
			// TODO: Read data into block here
		end
	end

	//
	// xor: keep track of XOR of block
	// XXX: eventually delete this!
	//
	always_comb begin
		if (currently_accepting_data) begin
			xor_enable = 1;
			xor_i = (^ blkRd.blockData) ^ xor_o;
		end else if (last_broadcast) begin
			xor_enable = 1;
			xor_i = 0;
		end else
			xor_enable = 0;
	end

	//
	// chunk_ix: increment every time we read a chunk. Sit at 44 when we're done until
	//           we're ready for more data.
	//
	always_comb begin
		if (currently_accepting_data && need_data) begin
			ix_enable = 1;
			ix_i = ix_o + 1;
		end else if (last_broadcast) begin
			ix_enable = 1;
			ix_i = 0;
		end else
			ix_enable = 0;
	end

	//
	// wrt_ix: increment every time we broadcast the block data, otherwise sit at 0
	//
	always_comb begin
		wrt_enable = can_broadcast;
		wrt_i = last_broadcast ? 0 : wrt_o + 1;
	end

	//
	// validOut: if we can broadcast, we do. So it's the same thing
	//
	assign validOut = can_broadcast;

	//
	// newBlock: True when this broadcast is the first of a new block
	// XXX: For now, this will be the XOR result. Change this!
	//
	assign newBlock = xor_o;

endmodule
