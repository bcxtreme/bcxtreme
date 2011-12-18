INTERFACES=../interfaces/blockStoreIfc.sv ../interfaces/nonceBufferIfc.sv 
SHARED=../shared/eff.sv

BLOCKSTORAGE=golden_blockstorage.sv
BCMINER=$(BLOCKSTORAGE) golden_bcminer.sv
SHA=../../test/sha256/SHA256.sv golden_sha.sv


.PHONY: bcminer blockstorage sha help clean


help:
	@echo "The following STIM targets are supported:"; \
	 echo "  bcminer"; \
	 echo "  blockstorage"; \
	 echo "  sha"; \
	 echo ""; \
	 echo "PROBLEM: These STIM files are out of date ...";

bcminer:
	vcs -PP -sverilog +define+SV +define+VPD $(INTERFACES) $(SHARED) $(BCMINER) golden_bcminer_stim.sv -o simulator.exe

blockstorage:
	vcs -PP -sverilog +define+SV +define+VPD $(INTERFACES) $(SHARED) $(BLOCKSTORAGE) golden_blockstorage_stim.sv -o simulator.exe

sha:
	vcs -PP -sverilog +define+SV +define+VPD ../shared/hashstate.sv ../interfaces/coreInputsIfc.sv $(SHARED) $(SHA) golden_sha_stim.sv -o golden_sha_stim


clean:
	rm -rf *.o *~ *.vpd sim* csrc DVEfiles *daidir *_stim *.exe ucli.key

