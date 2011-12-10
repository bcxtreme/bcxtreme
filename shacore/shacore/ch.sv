module sha_ch(input logic[31:0] x,
input logic[31:0] y,
input logic[31:0] z,
output logic[31:0] out);

assign out=(x & y) ^ (~x & z);

endmodule :sha_ch
