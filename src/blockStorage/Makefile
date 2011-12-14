SV=vcs -sverilog +lint=PCWM -debug_pp

SRC=blockStorage.sv
SHARED=../shared/ff.sv
INTERFACES=../interfaces/blockStoreIfc.sv
TEST=blockStorage_stim.sv

all:
	$(SV) $(SHARED) $(SRC) $(INTERFACES) $(TEST) -o test

tarball: clean
	tar -czvf source.tar.gz *

clean:
	rm -rf test .vcs.timestamp.tmp DVEfiles csrc *.daidir *.vpd *.vdb ucli.key source.tar.gz 

