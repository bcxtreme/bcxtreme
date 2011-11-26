module hash_validator(
input logic[9:0] difficulty,
input HashState state,
output logic valid);

logic[7:0][31:0] s;

assign s[0]=state.a;
assign s[1]=state.b;
assign s[2]=state.c;
assign s[3]=state.d;
assign s[4]=state.e;
assign s[5]=state.f;
assign s[6]=state.g;
assign s[7]=state.h;

always_comb begin
  valid=1;
  for(int i=0; i<difficulty; i++) begin
    if(s[i]) begin
      valid=0;
    end
  end
end


endmodule
