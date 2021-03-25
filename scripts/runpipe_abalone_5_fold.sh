#!/bin/bash

#
# Runs a simple analysis pipeline on the data in data/fulldata
#

### Safety standards
# -u : tell bash to fail if any variable is not set
# -e : tell bash to fail if any command fails (unless in an if)
# -o pipefail : tell bash to fail if part of a pipe fails (needs -e)
# -x Turn tracing on to make clearer what is happening
set -e
set -u
set -o pipefail
set -x 

# create the "folds"
python tools/create_folds.py --tag "abalone" -l Sex 5 data-abalone-UCI/abalone.csv

# for 5 folds: do projection, fit models + get metrics
for fold in 00 01 02 03 04
do
    echo " = Fold ${fold}"
    # calculate the projection for each fold
    python tools/calculate_data_projection.py "abalone-folded-${fold}"
    # run logistic regression w multiclass, evaluate
    python tools/evaluate_logisticreg.py --classes "I,M,F" "abalone-folded-${fold}"
    # run SVN, evaluate
    python tools/evaluate_svn.py --classes "I,M,F" "abalone-folded-${fold}"
    
done

