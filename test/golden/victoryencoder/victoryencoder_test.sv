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
	
	int number_of_hashes = 0;

	function void victoryencoder_result();
		if(success_in0 && succes_in1 && success_in2) begin
			success_out = 1;
		end
		else begin
			success_out = 0;
		end
	
		if(valid_in0 && newblock_in0) begin
			//check the hashes
			if(success_in0) begin
				number_of_hashes = number_of_hashes + 1;
			end
		end

		if(valid_in1 && newblock_in1) begin
			if(success_in1) begin
				number_of_hashes = number_of_hashes + 1;
			end
		end

		if(valid_in2 && newblock_in2) begin
			if(success_in2) begin
				number_of_hashes = number_of_hashes + 1;
			end
		end
		
		valid_out = 1;
		
		if(~(valid_out && success_out)) begin
			nonce = 0;
		end
	endfunction
endclass
