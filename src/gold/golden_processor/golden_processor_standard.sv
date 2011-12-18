class golden_processor_standard;
	bit validIn_i;
	bit newBlockIn_i;
	bit [351:0] initialStateIn_i;
	bit victoryIn_i;
	bit nonceIndexIn_i; //EDIT NUMBER OF BITS (M?)

	bit validOut_o;
	bit newBlockOut_o;
	bit [351:0] initialStateOut_o;
	bit nonceIndexOut_o;
	bit victoryOut_o;
	
	bit nonceIndex;  //SOME CONSTANT

	Hashstate state;
	coreInputsIfc.reader corein;
	golden_SHACORE sha;
	golden_hashvalidator validator;
	
	bit validOut_buff[DELAY_C+1];
	bit newBlockOut_buff[DELAY_C+1];
	bit [351:0] initialStateOut_buff[DELAY_C+1];
	bit victoryOut_buff[DELAY_C+1];
	bit nonceIndexOut_buff[DELAY_C+1]; //EDIT NUMBER OF BITS (M?)

	function void get_result();
		sha = new();
		validator = new();
		
		//MAY NEED TO CHANGE INPUT OUTPUT NAMES
		validOut_o = validIn_i;
		newBlockOut_o = newBlockIn_i;
		initialStateOut_o = initialStateIn_i;
	
	/*DEFINING SHA CORE INPUTS*/
		state.a = initialStateIn_i[351:320]
		state.b = initalStateIn[319:288];
		state.c = initalStateIn[287:256];
		state.d = initalStateIn[255:224];
		state.e = initalStateIn[223:192];
		state.f = initalStateIn[191:160];
		state.g = initalStateIn[159:128];
		state.h = initalStateIn[127:96];
		corein.hashstate = state;
		corein.w1 = initalStateIn[95:64];
		corein.w2 = initalStateIn[63:32];
		corein.w3 = initalStateIn[31:0];
		corein.valid = validIn_i;
		corein.newblock = newBlockIn_i;
		
		sha.cycle(corein);

	/*END DEFINING SHA CORE INPUTS*/

		
		validator.validIn_i = validIn_i;
		validator.newBlockIn_i = newBlockIn_i;
	
		validator.hash_i = sha.getResult();
		validator.difficulty_i = corein.w3;
		
		validator.cycle();//do hash validator stuff

		victoryOut_o = validator.success_o | victoryIn_i;
		
		if(validator.success_o) begin
			nonceIndexOut_o = nonceIndex;
		end
		else begin
			nonceIndexOut_o = nonceIndexIn_i;
		end
	endfunction
	
	
	function new();
		for (int i = 0; i <= DELAY_C; i++) begin
			validOut_buff[i] = 1'b0;
			newBlockOut_buff[i] = 1'b0;
			initialStateOut_buff[i] = 0;
			victoryOut_buff[i] = 1'b0;
			nonceIndexOut_buff[i] = 1'b0; 
		end
	endfunction
	
	
	task cycle();
		for (int i = DELAY_C; i > 0; i--) begin
			validOut_buff[i] = validOut_buff[i-1];
			newBlockOut_buff[i] = newBlockOut_buff[i-1]
			initialStateOut_buff[i] = initialStateOut_buff[i-1] 
			victoryOut_buff[i] = victoryOut_buff[i-1]
			nonceIndexOut_buff[i] = nonceIndexOut_buff[i-1]
		end
		
		get_result();

		validOut_buff[0] = validOut_o;
		newBlockOut_buff[0] = newBlockOut_o;
		initialStateOut_buff[0] = initialStateOut_o; 
		victoryOut_buff[0] = newBlockOut_o;
		nonceIndexOut_buff[0] = nonceIndexOut_o;
		
		validOut_o = validOut_buff[DELAY_C];
		newBlockOut_o = newBlockOut_buff[DELAY_C];
		initialStateOut_o = initialStateOut_buff[DELAY_C]; 
		victoryOut_o = newBlockOut_buff[DELAY_C];
		nonceIndexOut_o = nonceIndexOut_buff[DELAY_C];

		//if(validOut_o)
			//$display("Sending DoubleHash %x",hash_o);
		//$display("%t Valid_buf[0] %b",$time, valid_buf[0]);
	endtask
endclass
