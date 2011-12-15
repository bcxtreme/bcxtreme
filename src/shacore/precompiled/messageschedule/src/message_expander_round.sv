module sha_message_expander_round(
input logic[15:0][31:0] history,
output logic[31:0] W);

logic[31:0] tmp1;
logic[31:0] tmp2;
sha_sigma0 s0(.x(history[14]),.out(tmp1));
sha_sigma1 s1(.x(history[1]),.out(tmp2));

assign W=tmp1+tmp2+history[6]+history[15];

endmodule
