interface datapath();
logic rst;
logic[31:0] data;
logic ready;

modport DUT(input rst, input data, output ready);
modport external(output rst, output data, input ready);

endinterface

interface indexgenerator();
logic rst;
logic start;
logic[31:0] data;

endinterface

interface shahash();
  logic[31:0] a;
  logic[31:0] b;
  logic[31:0] c;
  logic[31:0] d;
  logic[31:0] e;
  logic[31:0] f;
  logic[31:0] g;
  logic[31:0] h;
  logic valid;
  modport in(input a, input b, input c, input d, input e, input f, input g, input h, input valid);
  modport out(output a, output b, output c, output d, output e, output f, output g, output h, output valid);
endinterface

interface hashvalid();
  logic valid;
  logic success;

  modport in(input valid, input success);
  modport out(output valid, output success);
endinterface

interface result();
logic[31:0] index;
logic valid;
logic success;

 modport DUT(output index, output valid, output success);
 modport external(input index, input valid, input success);
endinterface
