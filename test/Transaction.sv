
class Transaction;  
  static int count = 0;
  int id;

  rand bit read;
  rand bit[4:0] read_index;
  rand bit write;
  rand bit[4:0] write_index;
  rand bit[31:0] write_data;

  function new();
    id = count;
    ++count;
  endfunction : new

endclass : Transaction 

