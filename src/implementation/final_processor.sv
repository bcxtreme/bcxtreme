module bxctreme_final_processor #(parameter PARTITIONBITS=1, parameter PROCESSSORNUMBER) (
input logic clk,
input logic rst,
coreInputsIfc.reader inputs,
processorResultsIfc.reader previousResults,
processorResultsIfc.writer results,
//Extra outputs
output logic valid_final,
output logic newblock_final,
);

//Processing pipline.
HashState oh;
logic ov;
logic nb;
sha_last_pipelined_core core(.clk,.rst,.in(inputs),.output_valid(ov),.newblock_o(nb),.doublehash(oh));

logic success;
logic hvv;
logic hvnb;
final_hash_validator hv(.clk, .hash({oh.a,oh.b,oh.c,oh.d,oh.e,oh.f,oh.g,oh.h}),.valid_i(ov),.valid_o(hvv),.newblock_i(nv),.newblock_o(hvnb),.difficulty(inputs.w3),.success);


//Muxing the previous results
logic victory;
logic[PARTITIONBITS-1:0] nonce_start
victory_selector #(.PARTITIONBITS(PARTITIONBITS)) vs(.clk,.victory1(success),.nonce_start1(PROCESSORNUMBER),in2(previousResults),victory_o(victory),nonce_start_o(nonce_start));

ff #(.WIDTH(1)) vaff(.clk,.data_i(hvv),.data_o(valid_final));
ff #(.WIDTH(1)) nbff(.clk,.data_i(hvnb),.data_o(newblock_final));
ff #(.WIDTH(1)) viff(.clk,.data_i(victory),.data_o(results.victory));
ff #(.WIDTH(PARTITIONBITS)) nsff(.clk,.data_i(nonce_start),.data_o(results.nonce_start));


endmodule
