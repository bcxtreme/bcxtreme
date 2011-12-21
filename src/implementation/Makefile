

.PHONY: nonce clean

nonce:
	vcs -PP -sverilog +define+SV +define+VPD +lint=all ../interfaces/processorResultsIfc.sv ../shared/rff.sv ../shared/ff.sv nonce_decoder.sv  nonce_decoder_stim.sv -o simulator.exe

test:
	vcs -PP -sverilog +define+SV +define+VPD +lint=all ../interfaces/processorResultsIfc.sv ../shared/rff.sv ../shared/ff.sv  nonce_decoder_stim.sv -o simulator.exe

clean:
	rm -rf *.o *~ *.vpd sim* csrc DVEfiles *daidir *.exe ucli.key
