module sha_pipelined_pre_pipeline(
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
assign hashstate_pipeline[0]=state_in;
assign state_out=hashstate_pipeline[15];

logic[31:0] M[14:0];

/* feed in the M values to the first 15 stages */
assign M[0]=in.w1;
assign M[1]=in.w2;
assign M[2]=in.w3;
//Note that as the reset signal is on a one cycle delay, we source it from the previous step in the pipeline.
counter c1(.clk,.rst(valid_pipeline[2]& newblock_pipeline[2]),.inc(valid_pipeline[2]),.count(M[3]));
assign M[4]=32'h80000000; //The one bit of padding

generate 
for(genvar n=5; n<15; n++) begin
  assign M[n]=32'd0;  //The rest of the padding is zero until the final word.
end
endgenerate

/* assign the history values appropriately */
generate
for(n=0; n<3; n++) begin
  assign history[15-n]=M[n];
end 
endgenerate

//Note that as the reset signal is on a one cycle delay, we source it from the previous step in the pipeline.
counter c2(.clk,.rst(valid_pipeline[14] & newblock_pipeline[14]),.inc(valid_pipeline[14]),.count(history[15-3]));

generate
for(n=4; n<15; n++) begin
  assign history[15-n]=M[n];
end
endgenerate

assign history[15-15]=32'd640; //The size of the message in bits... appended as part of the padding.


/* Generate the first 15 stages of the pipeline */
for(genvar i=0; i<15; i++) begin
  sha_pipelined_pre_stage #(.K(Kfunction(i))) s(.clk,.state_i(hashstate_pipeline[i]),.W(M[i]),.valid_i(valid_pipeline[i]),.newblock_i(newblock_pipeline[i]),.state_o(hashstate_pipeline[i+1]),.valid_o(valid_pipeline[i+1]),.newblock_o(newblock_pipeline[i+1]));
end

endmodule
