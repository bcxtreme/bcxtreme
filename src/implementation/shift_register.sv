module shift_register #(parameter COUNTBITS=6) 
(input logic clk,
input logic write_valid,
input logic read,
input logic[7:0] block_data,
output logic full,
output logic[351:0] out
);
logic shift;
assign shift=write_valid & (~full);

logic[COUNTBITS:0] count;
logic start_counter;
logic inc_counter;
counter #(.WIDTH(COUNTBITS+1)) c(.clk,.inc(inc_counter),.rst(start_counter),.count);

assign inc_counter= shift; 
assign full=count[0];
assign start_counter = read & full;


logic[7:0] ffin[43:0];
logic[7:0] ffout[43:0];
generate
  for(genvar i=0; i<44; i++) begin
    ff #(.WIDTH(8)) f(.clk,.data_i(ffin[i]),.data_o(ffout[i]));
    assign out[352-i*8-1:352-(i+1)*8]=ffout[i];
  end
  
  assign ffin[0]=shift?block_data:ffout[0];
  for(i=1; i<44; i++) begin
    assign ffin[i]=shift?ffout[i-1]:ffout[i];
  end
endgenerate

endmodule
