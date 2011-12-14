class golden_noncebuffer;
	bit rst
		
	bit validIn;
	bit success:
	bit [31:0] nonceIn;
	bit [31:0] buffer;
	bit [31:0] buffer_out;
	
	bit overflow;
	bit nonceOut;
	
	bit readReady;

	bit storing;
	bit clockingout;

	function void noncebuffer_test();
		if(rst) begin
			buffer = 0;
		end

		if(storing && clockingout) begin  //if second nonce is found before first is clocked out
			overflow = 1;
		end

		if(validIn && success) begin
			storing = 1;
			if(storing) begin
				buffer_out = nonceIn; //store nonceIn
			end
			storing = 0;
		end

		

		if(readReady) begin
			clockingout = 1;
			if(clockingout) begin
				nonceOut = buffer_out[0];//clock out most recent nonce
			end
			clockingout = 0;
		end
	endfunction
endclass
