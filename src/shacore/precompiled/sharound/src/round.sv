module sha_round #(parameter PIPELINE_DEPTH=1) (
input logic clk,
input HashState in,
output HashState out,
input logic[31:0] K,
input logic[31:0] W
);

logic[31:0] sum0_tmp;
logic[31:0] sum1_tmp;
logic[31:0] ch_tmp;
logic[31:0] maj_tmp;

sha_sum0 s0(.x(in.a),.out(sum0_tmp));
sha_sum1 s1(.x(in.e),.out(sum1_tmp));
sha_ch ch(.x(in.e),.y(in.f),.z(in.g),.out(ch_tmp));
sha_maj maj(.x(in.a),.y(in.b),.z(in.c),.out(maj_tmp));


logic[31:0] T1;
logic[31:0] T2;

logic[31:0] a;
logic[31:0] e;

sha_aADDER aad(.h(in.h),.sum1(sum1_tmp),.ch(ch_tmp),.K,.W,.sum0(sum0_tmp),.maj(maj_tmp),.a);

sha_eADDER ead(.d(in.d),.h(in.h),.sum1(sum1_tmp),.ch(ch_tmp),.K,.W,.e);


HashState resbuff[PIPELINE_DEPTH:0];

assing resbuff[0].h=in.g;
assing resbuff[0].g=in.f;
assing resbuff[0].f=in.e;
assing resbuff[0].e=e;
assing resbuff[0].d=in.c;
assing resbuff[0].c=in.b;
assing resbuff[0].b=in.a;
assing resbuff[0].a=a;


generate
	for(genvar i=0; i<PIPELINE_DEPTH; i++) begin
		HashStateFF(.clk,.in(resbuff[i]),.out(resbuff[i+1]);
	end
endgenerate

assign out=resbuf[PIPELINE_DEPTH];


//assign T1=in.h+sum1_tmp+ch_tmp+K+W;
//assign T2=sum0_tmp+maj_tmp;
//assign out.h=in.g;
//assign out.g=in.f;
//assign out.f=in.e;
//assign out.e=in.d+T1;
//assign out.d=in.c;
//assign out.c=in.b;
//assign out.b=in.a;
//assign out.a=T1+T2;

endmodule
