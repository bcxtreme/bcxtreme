module threetwocompressor(
input logic[2:0] in,
output logic[1:0] out);

assign out[0]=in[0]^in[1]^in[2];
assign out[1]=(in[0]&in[1])|(in[0]&in[2])|(in[1]&in[2]);

endmodule