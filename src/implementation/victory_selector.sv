module victory_selector #(parameter PARTITIONBITS=1) (
    input logic clk,
    input logic victory1,
    input logic[PARTITIONBITS-1:0] nonce_start1,
    processorResultsIfc.reader in2,
    output logic victory_o,
    output logic[PARTITIONBITS-1:0] nonce_start_o
);


    assign victory_o=victory1 || in2.victory;
    assign nonce_start_o=victory1?nonce_start1:in2.nonce_start;

endmodule
