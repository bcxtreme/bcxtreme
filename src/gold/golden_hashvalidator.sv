

class golden_hashvalidator;
	
	bit validIn_i;
	bit newBlockIn_i;
	bit [255:0] hash_i;
	bit [31:0] difficulty_i;

	bit validOut_o;
	bit newBlockOut_o;
	bit success_o;



	local bit [255:0] le_hash;
	local bit [255:0] target;

	function void get_target();
		//calculate 256 bit target using diffuclty
		
		bit [31:0] le_diff;
		le_diff[31:24] = difficulty_i[7:0];
		le_diff[23:16] = difficulty_i[15:8];
		le_diff[15:8] = difficulty_i[23:16];
		le_diff[7:0] = difficulty_i[31:24];	
		
		target =  le_diff[23:0] << (8*(le_diff[31:24]-3));
		//$display("Difficulty: %x, target: %x",difficulty_i, target);
		//target = {32'b0, 16'hffff, 208'b0}; // lowest possible difficulty

	endfunction
	

	function void reverse_hash();
		for (int i = 0; i < 256; i += 8)
			le_hash[255 - i -: 7] = hash_i[i + 7 -: 7];

	endfunction
	bit success;
	bit valid;
	bit newBlock;
	task cycle();
		newBlockOut_o = newBlock;
		validOut_o = valid;
		success_o=success;

		newBlock = newBlockIn_i;
		valid = validIn_i;
		success = 'b0;
		if (validIn_i) begin
			get_target();
			reverse_hash(); //need to byte reverse the hash before comparing

			$display("le_hash: %x\n target: %x", le_hash, target);
			if(le_hash < target) //check if the output matches difficulty
				success = 'b1;
		end
	endtask
endclass
