module sha_super_pipelined_pad_hash(
input logic clk,
input logic rst,
input HashState instate,
input logic valid_i,
input logic newblock_i,
output logic[15:0][31:0] padded,
output logic valid_o,
output logic newblock_o);

ff #(.WIDTH(1)) valid(.clk,.data_i(valid_i),.data_o(valid_o));
ff #(.WIDTH(1)) newblock(.clk,.data_i(newblock_i),.data_o(newblock_o));

//Essentially the message wrapped around, so the bottom is queued up with the next words.
assign padded[0]=instate.a;
assign padded[1]=32'd256;
for(genvar i=2; i<8; i++) begin
   assign padded[i]=32'd0;
end
assign padded[8]=32'h80000000;
assign padded[9]=instate.h;
assign padded[10]=instate.g;
assign padded[11]=instate.f;
assign padded[12]=instate.e;
assign padded[13]=instate.d;
assign padded[14]=instate.c;
assign padded[15]=instate.b;

endmodule
