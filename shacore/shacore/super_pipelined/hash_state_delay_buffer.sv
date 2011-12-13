//On newblock, it will continue feeding in the old value for DELAY cycles (including the one on which newblock is high)
//Then, on the cycle after, it will begin outputting the new value.
//Note that this module assumes two things: 
//1. The input does not change twice within DELAY cycles.
//2. Whenever the input is changed, newblock is high for the first cycle in which it takes  on the new value.

module hash_state_delay_buffer #(parameter DELAY=64,parameter COUNTER_SIZE=$clog2(DELAY+1))
(input logic clk,
input logic newblock,
input HashState in,
output HashState out);

logic counter_reset;
logic[COUNTER_SIZE-1:0] count_in;
logic[COUNTER_SIZE-1:0] count_out;

ff #(.WIDTH(COUNTER_SIZE)) c(.clk,.data_i(count_in),.data_o(count_out));

logic steady;
assign steady = count_out==DELAY;

assign count_in=newblock?1'd0:(steady?DELAY[COUNTER_SIZE-1:0]:(count_out+1'd1));

HashState ffin;
HashState ffout;
HashStateFF ff(.clk,.in(ffin),.out(ffout));

assign out=ffout;

assign ffin=(count_out==(DELAY-2))?in:ffout;

endmodule
