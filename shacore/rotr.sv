module rotr #(parameter OFFSET=0) (input logic[31:0] x, output logic[31:0] out);

assign out= (x >> OFFSET) | (x <<(32-OFFSET));

endmodule
