#!/bin/bash

MG5_DIR="/home/ammelsayed/softwares/MG5_aMC_v3_8_1/bin/mg5_aMC"
PYTHIA_CARD="/data/ammelsayed/samples/Cards/pythia8_card_TuneA14.dat"
DELPHES_CARD="/data/ammelsayed/samples/Cards/delphes_card_ATLAS_FatJetPTMin50.tcl"
NB_EVENTS=10000
SEED=1

[ $# -eq 0 ] && { echo "ERROR: No input file provided."; exit 1; }
INPUT_FILE=$(realpath "$1")
[ ! -f "$INPUT_FILE" ] && { echo "ERROR: File '$INPUT_FILE' not found!"; exit 1; }

INPUT_DIR=$(dirname "$INPUT_FILE")
INPUT_BASENAME=$(basename "$INPUT_FILE")
PROC_NAME="${INPUT_BASENAME%.*}"

cd "$INPUT_DIR" || exit 1
export TMPDIR=/data/ammelsayed/my_tmp/
mkdir -p LogFiles

cd "$INPUT_DIR" || exit 1
export TMPDIR=/data/ammelsayed/my_tmp/
mkdir -p LogFiles
LOG="LogFiles/${PROC_NAME}.log"

{
echo "=== [1] MadGraph5: $(date) ==="
python3 "$MG5_DIR" "$INPUT_BASENAME"

cd "$PROC_NAME" || exit 1

echo "=== [2] Unpack gridpack: $(date) ==="
tar -xzf run_01_gridpack.tar.gz

echo "=== [3] Create Events/GridRun_${SEED}: $(date) ==="
mkdir -p "Events/GridRun_${SEED}"

echo "=== [4] Run gridpack: $(date) ==="
cp -r Cards Cards.bak.$$
bash run.sh "${NB_EVENTS}" "${SEED}"
[ -d Cards ] || cp -r Cards.bak.$$ Cards
rm -rf Cards.bak.$$

echo "=== [5] Move LHE: $(date) ==="
mv events.lhe.gz "Events/GridRun_${SEED}/unweighted_events.lhe.gz"

echo "=== [6] Pythia8 + Delphes: $(date) ==="
cat > "run_pythia_delphes_GridRun_${SEED}.txt" <<EOF
launch GridRun_${SEED}
shower=Pythia8
detector=Delphes
done
${PYTHIA_CARD}
${DELPHES_CARD}
done
EOF
./bin/madevent "run_pythia_delphes_GridRun_${SEED}.txt"

echo "=== Done: $(date) ==="
} 2>&1 | tee "LogFiles/${PROC_NAME}.log"
