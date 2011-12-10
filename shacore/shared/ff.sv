module ff #(parameter WIDTH=32) (
  input clk, 
  input[WIDTH-1:0] data_i,
  output[WIDTH-1:0] data_o);
  reg[WIDTH-1:0] tmp;
  assign data_o=tmp;
  always_ff @(posedge clk) begin
    tmp <=data_i;
  end
endmodule
