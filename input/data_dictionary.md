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

---

## Table 3: Monte Carlo Simulation

### Source
No external dataset. Data are generated programmatically in `code/analysis.R`
by calling the DGP function defined in `code/DGP.R`, taken directly from the
authors' replication package at:
https://www.openicpsr.org/openicpsr/project/113507/version/V1/view

### Simulation DGP Parameters

| Parameter | Value | Description |
|-----------|-------|-------------|
| `n` | 100 | Number of observations per simulation draw |
| `p` | 100 | Number of potential instruments |
| `s` | 5 | Number of nonzero first-stage coefficients (sparsity) |
| `n_reps` | 500 | Number of Monte Carlo replications |
| `alpha` | 1 | True treatment effect parameter |
| `F_target` | 30 | Target first-stage F-statistic |
| `Cev` | 0.0 | Correlation between structural and first-stage errors (independent errors) |
| Instrument correlation | toeplitz(0.5^(0:(p-1))) | AR(1)-type correlation structure across instruments |
| First-stage design | cutoff: c(rep(1,s), rep(0,p-s)) | Only first s instruments enter the first stage |

### Output Variables

| Variable | Description |
|----------|-------------|
| `bias` | Average bias of estimator across replications: E[β̂] − α, where α = 1 |
| `RP` | Rejection probability at nominal 5% level across replications |

### Methods Compared

| Column Label | Method |
|--------------|--------|
| post-Lasso | OLS on support selected by Lasso (via `rlassoIV` in `hdm`) |
| BA | L2-Boosting IV (via `boostSelectZ`, `post = FALSE`) |
| post-BA | Post-L2-Boosting IV: OLS on support selected by L2-Boosting (via `boostSelectZ`, `post = TRUE`) |
| oBA | Orthogonal L2-Boosting IV (via `orthoboostSelectZ`) |
