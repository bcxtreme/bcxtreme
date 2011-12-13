//Feed it in the Hash on the same cycle start is set high.
//The next cycle it will start feeding out the padded message one word at a time.
module hash_padder(
input logic clk,
input logic start,
input HashState hash,
output logic[31:0] word_o,
output logic output_begin
);

logic[4:0]  counter_in;
logic[4:0]  counter_out;
ff #(.WIDTH(5)) counter(.clk,.data_i(counter_in),.data_o(counter_out));

always_comb begin
   if(start)
      counter_in=0;
   else if((counter_out & (1<<4)) ==1) 
      counter_in= counter_out; 
   else
      counter_in=counter_out+1;
end

logic[31:0] shift_register_output;
enabled_shift_register sr(.clk,.write_en(start),.in(hash),.data_o(shift_register_output));

always_comb begin
  casex (counter_out)
    5'b00xxx: word_o=shift_register_output;
    5'b01000: word_o=32'h80000000;  //First bit after data is set
    5'b01111: word_o=32'h00000100;  //The last word is the size of the message, 256 in decimal, or 100 in hex.
    5'b01xxx: word_o=32'h00000000;  //Pad with zeros between the 9th and 15th word.
    default:  word_o=32'hxxxxxxxx;  //Output should not matter past this point.
  endcase
end
endmodule
