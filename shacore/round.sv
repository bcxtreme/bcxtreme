module sha_round(
input HashState in,
output HashState out,
input logic[31:0] K,
input logic[31:0] W
);

logic[31:0] sum0_tmp;
logic[31:0] sum1_tmp;
logic[31:0] ch_tmp;
logic[31:0] maj_tmp;

logic[31:0] T1;
logic[31:0] T2;

sha_sum0 s0(.x(in.a),.out(sum0_tmp));
sha_sum1 s1(.x(in.e),.out(sum1_tmp));
sha_ch ch(.x(in.e),.y(in.f),.z(in.g),.out(ch_tmp));
sha_maj maj(.x(in.a),.y(in.b),.z(in.c),.out(maj_tmp));

assign T1=in.h+sum1_tmp + ch_tmp + K + W;
assign T2=sum0_tmp+maj_tmp;

assign out.h=in.g;
assign out.g=in.f;
assign out.f=in.e;
assign out.e=in.d+T1;
assign out.d=in.c;
assign out.c=in.b;
assign out.b=in.a;
assign out.a=T1+T2;

endmodule
