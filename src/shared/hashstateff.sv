module HashStateFF(input logic clk, input HashState in, output HashState out);

always_ff @(posedge clk) begin
  out<=in;
end

endmodule
