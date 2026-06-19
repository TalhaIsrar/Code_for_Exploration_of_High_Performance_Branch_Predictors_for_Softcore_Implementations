# Branch Predictor Exploration for RISC-V Softcores
This repository serves as a branch predictor softcore testing framework. It contains multiple implementations of branch predictors of varying complexity. Each branch predictor performance is tested using the coremark benchmark program.

## 📑 Table of Contents

* [Repository Structure](#-repository-structure)
* [Baseline](#-baseline)
* [Predictor Versions](#-predictor-versions)
* [Usage](#-usage)
* [Prerequisites](#-Prerequisites)
* [Installation](#-installation)

## 📂 Repository Structure

```
branch_predictor_softcore_versions/     Different branch predictors with a RV32IM core
custom_c_test/                          Test custom programs on the core
riscv-tests/          
dhrystone/          
coremark/     
embench/     
rtl/                                    RTL code for RISC-V Core to test
Makefile
test.py                                 Cocotb test file
README.md                               This file
```

## 📊 Baseline
To test the performance of the different branch predictors, a baseline risc-v core has been used. It is based on the RV32IM ISA. Some features are:
* 5 Stage pipelined core
* RV32IM ISA support
* Multiplication takes 1 cycle and Division/Remainder is configurable and execution cycles depend on desired Fmax. For purpose of experients here it takes 16 cycles
* Jump/Branch operation is performed in MEM stage to achieve high Fmax
* The core has memory mapped registers for cycle count, instruction count, jump/branch instruction and misprediction count
* Branch Prediction Unit is connected to IF stage for prediction and update happens in MEM stage
* All big memory elements like memories, btb tables etc are modelled using BRAM

---

## ⚡ Predictor Versions

- [Always Not Taken](branch_predictor_softcore_versions/rv32im_not_taken/riscv_soc_top.sv)  
  This is the baseline version, because having no predictor and no target buffer is essentially same as branches always not taken.

- [Always Taken](branch_predictor_softcore_versions/rv32im_always_taken_2xn/riscv_soc_top.sv)  
  This version has a 2-way set assosiative branch target buffer with Least Recently Used (LRU) replacement policy. It is used to store targets for previously seen jump/branch instruction and for next occourance it uses stored addresses and always jumps. For jump/branch instructions seen for the first time, they are not taken.

- [Alternating](branch_predictor_softcore_versions/rv32im_alternating_2xn/riscv_soc_top.sv)  
  This version has a 2-way set assosiative branch target buffer with Least Recently Used (LRU) replacement policy. It is used to store targets for previously seen jump/branch instruction and also stores last action it takes and alternates the action next time so if last time a specific branch instruction was taken, this time it is not taken.

- [TAGE](branch_predictor_softcore_versions/rv32im_tage/riscv_soc_top.sv)  
  This version has a parametric TAGE branch predictor with configurable number of tables, table size, tag size, GHR length used a BTB size. The tables are designed such that they utilize BRAM.

- [TAGE-SC](branch_predictor_softcore_versions/rv32im_tage_sc/riscv_soc_top.sv)  
  This version has a parametric TAGE-SC branch predictor with configurable number of tables, table size, tag size, GHR length used a BTB size. The tables are designed such that they utilize BRAM.

---

## 💻 Prerequisites

* Linux / WSL
* **RISC-V GNU Toolchain** (Tested: `riscv32-unknown-elf-gcc 15.2.0`)
* **Verilator** (Tested: `v5.042`)
* **cocotb** (Tested: `2.0.1`)
* Gtkwave (optional)
* Vivado (Tested `2022.2`, `2025.1` for Area and Frequency estimates for FPGA)

For Benchmarking purposes, CoreMark, Dhrystone, Embench-IoT and RISCV-Tests have been used. These benchmarks have been developed by others and have been configured according to our requirements. To use these, the folders (coremark, dhrystone, embench, riscv-tests) must be copied from [link](https://github.com/TalhaIsrar/Branch_Predictor_Exploration_for_RISC-V_Softcores) into the root directory of this repo.

---

## 🔄 Usage (New)
To run coremark or embench_iot the provided scripts can be used: 

```bash
./run_tests.sh <softcore_bpu_name> <configuration_name>
./run_embench.sh <softcore_bpu_name> <configuration_name>
```
The softcore_bpu name can be found as the folder names in bpu_configuration and the configuration_name is the name of the respective file within each subfolder. Make sure to activate the python enviornemnt discussed below before running the tests.

## 🔄 Vivado Results
To replicate the results in Vivado, the following steps must be followed:
1. Generate the required code.hex file using the scripts available. The proper path of this code.hex file should be copied to rtl/fetch_stage/instruction_mem.sv (line 18) to ensure proper synthesis.
2. Create a new project in Vivado. The Project Type should be RTL Project.
3. In the Add Sources menu, click on Add Directories and select the rtl folder of a specific bpu (i.e rv32im_tage_sc)
4. A minimal constraints file can be setup. The clock frequency depends on the set clock period and is different for each configuration. It can be modified by the following line:

```bash
create_clock -name sys_clk -period 5.4 [get_ports clk]
```

The value can to put in place of 5.4 depends on the design and exact configurations. For the best results for each type of bpu, the values are: Always Not Taken (5.128), Always Taken (5.263), Alternating (5.263), 1-Bit Saturating (5.263), 2-Bit Saturating (5.405), TAGE (5.405), TAGE-SC (6.06)

5. Select the part number as: xczu3eg-sbva484-1-i
6. Click on Finish to make the project
7. Once the project is made, all settings are kept as Vivado Defaults for both synthesis and implementation.
8. First run the synthesis using the Run synthesis button followed by implementation. All reported results are post-implementation.

## 🔄 Usage (Old)
Copy the required version of the code from the branch_predictor_versions folder into the root directory of this repository and rename it to rtl.
To run any of the tests, after installing the pre-requisties, you can run the following commands:

```bash
make custom
make riscv-tests
make dhrystone
make coremark
make embench_all
```
---

## 📦 Installation

### 1️⃣ RISC-V GNU Toolchain

```bash
git clone https://github.com/riscv/riscv-gnu-toolchain
cd riscv-gnu-toolchain
```

```bash
sudo apt-get install -y autoconf automake autotools-dev curl python3 python3-pip \
libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf \
libtool patchutils bc zlib1g-dev libexpat-dev ninja-build git cmake \
libglib2.0-dev libslirp-dev libncurses-dev
```

```bash
./configure --prefix=$HOME/riscv32i --with-arch=rv32i --with-abi=ilp32
make
```

```bash
echo 'export RISCV=$HOME/riscv32i' >> ~/.bashrc
echo 'export PATH=$RISCV/bin:$PATH' >> ~/.bashrc
source ~/.bashrc
```

```bash
riscv32-unknown-elf-gcc --version
```

---

### 2️⃣ Verilator

```bash
sudo apt-get install -y git help2man perl python3 make autoconf g++ flex bison \
ccache libgoogle-perftools-dev numactl perl-doc \
libfl2 libfl-dev zlib1g zlib1g-dev
```

```bash
git clone https://github.com/verilator/verilator
cd verilator
git checkout stable
autoconf && ./configure && make
sudo make install
```

```bash
verilator --version
```

---

### 3️⃣ cocotb (Python Virtual Environment)

```bash
sudo apt-get install -y python3 python3-pip python3-venv libpython3-dev
```

```bash
python3 -m venv ~/cocotb
source ~/cocotb/bin/activate
pip install cocotb cocotb-bus cocotb-test
```

```bash
python3 -c "import cocotb; print('cocotb OK')"
```

---

## 📄 License

This project is released under the Apache 2.0 License. See the [LICENSE](LICENSE) file for details.

---