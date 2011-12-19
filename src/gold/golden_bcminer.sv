
class golden_bcminer  #(parameter COUNTBITS = 6,parameter DELAY_C=129);


	bit rst_i;
	
	// Block Storage Interface
	bit writeValid_i;
	bit writeReady_o;
	bit[7:0] blockData_i;

	// Result Outputs
	bit resultValid_o;
	bit success_o;

	// Nonce Buffer Interface
	bit readReady_i;
	bit nonce_o;
	bit overflow_o;

	// Golden units
	local golden_blockstorage #(.COUNTBITS(COUNTBITS)) gblock;
	local golden_sha #(.DELAY_C(DELAY_C)) sha;
	local golden_hashvalidator hval;

	// Reset the output pins and the internal state
	task reset();
		writeReady_o = 0;
		resultValid_o = 0;
		success_o = 0;
		nonce_o = 0;
		overflow_o = 0;

		gblock = new();
		sha = new();
		hval = new();
	endtask

	// Simulate a cycle
	task cycle();
		bit newBlock;
		bit validOut;
		bit[351:0] state;

		if (rst_i) begin
			reset();
			return;
		end

		// Block Storage
		gblock.writeValid_i = writeValid_i;
		gblock.blockData_i = blockData_i;

		gblock.cycle();


		// Sha Core
		sha.validIn_i = gblock.validOut_o;
		sha.newBlockIn_i = gblock.newBlock_o;
		sha.initialState_i = gblock.initialState_o;

		sha.cycle();
		//$display("Input to hashvalidator %x",sha.hash_o);
		// Hash Validator
		hval.validIn_i = sha.validOut_o;
		hval.newBlockIn_i = sha.newBlockOut_o;
		hval.hash_i = sha.hash_o;
		hval.difficulty_i = sha.difficulty_o;
	
		hval.cycle();

		writeReady_o = gblock.writeReady_o;
		resultValid_o=sha.validOut_o;
		//resultValid_o = hval.validOut_o;
		//success_o = hval.success_o;
		success_o = (^ sha.hash_o);
		//nonce_o = hval.newBlockOut_o;
		nonce_o = sha.newBlockOut_o;

	endtask

endclass


