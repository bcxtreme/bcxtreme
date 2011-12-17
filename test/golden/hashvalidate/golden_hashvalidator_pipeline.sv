class golden_hashvalidator_pipeline;
/*	golden_hashvalidator validator0;
	golden_hashvalidator validator1;
	golden_hashvalidator validator2;*/
	
	bit rst;
	
	bit [31:0] difficulty0;
	bit valid_in0;
	bit newblock_in0;
	bit [255:0] hash0;
	
	bit [31:0] difficulty1;
	bit valid_in1;
	bit newblock_in1;
	bit [255:0] hash1;

	
	bit [31:0] difficulty2;
	bit valid_in2;
	bit newblock_in2;
	bit [255:0] hash2;

	bit valid_out0;
	bit newblock_out0 ;
	bit success0;
		
	bit valid_out1; 
	bit newblock_out1;
	bit success1;
		
	bit valid_out2; 
	bit newblock_out2; 
	bit success2;

	function hashvalid_result();
	golden_hashvalidator validator0;
	golden_hashvalidator validator1;
	golden_hashvalidator validator2;
		validator0 = new();
		validator1 = new();
		validator2 = new();
		
		validator0.difficulty = difficulty0;
		validator0.valid_in = valid_in0;
		validator0.newblock_in = newblock_in0;
		validator0.hash = hash0;
		
		validator1.difficulty = difficulty1;
		validator1.valid_in = valid_in1;
		validator1.newblock_in = newblock_in1;
		validator1.hash = hash1;
		
		validator2.difficulty = difficulty2;
		validator2.valid_in = valid_in2;
		validator2.newblock_in = newblock_in2;
		validator2.hash = hash2;
		
		validator0.hashvalidate_result();
		validator1.hashvalidate_result();
		validator2.hashvalidate_result();

		valid_out0 = validator0.valid_out;
		newblock_out0 = validator0.newblock_out;
		success0 = validator0.success;
		
		valid_out1 = validator1.valid_out;
		newblock_out1 = validator1.newblock_out;
		success1 = validator1.success;
		
		valid_out2 = validator2.valid_out;
		newblock_out2 = validator2.newblock_out;
		success2 = validator2.success;
	endfunction
endclass