

.PHONY: nonce clean

nonce:
	vcs -PP -sverilog +define+SV +define+VPD +lint=all nonce_decoder_stim.sv ../interfaces/processorResultsIfc.sv ../shared/eff.sv ../shared/rff.sv ../shared/ff.sv nonce_decoder.sv  -o simulator.exe


clean:
	rm -rf *.o *~ *.vpd sim* csrc DVEfiles *daidir *.exe ucli.key
