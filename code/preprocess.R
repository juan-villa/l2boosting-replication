# =============================================================================
# preprocess.R
# Replication of Tables 2 and 3 from:
#   Luo, Y. and Spindler, M. (2017). "L2-Boosting for Economic Applications."
#   AER Papers & Proceedings, 107(5): 270-273.
#
# Reads:  EminentDomain dataset from hdm R package (no files in input/)
# Writes: temp/eminent_domain.rds
#
# Note: Table 3 uses no real data. Its DGP is defined in code/DGP.R and
#       called directly by code/analysis.R. No preprocessing required for it.
# =============================================================================

library(hdm)

cat("Loading EminentDomain from hdm package...\n")
data("EminentDomain")

# -----------------------------------------------------------------------------
# Extract raw variables (following Sim_AER_V3.R exactly)
# -----------------------------------------------------------------------------
y <- EminentDomain$logGDP$y
d <- EminentDomain$logGDP$d
z <- EminentDomain$logGDP$z
x <- EminentDomain$logGDP$x[, -50]   # column 50 dropped per replication code

# -----------------------------------------------------------------------------
# Standardize (following Sim_AER_V3.R exactly)
# y: demeaned only (scale=FALSE)
# d, x, z: demeaned and scaled to unit variance
# -----------------------------------------------------------------------------
ys <- scale(y, center = TRUE,  scale = FALSE)
ds <- scale(d, center = TRUE,  scale = TRUE)
xs <- scale(x, center = TRUE,  scale = TRUE)
zs <- scale(z, center = TRUE,  scale = TRUE)

# -----------------------------------------------------------------------------
# Save to temp/
# -----------------------------------------------------------------------------
dir.create("temp", showWarnings = FALSE)

saveRDS(
  list(y = y, d = d, z = z, x = x,
       ys = ys, ds = ds, zs = zs, xs = xs),
  file = "temp/eminent_domain.rds"
)

# -----------------------------------------------------------------------------
# Console summary (mirrors Assignment 4 style)
# -----------------------------------------------------------------------------
cat("\n=== Preprocessing Summary ===\n")
cat(sprintf("N observations:               %d\n",   nrow(z)))
cat(sprintf("N instruments (z):            %d\n",   ncol(z)))
cat(sprintf("N controls (x, col 50 drop):  %d\n",   ncol(x)))
cat(sprintf("log(GDP) mean:                %.4f\n", mean(y)))
cat(sprintf("log(GDP) sd:                  %.4f\n", sd(y)))
cat(sprintf("Treatment (d) mean:           %.4f\n", mean(d)))
cat(sprintf("Treatment (d) sd:             %.4f\n", sd(d)))
cat("\nScaled variables written to temp/eminent_domain.rds\n")
cat("=== preprocess.R complete ===\n")
