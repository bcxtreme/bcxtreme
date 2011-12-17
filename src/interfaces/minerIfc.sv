
interface minerIfc(input logic clk);

	logic rst;
	logic resultValid;
	logic success;

	clocking cb @(posedge clk);
		output rst;
		input resultValid;
		input success;
	endclocking

	modport dut (
		input rst,
		output resultValid,
		output success
	);

	modport bench (
		clocking cb
	);

endinterface
