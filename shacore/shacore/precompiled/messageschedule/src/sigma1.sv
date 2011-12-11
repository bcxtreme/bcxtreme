module sha_sigma1(input logic[31:0] x,
output logic[31:0] out);

sha_sigma #(.i1(17),.i2(19),.i3(10)) s(.x,.out);

endmodule
