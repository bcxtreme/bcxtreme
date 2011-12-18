module nonce_extractor #(parameter NUMPROCESSORS=1, parameter NONCESPACE=(1<<6),parameter PARTITIONBITS=$clog(NUMPROCESSORS),parameter NONCESPERPROCESSOR=NONCESPACE/NUMPROCESSORS, parameter LEFTOVER=NONCESPACE-NONCESPERPROCESSOR*NUMPROCESSORS)(
input logic clk,
input logic rst,
input logic valid_i,
input logic newblock_i,
input logic success_i,
output logic valid_o,
output logic newblock_o,
output logic success_o,
input logic[PARTITIONBITS-1:0] processor_index,
output logic[31:0] nonce);

logic[31:0] base_nonce;
logic[31:0] numextra;
always_comb begin
  numextra=(processor_index>LEFTOVER)?LEFTOVER:processor_index;
  base_nonce= NONCESPERPROCESSOR*processor_index+numextra;
end 
 
logic[31:0] count_old;
logic[31:0] count_new;
ff #(.WIDTH(32)) f(.clk,.data_i(count_new),.data_o(count_old));

logic[31:0] calculated_count;
assign count_new=(newblock&valid_i)?0:(count_old+valid_i);

logic[31:0] nonce_tmp;
assign nonce_tmp=new_count+base_nonce;

rff #(.WIDTH(1)) vff(.clk,.rst,.data_i(valid_i),.data_o(valid_o));
rff #(.WIDTH(1)) nbff(.clk,.rst,.data_i(newblock_i),.data_o(newblock_o));
rff #(.WIDTH(1)) sff(.clk,.rst,.data_i(success_i),.data_o(success_o));
rff #(.WIDTH(32)) nff(.clk,.rst,.data_i(nonce_tmp),.data_o(nonce));
endmodule
