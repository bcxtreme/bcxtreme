program nonce_test();
	
	golden_noncebuffer test;

	initial begin
		test = new();
		
		test.validIn_i = 1;
		test.successIn_i = 1;
		test.readReady_i = 1;
		test.nonceIn_i = 'h42a14695;
		repeat(100) begin
		test.cycle();
		
		$display("nonce out %x", test.nonceOut_o);
		$display("overflow %x", test.overflow_o);		
		end
	end

endprogram

