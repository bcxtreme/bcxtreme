class golden_noncedecoder #(parameter NUMPROCESSORS=10,parameter INDEXBITS=$clog2(NUMPROCESSORS),parameter NONCESPACE=(1<<6),parameter NONCESPERPROCESSOR=NONCESPACE/NUMPROCESSORS,parameter LEFTOVER=NONCESPACE-NUMPROCESSORS*NONCESPERPROCESSOR);

	// Nonce Input interface
	bit rst_i;
	bit valid_i;
	bit newblock_i;
	bit success_i
	bit[INDEXBITS-1:0] index_i;

	// Output Interface
	bit valid_o
	bit newblock_o;
	bit success_o;
	bit[31:0] nonce_o
	
	// Buffers for storing nonce
	local bit valid;
	local bit newblock;
	local bit success;
	local bit index;
	local bit[31:0] nonce;

	// Misc internal state


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
		newblock_o=newblock;
		success_o=success;
		nonce_o=nonce;

		valid=valid_i;
		newblock=newblock_i;
		success=success_i;
		index=index_i;

		nonce=index*NONCESPERPROCESSOR;
		if(index>LEFTOVER) index=LEFTOVER;
		nonce=nonce+index;
	endtask
endclass

