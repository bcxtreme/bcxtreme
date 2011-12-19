
module golden_sha_stim();

  bit clk;

  golden_sha #(.DELAY_C(256)) test;

  initial begin
    
    bit[31:0] w1, w2, w3;
    bit[31:0] hs[8];

    hs[0] = 32'h9524c593; 
    hs[1] = 32'h05c56713; 
    hs[2] = 32'h16e669ba; 
    hs[3] = 32'h2d2810a0; 
    hs[4] = 32'h07e86e37; 
    hs[5] = 32'h2f56a9da; 
    hs[6] = 32'hcd5bce69; 
    hs[7] = 32'h7a78da2d;
    
    
    /*
    inputs.w1 = little_endian_to_big( 32'hf1fc122b );
    inputs.w2 = little_endian_to_big( 32'hc7f5d74d );
    inputs.w3 = little_endian_to_big( 32'hf2b9441a );
    */

    w1 = 32'hf1fc122b;
    w2 = 32'hc7f5d74d;
    w3 = 32'hf2b9441a;
    //inputs.w3 = 1;
     
    // etc...

    test = new ();
    
    test.validIn_i = 1;
    test.newBlockIn_i = 1;
    test.initialState_i = { hs[0], hs[1], hs[2], hs[3], hs[4], hs[5], hs[6], hs[7], w1, w2, w3 };

    test.cycle();

    test.validIn_i = 1;
    test.newBlockIn_i = 0;

    for (int i = 1; i < 255; i++)
        test.cycle();

    $display("Hash: %x, Valid: %b; New: %b", test.hash_o, test.validOut_o, test.newBlockOut_o);
    test.cycle();
    $display("Hash: %x, Valid: %b; New: %b", test.hash_o, test.validOut_o, test.newBlockOut_o);
    test.cycle();
    $display("Hash: %x, Valid: %b; New: %b", test.hash_o, test.validOut_o, test.newBlockOut_o);
    test.cycle();
    $display("Hash: %x, Valid: %b; New: %b", test.hash_o, test.validOut_o, test.newBlockOut_o);
    test.cycle();
    $display("Hash: %x, Valid: %b; New: %b", test.hash_o, test.validOut_o, test.newBlockOut_o);
    test.cycle();
    $display("Hash: %x, Valid: %b; New: %b", test.hash_o, test.validOut_o, test.newBlockOut_o);
    /* 
    // modify inputs for next evaluation
    inputs.valid = 1;
    inputs.newblock = 0;
    inputs.w1 = 4;
    // etc...
    
    test.configure( inputs );
    test.evaluate();

    // or test.set_and_evaluate( inputs );
  
    // and results and hashstate are available
    //$display( "%h", test.getResult() );
    //$display( test.get_hashstate() );
    */

  end

endmodule

