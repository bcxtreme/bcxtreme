
class golden_bcminer  #(parameter BROADCAST_CNT = 100, parameter DELAY_C = 129, parameter NUM_CORES = 1);

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
	local golden_blockstorage #(.BROADCAST_CNT(BROADCAST_CNT)) gblock;
	// NOTE: Delay for DELAY_C cycles to account for the ShaCore, then NUM_CORES to account for the pipelining of the outputs
	// NOTE: Previously, the index was hard-coded to 32'h42a14600
	local golden_sha #(.DELAY_C(DELAY_C + NUM_CORES - 1), .NUM_CORES(NUM_CORES)) sha[NUM_CORES];
	local golden_hashvalidator hval[NUM_CORES];
	local golden_noncedecoder #(.NUMPROCESSORS(NUM_CORES), .NONCESPACE($clog2(BROADCAST_CNT))) ndec;

	// Reset the output pins and the internal state
	task reset();
		writeReady_o = 0;
		resultValid_o = 0;
		success_o = 0;
		nonce_o = 0;
		overflow_o = 0;

		gblock = new();
		for (int i = 0; i < NUM_CORES; i++) begin
			sha[i] = new(i);
			hval[i] = new();
		end
		ndec = new();
	endtask

	// Simulate a cycle
	task cycle();
		bit newBlock;
		bit[351:0] state;
		bit [31:0] valid_nonce;

		if (rst_i) begin
			reset();
			return;
		end

		// Block Storage
		gblock.writeValid_i = writeValid_i;
		gblock.blockData_i = blockData_i;

		gblock.cycle();

		writeReady_o = gblock.writeReady_o;


		// Sha Core & Hash Validator
		for (int i = 0; i < NUM_CORES; i++) begin
			sha[i].validIn_i = gblock.validOut_o;
			sha[i].newBlockIn_i = gblock.newBlock_o;
			sha[i].initialState_i = gblock.initialState_o;

			sha[i].cycle();

			hval[i].validIn_i = sha[i].validOut_o;
			hval[i].newBlockIn_i = sha[i].newBlockOut_o;
			hval[i].hash_i = sha[i].hash_o;
			hval[i].difficulty_i = sha[i].difficulty_o;
		
			hval[i].cycle();
		end

		// Accumulate results
		resultValid_o = hval[0].validOut_o;
		success_o = hval[0].success_o;
		newBlock = hval[0].newBlockOut_o;
		for (int i = 1; i < NUM_CORES; i++) begin
			ValidOutSymmetry: assert (resultValid_o == hval[i].validOut_o) else $warning("Golden cores not synchronized ValidOut");
			NewBlockSymmetry: assert (newBlock == hval[i].newBlockOut_o) else $warning("Golden cores not synchronized NewBlockOut");
			success_o = hval[i].success_o & success_o;
			if (hval[i].success_o) valid_nonce = sha[i].nonce_o;
		end

		// Pass through NonceDecoder
		ndec.valid_i = resultValid_o;
		ndec.newblock_i = newBlock;
		ndec.success_i = success_o;

		ndec.cycle();

		resultValid_o = ndec.valid_o;
		success_o = ndec.success_o;
		nonce_o = (& ndec.nonce_o);
		// DEBUG:
		overflow_o = newBlock;
	endtask

endclass


