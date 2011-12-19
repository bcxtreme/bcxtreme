module sha_pipelined_pre_pipeline #(parameter PROCESSORINDEX=0,parameter NUMPROCESSORS=1,parameter ROUND_PIPELINE_DEPTH=1) (
input logic clk,
input logic rst,
coreInputsIfc.reader in,
output logic output_valid,
output logic newblock_o,
output logic[15:0][31:0] history,
output HashState state_out
);

logic valid_pipeline[15:0];
assign valid_pipeline[0]=in.valid;
assign output_valid=valid_pipeline[15];

logic newblock_pipeline[15:0];
assign newblock_pipeline[0]=in.newblock;
assign newblock_o=newblock_pipeline[15];

HashState hashstate_pipeline[15:0];
assign hashstate_pipeline[0]=in.hashstate;
assign state_out=hashstate_pipeline[15];

logic[31:0] M[14:0];

/* feed in the M values to the first 15 stages */
assign M[0]=in.w1; //Zero delay for m0.
ff #(.WIDTH(32)) m2ff(.clk,.data_i(in.w2),.data_o(M[1]));  //1 delay for m2.

logic[31:0] m3next;
ff #(.WIDTH(32)) m3ff(.clk,.data_i(m3next),.data_o(M[2]));  //2 delay for m3.
assign m3next=(newblock_pipeline[1]&valid_pipeline[1])?in.w3:M[2];

//Note that as the reset signal is on a one cycle delay, we source it from the previous step in the pipeline.
counter #(.INITIALCOUNT(PROCESSORINDEX),.INCREMENT(NUMPROCESSORS)) c1(
	.clk,
	.rst(valid_pipeline[2]& newblock_pipeline[2]),
	.inc(valid_pipeline[2]),
	.count(M[3]));

assign M[4]=32'h80000000; //The one bit of padding

generate 
for(genvar n=5; n<15; n++) begin
  assign M[n]=32'd0;  //The rest of the padding is zero until the final word.
end
endgenerate

/* assign the history values appropriately */

/*Whether the next cycle will be a newblock output to the history.  If this is the case, then we want to load in the *new* values of w1 through w3 to the flip-flops, so next cycle, the *new* values of w1-w3 will be output to the history.*/
logic next_is_newblock; 
assign next_is_newblock=newblock_pipeline[14]&valid_pipeline[14];

logic[31:0] m1hnext;
ff #(.WIDTH(32)) m1hff(.clk,.data_i(m1hnext),.data_o(history[15]));
assign m1hnext=(next_is_newblock)?in.w1:history[15];  //If next is newblock, feed in new value, otherwise the same value as you had last round.

logic[31:0] m2hnext;
ff #(.WIDTH(32)) m2hff(.clk,.data_i(m2hnext),.data_o(history[14]));
assign m2hnext=(next_is_newblock)?in.w2:history[14];

logic[31:0] m3hnext;
ff #(.WIDTH(32)) m3hff(.clk,.data_i(m3hnext),.data_o(history[13]));
assign m3hnext=(next_is_newblock)?in.w3:history[13];

//Note that as the reset signal is on a one cycle delay, we source it from the previous step in the pipeline.
counter #(.INITIALCOUNT(PROCESSORINDEX),.INCREMENT(NUMPROCESSORS)) c2(
	.clk,
	.rst(valid_pipeline[14] & newblock_pipeline[14]),
	.inc(valid_pipeline[14]),
	.count(history[15-3]));

generate
for(n=4; n<15; n++) begin
  assign history[15-n]=M[n];
end
endgenerate

assign history[15-15]=32'd640; //The size of the message in bits... appended as part of the padding.


/* Generate the first 15 stages of the pipeline */
for(genvar i=0; i<15; i++) begin
  sha_pipelined_pre_stage #(.K(Kfunction(i)),.ROUND_PIPELINE_DEPTH(ROUND_PIPELINE_DEPTH)) s(
	.clk,.state_i(hashstate_pipeline[i]),
	.W(M[i]),.valid_i(valid_pipeline[i]),
	.newblock_i(newblock_pipeline[i]),
	.state_o(hashstate_pipeline[i+1]),
	.valid_o(valid_pipeline[i+1]),
	.newblock_o(newblock_pipeline[i+1]));
end

endmodule
