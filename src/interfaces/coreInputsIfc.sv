interface coreInputsIfc(input logic clk);
logic valid;
logic newblock;
HashState hashstate;
logic[31:0] w1;
logic[31:0] w2;
logic[31:0] w3;

modport writer(output newblock, output hashstate, output w1, output w2, output w3);
modport reader(input newblock, input hashstate, input w1, input w2, input w3);
endinterface
