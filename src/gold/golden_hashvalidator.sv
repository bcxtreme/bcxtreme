
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
	local bit [255:0] target;

	local function bit is_hash_valid(bit[255:0] hash, bit[31:0] dif_be);
		//calculate 256 bit target using difficulty
		
		bit [31:0] dif_le;
		dif_le[31:24] = dif_be[7:0];
		dif_le[23:16] = dif_be[15:8];
		dif_le[15:8] = dif_be[23:16];
		dif_le[7:0] = dif_be[31:24];	
		
		target =  dif_le[23:0]* 2 **(8*(dif_le[31:24]-3));

		return (hash < target);
	endfunction

	task cycle();
		newBlockOut_o = newBlockIn_i;
		if (validIn_i) begin
			$display("finally got valid %t",$time);
			validOut_o = 1;
			success_o = is_hash_valid(hash_i, difficulty_i);
		end else begin
			validOut_o = 0;
			success_o = 0;
		end
	endtask
endclass
