module sha_standard_pipelined_preserve_history_stage #(parameter K=0,parameter ROUND_PIPELINE_DEPTH=1)
(
input logic clk,
input HashState state_i,
input logic[15:0][31:0] W_i,
output HashState state_o,
output logic[15:0][31:0] W_o
);


sha_round #(.PIPELINE_DEPTH(ROUND_PIPELINE_DEPTH)) r(.clk,.in(state_i),.out(state_o),.K(K),.W(W_i[0]));

logic[15:0][31:0] Wbuff[ROUND_PIPELINE_DEPTH:0];

//Rotate the inputs into Wbuff[0].
for(genvar i=0; i<15; i++) begin
  assign Wbuff[0][i+1]=W_i[i];
end
assign Wbuff[0][0]=W_i[15];

//Flip flop to delay output by PIPELINE_DEPTH
for(genvar j=0; j<ROUND_PIPELINE_DEPTH; j++) begin
	for(i=0; i<16; i++) begin
  		ff #(.WIDTH(32)) wff(.clk,.data_i(Wbuff[j][i]),.data_o(Wbuff[j+1][i]));
	end
end

for(i=0; i<16; i++) begin
	assign W_o[i]=Wbuff[ROUND_PIPELINE_DEPTH][i];
end

endmodule : sha_standard_pipelined_preserve_history_stage
