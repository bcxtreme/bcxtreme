//Single cycle delay message expander
//The computation begins with the first cycle that the rst bit is set.
//every 64 cycles, it begins again.
module sha_message_schedule (
input logic clk,
input logic rst,
input logic[31:0] M,
output logic[31:0] W
); 

//Should wrap around after 64 clock cycles.
logic[5:0] counter_in;
logic[5:0] counter_out;
ff #(.WIDTH(6)) counter(.clk,.data_i(counter_in),.data_o(counter_out));

//17 locations.
logic[31:0] history[16:0];

//A chain of flip-flops which stores the last 16 values.
for(genvar i=0; i<16; i++) begin
   ff #(.WIDTH(32)) f(.clk,.data_i(history[i]),.data_o(history[i+1]));
end

//Calculation of new W_j
logic[31:0] calculated;
logic[31:0] tmp1;
logic[31:0] tmp2;
sha_sigma0 s0(.x(history[15]),.out(tmp1));
sha_sigma1 s1(.x(history[2]),.out(tmp2));

assign calculated=tmp1+tmp2+history[7]+history[16];

//Increment the counter or set it to zero if getting reset signal.
assign counter_in=rst?6'd0:(counter_out+6'd1);

//For the first 16, feed in the value directly
//After that, use the value calculated from previous values.
assign history[0]=(counter_in<16)?M:calculated;
assign W= history[1];
    
endmodule
