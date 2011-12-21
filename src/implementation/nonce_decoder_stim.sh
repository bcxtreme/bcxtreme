#! /bin/sh 

vcs -PP -sverilog  nonce_decoder_stim.sv ../interfaces/processorResultsIfc.sv ../shared/eff.sv ../shared/rff.sv ../shared/ff.sv nonce_decoder.sv  -o simulator.exe
