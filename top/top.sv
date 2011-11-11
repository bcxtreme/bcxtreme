module top();

logic clk;
logic rst;
logic[31:0] M;
HashState hash;

sha_simple_core s(.clk,.rst,.M,.hash);

initial $vcdpluson;

initial begin
  clk=0;
  rst=1;
  //W0
  M=32'h61626364;
  #1 clk=1;
  #1 clk=0;
  #1 clk=1;
  #1 clk=0;
  rst=0;
  //W1
  M=32'h62636465;
  #1 clk=1;
  #1 clk=0;
  M=32'h63646566;
  #1 clk=1;
  #1 clk=0;
  M=32'h64656667;
  #1 clk=1;
  #1 clk=0;
  M=32'h65666768;
  #1 clk=1;
  #1 clk=0;
  M=32'h66676869;
  #1 clk=1;
  #1 clk=0;
  M=32'h6768696a;
  #1 clk=1;
  #1 clk=0;
  M=32'h68696a6b;
  #1 clk=1;
  #1 clk=0;
  M=32'h696a6b6c;
  #1 clk=1;
  #1 clk=0;
  M=32'h6a6b6c6d;
  #1 clk=1;
  #1 clk=0;
  M=32'h6b6c6d6e;
  #1 clk=1;
  #1 clk=0;
  M=32'h6c6d6e6f;
  #1 clk=1;
  #1 clk=0;
  M=32'h6d6e6f70;
  #1 clk=1;
  #1 clk=0;
  M=32'h6e6f7071;
  #1 clk=1;
  #1 clk=0;
  M=32'h80000000;
  #1 clk=1;
  #1 clk=0;
  M=32'h00000000;
  #1 clk=1;
  #1 clk=0;
  for(int i=16; i<64; i++) begin
    #1 clk=1;
    #1 clk=0;
  end
  //W0 through W14
  M=32'h0;
  for(int i=0; i<15; i++) begin
    #1 clk=1;
    #1 clk=0;
  end
  //W15
  M=32'h000001c0;
  #1 clk=1;
  #1 clk=0;
  //W16 through W63
  for(int i=16; i<64; i++) begin
    #1 clk=1;
    #1 clk=0;
  end
  #1 $display("%x%x%x%x%x%x%x%x",hash.a,hash.b,hash.c,hash.d,hash.e,hash.f,hash.g,hash.h);
end
endmodule
