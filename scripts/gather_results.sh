#!/bin/bash/

# Gather all results .csv files and figures

mkdir -p results


for x in 0 1 2 3 4
do
  cp abalone-folded-0$x/svn_performance.csv ./results/abalone_svn_$x.csv
  cp abalone-folded-0$x/logreg_performance.csv ./results/abalone_logreg_$x.csv
  cp cancer-folded-0$x/svn_performance.csv ./results/cancer_svn_$x.csv
  cp cancer-folded-0$x/logreg_performance.csv ./results/cancer_logreg_$x.csv
  cp diabetes-folded-0$x/svn_performance.csv ./results/diabetes_svn_$x.csv
  cp diabetes-folded-0$x/logreg_performance.csv ./results/diabetes_logreg_$x.csv
done

header="algorithm,precision,accuracy,recall,f1"

echo $header > abalone_5foldresults.csv
echo $header > cancer_5fold_results.csv
echo $header > diabetes_5fold_results.csv

for result in ./results/abalone-folded*.csv
do
  cat $result >> abalone_5fold_results.csv
done

for result in ./results/cancer-folded*.csv
do
  cat $result >> cancer_5fold_results.csv
done

for result in ./results/diabetes-folded*.csv
do
  cat $result >> diabetes_5fold_results.csv
done
