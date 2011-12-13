
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




	//
	// writeReady: signal the world when we're ready for a new block
	//
	assign blkRd.writeReady = ((ix_o == 0) && !(accept_data_now && blkRd.writeValid)) || (wrt_o == 15);

	//
	// accept_data_now: True iff writes should be accepted
	//
	always_comb begin
		if (wrt_o == 15 || (!accept_data_now && ix_o == 0)) begin
			accept_data_enable = 1;
			accept_data_next_cycle = 1;
		end else if (ix_o == 44) begin
			accept_data_enable = 1;
			accept_data_next_cycle = 0;
		end else
			accept_data_enable = 0;
	end
		
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
		xor_enable = (accept_data_now && ix_o != 44 && blkRd.writeValid) || (wrt_o == 15);
		xor_i = (wrt_o == 15) ? 0 : ((^ blkRd.blockData) ^ xor_o);
	end
	initial $monitor("[%t] xor_i: %b, xor_o: %b; ix_o: %d", $time, xor_i, xor_o, ix_o);

	//
	// chunk_ix: increment every time we read a chunk. Sit at 44 when we're done until
	//           we're ready for more data.
	//
	always_comb begin
		if (accept_data_now && ix_o != 44) begin
			ix_enable = blkRd.writeValid;
			ix_i = ix_o + 1;
		end else if (wrt_o == 15) begin
			ix_enable = 1;
			ix_i = 0;
		end else
			ix_enable = 0;
	end

	//
	// wrt_ix: increment every time we broadcast the block data, otherwise sit at 0
	//
	always_comb begin
		wrt_enable = (ix_o == 44);
		wrt_i = (wrt_o == 15) ? 0 : wrt_o + 1;
	end

	//
	// validOut: if we can broadcast, we do. So it's the same thing
	//
	assign validOut = (ix_o == 44);

	//
	// newBlock: True when this broadcast is the first of a new block
	// XXX: For now, this will be the XOR result. Change this!
	//
	assign newBlock = xor_o;

endmodule
