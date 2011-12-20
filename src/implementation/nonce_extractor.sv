module nonce_extractor #(parameter NUMPROCESSORS=10, parameter NONCESPACE=10,parameter PARTITIONBITS=$clog2(NUMPROCESSORS))
(
	input logic clk,
	input logic rst,
	input logic valid_i,
	input logic newblock_i,
	input logic success_i,
	input logic[PARTITIONBITS-1:0] processor_index_i,
	
	output logic valid_o,
	output logic success_o,
	output logic[31:0] nonce_o
);

	 
	logic[31:0] count_old;
	logic[31:0] count_new;
	ff #(.WIDTH(32)) f(.clk,.data_i(count_new),.data_o(count_old));

	logic[31:0] calculated_count;
	assign count_new=valid_i?count_old:(newblock_i?0:(count_old+NUMPROCESSORS));

	logic[31:0] nonce_tmp;
	assign nonce_tmp=count_new+ processor_index_i;
	
	logic is_valid;
	assign is_valid=(count_new > (NONCESPACE - NUMPROCESSORS))?1:0;

	logic is_success;
	assign is_success = (success_i)?(is_valid?1:0):0;
	
	logic [31:0] nonce_tmp2;
	assign nonce_tmp2 = (success_i)?nonce_tmp:0;

	rff #(.WIDTH(1)) vff(.clk,.rst,.data_i(is_valid),.data_o(valid_o));
	//rff #(.WIDTH(1)) vff(.clk,.rst,.data_i(valid_i),.data_o(valid_o));
	//rff #(.WIDTH(1)) nbff(.clk,.rst,.data_i(newblock_i),.data_o(newblock_o));
	ff #(.WIDTH(1)) sff(.clk,.rst,.data_i(is_success),.data_o(success_o));
	ff #(.WIDTH(32)) nff(.clk,.rst,.data_i(nonce_tmp2),.data_o(nonce_o));
endmodule
