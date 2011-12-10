SV=vcs -sverilog +lint=PCWM -debug_pp

SRC=SHA256.sv

all:
	$(SV) $(SRC) test.sv -o test

tarball: clean
	tar -czvf source.tar.gz *

clean:
	rm -rf test .vcs.timestamp.tmp DVEfiles csrc *.daidir *.vpd *.vdb ucli.key source.tar.gz 

