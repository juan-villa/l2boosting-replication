# =============================================================================
# analysis.R
# Replication of Tables 2 and 3 from:
#   Luo, Y. and Spindler, M. (2017). "L2-Boosting for Economic Applications."
#   AER Papers & Proceedings, 107(5): 270-273.
#
# Inputs:  temp/eminent_domain.rds   (written by preprocess.R)
# Outputs: output/tables/table2.tex
#          output/tables/table3.tex
# =============================================================================

library(hdm)
library(mvtnorm)
library(MASS)

source("code/DGP.R")
source("code/helper.R")

# newboost is not on CRAN; install from R-Forge if not present:
#   install.packages("newboost", repos = "http://R-Forge.R-project.org")
library(newboost)

set.seed(12345)

# =============================================================================
# TABLE 2: Empirical Application — EminentDomain
# Effect of Federal Appellate Takings Law Decisions on Economic Outcomes
# =============================================================================

cat("Loading preprocessed EminentDomain data...\n")
ed <- readRDS("temp/eminent_domain.rds")
ys <- ed$ys
xs <- ed$xs
ds <- ed$ds
zs <- ed$zs

cat("Estimating Table 2: post-Lasso...\n")
ED1     <- rlassoIV(y = ys, x = xs, d = ds, z = zs,
                    select.Z = TRUE, select.X = FALSE)

cat("Estimating Table 2: BA (L2-Boosting)...\n")
EDB     <- boostSelectZ(y = ys, x = xs, d = ds, z = zs, post = FALSE)

cat("Estimating Table 2: post-BA (Post-L2-Boosting)...\n")
EDBp    <- boostSelectZ(y = ys, x = xs, d = ds, z = zs, post = TRUE)

cat("Estimating Table 2: oBA (Orthogonal L2-Boosting)...\n")
EDBo    <- orthoboostSelectZ(y = ys, x = xs, d = ds, z = zs)

# Collect Table 2 results
t2 <- data.frame(
  method = c("post-Lasso", "BA", "post-BA", "oBA"),
  beta   = c(coef(ED1)[1],       EDB$coef,        EDBp$coef,        EDBo$coef),
  se     = c(ED1$se[1],          EDB$se,           EDBp$se,          EDBo$se)
)

# Paper targets (Table 2 from preliminaries sheet)
t2_paper <- data.frame(
  method = c("post-Lasso", "BA", "post-BA", "oBA"),
  beta   = c(0.005, 0.005, 0.004, 0.008),
  se     = c(0.012, 0.007, 0.006, 0.006)
)

cat("\n=== TABLE 2 REPLICATION SUMMARY ===\n")
cat(sprintf("%-12s  %8s %8s  |  %8s %8s\n",
            "Method", "beta_rep", "se_rep", "beta_pap", "se_pap"))
cat(strrep("-", 56), "\n")
for (i in seq_len(nrow(t2))) {
  cat(sprintf("%-12s  %8.4f %8.4f  |  %8.4f %8.4f\n",
              t2$method[i], t2$beta[i], t2$se[i],
              t2_paper$beta[i], t2_paper$se[i]))
}

# Write Table 2 LaTeX fragment
t2_latex <- sprintf(
'\\begin{table}[h]
\\centering
\\caption{Replication of Table 2: Effect of Federal Appellate Takings Law Decisions
on Economic Outcomes. From Luo and Spindler (2017, AER P\\&P).}
\\begin{tabular}{lcccc}
\\hline
 & post-Lasso & BA & post-BA & oBA \\\\
\\hline
$\\hat{\\beta}$ & $%.3f$ & $%.3f$ & $%.3f$ & $%.3f$ \\\\
se             & $%.3f$ & $%.3f$ & $%.3f$ & $%.3f$ \\\\
\\hline
\\multicolumn{5}{l}{\\footnotesize Note: Paper reports $\\hat{\\beta}$ =
0.005, 0.005, 0.004, 0.008 and se = 0.012, 0.007, 0.006, 0.006.}
\\end{tabular}
\\label{tab:table2}
\\end{table}',
  t2$beta[1], t2$beta[2], t2$beta[3], t2$beta[4],
  t2$se[1],   t2$se[2],   t2$se[3],   t2$se[4]
)

dir.create("output/tables", recursive = TRUE, showWarnings = FALSE)
writeLines(t2_latex, "output/tables/table2.tex")
cat("\nWrote output/tables/table2.tex\n")

# =============================================================================
# TABLE 3: Monte Carlo Simulation — IV Setting
# DGP parameters (from DGP.R and Sim_AER_V3.R):
#   n = 100, p = 100, s = 5, R = 500 replications
#   alpha (true effect) = 1, F-stat target = 30
#   Instrument correlation: toeplitz(0.5^(0:(p-1)))
#   Error correlation (Cev): 0.0 (independent errors)
# =============================================================================

cat("\n\nRunning Table 3: Monte Carlo simulation (R=500, n=100, p=100)...\n")
cat("This may take several minutes.\n\n")

R <- 500
n <<- 100
p <<- 100
s <<- 5

Results <- matrix(NA, ncol = 5, nrow = R)
RP      <- matrix(NA, ncol = 5, nrow = R)

for (i in 1:R) {
  if (i %% 50 == 0) cat(sprintf("  Iteration %d / %d\n", i, R))

  data <- DGP()
  y    <- data$Y
  d    <- data$X
  Z    <- data$Z

  # Subsample instruments if p >= n
  if (n <= p) {
    pUse <- sample(p, n - 2, replace = FALSE, prob = rep(1/p, p))
    ZUSE <- Z[, pUse]
  } else {
    ZUSE <- Z
  }

  # post-Lasso IV
  tryCatch({
    lasso        <- rlassoIV(x = NULL, y = y, z = Z, d = d,
                             select.Z = TRUE, select.X = FALSE)
    Results[i,2] <- coef(lasso)[1]
    RP[i,2]      <- abs((coef(lasso)[1] - 1) / lasso$se) > 1.96
  }, error = function(e) {
    Results[i,2] <<- NA
    RP[i,2]      <<- NA
  })

  # BA (L2-Boosting IV)
  tryCatch({
    L2           <- boostSelectZ(x = NULL, d = d, y = y, z = Z, post = FALSE)
    Results[i,3] <- L2$coef
    RP[i,3]      <- abs((L2$coef - 1) / L2$se) > 1.96
  }, error = function(e) NULL)

  # post-BA (Post-L2-Boosting IV)
  tryCatch({
    L2p          <- boostSelectZ(x = NULL, d = d, y = y, z = Z, post = TRUE)
    Results[i,4] <- L2p$coef
    RP[i,4]      <- abs((L2p$coef - 1) / L2p$se) > 1.96
  }, error = function(e) NULL)

  # oBA (Orthogonal L2-Boosting IV)
  tryCatch({
    L2o          <- orthoboostSelectZ(x = NULL, d = d, y = y, z = Z)
    Results[i,5] <- L2o$coef
    RP[i,5]      <- abs((L2o$coef - 1) / L2o$se) > 1.96
  }, error = function(e) NULL)
}

# Compute bias (true alpha = 1) and rejection probability
bias <- colMeans(Results[, 2:5, drop = FALSE] - 1, na.rm = TRUE)
rp   <- colMeans(RP[, 2:5, drop = FALSE], na.rm = TRUE)

t3 <- data.frame(
  method = c("post-Lasso", "BA", "post-BA", "oBA"),
  bias   = bias,
  rp     = rp
)

# Paper targets (Table 3 from preliminaries sheet)
t3_paper <- data.frame(
  method = c("post-Lasso", "BA", "post-BA", "oBA"),
  bias   = c(0.082, 0.121, 0.136, 0.121),
  rp     = c(0.002, 0.042, 0.054, 0.042)
)

cat("\n=== TABLE 3 REPLICATION SUMMARY ===\n")
cat(sprintf("%-12s  %8s %8s  |  %8s %8s\n",
            "Method", "bias_rep", "rp_rep", "bias_pap", "rp_pap"))
cat(strrep("-", 56), "\n")
for (i in seq_len(nrow(t3))) {
  cat(sprintf("%-12s  %8.4f %8.4f  |  %8.4f %8.4f\n",
              t3$method[i], t3$bias[i], t3$rp[i],
              t3_paper$bias[i], t3_paper$rp[i]))
}

# Write Table 3 LaTeX fragment
t3_latex <- sprintf(
'\\begin{table}[h]
\\centering
\\caption{Replication of Table 3: Simulation Results (IV Setting).
$n=100$, $p=100$, $s=5$, $R=500$ replications, true $\\alpha=1$.
From Luo and Spindler (2017, AER P\\&P).}
\\begin{tabular}{lcccc}
\\hline
 & post-Lasso & BA & post-BA & oBA \\\\
\\hline
bias & $%.3f$ & $%.3f$ & $%.3f$ & $%.3f$ \\\\
RP   & $%.3f$ & $%.3f$ & $%.3f$ & $%.3f$ \\\\
\\hline
\\multicolumn{5}{l}{\\footnotesize Note: Paper reports bias =
0.082, 0.121, 0.136, 0.121 and RP = 0.002, 0.042, 0.054, 0.042.}
\\end{tabular}
\\label{tab:table3}
\\end{table}',
  t3$bias[1], t3$bias[2], t3$bias[3], t3$bias[4],
  t3$rp[1],   t3$rp[2],   t3$rp[3],   t3$rp[4]
)

writeLines(t3_latex, "output/tables/table3.tex")
cat("\nWrote output/tables/table3.tex\n")

cat("\n=== analysis.R complete ===\n")
