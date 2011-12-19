module standard_hash_validator(
	input logic clk,
	input logic rst,
	input logic[255:0] hash,
	input logic[31:0] difficulty,
	output logic success
);
	logic succ;
	rff #(.WIDTH(1)) valid(.clk,.rst,.data_i(succ),.data_o(success));

	logic[255:0] hash_as_number;
	generate 
	for(genvar i=0; i<32; i++) begin
		assign hash_as_number[8*i+7 : 8*i]=hash[255-i*8 : 248-i*8];
	end
	endgenerate

	logic[23:0] mantissa_as_number;
	generate
	for(i=0; i<3; i++) begin
		assign mantissa_as_number[8*i+7 : 8*i]=difficulty[31-i*8 : 24-i*8];
	end
	endgenerate

	logic[7:0] exp;
	assign exp=difficulty[7:0];

	logic[255:0] target;
	assign target = mantissa_as_number << 8*(exp-3);

	assign succ = (hash_as_number < target);

endmodule
