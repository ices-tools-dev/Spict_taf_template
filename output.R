## Extract parameter, reference point, status and catch-advice tables
## Before: data/catches.csv, model/fit.rds, model/management.rds
## After:  output/parameters.csv, output/reference_points.csv, output/state.csv,
##         output/management_scenarios.csv, output/risk.csv, output/advice.csv

library(icesTAF)
library(spict)
library(dplyr)
library(tibble)

mkdir("output")

source("utilities.R") # spictRisk()

catches    <- read.taf("data/catches.csv")
fit        <- readRDS("model/fit.rds")
management <- readRDS("model/management.rds")

last_data_year  <- max(catches$year)
assessment_year <- last_data_year + 1
advice_year     <- assessment_year + 1

## Parameter estimates --------------------------------------------------------
parameters <- sumspict.parest(fit) |>
  as.data.frame() |>
  rownames_to_column("parameter")
write.taf(parameters, dir = "output")

## Deterministic reference points --------------------------------------------
reference_points <- sumspict.drefpoints(fit) |>
  as.data.frame() |>
  rownames_to_column("reference_point")
write.taf(reference_points, dir = "output")

## Current stock status (last observed year) ---------------------------------
## Rows are named e.g. "B_<year>", "F_<year>", "B_<year>/Bmsy", "F_<year>/Fmsy"
## (see spict::sumspict.states()).
state <- sumspict.states(fit) |>
  as.data.frame() |>
  rownames_to_column("quantity")
write.taf(state, dir = "output")

## Management scenarios --------------------------------------------------------
manOutput <- sumspict.manage(management, include.unc = TRUE)

management_scenarios <- manOutput$est |>
  as.data.frame() |>
  rownames_to_column("scenario")
write.taf(management_scenarios, dir = "output")

## Risk table: probability of breaching Btrigger/Blim/Flim by scenario -------
risk <- spictRisk(management, bmsyfrac = 0.5, years = c(advice_year - 1, advice_year))
write.taf(risk, dir = "output")

## Catch advice ---------------------------------------------------------------
## sumspict.manage() labels the ICES hockey-stick scenario "ICES advice rule
## (2025)" and the current-F scenario "Keep current F" (spict::manage.R).
advice_row <- management_scenarios |>
  filter(grepl("ICES advice rule", scenario))

sq_row <- management_scenarios |>
  filter(grepl("Keep current F", scenario))

current_F_row <- state |> filter(grepl("/Fmsy$", quantity))
current_B_row <- state |> filter(grepl("/Bmsy$", quantity))

advice <- data.frame(
  assessment_year   = assessment_year,
  advice_year       = advice_year,
  advised_catch     = round(advice_row$C, 0),
  current_F_Fmsy    = current_F_row$estimate,
  current_B_Bmsy    = current_B_row$estimate,
  sq_forecast_B_Bmsy = sq_row$`B/Bmsy`
)
write.taf(advice, dir = "output")
