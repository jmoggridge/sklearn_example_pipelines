#!/bin/bash

# Gather all results .csv files and figures
# 
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

echo $header > ./results/kfold_abalone.csv
echo $header > ./results/kfold_cancer.csv
echo $header > ./results/kfold_diabetes.csv

echo "\n\n"
echo "Abalone"
echo "--------------"
echo $header
for result in ./results/abalone_*.csv
do
  cat $result
  cat $result >> ./results/kfold_abalone.csv
done

echo "\n\n"
echo "Cancer"
echo "--------------"
echo $header
for result in ./results/cancer_*.csv
do
  cat $result
  cat $result >> ./results/kfold_cancer.csv
done

echo "\n\n"
echo "Diabetes"
echo "--------------"
echo $header
for result in ./results/diabetes_*.csv
do
  cat $result
  cat $result >> ./results/kfold_diabetes.csv
done
