module sha_sum0(input logic[31:0] x,
output logic[31:0] out);

sha_sum #(.i1(2),.i2(13),.i3(22)) s(.x,.out);

endmodule
