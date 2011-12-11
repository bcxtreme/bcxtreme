module sha_sigma0(input logic[31:0] x,
output logic[31:0] out);

sha_sigma #(.i1(7),.i2(18),.i3(3)) s(.x,.out);

endmodule
