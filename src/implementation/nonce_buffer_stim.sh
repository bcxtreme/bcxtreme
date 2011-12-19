#! /bin/sh 

vcs -PP -sverilog +define+SV +define+VPD ../shared/eff.sv ../shared/rff.sv ../shared/ff.sv nonce_buffer.sv nonce_buffer_stim.sv -o nonce_buffer_stim
