library(tidyverse)
library(caret)

# source the function
source("multicoll_sol.R")

# load some example data
data("BloodBrain")

# run the function with a correlation cut-off of 0.7
result <- multicoll_sol(bbbDescr, 0.7)
result
