module secondary_ff_array #(parameter LOGNCYCLES=6) (
input logic clk,
input logic rst,
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

logic[LOGNCYCLES:0] round_i;
logic[LOGNCYCLES:0] round_o;
logic[LOGNCYCLES:0] next;
ff #(.WIDTH(LOGNCYCLES+1)) curr_round(.clk,.data_i(round_i),.data_o(round_o));
assign next=round_o[LOGNCYCLES]?round_o:round_o+1'd1;

always_comb begin
   if(rst) begin
      round_i=0;
      round_i[LOGNCYCLES]=1;
   end else begin
      round_i=reading?0:next;
   end
end

assign writeReady=next[LOGNCYCLES];
assign outputValid=~round_o[LOGNCYCLES];
assign newBlock=(0==round_o);
endmodule

module block_storage #(parameter LOGNCYCLES=6) (
input logic clk,
input logic rst,
blockStoreIfc.reader blkRd,
output logic outputValid,
output logic newBlock,
output logic[351:0] initialState);

logic rFull;
logic[351:0] rOut;


logic secondaryReady;
logic transfer;
assign transfer=secondaryReady & rFull;
secondary_ff_array #(.LOGNCYCLES(LOGNCYCLES)) sff(.clk,.rst,.write(rFull),.inputState(rOut),.writeReady(secondaryReady),.initialState,.newBlock,.outputValid);

shift_register r(.clk,.rst,.write_valid(blkRd.writeValid), .write_ready(blkRd.writeReady),.read(secondaryReady),.block_data(blkRd.blockData),.full(rFull),.out(rOut));

endmodule
