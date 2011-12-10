
interface blockStoreIfc();

	logic writeValid;
	logic writeReady;
	logic [7:0] blockData;

	modport writer(
		output writeValid, blockData,
		input writeReady
	);

	modport reader(
		input writeValid, blockData,
		output writeReady
	);

endinterface
