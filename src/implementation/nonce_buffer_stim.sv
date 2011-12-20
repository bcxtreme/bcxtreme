
module nonce_buffer_stim;

initial $vcdpluson;

bit clk = 0;
int ticks = 0;

logic rst;
logic valid;
logic success;
logic [31:0] nonce_i;
logic readready;

logic valid_o;
logic success_o;
wire nonce_o;
wire  error;

nonce_buffer test( .clk, .rst, .valid, .success, .nonce_i, .readready, .valid_o, .success_o, .nonce_o, .error);

string header;
default clocking cb @(posedge clk);
endclocking
initial begin


  $display( "Direct stim initialized" );  
  header = "[rst] [valid] [success]  [nonce_i] [readready]     [valid_o] [success_o] [nonce_o] [error]         ticks|";
  $display( header );
  
  $monitor( "    %d       %d         %d %d           %d             %b           %b        %d          %d   %d|", rst, valid, success, nonce_i, readready, valid_o, success_o, nonce_o, error, ticks);
  
  clk = 0;
  ticks = 0;
  readready=0;
  rst = 1;
  ##1;
  rst=0;
  nonce_i = 25;
  valid = 1;
  success = 1;

  ##1;
  valid = 0;
  success = 0;

  ##1;


  ##1;
  readready = 1;
  ##1
  readready=0;
  ##1 
  ##35;
  nonce_i = 1258197;
  valid = 1;
  success = 1;
##1
valid=0;
##5
readready=1;
##1;
readready=0;
  ##35;

  $finish; 



end

always begin
 #1 clk = ~clk;
end

always @( posedge clk) begin
  //$display("up, clock = %b", clock );
  ticks = ticks + 1;
end

endmodule : nonce_buffer_stim
