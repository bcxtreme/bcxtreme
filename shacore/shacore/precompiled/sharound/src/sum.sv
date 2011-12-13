module sha_sum #(parameter i1=0, i2=0, i3=0) (input logic[31:0] x,
output logic[31:0] out);

logic[31:0] tmp1;
logic[31:0] tmp2;
logic[31:0] tmp3;

rotr #(.OFFSET(i1)) r1 (.x,.out(tmp1));
rotr #(.OFFSET(i2)) r2 (.x,.out(tmp2));
rotr #(.OFFSET(i3)) r3 (.x,.out(tmp3));

assign out= tmp1 ^ tmp2 ^ tmp3;

endmodule
