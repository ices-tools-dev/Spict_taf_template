## Produce final report tables and diagnostic/summary plots
## Before: output/*.csv, model/fit.rds, model/management.rds
## After:  report/*.csv (rounded copies for presentation), report/*.png (plots)

library(icesTAF)
library(spict)

mkdir("report")

fit        <- readRDS("model/fit.rds")
management <- readRDS("model/management.rds")

## Rounded copies of the output tables for presentation ----------------------
round_numeric <- function(x, digits = 3) {
  x[] <- lapply(x, function(col) if (is.numeric(col)) round(col, digits) else col)
  x
}

for (tbl in c(
  "parameters", "reference_points", "state",
  "management_scenarios", "risk", "advice"
)) {
  x <- round_numeric(read.taf(file.path("output", paste0(tbl, ".csv"))))
  assign(tbl, x)
  write.taf(tbl, dir = "report") # write.taf() accepts a workspace object name as a string
}

## Diagnostic plots -----------------------------------------------------------
## Full SPiCT diagnostic panel (catch, biomass, F, B/Bmsy, F/Fmsy, residuals)
taf.png("report/diagnostics")
plot(fit)
dev.off()

taf.png("report/retro")
plotspict.retro(fit)
dev.off()

taf.png("report/hindcast")
plotspict.hindcast(fit)
dev.off()

## Summary plots ---------------------------------------------------------------
taf.png("report/biomass")
plotspict.biomass(fit)
dev.off()

taf.png("report/bbmsy")
plotspict.bbmsy(fit)
dev.off()

taf.png("report/fishing_mortality")
plotspict.f(fit)
dev.off()

taf.png("report/ffmsy")
plotspict.ffmsy(fit)
dev.off()

taf.png("report/catch")
plotspict.catch(fit)
dev.off()

## Management / harvest control rule plot -------------------------------------
taf.png("report/management_scenarios")
plotspict.hcr(management)
dev.off()
