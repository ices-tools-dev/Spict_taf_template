# Golden redfish SPiCT assessment (ICES TAF)

ICES [Transparent Assessment Framework](https://taf.ices.dk) analysis for
the Northeast Arctic golden redfish (*Sebastes norvegicus*, reg.27.1-2)
SPiCT surplus-production assessment. This is a TAF restructuring of the
AFWG production Quarto workflow, using the model configuration agreed at
the 2026 benchmark (WKBWNG).

## Structure

```text
.
├── DESCRIPTION.txt   Analysis metadata
├── CONTENTS.txt      One-line description of each script
├── utilities.R       spictRisk() - shared helper, sourced by output.R
├── data.R            Thin wrapper -> data/catches.csv, data/index.csv, data/spict_input.rds
├── data_scripts/     One script per data-prep stage, sourced by data.R
│   ├── catches.R         -> data/catches.csv
│   ├── index.R           -> data/index.csv
│   └── spict_input.R     -> data/spict_input.rds (ready for fit.spict())
├── model.R           Reads data/spict_input.rds -> model/fit.rds, model/management.rds
├── output.R          -> output/*.csv (parameters, reference points, status, advice)
├── report.R          -> report/*.csv (rounded tables), report/*.png (plots)
└── bootstrap/
    ├── DATA.bib               Metadata for the two raw input files
    └── initial/data/          Drop the raw files here (see its README.md)
```

All data processing - including assembling the SPiCT input list (`timeC`/`timeI`,
priors, `stdevfacC`/`stdevfacI`, the fixed Schaefer `logn`) - lives in
`data_scripts/`. `model.R` only reads `data/spict_input.rds` and
`data/catches.csv` (for `advice_year` bookkeeping); it does no data
wrangling of its own.

`data/`, `model/`, `output/`, `report/`, and `bootstrap/data/` are created
by running the scripts / bootstrap process; they are not committed (see
`.gitignore`).

## Running

```r
library(icesTAF)

# Copy raw files from bootstrap/initial/data/ into bootstrap/data/
taf.bootstrap()

# Run the four TAF scripts in sequence
sourceAll()
```

or run scripts individually with `source("data.R")`, etc.

## Before running

Place the two raw input files in `bootstrap/initial/data/` as described in
`bootstrap/initial/data/README.md`:

- `GoldenRedfish_landings_for_SPiCT.txt`
- `reg-assessment-survey-indices-1991.rds`

## Notes on this restructuring

- `model.R` derives `assessment_year`/`advice_year` from the last year of
  catch data (`last_data_year + 1` / `+ 2`), matching the AFWG convention.
  Adjust this in `model.R` if your assessment calendar differs.
- The priors, `stdevfacC` ramp, and fixed Schaefer shape (`logn`) are set
  in `data_scripts/spict_input.R`; the four management scenarios
  (`currentF`, `Fmsy`, `noF`, `ices`) are set in `model.R`. All are
  specific to the golden redfish 2026 benchmark model - if you're adapting
  this template for a different SPiCT stock, these are the values to
  review and change first.
- `report.R` produces standard TAF tables/plots only (no Quarto narrative
  document). The original repository's Quarto-based advice sheet, report,
  and benchmark exploration workflow (`src/exploration/`) are not part of
  this TAF restructuring.
- `spictRisk()` in `utilities.R` is ported unchanged from
  `src/spict_functions.R` in the original repository.
