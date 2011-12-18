class golden_noncebuffer;

	// Nonce Input interface
	bit rst_i;
	bit writeValid_i;
	bit success_i
	bit[31:0] nonce_i;

	// Output Interface
	bit new_nonce_o;
	bit nonce_o;
	bit overflow_o;
	bit readReady_i;
	
	// Buffers for storing nonce
	local bit[31:0] nonce;

	// Misc internal state
	local int next_bit;	// the next bit of the noncebuffer to write out
	local bit is_new;
	local bit overflow;

	function new();

	endfunction

	task do_reset();
		nonce='0;
		is_new='0;
		overflow=0;
		next_bit=0;
	endtask

	task cycle();
		if(rst_i) begin do_reset(); return; end
		nonce_o=nonce[next_bit];
		if(readReady_i) begin 
			is_new=0;
			next_bit++; 
			if(next_bit>=32) 
				next_bit=0; 
		end
		if(writeValid_i & success_i) begin
			if((is_new | next_bit!=0)) begin
				overflow=1;
			end else begin
				is_new=1;
				nonce=nonce_i;
			end
		end
		new_nonce_o=is_new;
		overflow_o=overflow;
	endtask
endclass

