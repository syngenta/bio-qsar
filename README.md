# Bio-QSAR

This repository includes the data and models from the publication: *Physiological variables in machine learning QSARs allow for both cross-chemical and cross-species predictions*

## Freshwater fish and invertebrate models

These Bio-QSAR models allow the prediction of toxicity in freshwater fish and invertebrates. For information on development, use, and limitations, please see our associated publication.

Models were built using R version 4.1.3 and the packages tidyverse (version 1.3.1), caret (version 6.0.91), and ranger (version 0.13.1).

\# load libraries
library(tidyverse)
library(caret)
library(ranger)

\# fish model

\## load the fish model
model_fish <-readRDS("model_fish.RDS")

\## show features required for predictions
model_fish$xNames

\## load fish example
example_data_fish <- read_csv("example_data_fish.csv")

\## make a prediction
pred_fish <- model_fish %>% predict(example_data_fish)
pred_fish$predictions

\## prediction is in log10(mg/L) --> make it mg/L
10^pred_fish$predictions

\# invertebrate model

\## load the invertebrate model
model_invertebrates <-readRDS("model_invertebrates.RDS")

\## show features required for predictions
model_invertebrates$xNames

\## load invertebrate example
example_data_invertebrates <- read_csv("example_data_invertebrates.csv")

\## make a prediction
pred_invertebrates <- model_invertebrates %>% predict(example_data_invertebrates)
pred_invertebrates$predictions

\## prediction is in log10(mg/L) --> make it mg/L
10^pred_invertebrates$predictions

# Algorithmic approach for multicollinearity correction

Here, we provide an R version of an approach to correct datasets for multicollinearity that was recently presented in a [blog post](https://towardsdatascience.com/are-you-dropping-too-many-correlated-features-d1c96654abe6) by Brian Pietracatella. This approach is deemed to prevent the drop of too many variables and thus loose an unnecessarily large amount of information, while still eliminating multicollinearity. For more information, see our associated publication.

The function was built using R version 4.1.3 and the packages tidyverse (version 1.3.1) and caret (version 6.0.91).

\# load libraries
library(tidyverse)
library(caret)

\# source the function
source("multicoll_sol.R")

\# load some example data
data("BloodBrain")

\# run the function with a correlation cut-off of 0.7
result <- multicoll_sol(bbbDescr, 0.7)
result

The function returns a list with four elements:
* result$drop :  the features to drop according to the algorithm
* result$caret_before : the features to drop according to the caret function findCorrelation()
* result$caret_after : result of a second run of findCorrelation() after result$drop features have been dropped from the dataset; should be empty
* result$saved : features that have been saved by the algorithm
