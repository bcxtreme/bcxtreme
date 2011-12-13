program target_test();
	
	bit[31:0] D;
	hashvalidate_test gettarget;
initial begin	
	gettarget = new();
	

	D = 'hcb04041b;
	//$display("%x",D);
		
	
	//gettarget.get_target();
end


endprogram
