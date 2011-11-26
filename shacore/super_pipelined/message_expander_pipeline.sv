module message_expander_pipeline (
input logic clk,
input logic[31:0] W_i[15:0],
output logic[31:0] W_o[15:0]
);

//Flip flop between W_calculated and W_o
logic[31:0] W_calculated[15:0];
for(genvar i=0; i<16; i++) begin
  ff #(.WIDTH(32)) wff(.clk,.data_i(W_calculated[i]),.data_o(W_calculated[i]));
end

//shift the "history" back one...
for(i=1; i<16; i++) begin
  assign W_calculated[i]=W_i[i-1];
end

//... and calculate the new W based on the history.
sha_message_expander_round r(.history(W_i),.W(W_calculated[0]));

endmodule : message_expander_pipeline
