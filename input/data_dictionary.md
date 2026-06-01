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

---

## Table 3: Monte Carlo Simulation

### Source
No external dataset. Data are generated programmatically in `code/analysis.{py,R}`
according to the DGP described in Luo and Spindler (2017) online Appendix.

### Simulation DGP Parameters

| Parameter | Value | Description |
|-----------|-------|-------------|
| `n` | — | Number of observations per simulation draw (see Appendix) |
| `p` | — | Number of covariates/instruments in each draw |
| `n_reps` | — | Number of Monte Carlo replications |
| `β_true` | — | True treatment effect parameter |
| Error structure | — | Specification of ε_i (see Appendix) |

### Output Variables

| Variable | Description |
|----------|-------------|
| `bias` | Average bias of β̂ across replications: E[β̂] − β_true |
| `RP` | Rejection probability at nominal 5% level across replications |

### Methods Compared
| Column Label | Method |
|--------------|--------|
| post-Lasso | OLS on support selected by Lasso |
| BA | L2-Boosting (classical) |
| post-BA | OLS on support selected by L2-Boosting |
| oBA | Orthogonal L2-Boosting |
