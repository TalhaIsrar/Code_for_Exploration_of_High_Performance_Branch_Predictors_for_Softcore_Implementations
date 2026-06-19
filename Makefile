# Cocotb Macros
SIM ?= verilator
TOPLEVEL_LANG ?= verilog
WAVES = 0 # 1 for waveform debugging

# Adding all .v and .sv files
VERILOG_SOURCES := $(shell find $(PWD)/rtl -type f \( -name "*.v" -o -name "*.sv" \))
VERILOG_INCLUDE := $(shell find $(PWD)/rtl -type d)
INC_DIRS := $(foreach dir,$(VERILOG_INCLUDE),+incdir+$(dir))

# EXTRA_ARGS += --trace --trace-structs --trace-fst --timing -j 8 $(INC_DIRS) # Use for debugging to generate wavefile
EXTRA_ARGS += -j 40  $(INC_DIRS)# Use this for faster simulation

# Connects cocotb test.py -> TB in verilog
TOPLEVEL = riscv_tb
MODULE = test

all:
	@echo "Select out of following options:"
	@echo "  make custom"
	@echo "  make riscv-tests"
	@echo "  make dhrystone"
	@echo "  make coremark"
	@echo "  make embench_all"

.PHONY: custom riscv-tests dhrystone coremark
custom: del
	@echo "---------------- Starting Custom C tests ----------------"
	$(MAKE) -C custom_c_test
	$(MAKE) convert_mem

riscv-tests: del
	@echo "---------------- Starting riscv-tests ----------------"
	$(MAKE) -C riscv-tests
	$(MAKE) convert_mem

dhrystone: del
	@echo "---------------- Starting Dhrystone Benchmark ----------------"
	$(MAKE) -C dhrystone
	$(MAKE) convert_mem

coremark: del
	@echo "---------------- Starting Coremark Benchmark ----------------"
	$(MAKE) -C coremark
	$(MAKE) convert_mem

aha-mont64:
	$(MAKE) embench BENCH=aha-mont64
crc32:
	$(MAKE) embench BENCH=crc32
cubic:
	$(MAKE) embench BENCH=cubic
edn:
	$(MAKE) embench BENCH=edn	
huffbench:
	$(MAKE) embench BENCH=huffbench
matmult-int:
	$(MAKE) embench BENCH=matmult-int
md5sum:
	$(MAKE) embench BENCH=md5sum
minver:
	$(MAKE) embench BENCH=minver
nbody:
	$(MAKE) embench BENCH=nbody
nettle-aes:
	$(MAKE) embench BENCH=nettle-aes
nettle-sha256:
	$(MAKE) embench BENCH=nettle-sha256
nsichneu:
	$(MAKE) embench BENCH=nsichneu
picojpeg:
	$(MAKE) embench BENCH=picojpeg
primecount:
	$(MAKE) embench BENCH=primecount
qrduino:
	$(MAKE) embench BENCH=qrduino
sglib-combined:
	$(MAKE) embench BENCH=sglib-combined
slre:
	$(MAKE) embench BENCH=slre
st:
	$(MAKE) embench BENCH=st
statemate:
	$(MAKE) embench BENCH=statemate
tarfind:
	$(MAKE) embench BENCH=tarfind
ud:
	$(MAKE) embench BENCH=ud
wikisort:
	$(MAKE) embench BENCH=wikisort
depthconv:
	$(MAKE) embench BENCH=depthconv
xgboost:
	$(MAKE) embench BENCH=xgboost

EMBENCH_LIST := \
	aha-mont64 crc32 cubic edn huffbench matmult-int md5sum minver \
	nbody nettle-aes nettle-sha256 nsichneu picojpeg primecount qrduino \
	sglib-combined slre st statemate tarfind ud wikisort depthconv xgboost
OTHER_BENCH := coremark dhrystone

# Convert .elf files to mem files
convert_mem: code.mem data.mem simulation

# Convert .bin files to .mem files in word addressable format
code.mem: code.bin core.dump
	@echo "---------------- Making code.mem ----------------"
	hexdump -v -e '1/4 "%08x\n"' code.bin > code.mem

data.mem: data.bin
	@echo "---------------- Making data.mem ----------------"
	hexdump -v -e '1/4 "%08x\n"' data.bin > data.mem

# Extract code and data sections
code.bin:
	riscv32-unknown-elf-objcopy -O binary --only-section=.text core.elf code.bin

data.bin: 
	riscv32-unknown-elf-objcopy -O binary -j .data -j .sdata core.elf data.bin

# Cocotb's makefile calls verilator and runs Python against the build simulation
simulation: code.mem data.mem del_extras
	@echo "---------------- Simulation Start ----------------"
	$(MAKE) -f $(shell cocotb-config --makefiles)/Makefile.sim \
		SIM=$(SIM) \
		TOPLEVEL_LANG=$(TOPLEVEL_LANG) \
		TOPLEVEL=$(TOPLEVEL) \
		MODULE=$(MODULE) \
		WAVES=$(WAVES) \
		VERILOG_SOURCES="$(VERILOG_SOURCES)" \
		EXTRA_ARGS="$(EXTRA_ARGS)"
	$(MAKE) del_extras

del_extras:
	-rm -rf *.o *.bin *.elf *.xml sim_build

del:
	-rm -rf *.o *.mem *.bin *.elf *dump* *.xml sim_build

.DEFAULT_GOAL := all

.PHONY: embench_all

embench: del
	@echo "---------------- Starting Embench: $(BENCH) ----------------"
	$(MAKE) -C embench BENCH=$(BENCH)
	$(MAKE) convert_mem

embench_all:

	@for bench in $(EMBENCH_LIST); do \
		echo ""; \
		echo "=============================================================== $$bench "===============================================================; \
		echo ""; \
		$(MAKE) $$bench; \
	done
