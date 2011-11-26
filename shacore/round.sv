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

//logic[31:0] sum0_out;
//logic[31:0] sum1_out;
//logic[31:0] ch_out;
//logic[31:0] maj_out;

//ff #(.WIDTH(32)) fs0(.clk,.data_i(sum0_tmp),.data_o(sum0_out));
//ff #(.WIDTH(32)) fs1(.clk,.data_i(sum1_tmp),.data_o(sum1_out));
//ff #(.WIDTH(32)) fch(.clk,.data_i(ch_tmp),.data_o(ch_out));
//ff #(.WIDTH(32)) fmaj(.clk,.data_i(maj_tmp),.data_o(maj_out));


sha_sum0 s0(.x(in.a),.out(sum0_tmp));
sha_sum1 s1(.x(in.e),.out(sum1_tmp));
sha_ch ch(.x(in.e),.y(in.f),.z(in.g),.out(ch_tmp));
sha_maj maj(.x(in.a),.y(in.b),.z(in.c),.out(maj_tmp));


logic[31:0] T1;
logic[31:0] T2;

sha_aADDER aad(.h(in.h),.sum1(sum1_tmp),.ch(ch_tmp),.K,.W,.sum0(sum0_tmp),.maj(maj_tmp),.a(out.a));
sha_eADDER ead(.d(in.d),.sum0(sum0_tmp),.maj(maj_tmp),.e(out.e));

//assign T1=in.h+sum1_tmp+ch_tmp+K+W;
//assign T2=sum0_tmp+maj_tmp;

assign out.h=in.g;
assign out.g=in.f;
assign out.f=in.e;
//assign out.e=in.d+T1;
assign out.d=in.c;
assign out.c=in.b;
assign out.b=in.a;
//assign out.a=T1+T2;

endmodule
