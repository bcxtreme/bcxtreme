
TOP=top.sv
INTERFACE=test_interface.sv
BENCH=testbench.sv
DUT=ff.sv

.PHONY: help

help:
        @echo "The following make targets are supported:" ;\
		echo " bench  - builds and runs the testbench";\
		echo " expand - expands veritedium directives (autoargs, inst etc.)";\
		echo " indent - automatically indents verilog and c files" ;\
		echo " clean  - cleans testbench and intermediate files" ;\
		echo " help   - show this information";\


indent:
		emacs --batch *.sv -f verilog-batch-indent
		indent -linux *.c *.h
		rm *~

dut:
		vcs -PP -sverilog +define+SV +define+VPD $(INTERFACE) $(DUT)

test:
		vcs -PP -sverilog +define+SV +define+VPD $(INTERFACE) $(BENCH)

bench:
		vcs -PP -sverilog +define+SV +define+VPD $(TOP) $(INTERFACE) $(BENCH) -o testbench.exe

clean:
		rm -rf *.o *~ *.vpd sim* csrc DVEfiles *daidir *exe
