//'timescale 1ns/1ps

module top();
	bit clk = 0;
	always #5 clk = ~clk;
	
	initial $vcdpluson;
	
	rst_ifc rst_IFC(clk);
	indexgen_ifc indexgen_IFC(clk);
	sha_ifc sha_IFC(clk);
	all_ifc all_IFC(clk);

	tb bench(all_IFC.bench);
endmodule
