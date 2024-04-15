library(tidyverse)
library(caret)
library(ranger)

### fish model

# load the fish model
model_fish <-readRDS("model_fish.RDS")

# show features required for predictions
model_fish$xNames

# load fish example
example_data_fish <- read_csv("example_data_fish.csv")

# make a prediction
pred_fish <- model_fish %>% predict(example_data_fish)
pred_fish$predictions

# prediction is in log10(mg/L) --> make it mg/L
10^pred_fish$predictions

### invertebrate model

# load the invertebrate model
model_invertebrates <-readRDS("model_invertebrates.RDS")

# show features required for predictions
model_invertebrates$xNames

# load invertebrate example
example_data_invertebrates <- read_csv("example_data_invertebrates.csv")

# make a prediction
pred_invertebrates <- model_invertebrates %>% predict(example_data_invertebrates)
pred_invertebrates$predictions

# prediction is in log10(mg/L) --> make it mg/L
10^pred_invertebrates$predictions
