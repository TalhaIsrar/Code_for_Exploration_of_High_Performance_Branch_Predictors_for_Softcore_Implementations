#!/bin/bash
set -e

git clone https://github.com/TalhaIsrar/Branch_Predictor_Exploration_for_RISC-V_Softcores.git

cp -r Branch_Predictor_Exploration_for_RISC-V_Softcores/coremark coremark
cp -r Branch_Predictor_Exploration_for_RISC-V_Softcores/dhrystone dhrystone
cp -r Branch_Predictor_Exploration_for_RISC-V_Softcores/embench embench
cp -r Branch_Predictor_Exploration_for_RISC-V_Softcores/riscv-tests riscv-tests

rm -r -f Branch_Predictor_Exploration_for_RISC-V_Softcores

echo "Done."
echo "Now you can run"
echo "./run_tests.sh <softcore_bpu_name> <configuration_name>"
echo "./run_embench.sh <softcore_bpu_name> <configuration_name>"