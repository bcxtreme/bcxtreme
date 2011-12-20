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
	parameter PARTITIONBITS = $clog2(NUM_CORES);
	parameter TARGET = BROADCAST_CNT * NUM_CORES;

	wire success_i = rawinput_i.success;
	wire [PARTITIONBITS -1 : 0] processor_index_i = rawinput_i.nonce_prefix;

	logic is_last_reading_new, is_last_reading_old;
	logic is_reading_old, is_reading_new;
	logic[31:0] count_old, count_new;
	logic[31:0] nonce_tmp;
	logic [31:0] validNonce_new, validNonce_old;
	logic success_new, success_old;

	// found_new_nonce: true if we found a valid nonce this cycle
	logic found_new_nonce = success_i & is_reading_old;

	// is_last_reading: 1 when we are reading in the last valid input
	rff #(.WIDTH(1)) last_reading_ff(.clk, .rst, .data_i(is_last_reading_new), .data_o(is_last_reading_old));
	assign is_last_reading_new = is_reading_old ? (count_old == (TARGET - NUM_CORES)) : 0;

	// is_reading: 1 when we receive a newBlock, 0 when we output our result from it
	rff #(.WIDTH(1)) reading_ff(.clk, .rst, .data_i(is_reading_new), .data_o(is_reading_old));
	always_comb begin
		if (newblock_i)
			is_reading_new = 1;
		else if (found_new_nonce)
			is_reading_new = 0;
		else if (is_reading_old)
			is_reading_new = is_reading_old ? count_new < TARGET : 0;
	end
	 
	// count: starts at 0, increments by NUM_CORES for each valid block we receive, resets on newblock
	rff #(.WIDTH(32)) f(.clk,.rst,.data_i(count_new),.data_o(count_old));
	always_comb begin
		if (!valid_i)
			count_new = count_old;
		else if (newblock_i)
			count_new = 0;
		else
			count_new = count_old + NUM_CORES;
	end

	// nonce_tmp: the nonce of the current inputs, possibly
	assign nonce_tmp=count_new + processor_index_i;

	// validNonce: hold the last correct nonce
	rff #(.WIDTH(32)) validNonce_ff(.clk, .rst, .data_i(validNonce_new), .data_o(validNonce_old));
	assign validNonce_new = found_new_nonce ? nonce_tmp : validNonce_old;

	// success: True when we found a bitcoin during this session
	rff #(.WIDTH(1)) success_ff(.clk, .rst, .data_i(success_new), .data_o(success_old));
	assign success_new = is_reading_old & (success_i);

	assign valid_o = is_last_reading_old;
	assign success_o = is_last_reading_old & success_old;
	assign nonce_o = validNonce_old;
endmodule
