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


	function void do_sha;
		if(valid_in && newblock_in) begin		
			sha.sha256();
		end;
	
	endfunction
endclass
