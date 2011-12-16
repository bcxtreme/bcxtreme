
class inputs;

	bit rst;
	bit writeValid;
	rand bit[7:0] blockData;

	local real density_rst;
	local real density_writeValid;

	function new(real density_rst, real density_writeValid);
		this.density_rst = density_rst;
		this.density_writeValid = density_writeValid;
	endfunction

	task generate_inputs();
		int max = 1000000000;
		this.randomize();

		if ($dist_uniform($random, 0, max) < density_rst*max) rst = 1; else rst = 0;
		if ($dist_uniform($random, 0, max) < density_writeValid*max) writeValid = 1; else writeValid = 0;
	endtask

endclass
