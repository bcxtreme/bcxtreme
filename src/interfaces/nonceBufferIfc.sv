
interface nonceBufferIfc(input logic clk);
	logic readReady;
	logic nonce;
	logic error;
`ifdef BENCHING
	clocking cb @(posedge clk);
		output readReady;
		input nonce;
		input error;
	endclocking

	modport reader(
		clocking cb
	);
`endif
	modport writer(
		input readReady,
		output nonce,
		output error
	);



endinterface
	
