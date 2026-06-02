# =============================================================================
# analysis.R
# Replication of Table 2 from:
#   Luo, Y. and Spindler, M. (2017). "L2-Boosting for Economic Applications."
#   AER Papers & Proceedings, 107(5): 270-273.
#
# Inputs:  temp/eminent_domain.rds   (written by preprocess.R)
# Outputs: output/tables/table2.tex
#
# DGP.R and helper.R are sourced from the original authors' replication package,
# available at https://www.openicpsr.org/openicpsr/project/113507/version/V1/view
# =============================================================================

library(hdm)
library(mvtnorm)
library(MASS)

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
ED1  <- rlassoIV(y = ys, x = xs, d = ds, z = zs,
                 select.Z = TRUE, select.X = FALSE)

cat("Estimating Table 2: BA (L2-Boosting)...\n")
EDB  <- boostSelectZ(y = ys, x = xs, d = ds, z = zs, post = FALSE)

cat("Estimating Table 2: post-BA (Post-L2-Boosting)...\n")
EDBp <- boostSelectZ(y = ys, x = xs, d = ds, z = zs, post = TRUE)

cat("Estimating Table 2: oBA (Orthogonal L2-Boosting)...\n")
EDBo <- orthoboostSelectZ(y = ys, x = xs, d = ds, z = zs)

# Collect Table 2 results
t2 <- data.frame(
  method = c("post-Lasso", "BA", "post-BA", "oBA"),
  beta   = c(coef(ED1)[1],        coef(EDB)[1],        coef(EDBp)[1],        coef(EDBo)[1]),
  se     = c(ED1$se[1],           EDB$se[1],            EDBp$se[1],           EDBo$se[1])
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
dir.create("output/tables", recursive = TRUE, showWarnings = FALSE)

t2_latex <- sprintf(
'\\begin{table}[h]
\\centering
\\caption{Replication of Table 2: Effect of Federal Appellate Takings Law Decisions
on Economic Outcomes. From Luo and Spindler (2017, AER P\\&P).}
\\begin{tabular*}{\\textwidth}{@{\\extracolsep{\\fill}}lcccc}
\\hline
 & post-Lasso & BA & post-BA & oBA \\\\
\\hline
$\\hat{\\beta}$ & $%.3f$ & $%.3f$ & $%.3f$ & $%.3f$ \\\\
se             & $%.3f$ & $%.3f$ & $%.3f$ & $%.3f$ \\\\
\\hline
\\end{tabular*}
\\begin{minipage}{\\textwidth}
\\footnotesize Note: Paper reports $\\hat{\\beta}$ = 0.005, 0.005, 0.004, 0.008
and se = 0.012, 0.007, 0.006, 0.006.
\\end{minipage}
\\label{tab:table2}
\\end{table}',
  t2$beta[1], t2$beta[2], t2$beta[3], t2$beta[4],
  t2$se[1],   t2$se[2],   t2$se[3],   t2$se[4]
)

writeLines(t2_latex, "output/tables/table2.tex")
cat("\nWrote output/tables/table2.tex\n")
cat("=== analysis.R complete ===\n")
