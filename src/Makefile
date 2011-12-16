TOP=top.sv
INTERFACES=interfaces/*.sv
BENCH=test/inputs.sv test/environ.sv test/bench.sv
GOLD=gold/golden_blockstorage.sv gold/golden_bcminer.sv

SHARED=shared/eff.sv implementation/shared/*.sv
IMPLEMENTATION=implementation/*.sv
DUT=$(IMPLEMENTATION) 

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

