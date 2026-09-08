## Prepare all data for the SPiCT assessment
## Thin wrapper - each stage lives in its own script under data_scripts/
## Before: bootstrap/data/GoldenRedfish_landings_for_SPiCT.txt,
##         bootstrap/data/reg-assessment-survey-indices-1991.rds
## After:  data/catches.csv, data/index.csv, data/spict_input.rds

library(icesTAF)

mkdir("data")

source("data_catch.R")       # -> data/catches.csv
source("data_index.R")       # -> data/index.csv
source("data_spict_input.R") # -> data/spict_input.rds (ready for fit.spict())

