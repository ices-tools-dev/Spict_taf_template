## Fit the SPiCT model, run diagnostics, and evaluate management scenarios
## Before: data/spict_input.rds, data/catches.csv
## After:  model/fit.rds, model/management.rds

library(icesTAF)
library(spict)

mkdir("model")

## Settings -------------------------------------------------------------------
nretroyears    <- 5
nhindcastyears <- 5

inp <- readRDS("data/spict_input.rds")

## Fit ----------------------------------------------------------------------
fit <- fit.spict(inp)
fit <- calc.osa.resid(fit)
fit <- calc.process.resid(fit)
fit <- check.ini(fit)

if (fit$opt$convergence != 0 || !all(is.finite(fit$sd))) {
  warning(
    "SPiCT model did not converge cleanly (optimizer exit code ",
    fit$opt$convergence, "; finite SDs: ", all(is.finite(fit$sd)),
    "). Inspect model/fit.rds before trusting downstream output."
  )
}

## Retrospective and hindcast analyses ---------------------------------------
fit <- retro(fit, nretroyear = nretroyears)
fit <- hindcast(fit, npeels = nhindcastyears)

saveRDS(fit, "model/fit.rds")

## Management scenarios -------------------------------------------------------
## advice_year follows the AFWG convention: catches run up to last_data_year,
## the assessment is carried out the following year (assessment_year), and
## advice is given for the year after that (advice_year).
catches <- read.taf("data/catches.csv")

last_data_year  <- max(catches$year)
assessment_year <- last_data_year + 1
advice_year     <- assessment_year + 1

## currentF, Fmsy, noF, and the ICES MSY hockey-stick advice rule (Blim,
## 35th percentile of the catch distribution), evaluated over the advice year.
management <- manage(
  fit,
  scenarios   = c("currentF", "Fmsy", "noF", "ices"),
  maninterval = c(advice_year, advice_year + 1),
  maneval     = advice_year + 1,
  verbose     = FALSE
)

saveRDS(management, "model/management.rds")
