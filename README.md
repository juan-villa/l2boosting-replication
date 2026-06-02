# Replication: Luo and Spindler (2017)

This repository replicates **Table 2** from:

> Luo, Ye, and Martin Spindler. 2017. "L2-Boosting for Economic Applications."
> *American Economic Review: Papers & Proceedings* 107(5): 270–273.
> https://doi.org/10.1257/aer.p20171040

Table 2 reports the estimated effect of federal appellate court property rights
decisions on log GDP per capita across four estimators: post-Lasso, BA (L2-Boosting),
post-BA (Post-L2-Boosting), and oBA (Orthogonal L2-Boosting).

---

## Results

| | post-Lasso | BA | post-BA | oBA |
|---|---|---|---|---|
| **β̂ (paper)** | 0.005 | 0.005 | 0.004 | 0.008 |
| **s.e. (paper)** | 0.012 | 0.007 | 0.006 | 0.006 |

*Replicated values are in `output/tables/table2.tex`.*

---

## Data

Table 2 uses the `EminentDomain` dataset bundled in the `hdm` R package
(Chernozhukov, Hansen, and Spindler, 2016). No external download is required —
`preprocess.R` loads it directly via `data("EminentDomain")`.

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
├── data_dictionary.md        # Variable descriptions
├── input/
│   └── README.md             # Data access instructions
├── code/
│   ├── preprocess.R          # Load and standardize EminentDomain data
│   ├── analysis.R            # Estimate Table 2, write LaTeX output
│   ├── DGP.R                 # From authors' replication package (unused in Table 2)
│   └── helper.R              # Boosting inference functions (from authors' replication package)
├── output/
│   └── tables/
│       └── table2.tex        # LaTeX fragment for Table 2
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
