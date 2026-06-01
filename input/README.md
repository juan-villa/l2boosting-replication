# Input Data

This replication has two data sources. Neither requires downloading external files.

---

## Table 2: EminentDomain (Empirical Application)

The dataset is bundled in the `hdm` R package. To load it:

```r
install.packages("hdm")
library(hdm)
data("EminentDomain")
```

No files need to be placed in `input/`. The preprocessing script (`code/preprocess.R`)
loads this directly from the package.

**Original source:** Belloni, A., D. Chen, V. Chernozhukov, and C. Hansen. 2012.
"Sparse Models and Methods for Optimal Instruments with an Application to Eminent Domain."
*Econometrica* 80(6): 2369–2429.

---

## Table 3: Monte Carlo Simulation

No dataset. Simulated data are generated programmatically in `code/analysis.R`
according to the DGP in the Luo & Spindler (2017) online Appendix.
See `data_dictionary.md` for DGP parameters.
