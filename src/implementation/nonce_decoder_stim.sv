module nonce_decoder_stim;

bit clk = 0;
int ticks = 0;

logic rst;

logic valid_i, newblock_i, success_o, valid_o;
processorResultsIfc #(.PARTITIONBITS(4)) rawinput(clk);
logic [31:0] nonce_o;

nonce_decoder #(.BROADCAST_CNT(5), .NUM_CORES(4)) test(
	.clk,
	.rst,
	.valid_i,
	.newblock_i,
	.rawinput_i(rawinput.reader),
	.valid_o,
	.success_o,
	.nonce_o
);

string header;

initial begin
  $vcdpluson;
  rawinput.nonce_prefix = 5;
  rawinput.success = 0;

  $display( "Direct stim initialized" );  
  header = "[rst] [valid_i] [newblock_i]  [success_i] [nonce_prefix_i]      [valid_o] [success_o]  [nonce_o]       ticks|clock";
  $display( header );
  $monitor( "    %d       %d         %d            %d           %d              %d          %d   %d|%d",
            rst, valid_i, newblock_i, rawinput.success, rawinput.nonce_prefix, valid_o, success_o, nonce_o, ticks, clk );
  
  clk = 0;
  ticks = 0;
  rst = 1;
  #2
  rst = 0;
  valid_i = 0;
  newblock_i = 0;
  rawinput.success = 0;

  #6;
  
  valid_i = 1;
  newblock_i = 1;

  #1

  newblock_i = 0;

  #30

  valid_i = 0;

  #4

  $finish; 



end

always begin
 #1 clk = ~clk;
end

always @( posedge clk) begin
  //$display("up, clock = %b", clock );
  ticks = ticks + 1;
end

endmodule : nonce_decoder_stim
