module bxctreme_final_processor #(parameter PARTITIONBITS=1, parameter PROCESSSORNUMBER) (
input logic clk,
input logic rst,
//From previous processor inputs
input logic valid_i,
input logic newblock_i,
input HashState hashstate_i,
input logic[2:0][31:0] Words_i,
//From previous processor outputs
input logic victory_i,
input logic[PARTITIONBITS-1:0] nonce_start_i,
//To noncebuffer
output logic valid_final
output logic newblock_final,
output logic victory_final,
output logic[PARTITIONBITS-1:0] nonce_start_final
);

//Processing pipline.
HashState oh;
logic ov;
logic nb;
sha_last_pipelined_core core(.clk,.rst,input_valid(valid_i),.newblock_i,.output_valid(ov),.newblock_o(nb),.round1(hashstate_i),.w1(Words_i[0]),.w2(Words_i[1]),.w3(Words_i[2]),.doublehash(oh));

logic success;
logic hvv;
logic hvnb;
final_hash_validator hv(.clk, .hash({oh.a,oh.b,oh.c,oh.d,oh.e,oh.f,oh.g,oh.h}),.valid_i(ov),.valid_o(hvv),.newblock_i(nv),.newblock_o(hvnb),.difficulty(Words_i[2]),.success);


//Muxing the previous results
logic victory;
logic[PARTITIONBITS-1:0] nonce_start
victory_selector #(.PARTITIONBITS(PARTITIONBITS)) vs(.clk,.victory1(success),.nonce_start1(PROCESSORNUMBER),.victory2(victory_i),.nonce_start2(nonce_start_i),.victory_o(victory), nonce_start_o(nonce_start));

ff #(.WIDTH(1)) vaff(.clk,.data_i(hvv),.data_o(valid_final));
ff #(.WIDTH(1)) nbff(.clk,.data_i(hvnb),.data_o(newblock_final));
ff #(.WIDTH(1)) viff(.clk,.data_i(success),.data_o(victory_final));
ff #(.WIDTH(PARTITIONBITS)) nsff(.clk,.data_i(nonce_start),.data_o(nonce_start_final));


endmodule
