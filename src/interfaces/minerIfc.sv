
interface minerIfc(input logic clk);

	logic rst;
	logic resultValid;
	logic success;
`ifdef BENCHING
	clocking cb @(posedge clk);
		output rst;
		input resultValid;
		input success;
	endclocking

	modport bench (
		clocking cb
	);
`endif
	modport dut (
		input rst,
		output resultValid,
		output success
	);



endinterface
