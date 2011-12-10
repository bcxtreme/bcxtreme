SHA_VERILOGS=shacore/*.sv
SHARED_VERILOGS=shared/*.sv
TOP_VERILOGS=top/*.sv

VCSARGS= \
-PP -sverilog\
+define+SV +define+VPD +lint=all\
#-cm_tgl mda -debug -lca -cm line+cond+fsm+tgl+path

all: shacore_design

shacore_design: $(SHARED_VERILOGS) $(TOP_VERILOGS) $(SHA_VERILOGS)
	vcs $(VCSARGS) $(SHARED_VERILOGS) $(TOP_VERILOGS)  $(SHA_VERILOGS) -o shacore_design
