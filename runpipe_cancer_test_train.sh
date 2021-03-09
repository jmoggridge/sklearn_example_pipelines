#!/bin/bash

#
# Runs a simple analysis pipeline on the data in data/fulldata
#

### Safety standards
# -u : tell bash to fail if any variable is not set
# -e : tell bash to fail if any command fails (unless in an if)
# -o pipefail : tell bash to fail if part of a pipe fails (needs -e)
set -e
set -u
set -o pipefail

# save the directory that our script it in so that we can find
# the tools
SCRIPTDIR=`dirname $0`

# -x Turn tracing on to make clearer what is happening
set -x 

# split the data
python ${SCRIPTDIR}/create_test_train_split.py \
        --tag "cancer" -l "cancer" \
        data-cancer-by-gene-expression/cancer-by-gene-expression.csv

# calculate the projection for this split
python ${SCRIPTDIR}/calculate_data_projection.py \
		--PCA --fig "cancer-train-vs-test"

# run SVN on the datea
python ${SCRIPTDIR}/evaluate_svn.py --fig "cancer-train-vs-test"


# run Logistic Regression on the datea
python ${SCRIPTDIR}/evaluate_logisticreg.py --fig "cancer-train-vs-test"

