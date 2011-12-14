INTERFACES=../interfaces/blockStoreIfc.sv ../interfaces/nonceBufferIfc.sv
SHARED=../shared/eff.sv

BLOCKSTORAGE=golden_blockstorage.sv
BCMINER=$(BLOCKSTORAGE) golden_bcminer.sv



.PHONY: bcminer blockstorage help clean


help:
	@echo "The following STIM targets are supported:"; \
	 echo "  bcminer"; \
	 echo "  blockstorage"; \
	 echo ""; \
	 echo "PROBLEM: These STIM files are out of date ...";

bcminer:
	vcs -PP -sverilog +define+SV +define+VPD $(INTERFACES) $(SHARED) $(BCMINER) golden_bcminer_stim.sv -o simulator.exe

blockstorage:
	vcs -PP -sverilog +define+SV +define+VPD $(INTERFACES) $(SHARED) $(BLOCKSTORAGE) golden_blockstorage_stim.sv -o simulator.exe


clean:
	rm -rf *.o *~ *.vpd sim* csrc DVEfiles *daidir *.exe ucli.key

