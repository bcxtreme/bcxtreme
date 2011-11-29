module enabled_shift_register(
input logic clk,
input logic write_en,
input HashState in,
output logic[31:0] data_o
);

logic[31:0] ffin[8:0];
logic[31:0] ffout[8:0];

for(genvar i=0; i<8; i++) begin
  ff f(.clk,.data_i(ffin[i]),.data_o(ffout[i+1]));
end

assign ffin[0]=write_en?in.a:ffout[1];
assign ffin[1]=write_en?in.b:ffout[2];
assign ffin[2]=write_en?in.c:ffout[3];
assign ffin[3]=write_en?in.d:ffout[4];
assign ffin[4]=write_en?in.e:ffout[5];
assign ffin[5]=write_en?in.f:ffout[6];
assign ffin[6]=write_en?in.g:ffout[7];
assign ffin[7]=write_en?in.h:0;

assign data_o=ffout[0];

endmodule
