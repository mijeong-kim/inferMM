# SDL demo provenance and preparation

The source fluorescence traces are in
`inst/extdata/sdl_fluorescence_raw.csv`. They are the six parental GH1 enzyme
variants (1111--6666) from Rapp, Bremer and Romero (2024), *Self-driving
laboratories to autonomously navigate the protein fitness landscape*,
Nature Chemical Engineering 1, 97--107,
<https://doi.org/10.1038/s44286-023-00002-4>. The CSV preserves the reaction
column ordering and duplicate headers of the source study files. Times are
in seconds and measurements are fluorescence RFU.

From this package's source directory, run:

```sh
Rscript inst/data-raw/prepare_sdl_demo.R
```

The script also accepts a source CSV path and a package-source path as its
first and second arguments. It calls a sourceable, non-exported helper in
`inst/data-preparation/prepare_sdl_demo.R`; it does not call any fitting solver.
An unexpected header stops preparation instead of silently discarding a
reaction. A unit suffix (`uM` or `u`) is optional; a decimal concentration is
never interpreted as an automatic name suffix.

Initial rates use a linear regression on the first three recorded times
(0, 119.815 and 239.817 seconds). Divide RFU/s by the published 4MU calibration
slope 794.64 RFU/micromolar and multiply by 60 for micromolar/minute. The
calibration intercept does not affect a time slope. The result must contain
six enzymes, eight concentrations (including 3.90625 micromolar), and four
reactions per enzyme/concentration: 192 rows in total. The script updates
both the CSV and R data mirrors and preserves the separate `alves_demo` data.

`replicate` is an ordinal assigned by source-column occurrence within each
enzyme/concentration, not a verified sample, well, plate, run or batch ID
linking observations across concentrations. These data do not establish
conditional independence or identify biological replicate clusters.

Versions through 0.1.1 contained 168 rates because the unit-free lowest
concentration headers were omitted during earlier preprocessing. Version
0.1.2 restores these 24 reactions. The estimation algorithms are unchanged.

The distributed source archive includes the preparation entry point and this
README under `inst/data-raw/`. The source checkout also retains a development
copy in top-level `data-raw/`, excluded from the build by `.Rbuildignore`.
