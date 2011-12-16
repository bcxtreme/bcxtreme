
class inputs;

	bit rst;
	bit valid;
	rand bit[256:0] hashstate;
	rand bit[31:0] w1;
	rand bit[31:0] w2;
	rand bit[31:0] w3;

	local real density_rst;
	local real density_valid;

	function new(real density_rst, real density_valid);
		this.density_rst = density_rst;
		this.density_valid = density_valid;
	endfunction

	task generate_inputs();
		int max = 1000000000;
		this.randomize();

		if ($dist_uniform($random, 0, max) < density_rst*max) rst = 1; else rst = 0;
		if ($dist_uniform($random, 0, max) < density_writeValid*max) valid = 1; else valid = 0;
	endtask

endclass
