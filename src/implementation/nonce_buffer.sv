// if I did not manage to clock out nonce before the next valid & success then overflow is high until next reset

module nonce_buffer (
	input clk,
	input rst,
	input valid,
	input success,
	input [31:0] nonce_i,
	input readready,

	output logic nonce_o,
	output logic overflow
);


wire[31:0] stored_nonce_output;

logic[31:0] next_nonce_bit_to_output_i;
logic[31:0] next_nonce_bit_to_output_o;

logic enable_write_to_stored_nonce;

// internally stored nonce value
eff #(32) stored_nonce (.clk, .rst, .enable( enable_write_to_stored_nonce ), .data_i( nonce_i ), .data_o( stored_nonce_output ) );

// stores a bit that moves along 
rff #(32) nonce_bit_being_clocked(.clk, .rst, .data_i(next_nonce_bit_to_output_i), .data_o(next_nonce_bit_to_output_o) ); 

logic _readready;
ff #(1) ff_readready(.clk, .data_i(readready), .data_o(_readready) ); 


// on each successive clock tick move the nonce_being_clocked position by 1 by shifting input to nonce_bit_being_clocked by 1 
always_comb begin
  if ( valid && success ) 
    next_nonce_bit_to_output_i = 1;
  else
    if ( _readready )
      if ( next_nonce_bit_to_output_o[31] != 1 )
        next_nonce_bit_to_output_i = next_nonce_bit_to_output_o << 1;
    else
      next_nonce_bit_to_output_i = 1;
end

// overflow goes high (and stays high until next reset) if asked to write new nonce to store before the entire previous once has been clocked out
always_comb begin
  if ( rst ) 
    overflow = 0;
  else
    if ( valid && success )
      if ( next_nonce_bit_to_output_o[31] != 1 && next_nonce_bit_to_output_o == 1 )
        overflow = 1;
      else
        overflow = 0;
end

assign nonce_o = ( ( | ( next_nonce_bit_to_output_o & stored_nonce_output ) ) && _readready );

assign enable_write_to_stored_nonce = ( valid && success ) ? 1 : 0;

always @( posedge clk ) begin
  //$display( "%d", next_nonce_bit_to_output_o );
end

// if valid & success are both high then write 1 to next_nonce_bit_to_output_i

// after first reset he is empty

// listen on valid & success

// waits until both high on clockedge

//   whatever on nonce_i, store inside

// hold onto until next both high then do the smae








/*

logic[31:0] stored_nonce;
logic[31:0] nonce_to_store;

logic write;
assign write=valid && success;

logic shift;
assign shift=readready;
generate
  for(genvar i=0; i<32; i++) begin
    ff #(.WIDTH(1)) f(.clk,.data_i(nonce_to_store[i]),.data_o(stored_nonce[i]));
  end
  for(i=0; i<31; i++) begin
    assign nonce_to_store[i]=shift?stored_nonce[i+1]:(write ? nonce_i[i] : stored_nonce[i]);
  end
  assign nonce_to_store[31]=shift?stored_nonce[0]:(write?nonce_i[31]:stored_nonce[31]);
endgenerate

logic[5:0] count;
logic[5:0] next_count;
logic counting;
logic will_be_counting;

ff #(.WIDTH(5)) ct(.clk,.data_i(next_count),.data_o(count));
assign next_count= readready ? 1 : (counting ? (count+1'd1) : count );

ff #(.WIDTH(1)) c(.clk,.data_i(will_be_counting),.data_o(counting));
assign will_be_counting=readready | (counting && (count!=0));


logic nonce_new;
logic nonce_will_be_new;
ff #(.WIDTH(1)) n(.clk,.data_i(nonce_will_be_new),.data_o(nonce_new));

assign nonce_will_be_new= ( (write && ~counting) | nonce_new) && ~readready;

assign nonce_o = stored_nonce[0];

assign overflow= (counting |nonce_new) & write;

assign newnonce=nonce_new;

*/

endmodule
