class golden_noncebuffer;
	bit rst;
		
	bit validIn;
	bit success;
	bit [31:0] nonceIn;
	bit [31:0] buffer;
	
	bit overflow;
	bit nonceOut;
	
	bit readReady;

	bit storing = 0;
	bit clockingout = 0;

	function void noncebuffer_test();
		if(rst) begin
			buffer = 0;
		end


		if(validIn && success) begin
			storing = 1;
			if(storing) begin
				if(clockingout) begin //if second nonce is found before first is clocked out
					overflow = 1;
				end
				else begin
					buffer = nonceIn; //store nonceIn
				end
			end
			storing = 0;
		end

		if(readReady) begin
			clockingout = 1;
			if(clockingout) begin
				
				nonceOut = buffer[0];//clock out most recent nonce
			end
			clockingout = 0;
		end
	endfunction
endclass
