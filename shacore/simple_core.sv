//Feed in the data (M) for 16 cycles starting on the cycle in which rst is high.
//63 cycles after you set rst high, the output will be correct for one cycle.
//(i.e. if you set rst high for the 0th cycle, it will be correct on cycle 63)
module sha_simple_core(
input logic clk,
input logic rst,
input logic[31:0] M,
output HashState hash
);

//Because we are only hashing 80 bits of data, we are really only dealing with two 512 bit blocks.
//that means 128 cycles before we start again.
logic[6:0] oldcycles;
logic[6:0] newcycles;
ff #(.WIDTH(7)) cycles(.clk,.data_i(newcycles),.data_o(oldcycles));

assign newcycles=rst?7'd0:oldcycles+7'd1;

logic[31:0] W;

HashState initialhashstate;

sha_initial_hashstate iniths(.state(initialhashstate));

//The hash state stored from the last computation
HashState oldhashstate;
HashState newhashstate;
HashStateFF f(.clk, .in(newhashstate),.out(oldhashstate));

//The hash state calculated during the previous clock cycle, and then the hash state to store the output from this cycle
HashState oldcalculatedhashstate;
HashState newcalculatedhashstate;
HashStateFF cf(.clk, .in(newcalculatedhashstate),.out(oldcalculatedhashstate));

//The hash state calculated by adding a,b,c,d calculated from the last round to the current H_i
HashState addedhashstate;
sha_add_hash_state a(.in1(oldhashstate),.in2(newcalculatedhashstate),.out(addedhashstate));

//The hash state fed to the round logic.  If it is the beginning of a hash, we feed the IV.  If not, we feed in the
//current H_i as calculated by adding the a,b,c,d to the old H_i.
HashState inputhashstate;
assign inputhashstate = (newcycles==0)?initialhashstate:addedhashstate;

//The new hash state is not changed, except for at the end of a 64 cycle round, when the a,b,c,d... are added to it.
//(every 64 cycles newcycles[5:0] overflows)
assign newhashstate = (newcycles[5:0]==0)?inputhashstate:oldhashstate;

sha_message_schedule sched(.clk,.rst,.M,.W);

sha_compressor cmp(.clk,.rst,.W,.inputhashstate(inputhashstate),.hash(newcalculatedhashstate));

assign hash=addedhashstate;
endmodule :sha_simple_core
