
class inputs;

	bit rst;
	bit writeValid;

	bit[7:0] blockData;


	local rand bit[23:0] mantissa;
	local bit[31:0] maxmantissa;

	constraint c { 0<=mantissa; 
			mantissa<=maxmantissa; }

	local bit[3:0][7:0] difficulty;
	local rand bit[31:0][7:0] block;
	local int blockindex;
	local int trailingzeros;

	local real density_rst;
	local real density_writeValid;

	bit writeReady;

	function new(real density_rst, real density_writeValid);
		this.density_rst = density_rst;
		this.density_writeValid = density_writeValid;
		generate_new_block();
	endfunction

	task generate_new_block();
		int bindex;
		int cindex;	

		writeReady=0;
	
		bindex=0;
		cindex=0;
		this.randomize();
		randomize_difficulty();
		//$display("Block = %x",block);
		trailingzeros=$dist_uniform($random,0,256);
		//$display("Trailing Zeros = %d",trailingzeros);
		
		for(int i=0; i<trailingzeros; i++) begin
			block[bindex][cindex]=1'd0;
			cindex++;
			if(cindex==8) begin
				cindex=0;
				bindex++;
			end
		end
		$display("Block = %x",block);
		blockindex=0;
	endtask

	task write_feedback(bit write_was_ready);
		if(write_was_ready)
			writeReady=1;
		if(writeReady & writeValid)
			blockindex++;
	endtask
	local task randomize_difficulty();
		bit[7:0] exp;

		exp=$dist_uniform($random, 0, 8'h1d); //maximum exponent is 1d
		$display("Exponent is %x",exp);

		if((8'h1d - exp)>2)
			maxmantissa=32'h00ffffff;
		else begin
			maxmantissa=(64'h00ffff)<< (8'h1d - exp); //The mantissa*2^(exp) must be less than 0x00ffff*2^(1d)
		end
		this.randomize(mantissa);
		$display("Mantissa is is %x",mantissa);
		difficulty[0]=mantissa[7:0];
		difficulty[1]=mantissa[15:8];
		difficulty[2]=mantissa[23:16];
		difficulty[3]=exp;
	endtask

	local task do_write();
		//$display("Blockindex is is %x",blockindex);
		if(blockindex<32) begin
			blockData=block[31-blockindex];
		end else if(blockindex<40) begin
			blockData=$random();
		end else if(blockindex<44) begin	
			blockData=difficulty[blockindex-40];
		end else begin
			generate_new_block();
		end
	endtask

	task generate_inputs();
		int max = 1000000000;
		
		if ($dist_uniform($random, 0, max) < density_rst*max) begin rst = 1;  generate_new_block(); end else rst = 0;
		if ($dist_uniform($random, 0, max) < density_writeValid*max) begin writeValid = 1; do_write(); end else writeValid = 0;
	endtask

endclass
