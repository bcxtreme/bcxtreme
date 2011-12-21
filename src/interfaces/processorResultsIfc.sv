interface processorResultsIfc #(parameter NUM_CORES=10)(input logic clk);
	parameter PARTITIONBITS = $clog2(NUM_CORES);
	logic success;
	logic[PARTITIONBITS-1:0] processor_index;

	modport writer(output success, output processor_index);
	modport reader(input success, input processor_index);
endinterface
