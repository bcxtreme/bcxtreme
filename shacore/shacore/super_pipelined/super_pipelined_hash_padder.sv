module sha_supper_pipelined_pad_hash(
input logic clk,
input logic rst,
input HashState instate,
input logic valid_i,
input logic newblock_i,
output logic[31:0] padded[15:0],
output logic valid_o,
output logic newblock_o);

ff #(.WIDTH(1)) valid(.clk,.data_i(valid_i),.data_o(valid_o));
ff #(.WIDTH(1)) newblock(.clk,.data_i(newblock_i),.data_o(newblock_o));

assign padded[0]=instate.a;
assign padded[1]=instate.b;
assign padded[2]=instate.c;
assign padded[3]=instate.d;
assign padded[4]=instate.e;
assign padded[5]=instate.f;
assign padded[6]=instate.g;
assign padded[7]=instate.h;
assign padded[8]=32'h80000000;
for(int i=9; i<15; i++) begin
   assign padded[i]=32'd0;
end
assign padded[15]=32'd256;//The size of the message in bits

endmodule
