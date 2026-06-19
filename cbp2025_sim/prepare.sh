#!/bin/bash

git clone https://github.com/ramisheikh/cbp2025.git

cp -r predictors cbp2025/
cp run.sh cbp2025/
chmod +x cbp2025/run.sh

echo ""
echo "Setup complete."
echo "Next steps:"
echo "  cd cbp2025"
echo "  ./run.sh <predictor_name> <trace_dir>"