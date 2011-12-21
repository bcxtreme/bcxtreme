
interface nonceBufferIfc(input logic clk);
	logic readReady;
	logic nonce;
	logic error;

	clocking cb @(posedge clk);
		output readReady;
		input nonce;
		input error;
	endclocking

	modport writer(
		input readReady,
		output nonce,
		output error
	);

	modport reader(
		clocking cb
	);

endinterface
	
