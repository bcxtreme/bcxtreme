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
	int index_of_out;
	bit is_clocking_out;
	bit nonce_is_unread;
	

	task cycle();
		// Grab any new successful nonce
		if (validIn_i && successIn_i) begin
			if (nonce_is_unread)
				error_o = 1;
		end else begin
			buffer = nonceIn_i;
			nonce_is_unread = 1;
		end

		// Clock out the next bit of the nonce, if that's what we're doing
		if (is_clocking_out) begin
			if (index_of_out == 32) begin
				is_clocking_out = 0;
				nonce_is_unread = 0;
			end else begin
				nonceOut_o = buffer[index_of_out];
				index_of_out += 1;
			end
		end
		
		// Initiate a reading of the Nonce, if requested
		if (readReady_i) begin
			is_clocking_out = 1;
			index_of_out = 0;
		end
	endtask
endclass

