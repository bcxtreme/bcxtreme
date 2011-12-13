module secondary_ff_array(
input logic clk,
input logic write,
input logic[351:0] input_state;
output logic write_ready,
output logic [351:0] inital_state,
output logic new_block,
output logic output_valid
);
logic reading;
assign reading=write & write_ready;

logic[351:0] current_state;
ff #(.WIDTH(352)) storage(.clk,.data_i(current_state),.data_o(initial_state));
assign current_state=reading?input_state:initial_state;

logic[32:0] round_i;
logic[32:0] round_o;
logic[32:0] next;
ff #(.WIDTH(33)) curr_round(.clk,.data_i(round_i),.data_o(round_o));
assign next=round_o[0]?round_o:round_o+1;
assign round_i=reading?0:next;

assign write_ready=next[0];
assign output_valid=~round_o[0];
assign new_block=(0==round_o);
endmodule

module block_storage(
input logic write_valid,
input logic[7:0] block_data,
output logic write_ready,
ouput logic output_valid,
output logic new_block,
output logic[351:0] initial_state);

logic transfer;
logic secondary_ready;
secondary_ff_array sff(.clk,.write(r_full),.input_state(r_out),write_ready(secondary_ready),.initial_state(r_out),.new_block,output_valid);

logic r_full;
logic[351:0] r_out;
shift_register r(.clk,.write_valid, .read(secondary_ready),.block_data,.full(r_full),.out(r_out));

endmodule
