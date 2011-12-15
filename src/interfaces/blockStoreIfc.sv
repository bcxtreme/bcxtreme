
interface blockStoreIfc();

	logic writeValid;
	logic writeReady;
	logic [7:0] blockData;

	clocking cb @(posedge clk);
		output writeValid;
		input writeReady;
		output blockData;
	endclocking

	modport writer(
		output writeValid, output blockData,
		input writeReady
	);

	modport reader(
		input writeValid, input blockData,
		output writeReady
	);

endinterface
