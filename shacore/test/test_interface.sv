interface input_com_ifc(input bit clk);
	logic rst;
	
	clocking cb @(posedge clk);
		output rst;

	endclocking

	modport dut(input clk, input rst);
	modport bench(clocking cb);
endinterface




interface rst_ifc(input bit clk);
	logic rst;	
	
	clocking cb @(posedge clk);
		output rst;
	endclocking

	modport dut(input clk, input rst);
	modport bench(clocking cb);
endinterface

interface indexgen_ifc(input bit clk);
	logic rst;
	logic start;
	
	clocking cb @(posedge clk);
		output rst;
		output start;
	endclocking

	modport dut(input rst, input clk, input start);
	modport bench(clocking cb);
endinterface


interface sha_ifc(input bit clk);
	logic [31:0] a;
	logic [31:0] b;
	logic [31:0] c;
	logic [31:0] d;
	logic [31:0] e;
	logic [31:0] f;
	logic [31:0] g;
	logic [31:0] h;
	logic valid;
	logic success;
	
	clocking cb @(posedge clk);
		output a;
		output b;
		output c;
		output d;
		output e;
		output f;
		output g;
		output h;
		input valid;
		input success;

	endclocking

	modport dut(input clk, 
				input a, 
				input b, 
				input c, 
				input d, 
				input e, 
				input f, 
				input g, 
				input h, 
				output valid, 
				output success);
	modport bench(clocking cb);
endinterface


interface all_ifc(input bit clk);
	logic rst;
	logic success;
	logic valid;
	logic [31:0] index;	
	logic [31:0] data;
	logic ready;
	
	clocking cb @(posedge clk);
		output rst;
		output data;
		output ready;
		input valid;
		input success;
		input index;
	endclocking

	modport dut(input clk, input rst, input data, input ready, output valid, output success, output index);
	modport bench(clocking cb);
endinterface
