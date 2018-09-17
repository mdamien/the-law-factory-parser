#!/bin/bash


trap ctrl_c INT
function ctrl_c() {
    exit 1;
}

cd $(dirname $0)
source ~/.bash_profile
pyenv activate lafabrique

DATADIR=data

echo "Parsing new promulgated texts..."
senapy-cli doslegs_urls --min-year=$((`date +%Y`)) | tlfp-parse-many $DATADIR --only-promulgated --quiet

echo
echo "Parsing texts in discussion in the Senate..."
senapy-cli doslegs_urls --in-discussion | tlfp-parse-many $DATADIR --quiet

echo
echo "Parsing texts in discussion in the National Assembly..."
anpy-cli doslegs_urls --in-discussion | tlfp-parse-many $DATADIR --quiet

echo
python tlfp/generate_dossiers_csv.py $DATADIR
python tlfp/tools/assemble_procedures.py $DATADIR > /dev/null

echo
#python tools/make_metrics_csv.py $DATADIR --quiet

python tlfp/tools/steps_as_dot.py $DATADIR | dot -Tsvg > $DATADIR/steps.svg
python tlfp/tools/steps_as_dot.py $DATADIR | dot -Tpng > $DATADIR/steps.png
python tlfp/tools/steps_as_dot.py $DATADIR 1 | dot -Tsvg > $DATADIR/steps-detailed.svg
python tlfp/tools/steps_as_dot.py $DATADIR 1 | dot -Tpng > $DATADIR/steps-detailed.png

