
program automatic test
(
  signal_interface.TEST sig,
  read_interface.TEST rif,
  write_interface.TEST wif,
  search_interface.TEST sif
);

Environment env;

initial begin

  env = new( sig, rif, wif, sif );
  env.configure();
  env.go();

end
           
endprogram : test

