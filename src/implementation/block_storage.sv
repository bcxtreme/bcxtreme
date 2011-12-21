module secondary_ff_array #(parameter NCYCLES=6, parameter LOGNCYCLES=$clog2(NCYCLES)) (
	input logic clk,
	input logic rst,
	input logic write,
	input logic[351:0] inputState,
	output logic writeReady,
	output logic [351:0] initialState,
	output logic newBlock,
	output logic outputValid
);
logic reading;
assign reading=write & writeReady;

logic[351:0] current_state;
ff #(.WIDTH(352)) storage(.clk,.data_i(current_state),.data_o(initialState));
assign current_state=reading?inputState:initialState;

logic[LOGNCYCLES:0] next_round;
logic[LOGNCYCLES:0] round;
logic[LOGNCYCLES:0] next;
ff #(.WIDTH(LOGNCYCLES+1)) curr_round(.clk,.data_i(next_round),.data_o(round));
assign next=(round==NCYCLES)?round:round+1'd1;

always_comb begin
   if(rst) begin
      next_round=NCYCLES;
   end else begin
      next_round=reading?0:next;
   end
end

assign writeReady=(next==NCYCLES);
assign outputValid= (round!=NCYCLES);
assign newBlock=(round==0);

endmodule




module block_storage #(parameter NCYCLES=64,parameter LOGNCYCLES=$clog2(NCYCLES)) (
	input logic clk,
	input logic rst,
	blockStoreIfc.reader blkRd,
	coreInputsIfc.writer broadcast
);

	logic rFull;
	logic[351:0] rOut;

	wire [351:0] initialState;
	
	assign {broadcast.hashstate.a, broadcast.hashstate.b, broadcast.hashstate.c, broadcast.hashstate.d, 
	        broadcast.hashstate.e, broadcast.hashstate.f, broadcast.hashstate.g, broadcast.hashstate.h,
	        broadcast.w1,          broadcast.w2,          broadcast.w3} = initialState;


	logic secondaryReady;
	logic transfer;
	assign transfer=secondaryReady & rFull;
	secondary_ff_array #(.NCYCLES(NCYCLES)) sff (
		.clk,
		.rst,
		.write(rFull),
		.inputState(rOut),
		.writeReady(secondaryReady),
		.initialState,
		.newBlock(broadcast.newblock),
		.outputValid(broadcast.valid)
	);

	shift_register r (
		.clk,
		.rst,
		.write_valid(blkRd.writeValid),
		.write_ready(blkRd.writeReady),
		.read(secondaryReady),
		.block_data(blkRd.blockData),
		.full(rFull),
		.out(rOut)
	);

endmodule

