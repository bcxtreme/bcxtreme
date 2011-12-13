module victory_selector #(parameter PARTITIONBITS=1)

input logic clk,
input logic victory1,
input logic nonce_start1,
input logic victory2,
input logic nonce_start2,
output logic victory_o,
output logic nonce_start_o);

assign victory_o=victory1 || victory2;

assign nonce_start_o=victory1?nonce_start1:nonce_start2;

endmodule
