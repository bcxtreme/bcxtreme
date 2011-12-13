
class Generator;
  
  virtual signal_interface.TEST sig;
  virtual read_interface.TEST rif;
  virtual write_interface.TEST wif;
  virtual search_interface.TEST sif;
  
  Transaction t;
  Model model;
  

  function new( virtual signal_interface.TEST sig, virtual read_interface.TEST rif, virtual write_interface.TEST wif, virtual search_interface.TEST sif );
    this.sig = sig;
    this.rif = rif;
    this.wif = wif;
    this.sif = sif;
  endfunction : new

  task run( int iterations );
    
    string header;
    string format;


    #5;

    model = new();

    header =  "[write] [write_index] [write_data] [read] [read_index] [DUT.read_valid] [Model.read_valid] [DUT.read_value] [Model.read_value]";
    format =  "      %d            %d   %d      %d           %d                %d                  %d       %d         %d   ...  %s";
	
		sig.reset <= 1;
		model.reset = 1;
		model.rst();

    repeat ( iterations ) begin

      //$display( t.count, t.id );
    	t = new();
      t.randomize();

      if ( t.id % 10 == 0 )
        $display( header ); //"[write] [write_index] [write_data] [read] [read_index] [DUT.read_valid] [Model.read_valid] [DUT.read_value] [Model.read_value]" );

			sig.reset <= 0;
			model.reset = 0;
			model.rst();

        // drive hardware

      rif.read <= t.read;
      rif.read_index <= t.read_index;

      wif.cb.write <= t.write;
      wif.cb.write_index <= t.write_index;
      wif.cb.write_data <= t.write_data;

      // replicate in model

      model.read = t.read;
      model.read_index = t.read_index;

      model.write = t.write;
      model.write_index = t.write_index;
      model.write_data = t.write_data;
      
      // iterate
      @(wif.cb);
      model.execute();

      // check value
      $display( format, t.write, t.write_index, t.write_data, t.read, t.read_index, 
        rif.read_valid, model.readValid(), rif.read_value, model.readValue(), 
        ( ( rif.read_valid == model.readValid() ) && ( rif.read_value == model.readValue() ) ) ? "PASS":"FAIL" );
      
    end

  endtask : run

endclass : Generator

