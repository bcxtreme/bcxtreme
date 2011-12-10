TOP=top.sv
INTERFACES=interfaces/blockStoreIfc.sv interfaces/nonceBufferIfc.sv
BENCH=bench.sv
DUT=bcminer.sv

.PHONY: help clean bench


bench:
	vcs -PP -sverilog +define+SV +define+VPD $(TOP) $(INTERFACES) $(DUT) $(BENCH) -o testbench.exe

help:
	@echo "The following make targets are supported:"; \
	 echo "  bench  - builds the testbench for the bcminer"; \
	 echo "  clean  - cleans the testbench and intermediate files"; \
	 echo "  help   - show this help information";

clean:
	rm -rf *.o *~ *.vpd sim* csrc DVEfiles *daidir *.exe ucli.key

