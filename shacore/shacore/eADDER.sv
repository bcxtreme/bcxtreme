module sha_eADDER(
input logic[31:0] d,
input logic[31:0] sum0,
input logic[31:0] maj,
output logic[31:0] e
);
assign e=d+sum0+maj;
endmodule
