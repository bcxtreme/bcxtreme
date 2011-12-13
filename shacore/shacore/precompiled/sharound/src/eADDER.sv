module sha_eADDER(
input logic[31:0] d,
input logic[31:0] h,
input logic[31:0] sum1,
input logic[31:0] ch,
input logic[31:0] K,
input logic[31:0] W,
output logic[31:0] e
);
assign e=d+h+sum1+ch+K+W;
endmodule
