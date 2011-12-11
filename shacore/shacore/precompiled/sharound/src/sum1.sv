module sha_sum1(input logic[31:0] x,
output logic[31:0] out);

sha_sum #(.i1(6),.i2(11),.i3(25)) s(.x,.out);

endmodule
