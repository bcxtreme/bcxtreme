module nonce_buffer (
input logic clk,
input logic valid,
input logic success,
input logic[31:0] nonce_i,
input logic read,
output logic newnonce,
output logic nonce_o,
output logic overflow);

logic[31:0] stored_nonce;
logic[31:0] nonce_to_store;

logic write;
assign write=valid && success;

logic shift;
assign shift=read;
generate
  for(genvar i=0; i<32; i++) begin
    ff #(.WIDTH(1)) f(.clk,.data_i(nonce_to_store[i]),.data_o(stored_nonce[o]));
  end
  for(i=0; i<31; i++) begin
    assign nonce_to_store[i]=shift?stored_nonce[i+1]:(write?nonce[i]:stored_nonce[i]);
  end
  assign nonce_to_store[31]=shift?stored_nonce[0]:(write?nonce[31]:stored_nonce[31]);
end

logic[5:0] count;
logic[5:0] next_count;
ff #(.WIDTH(5)) ct(.clk,.data_i(next_count),.data_o(count));
assign next_count=read?1:(counting?(count+1'd1));

logic counting;
logic will_be_counting;

ff #(.WIDTH(1)) c(.clk,.data_i(will_be_counting),.data_o(counting));
assign will_be_counting=read | (counting && (count!=0));


logic nonce_new;
logic nonce_will_be_new;
ff #(.WIDTH(1)) n(.clk,.data_i(nonce_will_be_new),.data_o(nonce_was_new));

assign nonce_will_be_new=((write && ~counting) | nonce_new) && ~read);

assign nonce_o=stored_nonce_[0];

assign overflow= (counting |nonce_new) & write;

assign newnonce=nonce_new;
endmodule
