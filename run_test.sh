#!/bin/bash
set -e

# Check arguments
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: ./run_test.sh <bpu_variant> <config_file_name_without_ext>"
    echo "Example: ./run_test.sh rv32im_tage_sc config1"
    exit 1
fi

BPU_VARIANT=$1
CONFIG_NAME=$2

BASE_DIR=$(pwd)

# Paths
SRC_BPU="$BASE_DIR/branch_predictor_softcore_versions/$BPU_VARIANT"
SRC_CFG_DIR="$BASE_DIR/bpu_configurations/$BPU_VARIANT"

CFG_FILE="$SRC_CFG_DIR/$CONFIG_NAME.sv"

DEST="$BASE_DIR/rtl"
DEST_CFG="$DEST/riscv_soc_top.sv"

# Checks
if [ ! -d "$SRC_BPU" ]; then
    echo "Error: BPU folder not found: $SRC_BPU"
    exit 1
fi

if [ ! -f "$CFG_FILE" ]; then
    echo "Error: config file not found: $CFG_FILE"
    exit 1
fi

# Step 1: Replace full RTL
echo "Copying BPU variant: $BPU_VARIANT"
rm -rf "$DEST"
cp -r "$SRC_BPU" "$DEST"

# Step 2: Replace config SV file
echo "Applying config: $CONFIG_NAME.sv"
cp "$CFG_FILE" "$DEST_CFG"

echo "Done."

make coremark