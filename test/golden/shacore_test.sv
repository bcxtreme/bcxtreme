class sha256;

	function void sha256;
		//PLACE C IMPLEMENTATION OF SHA256 HERE AND MAKE MODIFICATION TO VERILOG
	
	endfunction

endclass

class sha_test;
	bit valid_in;
	bit newblock_in;
	bit[352:0] inital_state;

	bit valid_out;
	bit newblock_out;
	bit [256:0] hash;
	int difficulty;

	sha256 sha; //make an array of sha256's when pipelined
	
	hash_validate validate; //make an array when pipelined

	function void do_sha;
		if(valid_in && newblock_in) begin		
			sha.sha256();
		end;
	
	endfunction
endclass




class hash_validate;
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
