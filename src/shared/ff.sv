
module ff #(parameter WIDTH = 1)
(
	input clk,
	input rst,
	input enable,
	input [WIDTH - 1: 0] data_i,
	output [WIDTH - 1: 0] data_o
);

	reg[WIDTH - 1: 0] mem;

	always_ff @(posedge clk) begin
		if (rst)
			mem <= 0;
		else if (enable)
			mem <= data_i;
		else
			mem <= mem;
	end
	assign data_o = mem;
endmodule