
module golden_sha_stim();

  bit clk;

  coreInputsIfc inputs(.clk);
  golden_sha test;
  HashState hashstate;

  initial begin
    inputs.valid = 1;
    inputs.newblock = 1;
    
    /*hashstate.a = little_endian_to_big( 32'h9524c593 ); 
    hashstate.b = little_endian_to_big( 32'h05c56713 ); 
    hashstate.c = little_endian_to_big( 32'h16e669ba ); 
    hashstate.d = little_endian_to_big( 32'h2d2810a0 ); 
    hashstate.e = little_endian_to_big( 32'h07e86e37 ); 
    hashstate.f = little_endian_to_big( 32'h2f56a9da ); 
    hashstate.g = little_endian_to_big( 32'hcd5bce69 ); 
    hashstate.h = little_endian_to_big( 32'h7a78da2d );
    */
    
    hashstate.a = 32'h9524c593; 
    hashstate.b = 32'h05c56713; 
    hashstate.c = 32'h16e669ba; 
    hashstate.d = 32'h2d2810a0; 
    hashstate.e = 32'h07e86e37; 
    hashstate.f = 32'h2f56a9da; 
    hashstate.g = 32'hcd5bce69; 
    hashstate.h = 32'h7a78da2d;
    
    
    inputs.hashstate = hashstate;
    
    /*
    inputs.w1 = little_endian_to_big( 32'hf1fc122b );
    inputs.w2 = little_endian_to_big( 32'hc7f5d74d );
    inputs.w3 = little_endian_to_big( 32'hf2b9441a );
    */

    inputs.w1 = 32'hf1fc122b;
    inputs.w2 = 32'hc7f5d74d;
    inputs.w3 = 32'hf2b9441a;
    //inputs.w3 = 1;
     
    // etc...
    test = new ( inputs );
    
    test.evaluate();
    $display( "%h", test.getResult() );

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

