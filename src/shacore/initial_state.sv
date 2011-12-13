module sha_initial_hashstate(output HashState state);

assign state.a = 32'h6a09e667;
assign state.b = 32'hbb67ae85;
assign state.c = 32'h3c6ef372;
assign state.d = 32'ha54ff53a;
assign state.e = 32'h510e527f;
assign state.f = 32'h9b05688c;
assign state.g = 32'h1f83d9ab;
assign state.h = 32'h5be0cd19;

endmodule
