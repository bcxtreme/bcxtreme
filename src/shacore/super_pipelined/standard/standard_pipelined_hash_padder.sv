module sha_standard_pipelined_pad_hash(
	input logic clk,
	input HashState instate,
	output logic[15:0][31:0] padded
);

HashState ffed;
HashStateFF hsff(.clk, .in(instate), .out(ffed));

//Essentially the message wrapped around, so the bottom is queued up with the next words.
assign padded[0]=ffed.a;
assign padded[1]=32'd256;
for(genvar i=2; i<8; i++) begin
   assign padded[i]=32'd0;
end
assign padded[8]=32'h80000000;
assign padded[9]=ffed.h;
assign padded[10]=ffed.g;
assign padded[11]=ffed.f;
assign padded[12]=ffed.e;
assign padded[13]=ffed.d;
assign padded[14]=ffed.c;
assign padded[15]=ffed.b;

endmodule
