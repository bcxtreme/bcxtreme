module secondary_ff_array(
input logic clk,
input logic write,
input logic[351:0] inputState,
output logic writeReady,
output logic[351:0] initialState,
output logic newBlock,
output logic outputValid
);
logic reading;
assign reading=write & writeReady;

logic[351:0] current_state;
ff #(.WIDTH(352)) storage(.clk,.data_i(current_state),.data_o(initialState));
assign current_state=reading?inputState:initialState;

logic[32:0] round_i;
logic[32:0] round_o;
logic[32:0] next;
ff #(.WIDTH(33)) curr_round(.clk,.data_i(round_i),.data_o(round_o));
assign next=round_o[0]?round_o:round_o+1;
assign round_i=reading?0:next;

assign writeReady=next[0];
assign outputValid=~round_o[0];
assign newBlock=(0==round_o);
endmodule

module block_storage(
input logic clk,
input logic rst,
blockStoreIfc.reader blkRd,
output logic outputValid,
output logic newBlock,
output logic[351:0] initialState);

logic rFull;
logic[351:0] rOut;

logic transfer;
logic secondaryReady;
secondary_ff_array sff(.clk,.write(rFull),.inputState(rOut),.writeReady(secondaryReady),.initialState,.newBlock,.outputValid);

shift_register r(.clk,.write_valid(blkRd.writeValid), .read(secondaryReady),.block_data(blkRd.blockData),.full(rFull),.out(rOut));

assign blkRd.writeReady=~rFull;
endmodule
