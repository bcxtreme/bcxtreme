
class golden_sha;

  
  bit data[];

  function new ( bit valid, bit newBlock, bit[512:0] initialState, bit[31:0] w1, bit[31:0] w2, bit[31:0] w3 ) 
    
    data = new[1024](initialState);
    

  endfunction  




endclass

