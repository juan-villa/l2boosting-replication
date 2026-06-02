# Input Data

This replication has one data source. No external file download is required.

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
