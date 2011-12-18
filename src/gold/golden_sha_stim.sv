
module golden_sha_stim();

  bit clk;

  coreInputsIfc inputs(.clk);
  golden_sha test;

  initial begin
    inputs.valid = 1;
    inputs.newblock = 0;
    // etc...
    test = new ( inputs );
    
    test.evaluate();

    // modify inputs for next evaluation
    inputs.valid = 1;
    inputs.newblock = 0;
    inputs.w1 = 4;
    // etc...
    
    test.configure( inputs );
    test.evaluate();

    // or test.set_and_evaluate( inputs );

    // and results and hashstate are available
    $display( "%h", test.getResult() );
    $display( test.get_hashstate() );

  end

endmodule

