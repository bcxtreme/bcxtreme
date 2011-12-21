class golden_noncedecoder #(parameter NUMPROCESSORS=10,parameter NONCESPACE=(1<<6),parameter INDEXBITS=$clog2(NUMPROCESSORS));


	// Nonce Input interface

	bit valid_i;
	bit newblock_i;
	bit success_i;
	bit[INDEXBITS-1:0] index_i;

	// Output Interface
	bit valid_o;
	bit success_o;
	bit[31:0] nonce_o;
	
	// Buffers for storing nonce
	local bit valid;
	local bit success;
	local bit index;
	local bit[31:0] nonce;

	// Misc internal state
	local int base_nonce;
	local bit is_accumulating;

	task cycle();
		if(valid_i) begin
			if (is_accumulating && base_nonce+NUMPROCESSORS>=NONCESPACE) begin
				valid_o=1'b1;
				success_o=success;
				nonce_o=nonce;
				is_accumulating = 0;
			end else 
				valid_o=1'b0;

			if(newblock_i) begin
				base_nonce= 0;
				success=0;
				nonce=0;
				is_accumulating = 1;
			end
			else if (is_accumulating) begin
				base_nonce = base_nonce + NUMPROCESSORS;
				if (success_i) begin 
					nonce = base_nonce + index_i;
					success = 1'b1;
				end
			end
		
			
		end

	endtask
endclass

