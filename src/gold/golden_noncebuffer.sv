class golden_noncebuffer;
	
	//INPUTS
	bit validIn_i;
	bit successIn_i;
	bit [31:0] nonceIn_i;
	
	bit readReady_i;

	//OUTPUTS
	bit error_o;
	bit nonceOut_o;
	bit validOut_o;
	bit successOut_o;
	

	//BUFFERS
	bit [31:0] buffer;
	bit storing = 1'b0;
	bit clockingout = 1'b0;

	int index_of_out_bit;	
	

	function void noncebuffer_result();
		validOut_o = validIn_i;
		successOut_o = successIn_i;
		
		if(validIn_i && successIn_i) begin

			storing = 1'b1;
			if(storing) begin
				if(clockingout) begin //if second nonce is found before first is clocked out
					error_o = 1'b1;
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
				//clockout_nonce();  TODO
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
