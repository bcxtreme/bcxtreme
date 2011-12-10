class encoder_test;
	bit valid_in;		//make array when pipelined
	bit newblock_in;	// "
	bit success_in;		// "

	bit valid_out;
	bit succes_out;
	bit [31:0] nonce;

	function void victoryencoder_result;
		if(valid_in) begin
				//check the hashes



		end
	endfunction
endclass
