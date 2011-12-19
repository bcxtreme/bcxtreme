
module nonce_buffer_stim;

bit clk = 0;
int ticks = 0;

logic rst;
logic valid;
logic success;
logic [31:0] nonce_i;
logic readready;

wire nonce_o;
wire overflow;

nonce_buffer test( .clk, .rst, .valid, .success, .nonce_i, .readready, .nonce_o, .overflow );

string header;

initial begin


  $display( "Direct stim initialized" );  
  header = "[rst] [valid] [success]  [nonce_i] [readready]      [nonce_o] [overflow]         ticks|clock";
  $display( header );
  
  $monitor( "    %d       %d         %d %d           %d              %d          %d   %d|%d", rst, valid, success, nonce_i, readready, nonce_o, overflow, ticks, clk );
  
  clk = 0;
  ticks = 0;
  rst = 0;

  #2;
  nonce_i = 25;
  valid = 1;
  success = 1;


  #2;
  valid = 0;
  success = 0;

  #2;


  #2;
  readready = 1;

  #15;


  #2;
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
