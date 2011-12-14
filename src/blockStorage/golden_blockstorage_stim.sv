
module blockStorage_stim();

  bit clk;
  int ticks;
  bit rst;
  blockStoreIfc blkRd();

  wire validOut;
  wire newBlock;
  wire [351:0] initialState;

  //blockStorage test(.clk, .rst, .blkRd, .validOut, .newBlock, .initialState );
  golden_blockstorage test;
  

  string header;


initial begin
  clk = 0;
  rst = 0;
  blkRd.writeValid = 0;
  blkRd.blockData = 0;

  test = new();

  $display( "Stim initialized" );  
  header = "[rst][writeValid][blockData]       [validOut][newBlock]                 ticks|clk             (initialState)";
  $display( header );
        
  $monitor( "    %d           %d        %d                %d         %d           %d|%d\n(%d)", rst, blkRd.writeValid, blkRd.blockData, 
    validOut, newBlock, ticks, clk, initialState );

  #2;
  rst = 1;

  #2;
  rst = 0;

  blkRd.blockData = '1;
  blkRd.writeValid = 1;

  #500;




  $finish;


end


always begin
  #1 clk = ~clk;
end

always @( posedge clk) begin
  ticks = ticks + 1;
  if ( ticks % 5 == 0 )
    $display( header );
end


endmodule : blockStorage_stim
