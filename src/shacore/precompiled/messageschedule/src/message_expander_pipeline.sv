module sha_message_expander_pipeline #(parameter PIPELINE_DEPTH=1) (
input logic clk,
input logic[15:0][31:0] W_i,
output logic[15:0][31:0] W_o
);

logic[15:0][31:0] Wbuff[PIPELINE_DEPTH:0];

//shift the "history" back one...
for(i=1; i<16; i++) begin
  assign Wbuff[0][i]=W_i[i-1];
end

//... and calculate the new W based on the history.
sha_message_expander_round r(.history(W_i),.W(Wbuff[0][0]));

//Flip flop to delay output by PIPELINE_DEPTH
for(genvar j=0; j<PIPELINE_DEPTH; j++) begin
	for(i=0; i<16; i++) begin
  		ff #(.WIDTH(32)) wff(.clk,.data_i(Wbuff[j][i]),.data_o(Wbuff[j+1][i]));
	end
end

for(i=0; i<16; i++) begin
	assign W_o[i]=Wbuff[PIPELINE_DEPTH][i];
end

endmodule : sha_message_expander_pipeline
