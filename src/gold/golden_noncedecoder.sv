class golden_noncedecoder #(parameter NUMPROCESSORS=10,parameter INDEXBITS=$clog2(NUMPROCESSORS),parameter NONCESPACE=(1<<6),parameter DIVRESULT=NONCESPACE/NUMPROCESSOR, parameter NONCESPERPROCESSOR=(DIVRESULT*NUMPROCESSORS==NONCESPACE)?DIVRESULTS:(DIVRESULT+1));

	// Nonce Input interface
	bit rst_i;
	bit valid_i;
	bit newblock_i;
	bit success_i
	bit[INDEXBITS-1:0] index_i;

	// Output Interface
	bit valid_o
	bit success_o;
	bit[31:0] nonce_o
	
	// Buffers for storing nonce
	local bit valid;
	local bit success;
	local bit index;
	local bit[31:0] nonce;

	// Misc internal state
	local int cycles_since_newblock;

	function new();

	endfunction

	task do_reset();
		valid='0;
		newblock='0;
		success='0;
		nonce='0;
	endtask

	task cycle();
		//Reset interface
		if(rst_i) begin do_reset(); return; end

		valid_o=valid;
		success_o=success;
		nonce_o=nonce;

		valid=valid_i;
		success=//TODO: HANDLE THE LOGIC FOR SUCCESS (should only be high once at the end of every block)
		index=index_i;
		cycles_since_newblock++;
		if(newblock&valid) cycles_since_newblock=0;
		nonce=cycles_since_newblock*NONCESPERPROCESSOR+index;
	endtask
endclass

