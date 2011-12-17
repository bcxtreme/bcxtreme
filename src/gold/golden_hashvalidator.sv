
class golden_hashvalidator;

	// Inputs
	bit validIn_i;
	bit newBlockIn_i;
	bit [255:0] hash_i;
	bit [31:0] difficulty_i;

	// Outputs
	bit validOut_o;
	bit newBlockOut_o;
	bit success_o;
	
	// Local state
	local bit [255:0] max_target = 256'h00000000FFFF0000000000000000000000000000000000000000000000000000;
	local bit [255:0] target;

	local function bit is_hash_valid(bit[255:0] hash, bit[31:0] dif_be);
		//calculate 256 bit target using difficulty
		
		bit [31:0] dif_le;
		bit [255:0] max_threshold;

		dif_le[31:24] = dif_be[7:0];
		dif_le[23:16] = dif_be[15:8];
		dif_le[15:8] = dif_be[23:16];
		dif_le[7:0] = dif_be[31:24];	
		
		target =  dif_le[23:0]* 2 **(8*(dif_le[31:24]-3));
		max_threshold = max_target / target;

		return (hash < max_threshold);
	endfunction

	task cycle();
		newBlockOut_o = newBlockIn_i;
		if (validIn_i) begin
			validOut_o = 1;
			success_o = is_hash_valid(hash_i, difficulty_i);
		end else begin
			validOut_o = 0;
			success_o = 0;
		end
	endtask
endclass
