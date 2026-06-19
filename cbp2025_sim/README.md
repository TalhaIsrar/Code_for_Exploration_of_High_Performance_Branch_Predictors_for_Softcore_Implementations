# Branch Predictor Simulation Framework based on CBP2025

This repository extends the CBP2025 simulator with custom branch predictors and provides an automated workflow for compiling, running, and evaluating experiments on CBP traces.

---

## 📋 Overview

This project integrates custom branch predictors into the CBP2025 framework and automates:

- Compilation of the simulator with selected predictors
- Execution over CBP training traces
- Extraction of metrics from simulation logs
- Computation of per-workload and overall summary statistics

---

## 📁 Repository Structure

```
cbp2025_sim/
├── predictors/     # Custom branch predictor implementations
├── scripts/        # Trace processing and analysis scripts
├── run.sh          # Main execution script
└── prepare.sh      # Setup script for framework integration
```

---

## ⚙️ Requirements

- Python >= 3.10 (tested on Python 3.12.3)
- pandas (tested on 3.0.3)
- numpy (tested on 2.4.6)
- g++ and make (for building the simulator)

Other versions of Python dependencies may work but are not guaranteed.

---

## 🚀 Setup

Run the setup script:

```bash
bash prepare.sh
```

This will:

- Clone the CBP2025 framework
- Copy predictor implementations and scripts into the framework directory

---

## 📊 Comparison Predictors

For comparison against established baselines, experiments were also performed using the following predictor configurations:

- `tage_2025`
- `tage_sc_2025`
- `tage_sc_l_2025`
- `pTAGE`

These predictors are not included in this Zenodo archive. They can be obtained from:

https://github.com/TalhaIsrar/Branch_Predictor_Exploration_for_RISC-V_Softcores/tree/main/cbp2025_sim/predictors

After running `prepare.sh`, copy the predictor directories listed above into:

```text
cbp2025/predictors/
```

before running experiments.

---

## 💾 Trace Dataset

The simulator requires traces placed inside the CBP2025 directory:

```
cbp2025/traces/
├── int/
├── fp/
├── compress/
├── media/
├── web/
└── infra/
```

### 🧪 Sample traces (quick test)

The original CBP2025 framework includes sample traces for quick validation.

### 📦 Full training traces

Download using:

```bash
pip install gdown
gdown --folder https://drive.google.com/drive/folders/10CL13RGDW3zn-Dx7L0ineRvl7EpRsZDW
```

Extract the traces into the CBP2025 traces directory using:

```bash
tar -xf <trace-archive>.tar.xz -C cbp2025/traces/
```

---

## 🔬 Running Experiments

First, move into the CBP2025 framework directory:

```bash
cd cbp2025
```

Then run experiments.

### ⚡ Quick test

```bash
./run.sh <predictor_name> sample_traces
```

### 🏁 Full evaluation

```bash
./run.sh <predictor_name> traces
```

### 📝 Arguments

- `<predictor_name>`: name of a folder inside `predictors/`
- `<trace_dir>`: either `sample_traces` or `traces`

---

## 📈 Output

Results are stored in:

```
results/<predictor_name>/
```

Each run generates:

- Per-trace log files
- Aggregated `results.csv`

---

## 💡 Notes

- Ensure `prepare.sh` is executed before running experiments
- Trace directory names must match exactly (`sample_traces` or `traces`)
- All compilation is handled automatically
- Predictor names must match folder names inside `predictors/`

---

## 📜 License

This repository builds on the CBP2025 framework. The original framework license applies. Custom additions are provided for research and reproducibility purposes.
