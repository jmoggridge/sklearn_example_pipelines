#!/bin/bash

### Safety standards
# -u : tell bash to fail if any variable is not set
# -e : tell bash to fail if any command fails (unless in an if)
# -o pipefail : tell bash to fail if part of a pipe fails (needs -e)
# -x Turn tracing on to make clearer what is happening
set -u           
set -e           
set -o pipefail  
set -x           


# create the "folds"
python tools/create_folds.py -s 9 --tag "diabetes" 5 data-diabetes/diabetes_extra.csv

# for 5 folds: do projection, fit models + get metrics
for fold in 00 01 02 03 04
do
    echo " = Fold ${fold}"
    # calculate the projection for each fold
    python tools/calculate_data_projection.py "diabetes-folded-${fold}"
    # run logistic regression w multiclass, evaluate
    python tools/evaluate_logisticreg.py --fig -s 9 "diabetes-folded-${fold}"
    # run SVN, evaluate
    python tools/evaluate_svn.py --fig -s 9 "diabetes-folded-${fold}"
done

# 
# for fold in 00 01 02 03 04
# do
#     echo " = Fold ${fold}"
#     # run SVN on the fold
#     python tools/evaluate_svn_NO_PCA.py --fig "diabetes-folded-${fold}"
# 
#     # run LogReg on the fold
#     python tools/evaluate_logreg_NO_PCA.py  --fig  "diabetes-folded-${fold}"
#     
#     # leave two blank lines between folds
#     echo "\n"
# done
