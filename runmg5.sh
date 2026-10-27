#!/bin/bash

# Add the madgraph5 dir
# in madgraph5, install pythia8, install Delphes, and install MadAnalysis5
MG5_DIR="/home/ammelsayed/softwares/MG5_aMC_v3_7_2/bin/mg5_aMC"

# Usage check: input file is mandatory 
if [ $# -eq 0 ]; then
    echo "ERROR: No input file provided."
    exit 1
fi

# Resolve absolute path of the input file 
INPUT_FILE=$(realpath "$1")
if [ ! -f "$INPUT_FILE" ]; then
    echo "ERROR: File '$INPUT_FILE' not found!"
    exit 1
fi

# Optional: activate conda env (uncomment next line if needed)
# echo "Activating conda with: conda activate py310"
# source /home/ammelsayed/miniconda3/bin/activate
# conda activate py310

# Extract directory and base filename
INPUT_DIR=$(dirname "$INPUT_FILE")
INPUT_BASENAME=$(basename "$INPUT_FILE")
INPUT_NAME_NO_EXT="${INPUT_BASENAME%.*}"  # Removes .yml, .txt, .md, etc.

# Change to the input file's directory 
cd "$INPUT_DIR" || exit 1

# setup new tmp dir to avoid uncontrolable
# tmp disk out of space issue
export TMPDIR=/data/ammelsayed/my_tmp/

# run nohup
DIR=LogFiles
mkdir $DIR
LOG="${INPUT_NAME_NO_EXT}.log"
PID="${INPUT_NAME_NO_EXT}.pid"
nohup bash -c "date && python3 \"$MG5_DIR\" \"$INPUT_BASENAME\"" > "$DIR/$LOG" 2>&1 &
echo $! > "$DIR/$PID"

echo "MadGraph5 started with PID $(cat $DIR/$PID)."
echo " > Log file: ${INPUT_DIR}/${DIR}/${LOG}"
echo " > PID file: ${INPUT_DIR}/${DIR}/${PID}"s