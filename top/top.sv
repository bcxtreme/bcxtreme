module top();

logic clk;
logic rst;
logic input_valid;
logic newblock_i;
logic[31:0] w1;
logic[31:0] w2;
logic[31:0] w3;
HashState round1;

logic newblock_o;
logic output_valid;
HashState doublehash;



sha_super_pipelined_core sp(.clk,.rst,.input_valid,.newblock_i,.round1,. w1,.w2,.w3,.output_valid,.newblock_o,.doublehash);

initial $vcdpluson;

initial begin
  clk=0;
  rst=0;
  input_valid=1;
  newblock_i=1;
  w1=32'hf1fc122b;
  w2=32'hc7f5d74d;
  w3=32'hf2b9441a;
  round1.a=32'h9524c593;
  round1.b=32'h05c56713;
  round1.c=32'h16e669ba;
  round1.d=32'h2d2810a0;
  round1.e=32'h07e86e37;
  round1.f=32'h2f56a9da;
  round1.g=32'hcd5bce69;
  round1.h=32'h7a78da2d;
  clk=1;#1
  clk=0; #1
  newblock_i<=0;
  for(int i=0; i<1000; i++) begin
  clk=1;
  #1 $display("%x%x%x%x%x%x%x%x",doublehash.a,doublehash.b,doublehash.c,doublehash.d,
                                 doublehash.e,doublehash.f,doublehash.g,doublehash.h);
  clk=0; #1;
  end
end


endmodule
