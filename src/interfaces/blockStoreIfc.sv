interface blockStoreIfc(input logic clk);

	logic writeValid;
	logic writeReady;
	logic [7:0] blockData;
`ifdef BENCHING
	clocking cb @(posedge clk);
		output writeValid;
		input writeReady;
		output blockData;
	endclocking

	modport writer(
		clocking cb
	);
`endif
	modport reader(
		input writeValid, input blockData,
		output writeReady
	);

endinterface
