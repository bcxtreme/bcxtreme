//
module sha_aADDER(
input logic[31:0] h,
input logic[31:0] sum1,
input logic[31:0] ch,
input logic[31:0] K,
input logic[31:0] W,
input logic[31:0] sum0,
input logic[31:0] maj,
output logic[31:0] a
);
/*
logic[2:0] compressed[31:0];
for(genvar i=0; i<32; i++) begin
   seventhreecompressor stc(.in({h[i],sum1[i],ch[i],K[i],W[i],sum0[i],maj[i]}),.sum(compressed[i]));
end

logic[1:0] doublecompressed[31:0];
assign doublecompressed[0]=compressed[0][0];
assign doublecompressed[1][0]=compressed[1][0]^compressed[0][1];
assign doublecompressed[1][1]=compressed[1][0]&compressed[0][1];
for(i=2; i<32; i++) begin
  threetwocompressor ttc(.in({compressed[i][0],compressed[i-1][1],compressed[i-2][2]}),.out(doublecompressed[i]));
end

logic[31:0] sum;
logic[31:0] carry;
for(genvar n=0; n<32; n++) begin
  assign sum[n]=doublecompressed[n][0];
  assign carry[n]=doublecompressed[n][1];
end
assign a=sum+carry;
*/
/*
logic U1co;
logic[31:0] U1sum;
logic[31:0] U1carry;
DW01_csa #(.width(32)) U1( .a(h), .b(K), .c(W), .ci('0), .carry(U1carry), .sum(U1sum), .co(U1co) );

logic U2co;
logic[31:0] U2sum;
logic[31:0] U2carry;
DW01_csa #(.width(32)) U2( .a(maj), .b(ch), .c(sum1), .ci('0), .carry(U2carry), .sum(U2sum), .co(U1co) );

logic U3co;
logic[31:0] U3sum;
logic[31:0] U3carry;
DW01_csa #(.width(32)) U3( .a(U1sum), .b(U1carry), .c(sum0), .ci('0), .carry(U3carry), .sum(U3sum), .co(U3co) );

logic U4co;
logic[31:0] U4sum;
logic[31:0] U4carry;
DW01_csa #(.width(32)) U4( .a(U3sum), .b(U3carry), .c(U2sum), .ci('0), .carry(U4carry), .sum(U4sum), .co(U4co) );

logic U5co;
logic[31:0] U5sum;
logic[31:0] U5carry;
DW01_csa #(.width(32)) U5( .a(U4sum), .b(U4carry), .c(U2carry), .ci('0), .carry(U5carry), .sum(U5sum), .co(U5co) );
*/
assign a=h+sum0+sum1+ch+K+W+maj;
endmodule
