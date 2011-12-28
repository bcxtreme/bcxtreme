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
NONCEBUFFER=implementation/nonce_buffer.sv
DUT=$(NONCEDECODER) $(NONCEBUFFER) $(BLOCKSTORAGE) $(SHACORE) $(HASHVAL) $(LATTICE) bcminer.sv

SHACORE_TOP=shacore_top.sv
SHACORE_BENCH=test/shacore/*.sv

VCS=vcs -PP -sverilog +define+SV -notice +define+VPD +lint=all

.PHONY: help clean bench shacore_bench test sharound_syn messageround_syn synthesis coresynthesis


bench:
	$(VCS) $(TOP) $(SHARED) $(INTERFACES) $(DUT) $(GOLD) $(BENCH) -o simulator.exe

shacore_bench:
	$(VCS) $(SHACORE_TOP) $(SHARED) $(INTERFACES) $(DUT) $(GOLD) $(SHACORE_BENCH) -o simulator.exe

coverage:
	$(VCS) $(TOP) $(SHARED) $(INTERFACES) $(DUT) $(GOLD) $(BENCH) -o simulator.exe -cm line -lca
	./simulator.exe -cm line -lca
	urg -dir simulator.exe.cm -format text -lca
	
test: bench
	./simulator.exe
coresynthesis:
	dc_shell -f coredsyn.tcl;\
	icc_shell -f corepsyn.tcl;

synthesis: sharound_syn messageround_syn
	dc_shell -f dsyn.tcl
	icc_shell -f psyn.tcl

sharound_syn:
	cd shacore/precompiled/sharound;\
	dc_shell -f dsyn.tcl;\
	cd ../../..;

messageround_syn:
	cd shacore/precompiled/messageschedule;\
	dc_shell -f dsyn.tcl;\
	cd ../../..;

help:
	@echo "The following make targets are supported:"; \
	 echo "  bench            - builds the testbench for the bcminer"; \
	 echo "  shacore_bench    - builds the testbench for the ShaCore"; \
	 echo "  coverage         - runs the code coverage tool"; \
	 echo "  test             - compiles the bench, then runs simulator.exe"; \
	 echo "  synthesis        - synthesize the entire design"; \
	 echo "  coresynthesis    - synthesize the ShaCore"; \
	 echo "  sharound_syn     - synthesize a single Sha round"; \
	 echo "  messageround_syn - synthesize a single message round"; \
	 echo "  clean            - cleans the testbench and intermediate files"; \
	 echo "  help             - show this help information";

clean:
	rm -rf *.o *~ *.vpd sim* csrc DVEfiles *daidir *.exe ucli.key

