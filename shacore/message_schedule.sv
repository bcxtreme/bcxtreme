//Single cycle delay message expander
//To begin the computation, set counter to 0 and feed in M_0 during the same cycle.
//The outputs will begin the *next* cycle.
//Then, each sucessive cycle increment counter. 
//Note that holding the counter at any value except zero for more than one cycle will mess up the computation.
//(Note that as counter is 5 bits, always incrementing the counter will result in the message scheduler
// starting a new block every 64 cycles.)
module sha_message_schedule (
input logic clk,
input logic[5:0] counter,
input logic[31:0] M,
output logic[31:0] W
); 


//17 locations.
logic[31:0] history[16:0];

//A chain of flip-flops which stores the last 16 values.
for(genvar i=0; i<16; i++) begin
   ff #(.WIDTH(32)) f(.clk,.data_i(history[i]),.data_o(history[i+1]));
end


logic[31:0] calculated;
//Calculation of new W_j
sha_message_expander_round r(.history(history[16:1]),.W(calculated));


//For the first 16, feed in the value directly
//After that, use the value calculated from previous values.
assign history[0]=(counter<16)?M:calculated;
assign W= history[1];
    
endmodule
