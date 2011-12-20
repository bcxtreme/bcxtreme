#! /bin/sh 

vcs -PP -sverilog +define+SV +define+VPD +lint=all dummy.sv ../interfaces/processorResultsIfc.sv ../shared/eff.sv ../shared/rff.sv ../shared/ff.sv nonce_decoder.sv nonce_decoder_stim.sv -o simulater.exe
