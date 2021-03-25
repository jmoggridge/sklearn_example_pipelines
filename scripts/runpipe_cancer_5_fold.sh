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
python tools/create_folds.py \
        --tag "cancer" -l "cancer" 5 \
        data-cancer-by-gene-expression/cancer-by-gene-expression.csv

for fold in 00 01 02 03 04
do
    echo " = Fold ${fold}"

    # add --fig flag to any tools to get figures
    
    # calculate the projection for each fold
    python tools/calculate_data_projection.py \
            --PCA "cancer-folded-${fold}"

    # run SVN on the fold
    python tools/evaluate_svn.py --fig "cancer-folded-${fold}"

    # run LogReg on the fold
    python tools/evaluate_logisticreg.py --fig "cancer-folded-${fold}"
    
    # leave two blank lines between folds
    echo "\n"
done

