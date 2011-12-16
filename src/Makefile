TOP=top.sv
INTERFACES=interfaces/blockStoreIfc.sv interfaces/nonceBufferIfc.sv
BENCH=test/inputs.sv test/environ.sv test/bench.sv
GOLD=gold/golden_blockstorage.sv gold/golden_bcminer.sv

SHARED=shared/eff.sv implementation/shared/*.sv
BLOCKSTORAGE=implementation/shift_register.sv implementation/block_storage.sv
DUT=$(SHARED) $(BLOCKSTORAGE) bcminer.sv

HASHVALIDATOR_TOP=hashvalidator_top.sv
HASHVALIDATOR_BENCH=test/hashvalidator/inputs.sv test/hashvalidator/environ.sv test/hashvalidator/bench.sv

VCS=vcs -PP -sverilog +define+SV -notice +define+VPD +lint=all

.PHONY: help clean bench hashvalidator_bench test


bench:
	$(VCS) $(TOP) $(INTERFACES) $(DUT) $(GOLD) $(BENCH) -o simulator.exe

hashvalidator_bench:
	$(VCS) $(HASHVALIDATOR_TOP) $(INTERFACES) $(DUT) $(GOLD) $(HASHVALIDATOR_BENCH) -o simulator.exe

test: bench
	./simulator.exe

help:
	@echo "The following make targets are supported:"; \
	 echo "  bench  - builds the testbench for the bcminer"; \
	 echo "  clean  - cleans the testbench and intermediate files"; \
	 echo "  help   - show this help information";

clean:
	rm -rf *.o *~ *.vpd sim* csrc DVEfiles *daidir *.exe ucli.key

