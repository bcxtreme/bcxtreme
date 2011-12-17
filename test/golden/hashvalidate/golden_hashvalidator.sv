class golden_hashvalidator;
	bit rst;
	
	bit [31:0] difficulty;
	bit valid_in;
	bit newblock_in;
	bit [255:0] hash;
	
	bit [255:0] le_hash;
	
	bit [255:0] target;
	bit valid_out;
	bit newblock_out;
	bit success;

	function void get_target();
		//calculate 256 bit target using diffuclty
		
		bit [31:0] le_diff;
		le_diff[31:24] = difficulty[7:0];
		le_diff[23:16] = difficulty[15:8];
		le_diff[15:8] = difficulty[23:16];
		le_diff[7:0] = difficulty[31:24];	
		
		target =  le_diff[23:0]* 2 **(8*(le_diff[31:24]-3));

		valid_out = 1;
	endfunction
	

	function void reverse_hash();
		le_hash[255:248] = hash[7:0];
		le_hash[247:240] = hash[15:8];
		le_hash[239:232] = hash[23:16];
		le_hash[231:224] = hash[31:24];
		le_hash[223:216] = hash[39:32];
		le_hash[215:208] = hash[47:40];
		le_hash[207:200] = hash[55:48];
		le_hash[199:192] = hash[63:56];
		le_hash[191:184] = hash[71:65];
		le_hash[191:184] = hash[79:72];
		le_hash[183:176] = hash[87:80];
		le_hash[175:168] = hash[95:88];
		le_hash[167:160] = hash[103:96];
		le_hash[159:152] = hash[111:104];
		le_hash[151:144] = hash[119:112];
		le_hash[135:128] = hash[127:120];
		le_hash[127:120] = hash[135:128];
		le_hash[119:112] = hash[143:136];
		le_hash[111:104] = hash[151:144];
		le_hash[103:96] = hash[159:152];
		le_hash[95:88] = hash[167:160];
		le_hash[87:80] = hash[175:168];
		le_hash[79:72] = hash[183:176];
		le_hash[71:65] = hash[191:184];
		le_hash[63:56] = hash[199:192];
		le_hash[55:48] = hash[207:200];
		le_hash[47:40] = hash[215:208];
		le_hash[39:32] = hash[223:216];
		le_hash[31:24] = hash[231:224];
		le_hash[23:16] = hash[239:232];
		le_hash[15:8] = hash[247:240];
		le_hash[7:0] = hash[255:248];

	endfunction
	
	function void hashvalidate_result();
		if (valid_in) begin
			if(newblock_in) begin
				newblock_out = 1;
			end
			
			get_target();
			reverse_hash(); //need to byte reverse the hash before comparing

			if(le_hash < target) begin //check if the output matches difficulty
				success = 1;
			end

			else begin
				success = 0;
			end
		end

		if(rst) begin
			valid_out = 0;
			newblock_out = 0;
			success = 0;
		end
	endfunction

endclass
