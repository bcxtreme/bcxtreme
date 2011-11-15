
class Environment;
  
  virtual signal_interface.TEST sig;
  virtual read_interface.TEST rif;
  virtual write_interface.TEST wif;
  virtual search_interface.TEST sif;
  
  Config conf;
  Generator gen;


  function new( virtual signal_interface.TEST sig, virtual read_interface.TEST rif, virtual write_interface.TEST wif, virtual search_interface.TEST sif );

    this.sig = sig;
    this.rif = rif;
    this.wif = wif;
    this.sif = sif;

  endfunction : new

  function void configure();
    conf = new();
    conf.display();
  endfunction : configure

  task go();
    gen = new( sig, rif, wif, sif );
    gen.run( conf.max_transactions );
  endtask : go

endclass : Environment 

