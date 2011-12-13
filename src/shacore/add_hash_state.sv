module sha_add_hash_state(input HashState in1, input HashState in2, output HashState out);

assign out.a=in1.a+in2.a;
assign out.b=in1.b+in2.b;
assign out.c=in1.c+in2.c;
assign out.d=in1.d+in2.d;
assign out.e=in1.e+in2.e;
assign out.f=in1.f+in2.f;
assign out.g=in1.g+in2.g;
assign out.h=in1.h+in2.h;

endmodule
