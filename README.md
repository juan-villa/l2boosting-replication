# Replication: Luo and Spindler (2017)

This repository replicates **Tables 2 and 3** from:

> Luo, Ye, and Martin Spindler. 2017. "L2-Boosting for Economic Applications."
> *American Economic Review: Papers & Proceedings* 107(5): 270–273.
> https://doi.org/10.1257/aer.p20171040

Table 2 reports the estimated effect of federal appellate court property rights
decisions on log GDP per capita across four estimators (post-Lasso, BA, post-BA,
oBA). Table 3 reports Monte Carlo simulation results evaluating the same four
estimators under a controlled data-generating process with known true effect
α = 1.

---

## Results

| | post-Lasso | BA | post-BA | oBA |
|---|---|---|---|---|
| **Table 2: β̂** | 0.005 | 0.005 | 0.004 | 0.008 |
| **Table 2: s.e.** | 0.012 | 0.007 | 0.006 | 0.006 |
| **Table 3: bias** | 0.082 | 0.121 | 0.136 | 0.121 |
| **Table 3: RP** | 0.002 | 0.042 | 0.054 | 0.042 |

*Paper's reported values. Replicated values are in `output/tables/`.*

---

## Data

**Table 2** uses the `EminentDomain` dataset bundled in the `hdm` R package
(Chernozhukov, Hansen, and Spindler, 2016). No external download is required —
`preprocess.R` loads it directly via `data("EminentDomain")`.

**Table 3** uses no real data. Simulated observations are generated
programmatically by `code/DGP.R`, taken from the authors' original replication
package at:
https://www.openicpsr.org/openicpsr/project/113507/version/V1/view

See `input/README.md` and `data_dictionary.md` for full details.

---

## Prerequisites

**R packages** (install before running):
```r
install.packages(c("hdm", "mvtnorm", "MASS"))
install.packages("newboost", repos = "http://R-Forge.R-project.org")
```

> **Note:** `newboost` is not on CRAN. If R-Forge is unavailable, contact the
> authors at martin.spindler@uni-hamburg.de.

**LaTeX:** A full LaTeX distribution is required to compile the paper.
- Mac: [MacTeX](https://www.tug.org/mactex/)
- Linux: `sudo apt install texlive-full`

**Other:** GNU Make, R (≥ 4.0), bash

---

## Reproduction

Clone the repository and run:

```bash
git clone git@github.com:juan-villa/l2boosting-replication.git
cd l2boosting-replication
make
```

Or using the convenience wrapper:

```bash
bash run_all.sh
```

The compiled paper will be at `paper/paper.pdf`.

To remove all generated files and rerun from scratch:

```bash
make clean
make
```

---

## Repository Structure

```
l2boosting-replication/
├── Makefile                  # Pipeline automation
├── run_all.sh                # Convenience wrapper
├── README.md                 # This file
├── data_dictionary.md        # Variable descriptions and DGP parameters
├── input/
│   └── README.md             # Data access instructions
├── code/
│   ├── preprocess.R          # Load and standardize EminentDomain data
│   ├── analysis.R            # Estimate Tables 2 and 3, write LaTeX output
│   ├── DGP.R                 # Simulation DGP (from authors' replication package)
│   └── helper.R              # Boosting inference functions (from authors' replication package)
├── output/
│   └── tables/
│       ├── table2.tex        # LaTeX fragment for Table 2
│       └── table3.tex        # LaTeX fragment for Table 3
├── temp/                     # Intermediate files (gitignored)
└── paper/
    ├── paper.tex             # Main paper
    ├── references.bib        # Bibliography
    └── paper.pdf             # Compiled output
```

---

## Reference

Luo, Ye, and Martin Spindler. 2017. "L2-Boosting for Economic Applications."
*American Economic Review: Papers & Proceedings* 107(5): 270–273.
