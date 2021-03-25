#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Mar  8 20:43:00 2021
@author: jasonmoggridge

Evaluate logistic regression for a single fold
"""

import sys
import argparse
import pathlib
import math
import pandas as pd
import numpy as np
import random
import matplotlib.pyplot as plt
import seaborn as sns

from sklearn.model_selection import GridSearchCV
from sklearn.linear_model import LogisticRegression ##
from sklearn import metrics
import confusion # confusion.py script


## get values from command line if given
argparser = argparse.ArgumentParser(
        description="Standardize and project the data using PCA")
argparser.add_argument("-s", "--seed", action="store",
        default=None, type=int,
        help="Set the random seed -- if set to any value, every "
            "run of the program will use the same sequence of "
            "random values")
argparser.add_argument("-c", "--classes", action="store", default=None,
		help="A comma-separated list of class names to report in "
			"evalulation metrics.  If not supplied, class names "
			"based on integer numbers starting at zero will be used.")
argparser.add_argument("-f", "--fig", action="store_true",
        help="Stores the confusion matrix in a PDF figure")
argparser.add_argument("dirname",
        type=pathlib.Path,
        help="Sets the data directory -- alterate to -I")
##
args = argparser.parse_args(sys.argv[1:])
if args.classes is None:
    CLASS_NAMES = None
else:
    CLASS_NAMES = args.classes.split(',')
## set the seed if given for reproducible runs
if args.seed is not None:
    random.seed(args.seed)
MAKE_FIG=args.fig
DATA_DIRNAME=args.dirname

## read data in
print(" . Loading....")
X_training = pd.read_csv("%s/X_proj_train.csv" % DATA_DIRNAME)
X_validation = pd.read_csv("%s/X_proj_validation.csv" % DATA_DIRNAME)
X_test = pd.read_csv("%s/X_proj_test.csv" % DATA_DIRNAME)

y_training = pd.read_csv("%s/y_train.csv" % DATA_DIRNAME)
y_validation = pd.read_csv("%s/y_validation.csv" % DATA_DIRNAME)
y_test = pd.read_csv("%s/y_test.csv" % DATA_DIRNAME)


## need to convert X to numpy arrays and y to a column vector
X_training = X_training.to_numpy()
X_validation = X_validation.to_numpy()
X_test = X_test.to_numpy()

# convert from 1-d array to column vector
y_training = np.ravel(y_training.to_numpy())
y_validation = np.ravel(y_validation.to_numpy())
y_test = np.ravel(y_test.to_numpy())


## Use "grid search" to find good values for our Logistic Regression for this
## training set.

# Set up the list of values to search among
logreg_parameters = [
        {'penalty' : ['l1', 'l2'],
        'C' : np.logspace(-3, 2, 20),
        'solver' : ['liblinear']},
        ]

# perform the search
print(" . Performing grid search")
logreg_search = GridSearchCV(
        LogisticRegression(),
        logreg_parameters,
        n_jobs=-1,
        verbose=1
        )

logreg_search.fit(X_validation, y_validation)

best_parameters = logreg_search.best_params_
print(" . Best parameters found for Logistic Regression:", best_parameters)

print(" . Creating Logistic Regression model to use on training data")
# Here the "**" means that we take the list of keyword=arg
# values in best_parameters and convert it into a dictionary
# to pass as arguments to the creation of the LogReg implementation
# that we will use to actually train on our training data.
#
# This line creates the classifier with the best training parameters
model = LogisticRegression(**best_parameters)

# ... and finally, we use our training data to train the classifier
model.fit(X_training, y_training)

##
## Evaluate the results
##
print(" . Performing evaluation:")


# Make some predictions on the test data -- this generates
# a set of new labels, which should match the test labels
# if our classifier is a strong one
y_pred = model.predict(X_test)

# If these labels are correct, they will match the ones in y_test
prediction_accuracy = metrics.accuracy_score(y_test, y_pred)

unique_labels = np.unique(y_training)
if len(unique_labels) <= 2:
	prediction_precision = metrics.precision_score(y_test, y_pred)
	prediction_recall = metrics.recall_score(y_test, y_pred)
	prediction_fmeasure = metrics.f1_score(y_test, y_pred)
else:
	prediction_precision = metrics.precision_score(y_test, y_pred,
			average="macro")
	prediction_recall = metrics.recall_score(y_test, y_pred,
			average="macro")
	prediction_fmeasure = metrics.f1_score(y_test, y_pred,
			average="macro")

print('Log. reg. Performance metrics:  accuracy %.2f, precision %.2f, recall %.2f, f1 %.2f'
        % (prediction_accuracy, prediction_precision, prediction_recall, prediction_fmeasure))

performance = pd.DataFrame()
performance['algortithm'] = ['SVC']
performance['precision'] = [prediction_precision]
performance['accuracy'] = [prediction_accuracy]
performance['recall'] = [prediction_recall]
performance['fmeasure'] = [prediction_fmeasure]
performance.to_csv('%s/logreg_performance.csv' % DATA_DIRNAME, header=False, index=False)
print(performance)

outcome = pd.DataFrame()
outcome['predicted'] = y_pred
outcome['actual'] = y_test
outcome.to_csv('%s/logreg_outcome.csv' % DATA_DIRNAME, index=False)

# Calculate confusion matrix and print it
cm = metrics.confusion_matrix(y_test, y_pred)
confusion.print_confusion_matrix(cm, CLASS_NAMES, y_training)
confusion.print_confusion_matrix(cm, CLASS_NAMES, y_training,
		filename="%s/logreg_confusion.txt" % DATA_DIRNAME)

if MAKE_FIG:
	confusion.confusion_matrix_heatmap(
            '%s/logreg_confusion_heatmap.pdf' % DATA_DIRNAME,
            cm, CLASS_NAMES, y_training)
        
# 
