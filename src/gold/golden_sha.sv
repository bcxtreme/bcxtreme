
class golden_sha #(parameter DELAY_C = 10, parameter INDEX=0, parameter NUM_CORES=1);

	// Inputs
	bit validIn_i;
	bit newBlockIn_i;
	bit[351:0] initialState_i;

	// Outputs
	bit validOut_o;
	bit newBlockOut_o;
	bit[255:0] hash_o;
	bit[31:0] difficulty_o;

	bit[31:0] nonce_o;

	// Internal State
	local bit[255:0] hash_buf[DELAY_C + 1];
	local bit[31:0] dif_buf[DELAY_C + 1];
	local bit valid_buf[DELAY_C + 1];
	local bit new_buf[DELAY_C + 1];
	local bit nonce_buf[DELAY_C + 1];
	local bit[31:0] nonce;

	function new();
		// Initialize buffers
		for (int i = 0; i <= DELAY_C; i++) begin
			hash_buf[i] = 0;
			dif_buf[i] = 0;
			valid_buf[i] = 1'b0;
			new_buf[i] = 1'b0;
			nonce_buf[i] = 0;
		end
		nonce = INDEX;
	endfunction

 	local function bit[255:0] evaluate(bit[31:0] hs[8], bit[31:0] w1, bit[31:0] w2, bit[31:0] w3);
		bit[639:0] msg1;
		bit[255:0] middleHash;
		bit[31:0] _h[8];
		bit arr[];


		// Note: 512 bits of 0 are just for padding: They are not used in our algorithm
		// Note: sha256 function must be passed a dynamic array
		// Note: sha256 expects the bits in the opposite order, so we reverse them
		msg1 = { 512'b0, w1, w2, w3, nonce };
		arr = new[640];
		for (int i = 0; i < 640; i++)
			arr[i] = msg1[639 - i];
		middleHash = golden_sha256( hs, arr );

		// This is SHA-specific hard-coded hash state
		_h = {
			32'h6a09e667, 32'hbb67ae85, 32'h3c6ef372, 32'ha54ff53a,
			32'h510e527f, 32'h9b05688c, 32'h1f83d9ab, 32'h5be0cd19
		};

		arr = new[256];
		for (int i = 0; i < 256; i++)
			arr[i] = middleHash[255 - i];
		return golden_sha256( _h, arr);
	endfunction

	task cycle();
		bit[31:0] hs[8];
		bit[31:0] w1, w2, w3;
		bit[255:0] out;

		// Advance buffers
		for (int i = DELAY_C; i > 0; i--) begin
			valid_buf[i] = valid_buf[i - 1];
			dif_buf[i] = dif_buf[i - 1];
			hash_buf[i] = hash_buf[i - 1];
			new_buf[i] = new_buf[i - 1];
		end

		// Advance nonce
		if (validIn_i) begin
			if (newBlockIn_i)
				nonce = INDEX;
			else
				nonce += NUM_CORES;
		end

		// Format input
		w3 = initialState_i[31: 0];
		w2 = initialState_i[63:32];
		w1 = initialState_i[95:64];

		hs[7] = initialState_i[127: 96];
		hs[6] = initialState_i[159:128];
		hs[5] = initialState_i[191:160];
		hs[4] = initialState_i[223:192];
		hs[3] = initialState_i[255:224];
		hs[2] = initialState_i[287:256];
		hs[1] = initialState_i[319:288];
		hs[0] = initialState_i[351:320];

		// Do SHA Logic
		out = evaluate(hs, w1, w2, w3);

		// Queue data in buffers
		valid_buf[0] = validIn_i;
		dif_buf[0] = w3;
		new_buf[0] = newBlockIn_i;
		hash_buf[0] = out;
		nonce_buf[0] = nonce;

		// Pull outputs from the other side of buffers
		validOut_o = valid_buf[DELAY_C];
		difficulty_o = dif_buf[DELAY_C];
		newBlockOut_o = new_buf[DELAY_C];
		hash_o = hash_buf[DELAY_C];
		nonce_o = nonce_buf[DELAY_C];
	endtask

endclass

