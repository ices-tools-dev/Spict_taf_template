## Stage: SPiCT input assembly
## Before: data/catches.csv, data/index.csv (clean files - see catches.R, index.R)
## After:  data/spict_input.rds
##
## Builds the full SPiCT input list ready for fit.spict(): time series,
## fixed Schaefer shape, priors, and catch/index uncertainty scaling agreed
## at the 2026 benchmark (WKBWNG). model.R just reads this file and fits.

library(icesTAF)
library(spict)
library(dplyr)

catches <- read.taf("data/catches.csv")
index   <- read.taf("data/index.csv")

inp <- list(
  timeC = catches$year,
  obsC  = catches$total,
  timeI = index$year + 6 / 12, # survey timing: June
  obsI  = index$index
)

## Shape parameter n fixed at Schaefer (log(2)), as agreed at WKBWNG 2026
inp$phases$logn <- -1
inp$ini$logn <- log(2)

inp <- check.inp(inp, verbose = TRUE)

## Priors accepted at the 2026 benchmark (WKBWNG) ----------------------------
priors <- list(
  logbkfrac = c(log(0.9), 0.5, 1),
  logr      = c(log(0.064), 0.5, 1),
  logsdb    = c(log(0.05), 0.2, 1),
  logalpha  = c(0, 0, 0), # deactivated: index-to-biomass deviation coupling
  logbeta   = c(0, 0, 0)  # deactivated: catch-to-F deviation coupling
)
for (nm in names(priors)) inp$priors[[nm]] <- priors[[nm]]

## Catch and index uncertainty scaling ---------------------------------------
## stdevfacC ramps linearly from 3x (pre-1987) down to 1x (post-2022),
## reflecting reduced confidence in the historical catch series, then is
## rescaled to average 1 (required by SPiCT).
stdevfacC <- data.frame(year = min(catches$year):max(catches$year)) |>
  mutate(
    uncertainty = case_when(
      year < 1987 ~ 3,
      year > 2022 ~ 1,
      .default = NA_real_
    ),
    uncertainty = zoo::na.approx(uncertainty),
    stdevfacC = uncertainty / mean(uncertainty, na.rm = TRUE)
  ) |>
  pull(stdevfacC)

inp$stdevfacC <- stdevfacC
inp$stdevfacI <- index$stdevI

saveRDS(inp, "data/spict_input.rds")
