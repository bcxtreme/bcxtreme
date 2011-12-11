//Feed in the old hash state at counter=0, then W_i at counter=1...counter=63,counter=0 (of next round)
//In order to run the calculation, set counter=0, and then each sucessive clock cycle 
//increment counter.  The output will be valid the next time counter=0. 
//Note that holding the value of counter at any value except zero will mess up the calculation.
//(Note that counter is 6 bits, so on the cycle that the previous computation is output (counter=0), the next
// computation is ready to have its initial hash state fed in).
module sha_compressor(
input logic clk,
input logic[5:0] counter,
input logic[31:0] W,
input HashState inputhashstate,
output HashState hash
);

HashState newhs;

//Fetch the constant K which depends on the round number.
logic[31:0] K;
//Because the data gets fed in the clock cycle *after* the reset signal, we want the *old*
// counter value for the lookup, which will be 0 on the first cycle that data is fed in.
Klookup kl(.index(counter),.K);

HashState calculatedhs;
sha_round r(.clk,.in(newhs),.out(calculatedhs),.K,.W);


//If the next round will be the start of a new calculation, then feed in the input hash state.
//Otherwise loop back the calculated state
assign newhs=(counter==0)?inputhashstate:calculatedhs;

assign hash =calculatedhs;
endmodule
