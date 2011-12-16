program target_test();
	
	bit[31:0] D;
	bit[255:0] X;
	hashvalidate_test gettarget;
initial begin	
	gettarget = new();
	

	D = 'hcb04041b;
	X = 256'h00000000000404cb000000000000000000000000000000000000000000000000;

//	$display("%x",X);
		
	
	//gettarget.reverse_hash(X);
end


endprogram

