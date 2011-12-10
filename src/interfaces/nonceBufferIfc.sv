
interface nonceBufferIfc();
	logic readReady;
	logic nonce;
	logic overflow;

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
	
