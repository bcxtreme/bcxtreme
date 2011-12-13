module bxctreme_standard_processor #(parameter PARTITIONBITS=1, parameter PROCESSSORNUMBER) (
input logic clk,
input logic rst,
//From previous processor inputs
input logic valid_i,
input logic newblock_i,
input HashState hashstate_i,
input logic[2:0][31:0] Words_i,
//To next processor inputs
output logic valid_o,
output logic newblock_o,
output HashState hashstate_o,
output logic[2:0][31:0] Words_o,
//From previous processor outputs
input logic victory_i,
input logic[PARTITIONBITS-1:0] nonce_start_i,
//To next processor outputs
output logic victory_o,
output logic[PARTITIONBITS-1:0] nonce_start_o
);

//Processing pipline.
HashState oh;
sha_standard_pipelined_core core(.clk,.rst,input_valid(valid_i),.newblock_i,.round1(hashstate_i),.w1(Words_i[0]),.w2(Words_i[1]),.w3(Words_i[2]),.doublehash(oh));

logic success;
standard_hash_validator hv(.clk, .hash({oh.a,oh.b,oh.c,oh.d,oh.e,oh.f,oh.g,oh.h}),.difficulty(Words_i[2]),.success);


//Muxing the previous results
logic victory;
logic[PARTITIONBITS-1:0] nonce_start
victory_selector #(.PARTITIONBITS(PARTITIONBITS)) vs(.clk,.victory1(success),.nonce_start1(PROCESSORNUMBER),.victory2(victory_i),.nonce_start2(nonce_start_i),.victory_o(victory), nonce_start_o(nonce_start));

ff #(.WIDTH(1)) viff(.clk,.data_i(success),.data_o(victory_o));
ff #(.WIDTH(PARTITIONBITS)) nsff(.clk,.data_i(nonce_start),.data_o(nonce_start_o));


//Passthroughs at the beginning.
HashStateFF hsff(.clk,.in(hashstate_i),.out(hashstate_o));
ff #(.WIDTH(96)) wff(.clk,.data_i(Words_i),.data_o(Words_o));
ff #(.WIDTH(1)) vaff(.clk,.data_i(valid_i),.data_o(valid_o));
ff #(.WIDTH(1)) nbff(.clk,.newblock_i(newblock_i),.data_o(newblock_o));



endmodule
