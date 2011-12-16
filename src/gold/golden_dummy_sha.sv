
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
	bit[255:0] hash_buf[DELAY_C + 1];
	bit valid_buf[DELAY_C + 1];
	bit new_buf[DELAY_C + 1];

	function new();
		for (int i = 0; i <= DELAY_C; i++) begin
			hash_buf[i] = 0;
			valid_buf[i] = 0;
			new_buf[i] = 0;
		end
	endfunction
			

	task cycle();
		valid_buf[0] = validIn_i;
		hash_buf[0] = initialState_i[255:0] ^ initialState_i[351:256];
		new_buf[0] = newBlockIn_i;

		for (int i = 0; i < DELAY_C; i++) begin
			valid_buf[i + 1] = valid_buf[i];
			hash_buf[i + 1] = hash_buf[i];
			new_buf[i + 1] = new_buf[i];
		end

		validOut_o = valid_buf[DELAY_C];
		hash_o = hash_buf[DELAY_C];
		newBlockOut_o = new_buf[DELAY_C];


	endtask

endclass

