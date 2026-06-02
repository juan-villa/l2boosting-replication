# Data Dictionary

---

## Table 2: Empirical Application (EminentDomain)

### Source
Belloni, A., D. Chen, V. Chernozhukov, and C. Hansen. 2012. "Sparse Models and Methods
for Optimal Instruments with an Application to Eminent Domain." *Econometrica* 80(6): 2369–2429.

Accessed via the R package `hdm` using `data("EminentDomain")`. No external download required:
`install.packages("hdm"); data("EminentDomain")`.

### Dataset: EminentDomain$logGDP
N = 312 observations, 140 instrumental variables.

| Variable | Object in R | Type | Description | Units |
|----------|-------------|------|-------------|-------|
| `y` | `EminentDomain$logGDP$y` | Numeric (outcome) | Log GDP per capita. Mean = 11.2297, SD = 0.694. | Log USD |
| `d` | `EminentDomain$logGDP$d` | Numeric (treatment) | Share of pro-plaintiff decisions by federal appellate courts; measures strength of property rights protection. | Proportion |
| `z` | `EminentDomain$logGDP$z` | Numeric matrix (instruments) | 140 potential instrumental variables capturing judge characteristics and court composition. | Various |
| `x` | `EminentDomain$logGDP$x[, -50]` | Numeric matrix (controls) | Control variables; column 50 dropped per replication code (likely collinearity). | Various |

### Standardization (applied in preprocess.R)

| Variable | Transformation |
|----------|---------------|
| `ys` | Demeaned only (`scale = FALSE`) |
| `ds` | Demeaned and scaled to unit variance |
| `xs` | Demeaned and scaled to unit variance |
| `zs` | Demeaned and scaled to unit variance |
