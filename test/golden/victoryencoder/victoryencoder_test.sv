class encoder_test;
	bit valid_in0;
	bit newblock_in0; 	
	bit success_in0;

	bit valid_in1;
	bit newblock_in1; 	
	bit success_in1;

	bit valid_in2;
	bit newblock_in2; 	
	bit success_in2;

	bit valid_out;
	bit success_out;
	bit [31:0] nonce = 0;

	function void victoryencoder_result();
		if(valid_in0 && newblock_in0) begin
			//check the hashes
			if(success_in0) begin
				nonce = nonce + 1;
			end
		end

		if(valid_in1 && newblock_in1) begin
			if(success_in1) begin
				nonce = nonce + 1;
			end
		end

		if(valid_in2 && newblock_in2) begin
			if(success_in2) begin
				nonce = nonce + 1;
			end
		end
		
		valid_out = 1;
	endfunction
endclass
