#!/bin/sh

echo '\n\n Run diabetes 5 fold\n '
./scripts/runpipe_diabetes_5_fold.sh

echo '\n\nRunning cancer test train\n'
./scripts/runpipe_cancer_test_train.sh 

echo '\n\nRunning cancer 5 fold\n'
./scripts/runpipe_cancer_5_fold.sh

echo '\n\nRun abalone test train\n'
./scripts/runpipe_abalone_test_train.sh

echo '\n\nRun abalone 5 fold\n'
./scripts/runpipe_abalone_5_fold.sh
