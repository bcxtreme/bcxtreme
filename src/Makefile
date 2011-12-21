TOP=top.sv
INTERFACES=interfaces/blockStoreIfc.sv interfaces/nonceBufferIfc.sv interfaces/minerIfc.sv \
           interfaces/coreInputsIfc.sv interfaces/processorResultsIfc.sv
GOLD=gold/golden_noncebuffer.sv gold/golden_noncedecoder.sv gold/SHA256.sv \
     gold/golden_hashvalidator.sv gold/golden_sha.sv gold/golden_blockstorage.sv gold/golden_bcminer.sv
BENCH=test/inputs.sv test/environ.sv test/bench.sv

SHARED=shared/*.sv
BLOCKSTORAGE=implementation/shift_register.sv implementation/block_storage.sv
SHACORE=shacore/*.sv shacore/precompiled/messageschedule/src/*.sv\
	shacore/precompiled/sharound/src/*.sv shacore/super_pipelined/*.sv\
	shacore/super_pipelined/last/*.sv shacore/super_pipelined/standard/*.sv
HASHVAL=implementation/standard_hash_validator.sv implementation/final_hash_validator.sv
LATTICE=implementation/lattice_ff_input.sv implementation/lattice_ff_output.sv \
        implementation/lattice_core.sv implementation/lattice_core_last.sv \
        implementation/lattice_block.sv implementation/lattice_block_first.sv implementation/lattice_block_last.sv
NONCEDECODER=implementation/nonce_decoder.sv
DUT=$(NONCEDECODER) $(BLOCKSTORAGE) $(SHACORE) $(HASHVAL) $(LATTICE) bcminer.sv

SHACORE_TOP=shacore_top.sv
SHACORE_BENCH=test/shacore/*.sv

VCS=vcs -PP -sverilog +define+SV -notice +define+VPD +lint=all

.PHONY: help clean bench shacore_bench test


bench:
	$(VCS) $(TOP) $(SHARED) $(INTERFACES) $(DUT) $(GOLD) $(BENCH) -o simulator.exe

shacore_bench:
	$(VCS) $(SHACORE_TOP) $(SHARED) $(INTERFACES) $(DUT) $(GOLD) $(SHACORE_BENCH) -o simulator.exe

test: bench
	./simulator.exe

help:
	@echo "The following make targets are supported:"; \
	 echo "  bench  - builds the testbench for the bcminer"; \
	 echo "  clean  - cleans the testbench and intermediate files"; \
	 echo "  help   - show this help information";

clean:
	rm -rf *.o *~ *.vpd sim* csrc DVEfiles *daidir *.exe ucli.key

