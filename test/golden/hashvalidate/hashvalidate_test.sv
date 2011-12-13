class hashvalidate_test;
	bit [31:0] difficulty;
	bit valid_in;
	bit newblock_in;
	bit [255:0] hash;

	bit [255:0] max_target = 256'h00000000FFFF0000000000000000000000000000000000000000000000000000;
	
	bit [255:0] target;
	bit valid_out;
	bit newblock_out;
	bit success;

	bit[255:0] diff;

	function void get_target();
		//calculate 256 bit target using diffuclty
		
		bit [31:0] le_diff;
		le_diff[31:24] = difficulty[7:0];
		le_diff[23:16] = difficulty[15:8];
		le_diff[15:8] = difficulty[23:16];
		le_diff[7:0] = difficulty[31:24];	
		
		//$display("%x", le_diff);
		
		target =  le_diff[23:0]* 2 **(8*(le_diff[31:24]-3));
		//$display("%x",target);

		$display("%x", max_target);
		diff = max_target / target;
		$display(diff);
		valid_out = 1;
	endfunction
	
	function void hashvalidate_result();
		if (valid_in) begin
				
		
			if(newblock_in) begin
				newblock_out = 1;
			end
			
			get_target();
			

			if(hash < diff) begin
				//check if the output matches difficulty
				success = 1;
			end

			else begin
				success = 0;
			end
		end
	endfunction
endclass
