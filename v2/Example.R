# This code and the used models were generated using R version 4.1.3 and the 
# packages tidyverse (version 2.0.0), gpboost (version 1.2.1), and
# SHAPforxgboost (version 0.1.3).
# To install these package versions on your system, you can run the commented 
# code below.

# install.packages("devtools")
# 
# require(devtools)
# install_version("tidyverse", version = "2.0.0", repos = "http://cran.us.r-project.org")
# install_version("gpboost", version = "1.2.1", repos = "http://cran.us.r-project.org")
# install_version("SHAPforxgboost", version = "0.1.3", repos = "http://cran.us.r-project.org")

#### Load libraries ####

library(tidyverse)
library(gpboost)
library(SHAPforxgboost)

#### Example model predictions ####

# Here we try to reproduce the metrics for the model for fish with DEB parameter
# values available. 
# Note that models are named according to the subgroup they are fit for, i.e, 
# "Fish with DEB", "Fish without DEB", "Invertebrate with DEB", and 
# "Invertebrate without DEB". All vectors and lists are named accordingly. 
# As an example, we will analyze data and model for "Fish with DEB". 
# However, by simply changing the name variable below, you can perform
# analysis on the other subgroups.

name <- "Fish with DEB"
# name <- "Fish without DEB"
# name <- "Invertebrate with DEB"
# name <- "Invertebrate without DEB"

### Load model

model <- gpb.load(paste0(str_replace_all(name, " ", "_"),".json"))

### Load training and test data

training_data <- readRDS("training_data.rds")[[name]]

test_data <- readRDS("test_data.rds")[[name]]

# For transparency, training and test data feature a variable 'Latin name',
# i.e., the name of the involved species. This variable is not required for 
# predictions, so we drop it here.

training_data <- training_data %>%
  select(-'Latin name')

test_data <- test_data %>%
  select(-'Latin name')

### Make predictions

## Create tables with actual vs. predicted target values

pred_training_data <- tibble(actual = training_data$`Effect value`, 
                             pred = predict(model, data = 
                                              training_data %>% 
                                              select(-id, -`Effect value`) %>% 
                                              as.matrix(), 
                                            group_data_pred = 
                                              training_data$id, 
                                            predict_var = TRUE, pred_latent = 
                                              FALSE)[["response_mean"]])

pred_test_data <- tibble(actual = test_data$`Effect value`, 
                             pred = predict(model, data = 
                                              test_data %>% 
                                              select(-id, -`Effect value`) %>% 
                                              as.matrix(), 
                                            group_data_pred = 
                                              test_data$id, 
                                            predict_var = TRUE, pred_latent = 
                                              FALSE)[["response_mean"]])

# Important note: if you want to make predictions with new data, you need to
# feed the model an id that is different from all ids it was trained on.
# Could use, e.g., something like 
# id <- max(training_data$id) + 1

## Calculate RMSE and RSQ values

rmse_training <- yardstick::rmse(pred_training_data, pred, actual) %>%
  pull(.estimate)
rsq_training <- yardstick::rsq(pred_training_data, pred, actual) %>%
  pull(.estimate)

rmse_test <- yardstick::rmse(pred_test_data, pred, actual) %>%
  pull(.estimate)
rsq_test <- yardstick::rsq(pred_test_data, pred, actual) %>%
  pull(.estimate)

# Gives you the results presented in Table 9 of the publication.


#### Applicability domain #### 

# We will apply the respective applicability domain to the test data.
# Let's create a helper function first.

is_in_AD <- function(data, model_name) {
  
  # prepare dataset 
  
  const <- readRDS("constant_features.rds")[[model_name]]
  data_testing <- data %>% 
    select(-c(1,2, all_of(const))) %>%
    as_tibble()
  
  data_testing <- as_tibble(scale(data_testing))
  
  SHAP_names <- readRDS("SHAP_names.rds")[[model_name]]
  
  data_testing_depr <- data_testing %>% select(any_of(names(SHAP_names)))
  
  # apply weights
  
  weighting <- readRDS("SHAP_weights.rds")[[model_name]]
  
  data_testing_depr2 <- data_testing_depr %>% 
    mutate(across(everything(), ~ . * pull(weighting[1, cur_column()])))
  
  # apply PCA and calculate distances
  
  pcs <- readRDS("PCAs.rds")[[model_name]]
  
  eigs <- pcs$sdev^2
  cum_sum <- cumsum(eigs) / sum(eigs)
  num_comp <- sum(cum_sum <= 0.99) + 1
  
  pca_means <- colMeans(pcs$x)
  
  pcs_pred <- stats::predict(pcs, data_testing_depr2)
  pcs_pred <- pcs_pred[, 1:num_comp, drop = FALSE]
  
  diffs_pred <- sweep(pcs_pred, 2, pca_means)
  sq_diff_pred <- diffs_pred^2
  dists_pred <- apply(sq_diff_pred, 1, function(x) sqrt(sum(x)))
  
  # create logical vector is_in_AD
  
  cutoff_dist <- readRDS("cutoff_dists.rds")[[model_name]]
  
  is_in_AD <- dists_pred < cutoff_dist
  
  is_in_AD
  
}

# Test the function with the data for "Fish with DEB"; change variable name
# above if you want to test another dataset.

AD_vector <- is_in_AD(test_data, name)

# This gives a vector with TRUE where samples are within the applicability 
# domain and FALSE where they are outside.

# We could now apply this vector for indexing either to the whole dataset and
# then do predictions. But we already have the predictions on the whole dataset
# (object 'pred_test_data'). So we can just index this and then recalculate 
# RMSE and RSQ.

pred_test_in_AD <- pred_test_data[AD_vector, ]

rmse_test_in_AD <- yardstick::rmse(pred_test_in_AD, pred, actual) %>%
  pull(.estimate)
rsq_test_in_AD <- yardstick::rsq(pred_test_in_AD, pred, actual) %>%
  pull(.estimate)

# This gives the values presented in Table A3 of the publication.


#### Local SHAP predictions ####

# If you are interested in how one of our models came up with a prediction,
# you can use a local SHAP value breakdown.
# Let's do this on the first sample of the test data as an example.
# Note that X_train is an unlucky naming convention within the shap.values
# function. Also new data can be analysed here.

SHAP <- shap.values(xgb_model = model, X_train = test_data[1, ] %>%
                      select(-id, -`Effect value`) %>% as.matrix())

# To access the model bias (like an intercept), you can run

SHAP$BIAS0

# For accessing the SHAP scores, run

SHAP$mean_shap_score %>% enframe()
