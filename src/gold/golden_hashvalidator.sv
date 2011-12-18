

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
		le_hash[255:248] = hash_i[7:0];
		le_hash[247:240] = hash_i[15:8];
		le_hash[239:232] = hash_i[23:16];
		le_hash[231:224] = hash_i[31:24];
		le_hash[223:216] = hash_i[39:32];
		le_hash[215:208] = hash_i[47:40];
		le_hash[207:200] = hash_i[55:48];
		le_hash[199:192] = hash_i[63:56];
		le_hash[191:184] = hash_i[71:65];
		le_hash[191:184] = hash_i[79:72];
		le_hash[183:176] = hash_i[87:80];
		le_hash[175:168] = hash_i[95:88];
		le_hash[167:160] = hash_i[103:96];
		le_hash[159:152] = hash_i[111:104];
		le_hash[151:144] = hash_i[119:112];
		le_hash[135:128] = hash_i[127:120];
		le_hash[127:120] = hash_i[135:128];
		le_hash[119:112] = hash_i[143:136];
		le_hash[111:104] = hash_i[151:144];
		le_hash[103:96] = hash_i[159:152];
		le_hash[95:88] = hash_i[167:160];
		le_hash[87:80] = hash_i[175:168];
		le_hash[79:72] = hash_i[183:176];
		le_hash[71:65] = hash_i[191:184];
		le_hash[63:56] = hash_i[199:192];
		le_hash[55:48] = hash_i[207:200];
		le_hash[47:40] = hash_i[215:208];
		le_hash[39:32] = hash_i[223:216];
		le_hash[31:24] = hash_i[231:224];
		le_hash[23:16] = hash_i[239:232];
		le_hash[15:8] = hash_i[247:240];
		le_hash[7:0] = hash_i[255:248];

	endfunction
	bit success;
	bit valid;
	bit newBlock;
	task cycle();
		newBlockOut_o = newBlock;
		validOut_o = valid;
		newBlock = newBlockIn_i;
		valid = validIn_i;
		success_o=success;
		success = 'b0;
		if (validIn_i) begin
			get_target();
			reverse_hash(); //need to byte reverse the hash before comparing

			if(le_hash < target) //check if the output matches difficulty
				success = 'b1;
		end
	endtask
endclass
