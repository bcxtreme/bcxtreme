interface processorResultsIfc #(parameter PARTITIONBITS=6) (input logic clk);
logic success;
logic[PARTITIONBITS-1:0] nonce_prefix;

modport writer(output success, output nonce_prefix);
modport reader(input success, input nonce_prefix);
endinterface
