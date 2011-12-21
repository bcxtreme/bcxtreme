interface processorResultsIfc #(parameter NUM_CORES=10,PARTITIONBITS=$clog2(NUMPROCESSORS)) (input logic clk);
logic success;
logic[PARTITIONBITS-1:0] processor_index;

modport writer(output success, output processor_index);
modport reader(input success, input processor_index);
endinterface
