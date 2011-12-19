interface coreInputsIfc(input logic clk);
logic valid;
logic newblock;
HashState hashstate;
logic[31:0] w1;
logic[31:0] w2;
logic[31:0] w3;

clocking cb @(posedge clk);
  output valid;
  output newblock;
  output hashstate;
  output w1;
  output w2;
  output w3;
endclocking

modport bench(clocking cb);
modport writer(output valid, output newblock, output hashstate, output w1, output w2, output w3);
modport reader(input valid, input newblock, input hashstate, input w1, input w2, input w3);
endinterface
