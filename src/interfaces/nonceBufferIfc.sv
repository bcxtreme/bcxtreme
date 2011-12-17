
interface nonceBufferIfc();
	logic readReady;
	logic nonce;
	logic overflow;

	clocking cb @(posedge clk)
		output readReady;
		output nonce;
		output overflow;
	endclocking

	modport writer(
		input readReady,
		output nonce,
		output overflow
	);

	modport reader(
		output readReady,
		input nonce,
		input overflow
	);

endinterface
	
