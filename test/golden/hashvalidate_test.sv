class hash_validate_test;
	int difficulty;
	bit valid_in;
	bit newblock_in;
	bit [255:0] hash;
	
	bit valid_out;
	bit newblock_out;
	bit_success;

	function bit[256] difficulty_calc(difficulty)
		//calculate 256 bit number using diffuclty
		valid_out = 1;

	endfunction
	
	function void hash_validate_result;
		if (valid_in) begin
			//check if the output matches the difficulty
		
			if(newblock_in) begin
				newblock_out = 1;
			end
			
			
			if(hash < difficulty_calc(difficulty)) begin
				//check if the output matches difficulty
				success = 1;
			end
			else begin
				success = 0;
			end
		end
	endfunction
endclass
