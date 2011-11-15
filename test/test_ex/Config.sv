class Config;

  int seed = 1;
  int max_transactions = 10000;
  string filename = "config.txt";

  function new();

    int file = $fopen(filename, "r");
    string param;
    string value;

    while(!$feof(file)) begin
      $fscanf(file, "%s %d", param, value);
      if ("RANDOM_SEED" == param) begin
        seed = value;
      end
      else if("TRANSACTIONS" == param) begin
        max_transactions = value;
      end
      else begin
        $display("Never heard of a: %s", param);
        $exit();
      end
    end
    
    if ( $test$plusargs( "ntb_random_seed" ) ) begin
      $value$plusargs( "ntb_random_seed=%d", seed );
      $display( "Random seed=%0d read from command-line", seed );
    end

    if ( seed != 0 )
      $display( "Random seed=%0d read from config file", seed );
    else
      $display( "Using default random seed=%0d", seed );

    $srandom( seed );

  endfunction : new

  function display();
    $display( "Simulation run with random seed=%0d, maximum transactions=%0d", seed, max_transactions );   
  endfunction : display

endclass : Config

