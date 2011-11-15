interface rst_inf(input bit clk);
	logic rst;	
	
	clocking cb @(posedge clk);
		output rst;
	endclocking

	modport dut(input clk, input rst);
	modport bench(clocking cb);
endinterface




interface _inf(input bit clk);

	clocking cb @(posedge clk);
	
	

	endclocking

	modport dut();
	modport bench(clocking cb);
endinterface


interface sha_inf(input bit clk);
	logic [0:31] block;	

	clocking cb @(posedge clk);
	
	

	endclocking

	modport dut();
	modport bench(clocking cb);
endinterface



interface all_inf(input bit clk);
	logic rst;
	logic valid;	
	
	clocking cb @(posedge clk);
		output rst;
		input valid;

	endclocking

	modport dut(input clk, input rst, output valid);
	modport bench(clocking cb);
endinterface
