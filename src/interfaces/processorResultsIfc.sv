interface processorResultsIfc #(parameter PARTITIONBITS=6) (input logic clk);
logic victory;
logic[PARTITIONBITS-1:0] nonce_start;

modport writer(output victory, output nonce_start);
modport reader(input victory, input nonce_start);
endinterface
