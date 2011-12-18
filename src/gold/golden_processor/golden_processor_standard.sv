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
		
		sha.set_and_evaluate(corein);

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
endclass
