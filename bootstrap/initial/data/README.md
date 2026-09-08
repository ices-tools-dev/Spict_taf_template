# Raw input data

This folder holds the two raw files referenced in `bootstrap/DATA.bib`.
Running `TAF::taf.boot()` (or `icesTAF::taf.bootstrap()`) copies them
into `bootstrap/data/`, which `data.R` reads from.

Place the following files here, unmodified, before running the analysis:

- **`GoldenRedfish_landings_for_SPiCT.txt`** - tab-separated total annual
  landings. Expected columns (case-insensitive): `Year`, `Norway`,
  `Russia`, `OtherNations`, `Total`, and a notes column that `data.R`
  drops (matched as `data_note` after lower-casing).

- **`reg-assessment-survey-indices-1991.rds`** - an R list of 4 biomass
  survey indices (total biomass, >30 cm, >55 cm, <15 cm), each a data
  frame with columns `year`, `est`, `lwr`, `upr`, `se`. `data.R` uses
  list element `[[2]]` (>30 cm), matching the choice made at the 2026
  benchmark (WKBWNG).

If either file has different column names, update `data.R` accordingly
rather than relying on it to guess.
