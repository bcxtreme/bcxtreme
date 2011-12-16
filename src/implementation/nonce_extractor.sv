module nonce_extractor #(parameter PARTITIONBITS=1)(
input logic clk,
input logic newblock,
input logic[PARTITIONBITS-1:0] processor_index,
output logic[31:0] nonce);

logic[31:0] base_nonce;
always_comb begin
  base_nonce= processor_index <<(32-PARTITIONBITS);
  //TODO implement more complex schemes for non-power-of-two partitioning.
end 
 
logic[31:0] count_old;
logic[31:0] count_new;
ff #(.WIDTH(32)) f(.clk,.data_i(count_new),.data_o(count_old));

logic[31:0] calculated_count;
assign calculated_count=newblock?0:count_old;
assign count_new=calculated_count+1'd1;

assign nonce=calculated_count+base_nonce;

endmodule
