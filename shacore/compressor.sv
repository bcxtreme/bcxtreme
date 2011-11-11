//begin feeding data the clock cycle *after* the reset signal is recieved
module sha_compressor(
input clk,
input rst,
input logic[31:0] W,
input HashState inputhashstate,
output HashState hash
);

HashState oldhs;
HashState newhs;

HashStateFF hs(.clk, .in(newhs),.out(oldhs));

//A counter which keeps track of how many iterations have been applied.
logic[5:0] counter_new;
logic[5:0] counter_old;
ff #(.WIDTH(6)) counter(.clk, .data_i(counter_new),.data_o(counter_old));

assign counter_new=rst?6'd0:(counter_old+6'd1);

//Fetch the constant K which depends on the round number.
logic[31:0] K;
//Because the data gets fed in the clock cycle *after* the reset signal, we want the *old*
// counter value for the lookup, which will be 0 on the first cycle that data is fed in.
Klookup kl(.index(counter_old),.K);

HashState calculatedhs;
sha_round r(.in(oldhs),.out(calculatedhs),.K,.W);


//If the next round will be the start of a new calculation, then feed in the input hash state.
//Otherwise loop back the calculated state
assign newhs=(counter_new==0)?inputhashstate:calculatedhs;

assign hash =calculatedhs;
endmodule
