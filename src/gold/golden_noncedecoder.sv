class golden_noncedecoder #(parameter NUMPROCESSORS=10)//,parameter INDEXBITS=$clog2(NUMPROCESSORS),parameter NONCESPACE=(1<<6));

	// Nonce Input interface

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

	task cycle();

		if(valid_i) begin
			if(newblock_i) begin
				cycles_since_newblock = 0;
			end
			else begin
				cycles_since_newblock = cycles_since_newblock + NUMPROCESSORS;
			end
		
			if (success_i) begin 
				nonce_o = cycles_since_newblock * index_i;
				valid_o = 1'b1;
			end
			else begin
				valid_o = 1'b0;
			end
			
			if(valid_0) begin
				success_o = 1'b1;
			end			
			else begin
				success_o = 1'b0;
				nonce_o = 0;
			end

			/*
			valid_o=valid;
			success_o=success;
			nonce_o=nonce;
			*/
		end

	/*	valid=valid_i;
		success=//TODO: HANDLE THE LOGIC FOR SUCCESS (should only be high once at the end of every block)
		index=index_i;
		cycles_since_newblock++;
		if(newblock&valid) cycles_since_newblock=0;
		nonce=cycles_since_newblock*NONCESPERPROCESSOR+index;*/
	endtask
endclass

