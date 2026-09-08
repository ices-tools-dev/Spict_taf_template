# SPiCT assessment template (ICES TAF)
 
ICES [Transparent Assessment Framework](https://taf.ices.dk) template for a
SPiCT surplus-production stock assessment.
  
This repository is populated with a worked example - the Northeast Arctic
golden redfish (*Sebastes norvegicus*, reg.27.1-2) SPiCT assessment, using
the model configuration agreed at the 2026 benchmark (WKBWNG) - so that every
script runs end-to-end and produces real output. **To use it for a different
stock, you need to:**
 
1. Replace the files in `bootstrap/initial/data/` with your own data
   (see that folder's `README.md` for the expected format).
2. Update `data_catches.R` and `data_index.R` if your raw files have
   different column names or structure.
3. Review and change the stock-specific settings in `data_spict_input.R`
   (priors, `stdevfacC` ramp, fixed `logn`) and `model.R` (management
   scenarios, `advice_year` calculation) - see "Notes on this template"
   below for exactly what to look at.
4. Update `bootstrap/DATA.bib` and `DESCRIPTION.txt` to describe your own
   data sources and stock.
   
## Structure
 
```text
.
├── DESCRIPTION.txt      Analysis metadata
├── CONTENTS.txt         One-line description of each script
├── utilities.R          spictRisk() - shared helper, sourced by output.R
├── data.R                 Thin wrapper -> data/catches.csv, data/index.csv, data/spict_input.rds
├── data_catches.R         -> data/catches.csv
├── data_index.R           -> data/index.csv
├── data_spict_input.R     -> data/spict_input.rds (ready for fit.spict())
├── model.R               Reads data/spict_input.rds -> model/fit.rds, model/management.rds
├── output.R              -> output/*.csv (parameters, reference points, status, advice)
├── report.R              -> report/*.csv (ICES-rounded tables), report/*.png (plots)
└── bootstrap/
    ├── DATA.bib               Metadata for the two raw input files
    └── initial/data/          Drop your raw files here (see its README.md)
```
 
`data.R`  calls `source()` on `data_catches.R`, `data_index.R`, and `data_spict_input.R` in order. All data
processing - including assembling the SPiCT input list (`timeC`/`timeI`,
priors, `stdevfacC`/`stdevfacI`, the fixed Schaefer `logn`) - lives in those
three scripts. `model.R` only reads `data/spict_input.rds` and
`data/catches.csv` (to keep track of `advice_year`); it does no data
wrangling of its own.
 
`data/`, `model/`, `output/`, `report/`, and `bootstrap/data/` are created
by running the scripts / bootstrap process
 
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
 
Place the raw input files in `bootstrap/initial/data/` as described in
`bootstrap/initial/data/README.md` (for the golden redfish worked example):
 
- `GoldenRedfish_landings_for_SPiCT.txt`
- `reg-assessment-survey-indices-1991.rds`
## Notes on this template
 
- `model.R` derives `assessment_year`/`advice_year` from the last year of
  catch data (`last_data_year + 1` / `+ 2`).
  Adjust this in `model.R` if your assessment calendar differs.
- The priors, `stdevfacC` ramp, and fixed Schaefer shape (`logn`) are set
  in `data_spict_input.R`; the four management scenarios (`currentF`,
  `Fmsy`, `noF`, `ices`) are set in `model.R`. All are specific to the
  golden redfish 2026 benchmark model - these are the values to review and
  change first when adapting this template for a different SPiCT stock.
- `report.R` produces standard TAF tables/plots only (no Quarto narrative
  document), and rounds numeric columns using ICES conventions via
  `icesAdvice::icesRound()`.
- `spictRisk()` in `utilities.R` is ported unchanged from the AFWG golden
  redfish repository's `src/spict_functions.R`.
 
