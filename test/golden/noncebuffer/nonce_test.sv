program nonce_test();
	
	golden_noncebuffer test;

	initial begin
		test = new();
		
		test.rst = 0;
		test.validIn = 1;
		test.success = 1;
		test.readReady = 1;
		test.nonceIn = 'h42a14695;
		repeat(100) begin
		test.noncebuffer_test();
		
		$display("nonce out %x", test.nonceOut);
		$display("overflow %x", test.overflow);		
		end
	end

endprogram

