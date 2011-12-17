program target_test();
	bit[31:0] le_diff;
	golden_hashvalidator_pipeline test;
initial begin	
	test = new();
	
	test.rst = 0;
		


	/*test.hash = 256'h000000000000000000000000000000000000000000000000bb04040000000000;
	test.valid_in = 1;
	test.newblock_in  = 1; 
	test.difficulty = 'hcb04041b;

	test.hashvalidate_result();

	$display("newblock %x",test.newblock_out);
	$display("validout %x",test.valid_out);
	$display("success %x",test.success);*/
		
	
	
end


endprogram

