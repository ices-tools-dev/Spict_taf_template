## Stage: catches
## Before: bootstrap/data/GoldenRedfish_landings_for_SPiCT.txt
## After:  data/catches.csv
##
## Columns in the raw file: Year, Norway, Russia, OtherNations, Total, and a
## notes column - renamed/dropped below. See bootstrap/initial/data/README.md
## if these names ever change.

library(icesTAF)
library(dplyr)
library(readr)

catches <- read_tsv(
  file.path(boot.dir(), "data", "GoldenRedfish_landings_for_SPiCT.txt"),
  col_names = TRUE,
  show_col_types = FALSE
) |>
  rename_with(tolower) |>
  rename(nor = norway, rus = russia, other = othernations) |>
  select(-data_note)

## Sanity check: where all three national components are reported, they
## should sum to the reported total.
catch_totals_match <- catches |>
  filter(!is.na(nor)) |>
  rowwise() |>
  mutate(total2 = sum(c_across(c(nor, rus, other)), na.rm = TRUE)) |>
  ungroup() |>
  mutate(equal = total2 == total) |>
  pull(equal) |>
  all()

if (!catch_totals_match) {
  stop(
    "Catch totals do not match the sum of the national components (nor + ",
    "rus + other). Check bootstrap/initial/data/GoldenRedfish_landings_for_SPiCT.txt."
  )
}

write.taf(catches, dir = "data")
