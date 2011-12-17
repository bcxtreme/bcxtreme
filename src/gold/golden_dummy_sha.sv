
class golden_dummy_sha #(parameter COUNTBITS = 6, parameter DELAY_C = 10);

	// Inputs
	bit validIn_i;
	bit newBlockIn_i;
	bit[351:0] initialState_i;

	// Outputs
	bit validOut_o;
	bit newBlockOut_o;
	bit[255:0] hash_o;
	bit[31:0] difficulty_o;

	// Internal State
	local bit[255:0] hash_buf[DELAY_C + 1];
	local bit[32:0] dif_buf[DELAY_C + 1];
	local bit valid_buf[DELAY_C + 1];
	local bit new_buf[DELAY_C + 1];

	function new();
		for (int i = 0; i <= DELAY_C; i++) begin
			hash_buf[i] = 0;
			dif_buf[i] = 0;
			valid_buf[i] = 1'b0;
			new_buf[i] = 1'b0;
		end
	endfunction
			

	task cycle();
		for (int i = DELAY_C; i > 0; i--) begin
			valid_buf[i] = valid_buf[i - 1];
			dif_buf[i] = dif_buf[i - 1];
			hash_buf[i] = hash_buf[i - 1];
			new_buf[i] = new_buf[i - 1];
		end

		valid_buf[0] = validIn_i;
		dif_buf[0] = initialState_i[351:320];
		hash_buf[0] = initialState_i[255:0];
		new_buf[0] = newBlockIn_i;

		validOut_o = valid_buf[DELAY_C];
		difficulty_o = dif_buf[DELAY_C];
		newBlockOut_o = new_buf[DELAY_C];
		hash_o = hash_buf[DELAY_C];

	endtask

endclass

