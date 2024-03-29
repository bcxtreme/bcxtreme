//Pipelined double hash implementation.
module sha_simple_doublehash(
input logic clk,
input logic rst,
input logic[31:0] M,
output logic input_valid,
output HashState hash,
output logic hash_valid
);

logic core1done;
HashState core1result;

sha_simple_core core1(.clk,.rst,.M,.hash(core1result),.hash_valid(core1done),.input_valid(input_valid));

logic core2begin;
logic[31:0] core2_input;

hash_padder hp(.clk,.start(core1done),.hash(core1result),.word_o(core2_input), .output_begin(core2begin));

logic core2_inputready;

sha_simple_core #(.ROUNDS(1),.CYCLESWIDTH(6)) core2(.clk,.rst(core2begin),.M(core2_input),.hash_valid,.input_valid(core2_inputready));

endmodule
