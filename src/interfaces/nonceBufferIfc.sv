
interface nonceBufferIfc(input logic clk);
	logic readReady;
	logic nonce;
	logic overflow;

	clocking cb @(posedge clk);
		output readReady;
		input nonce;
		input overflow;
	endclocking

	modport writer(
		input readReady,
		output nonce,
		output overflow
	);

	modport reader(
		clocking cb
	);

endinterface
	
