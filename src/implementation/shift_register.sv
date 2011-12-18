module shift_register #(parameter MAXELEMENTS=44,parameter COUNTBITS=7) 
(input logic clk,
input logic rst,
input logic write_valid,
input logic read,
input logic[7:0] block_data,
output logic full,
output logic write_ready,
output logic[351:0] out
);
logic shift;
//We accept input under two conditions: we are not full and we are being written, and we are being read and written at the same time
assign shift=write_valid & (~full | read);

logic start_counter;

logic[COUNTBITS-1:0] count;
logic[COUNTBITS-1:0] next_count;
ff #(.WIDTH(COUNTBITS)) c(.clk,.data_i(rst?1'd0:next_count),.data_o(count));
assign next_count=(start_counter?1'd0:count)+shift;

assign full=(count==MAXELEMENTS);
assign start_counter = (read & full);

assign write_ready= start_counter | (count==0);

logic[7:0] ffin[43:0];
logic[7:0] ffout[43:0];
generate
  for(genvar i=0; i<44; i++) begin
    ff #(.WIDTH(8)) f(.clk,.data_i(ffin[i]),.data_o(ffout[i]));
    assign out[(i+1)*8-1 -:8]=ffout[i];
  end
  
  assign ffin[0]=shift?block_data:ffout[0];
  for(i=1; i<44; i++) begin
    assign ffin[i]=shift?ffout[i-1]:ffout[i];
  end
endgenerate

endmodule
