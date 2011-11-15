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
	logic success;
	logic valid;
	logic [0:31] index;	
	
	clocking cb @(posedge clk);
		output rst;
		input valid;
		input success;
		input index;
	endclocking

	modport dut(input clk, input rst, output valid, output success, output index);
	modport bench(clocking cb);
endinterface
