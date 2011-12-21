//
module nonce_decoder #(parameter NUM_CORES=10, parameter BROADCAST_CNT=100)
(
	input logic clk,
	input logic rst,
	input logic valid_i,
	input logic newblock_i,
	processorResultsIfc.reader rawinput_i,
	
	output logic valid_o,
	output logic success_o,
	output logic[31:0] nonce_o
);
//States:
//      Inputting: 0/1
//	Outputting: 0/1  (last cycle was the last of a block)

	parameter PARTITIONBITS = $clog2(NUM_CORES);
	parameter TARGET = BROADCAST_CNT * NUM_CORES;

	wire success_i = rawinput_i.success;
	wire [PARTITIONBITS -1 : 0] processor_index_i = rawinput_i.processor_index;

	logic is_reading, was_reading;
	logic[31:0] count_new;
	logic[31:0] count_old;
	//is_reading: 1 when we receive a newBlock, 0 when we output our result from it
	rff #(.WIDTH(1)) reading_ff(.clk, .rst, .data_i(is_reading), .data_o(was_reading));

	always_comb begin
		if(~valid_i)
			is_reading=was_reading;
		else if (newblock_i)
			is_reading = 1;
		else if (was_reading)
			is_reading = (count_new < TARGET);
		else 
			is_reading=0;
	end
	
	logic is_last_of_block;
	logic was_last_of_block;
	assign is_last_of_block= (count_old+NUM_CORES)==TARGET;
	rff #(.WIDTH(1)) lastboflblk_ff(.clk, .rst, .data_i(is_last_of_block), .data_o(was_last_of_block));

	// count: starts at 0, increments by NUM_CORES for each valid block we receive, resets on newblock
	ff #(.WIDTH(32)) f(.clk,.rst,.data_i(count_new),.data_o(count_old));
	always_comb begin
		if (!valid_i)
			count_new = count_old;
		else if (newblock_i)
			count_new = 0;
		else
			count_new = count_old + NUM_CORES;
	end

	// nonce_tmp: the nonce of the current inputs, possibly
	logic[31:0] nonce_tmp;
	assign nonce_tmp=count_new + processor_index_i;

	logic found_new_nonce;

	assign found_new_nonce= is_reading && valid_i && success_i;

	logic[31:0] validNonce_new;
	logic[31:0] validNonce;
	// validNonce: hold the last correct nonce
	rff #(.WIDTH(32)) validNonce_ff(.clk, .rst, .data_i(validNonce_new), .data_o(validNonce));
	assign validNonce_new = found_new_nonce ? nonce_tmp : validNonce;

	logic success;
	logic success_new;
	// success: True when we found a bitcoin during this session
	rff #(.WIDTH(1)) success_ff(.clk, .rst, .data_i(success_new), .data_o(success));

	assign success_new = (is_reading && success_i) || (success && !was_last_of_block);

	assign valid_o = was_last_of_block;
	assign success_o = success;
	assign nonce_o = validNonce;
endmodule
