module bxctreme_first_processor (
input logic clk,
input logic rst,
//Initial inputs.
coreInputsIfc.reader inputs,
coreInputsIfc.writer nextInputs,
processorResultsIfc.writer results
);
    parameter PARTITIONBITS=1;
    parameter PROCESSORNUMBER=0;

    logic valid_i;
    logic newblock_i;
    
//Processing pipline.
HashState oh;
sha_standard_pipelined_core core(.clk,.rst,.in(inputs),.doublehash(oh));

logic success;
standard_hash_validator hv(.clk, .hash({oh.a,oh.b,oh.c,oh.d,oh.e,oh.f,oh.g,oh.h}),.difficulty(inputs.w3),.success);

ff #(.WIDTH(1)) viff(.clk,.data_i(success),.data_o(results.victory));

assign results.nonce_start=PROCESSORNUMBER;

//Passthroughs at the beginning.
HashStateFF hsff(.clk,.in(inputs.hashstate),.out(nextInputs.hashstate));
ff #(.WIDTH(32)) w1ff(.clk,.data_i(inputs.w1),.data_o(nextInputs.w1));
ff #(.WIDTH(32)) w2ff(.clk,.data_i(inputs.w2),.data_o(nextInputs.w2));
ff #(.WIDTH(32)) w3ff(.clk,.data_i(inputs.w3),.data_o(nextInputs.w3));
ff #(.WIDTH(1)) vaff(.clk,.data_i(valid_i),.data_o(nextInputs.valid));
ff #(.WIDTH(1)) nbff(.clk,.newblock_i(newblock_i),.data_o(nextInputs.newblock));

endmodule
