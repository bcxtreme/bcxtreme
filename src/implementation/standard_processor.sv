module bxctreme_standard_processor #(parameter PARTITIONBITS=1, parameter PROCESSSORNUMBER) (
input logic clk,
input logic rst,
coreInputsIfc.reader inputs,
coreInputsIfc.writer nextInputs,
processorResultsIfc.reader previousResults,
processorResultsIfc.writer results
);

//Processing pipline.
HashState oh;
sha_standard_pipelined_core core(.clk,.rst,.in(inputs),.doublehash(oh));

logic success;
standard_hash_validator hv(.clk, .hash({oh.a,oh.b,oh.c,oh.d,oh.e,oh.f,oh.g,oh.h}),.difficulty(inputs.w3),.success);


//Muxing the previous results
logic victory;
logic[PARTITIONBITS-1:0] nonce_start
victory_selector #(.PARTITIONBITS(PARTITIONBITS)) vs(.clk,.victory1(success),.nonce_start1(PROCESSORNUMBER),.in2(previousResults),.victory_o(victory), nonce_start_o(nonce_start));

ff #(.WIDTH(1)) viff(.clk,.data_i(victory),.data_o(results.victory));
ff #(.WIDTH(PARTITIONBITS)) nsff(.clk,.data_i(nonce_start),.data_o(results.nonce_start));


//Passthroughs at the beginning.
HashStateFF hsff(.clk,.in(inputs.hashstate),.out(nextInputs.hashstate));
ff #(.WIDTH(32)) w1ff(.clk,.data_i(inputs.w1),.data_o(nextInputs.w1));
ff #(.WIDTH(32)) w2ff(.clk,.data_i(inputs.w2),.data_o(nextInputs.w2));
ff #(.WIDTH(32)) w3ff(.clk,.data_i(inputs.w3),.data_o(nextInputs.w3));
ff #(.WIDTH(1)) vaff(.clk,.data_i(inputs.valid),.data_o(nextInputs.valid));
ff #(.WIDTH(1)) nbff(.clk,.newblock_i(inputs.newblock),.data_o(nextInputs.newblock));

endmodule
