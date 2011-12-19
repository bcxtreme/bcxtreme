module rotr #(parameter OFFSET=0) (input logic[31:0] x, output logic[31:0] out);

for(genvar i=0; i<32-OFFSET; i++) begin
  assign out[i]=x[i+OFFSET];
end
for(i=0; i<OFFSET; i++) begin
  assign out[32-OFFSET+i]=x[i];
end
endmodule
