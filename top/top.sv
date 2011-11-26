module top();

logic clk;
logic rst;
logic[31:0] M;
logic input_valid;
logic hash_valid;
HashState hash;

sha_simple_core s(.clk,.rst,.M,.hash,.input_valid,.hash_valid);

initial $vcdpluson;

initial begin
  clk=0;
  rst=1;
  //W0
  M=32'h68656c6c;
  #1 clk=1;
  #1 clk=0;
  #1 clk=1;
  #1 clk=0;
  rst=0;
  //W1
  M=32'h6f800000;
  #1 clk=1;
  #1 clk=0;
  M=0;
  for(int i=2; i<15; i++) begin
    #1 clk=1;
    #1 clk=0;
  end
  M=32'h00000028;
  #1 clk=1;
  #1 clk=0;
  for(int i=16; i<64; i++) begin
    #1 clk=1;
    #1 clk=0;
  end

  #1 $display("%x%x%x%x%x%x%x%x",hash.a,hash.b,hash.c,hash.d,hash.e,hash.f,hash.g,hash.h);
end
endmodule
