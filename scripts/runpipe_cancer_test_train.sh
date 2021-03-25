#!/bin/bash

# Runs a simple analysis pipeline on the data in data/fulldata

# Safety standards
# -u : tell bash to fail if any variable is not set
# -e : tell bash to fail if any command fails (unless in an if)
# -o pipefail : tell bash to fail if part of a pipe fails (needs -e)
# -x Turn tracing on to make clearer what is happening
set -e
set -u
set -o pipefail
set -x 

# set random seed everywhere for consistent results (-s 9)

# split the cancer data
python tools/create_test_train_split.py \
        --tag "cancer" -l "cancer" -s 9 \
        data-cancer-by-gene-expression/cancer-by-gene-expression.csv

# calculate the projection for this split
python tools/calculate_data_projection.py \
		--PCA --fig "cancer-train-vs-test"

# run SVN on the pca'd data
python tools/evaluate_svn.py --fig -s 9 "cancer-train-vs-test"

# run Logistic Regression on the datea
python tools/evaluate_logisticreg.py --fig -s 9 "cancer-train-vs-test"

