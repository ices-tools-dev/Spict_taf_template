## Stage: survey index
## Before: bootstrap/data/reg-assessment-survey-indices-1991.rds
## After:  data/index.csv
##
## reg-assessment-survey-indices-1991.rds is a list of 4 biomass indices
## (total, >30 cm, >55 cm, <15 cm). Element 2 (>30 cm) is used, matching the
## choice made at the 2026 benchmark (WKBWNG).

library(icesTAF)
library(dplyr)

index_list <- readRDS(file.path(boot.dir(), "data", "reg-assessment-survey-indices-1991.rds"))

index <- index_list[[2]] |>
  mutate(
    index     = est / mean(est, na.rm = TRUE),
    index_lwr = lwr / mean(est, na.rm = TRUE),
    index_upr = upr / mean(est, na.rm = TRUE),
    stdevI    = se / mean(se, na.rm = TRUE)
  )

write.taf(index, dir = "data")
