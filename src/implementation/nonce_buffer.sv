// if I did not manage to clock out nonce before the next valid & success then overflow is high until next reset

module nonce_buffer (
	input logic clk,
	input logic rst,
 	input logic valid,
	input logic success,
	input logic[31:0] nonce_i,

//Victory Status Interface
	output logic valid_o,
	output logic success_o,
//Nonce output interface
	input logic readready,
	output logic nonce_o,
	output logic error
);


wire[31:0] stored_nonce;

logic enable_write_to_stored_nonce;

assign enable_write_to_stored_nonce = ( valid && success );

// internally stored nonce value
eff #(32) stored_nonceff (.clk, .rst, .enable( enable_write_to_stored_nonce ), .data_i( nonce_i ), .data_o( stored_nonce ) );

logic[31:0] output_mask;
logic[31:0] next_output_mask;
ff #(32) omask(.clk,.data_i(next_output_mask),.data_o(output_mask));

always_comb begin
	if(rst) begin
		next_output_mask=32'd1;
	end else if(readready) begin
		next_output_mask=(1<<1);
	end else if(output_mask!=1) begin
		next_output_mask=(output_mask<<1) | (output_mask >>31);  //Rotated left by 1.
	end else next_output_mask=output_mask;
end

logic[31:0] masked;

assign masked =output_mask & stored_nonce;
assign nonce_o = | ( output_mask & stored_nonce ) ;

rff #(1) valid_ff(.clk,.rst,.data_i(valid),.data_o(valid_o));
ff #(1) success_ff(.clk,.data_i(success),.data_o(success_o));

logic full;
logic next_full;
rff #(1) fullff(.clk,.rst,.data_i(next_full),.data_o(full));

always_comb begin
	if(full) begin
		next_full=(output_mask==1) || next_output_mask!=1;
	end else begin
		next_full=enable_write_to_stored_nonce;
	end
end
logic errored;
logic next_errored;

rff #(1) err(.clk,.rst,.data_i(next_errored),.data_o(errored));

logic overflow;
assign overflow=(enable_write_to_stored_nonce & full);

logic underflow;
assign underflow=readready && (output_mask!=1);

assign next_errored=errored | overflow | underflow;

assign error=errored;

// if valid & success are both high then write 1 to next_nonce_bit_to_output_i

// after first reset he is empty

// listen on valid & success

// waits until both high on clockedge

//   whatever on nonce_i, store inside

// hold onto until next both high then do the smae


endmodule
