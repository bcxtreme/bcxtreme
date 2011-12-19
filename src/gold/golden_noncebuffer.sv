class golden_noncebuffer;
	
	bit validIn_i;
	bit successIn_i;
	bit [31:0] nonceIn_i;
	
	bit readReady_i;

	bit overflow_o;
	bit nonceOut_o;
	bit validOut_i;
	bit successOut_o;
	
	bit [31:0] buffer;
	bit storing = 1'b0;
	bit clockingout = 1'b0;

	function void noncebuffer_result();
		validOut_o = validIn_i;
		successOut_o = successIn_i;
		
		if(validIn_i && successIn_i) begin

			storing = 1'b1;
			if(storing) begin
				if(clockingout) begin //if second nonce is found before first is clocked out
					overflow_o = 1'b1;
				end
				else begin
					buffer = nonceIn_i; //store nonceIn
				end
			end
			storing = 1'b0;
		end

		if(readReady_i) begin
			clockingout = 1'b1;
			if(clockingout) begin	
				for (int i = 0; i < 32; i++) begin		
					nonceOut_o = buffer[i];//clock out most recent nonce
				end		
			end
			clockingout = 1'b0;
		end
	endfunction

	task cycle();
		noncebuffer_result();
	endtask
endclass
