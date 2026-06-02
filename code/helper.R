# help functions for estimation of inference of treatment effects with many controls and many instruements
# These functions will be provided in the R package newboost which is in preparation
# preview versioin available upon request by the authors


boostSelectZ <- function (x, d, y, z, post = TRUE) 
{
  d <- as.matrix(d)
  if (is.vector(x)) 
    x <- as.matrix(x)
  n <- length(y)
  kex <- dim(x)[2]
  ke <- dim(d)[2]
  if (is.null(colnames(d))) 
    colnames(d) <- paste("d", 1:ke, sep = "")
  if (is.null(colnames(x)) & !is.null(x)) 
    colnames(x) <- paste("x", 1:kex, sep = "")
  # if (intercept) ys <- scale(y, center=TRUE, scale=FALSE)
  # if (normalize) {
  #   ds <- scale(d, center=TRUE, scale=TRUE)
  #   xs <- scale(x, center=TRUE, scale=TRUE)
  #   zs <- scale(z, center=TRUE, scale=TRUE)
  # }

  Z <- cbind(z, x)
  kiv <- dim(Z)[2]
  Dhat <- NULL
  flag.const <- 0
  for (i in 1:ke) {
    di <- d[, i]
    L2Boost.fit <- L2Boost(y=di, X=Z, post = post)
    if (sum(L2Boost.fit$stop_rule) == 0) {
      dihat <- rep(mean(di), n)
      flag.const <- flag.const + 1
      if (flag.const > 1) 
        message("No variables selected for two or more instruments leading to multicollinearity problems.")
    }
    else {
      dihat <- predict(L2Boost.fit)
    }
    Dhat <- cbind(Dhat, dihat)
  }
  Dhat <- cbind(Dhat, x)
  d <- cbind(d, x)
  alpha.hat <- solve(t(Dhat) %*% d) %*% (t(Dhat) %*% y)
  residuals <- y - d %*% alpha.hat
  Omega.hat <- t(Dhat) %*% diag(as.vector(residuals^2)) %*% 
    Dhat
  Q.hat.inv <- MASS::ginv(t(d) %*% Dhat)
  vcov <- Q.hat.inv %*% Omega.hat %*% t(Q.hat.inv)
  rownames(alpha.hat) <- c(colnames(d))
  colnames(vcov) <- rownames(vcov) <- rownames(alpha.hat)
  res <- list(coefficients = alpha.hat[1:ke, ], se = sqrt(diag(vcov))[1:ke], 
              vcov = vcov[1:ke, 1:ke, drop = FALSE], residuals = residuals, 
              samplesize = n, call = match.call())
  class(res) <- "L2BoostIVselectZ"
  return(res)
}

orthoboostSelectZ <- function (x, d, y, z) 
{
  d <- as.matrix(d)
  if (is.vector(x)) 
    x <- as.matrix(x)
  n <- length(y)
  kex <- dim(x)[2]
  ke <- dim(d)[2]
  if (is.null(colnames(d))) 
    colnames(d) <- paste("d", 1:ke, sep = "")
  if (is.null(colnames(x)) & !is.null(x)) 
    colnames(x) <- paste("x", 1:kex, sep = "")
  # if (intercept) ys <- scale(y, center=TRUE, scale=FALSE)
  # if (normalize) {
  #   ds <- scale(d, center=TRUE, scale=TRUE)
  #   xs <- scale(x, center=TRUE, scale=TRUE)
  #   zs <- scale(z, center=TRUE, scale=TRUE)
  # }
  
  Z <- cbind(z, x)
  kiv <- dim(Z)[2]
  Dhat <- NULL
  flag.const <- 0
  for (i in 1:ke) {
    di <- d[, i]
    L2Boost.fit <- L2BoostOGA(y=di, X=Z)
    if (sum(L2Boost.fit$stop_rule) == 0) {
      dihat <- rep(mean(di), n)
      flag.const <- flag.const + 1
      if (flag.const > 1) 
        message("No variables selected for two or more instruments leading to multicollinearity problems.")
    }
    else {
      dihat <- predict(L2Boost.fit)
    }
    Dhat <- cbind(Dhat, dihat)
  }
  Dhat <- cbind(Dhat, x)
  d <- cbind(d, x)
  alpha.hat <- solve(t(Dhat) %*% d) %*% (t(Dhat) %*% y)
  residuals <- y - d %*% alpha.hat
  Omega.hat <- t(Dhat) %*% diag(as.vector(residuals^2)) %*% 
    Dhat
  Q.hat.inv <- MASS::ginv(t(d) %*% Dhat)
  vcov <- Q.hat.inv %*% Omega.hat %*% t(Q.hat.inv)
  rownames(alpha.hat) <- c(colnames(d))
  colnames(vcov) <- rownames(vcov) <- rownames(alpha.hat)
  res <- list(coefficients = alpha.hat[1:ke, ], se = sqrt(diag(vcov))[1:ke], 
              vcov = vcov[1:ke, 1:ke, drop = FALSE], residuals = residuals, 
              samplesize = n, call = match.call())
  class(res) <- "L2BoostIVselectZ"
  return(res)
}

#######################################################################################

L2BoostEffect <- function(x, y, d, method = "double selection", I3 = NULL, 
                         post = TRUE, ...) {
  d <- as.matrix(d, ncol = 1)
  y <- as.matrix(y, ncol = 1)
  kx <- dim(x)[2]
  n <- dim(x)[1]
  if (is.null(colnames(d))) 
    colnames(d) <- "d1"
  if (is.null(colnames(x)) & !is.null(x)) 
    colnames(x) <- paste("x", 1:kx, sep = "")
  if (method == "double selection") {
    B1 <- L2Boost(y=d, X=x, post = post)
    Ind <- rep(0,kx)
    Ind[B1$S[1:B1$stop_rule]] <- 1
    I1 <- Ind
    B2 <- L2Boost(y=y, X=x, post = post)
    Ind <- rep(0,kx)
    Ind[B2$S[1:B2$stop_rule]] <- 1
    I2 <- Ind
    if (is.logical(I3)) {
      I <- I1 + I2 + I3
      I <- as.logical(I)
    } else {
      I <- I1 + I2
      I <- as.logical(I)
    }
    if (sum(I) == 0) {
      I <- NULL
    }
    x <- cbind(d, x[, I, drop = FALSE])
    reg1 <- lm(y ~ x)
    alpha <- coef(reg1)[2]
    names(alpha) <- colnames(d)
    xi <- reg1$residuals * sqrt(n/(n - sum(I) - 1))
    if (is.null(I)) {
      reg2 <- lm(d ~ 1)
    }
    if (!is.null(I)) {
      reg2 <- lm(d ~ x[, -1, drop = FALSE])
    }
    v <- reg2$residuals
    var <- 1/n * 1/mean(v^2) * mean(v^2 * xi^2) * 1/mean(v^2)
    se <- sqrt(var)
    tval <- alpha/sqrt(var)
    pval <- 2 * pnorm(-abs(tval))
    if (is.null(I)) {
      no.selected <- 1
    } else {
      no.selected <- 0
    }
    res <- list(epsilon = xi, v = v)
    # results <- list(alpha=unname(alpha), se=drop(se), t=unname(tval),
    # pval=unname(pval), no.selected=no.selected,
    # coefficients=unname(alpha), coefficient=unname(alpha),
    # coefficients.reg=coef(reg1), residuals=res, call=match.call(),
    # samplesize=n)
    se <- drop(se)
    names(se) <- colnames(d)
    results <- list(alpha = alpha, se = se, t = tval, pval = pval, 
                    no.selected = no.selected, coefficients = alpha, coefficient = alpha, 
                    coefficients.reg = coef(reg1), residuals = res, call = match.call(), 
                    samplesize = n)
  }
  
  if (method == "partialling out") {
    yr <- y - predict(L2Boost(y=y, X=x, post = post))
    dr <- d - predict(L2Boost(y=d, X=x, post = post))
    reg1 <- lm(yr ~ dr)
    alpha <- coef(reg1)[2]
    var <- vcov(reg1)[2, 2]
    se <- sqrt(var)
    tval <- alpha/sqrt(var)
    pval <- 2 * pnorm(-abs(tval))
    res <- list(epsilon = reg1$residuals, v = dr)
    results <- list(alpha = unname(alpha), se = drop(se), t = unname(tval), 
                    pval = unname(pval), coefficients = unname(alpha), coefficient = unname(alpha), 
                    coefficients.reg = coef(reg1), residuals = res, call = match.call(), 
                    samplesize = n)
  }
  class(results) <- "L2BoostEffects"
  return(results)
}


orthoL2BoostEffect <- function(x, y, d, method = "double selection", I3 = NULL, ...) {
  d <- as.matrix(d, ncol = 1)
  y <- as.matrix(y, ncol = 1)
  kx <- dim(x)[2]
  n <- dim(x)[1]
  if (is.null(colnames(d))) 
    colnames(d) <- "d1"
  if (is.null(colnames(x)) & !is.null(x)) 
    colnames(x) <- paste("x", 1:kx, sep = "")
  if (method == "double selection") {
    B1 <- L2BoostOGA(y=d, X=x)
    Ind <- rep(0,kx)
    Ind[B1$S[1:B1$stop_rule]] <- 1
    I1 <- Ind
    B2 <- L2BoostOGA(y=y, X=x)
    Ind <- rep(0,kx)
    Ind[B2$S[1:B2$stop_rule]] <- 1
    I2 <- Ind
    if (is.logical(I3)) {
      I <- I1 + I2 + I3
      I <- as.logical(I)
    } else {
      I <- I1 + I2
      I <- as.logical(I)
    }
    if (sum(I) == 0) {
      I <- NULL
    }
    x <- cbind(d, x[, I, drop = FALSE])
    reg1 <- lm(y ~ x)
    alpha <- coef(reg1)[2]
    names(alpha) <- colnames(d)
    xi <- reg1$residuals * sqrt(n/(n - sum(I) - 1))
    if (is.null(I)) {
      reg2 <- lm(d ~ 1)
    }
    if (!is.null(I)) {
      reg2 <- lm(d ~ x[, -1, drop = FALSE])
    }
    v <- reg2$residuals
    var <- 1/n * 1/mean(v^2) * mean(v^2 * xi^2) * 1/mean(v^2)
    se <- sqrt(var)
    tval <- alpha/sqrt(var)
    pval <- 2 * pnorm(-abs(tval))
    if (is.null(I)) {
      no.selected <- 1
    } else {
      no.selected <- 0
    }
    res <- list(epsilon = xi, v = v)
    # results <- list(alpha=unname(alpha), se=drop(se), t=unname(tval),
    # pval=unname(pval), no.selected=no.selected,
    # coefficients=unname(alpha), coefficient=unname(alpha),
    # coefficients.reg=coef(reg1), residuals=res, call=match.call(),
    # samplesize=n)
    se <- drop(se)
    names(se) <- colnames(d)
    results <- list(alpha = alpha, se = se, t = tval, pval = pval, 
                    no.selected = no.selected, coefficients = alpha, coefficient = alpha, 
                    coefficients.reg = coef(reg1), residuals = res, call = match.call(), 
                    samplesize = n)
  }
  
  if (method == "partialling out") {
    yr <- y - predict(L2Boost(y=y, X=x))
    dr <- d - predict(L2Boost(y=d, X=x))
    reg1 <- lm(yr ~ dr)
    alpha <- coef(reg1)[2]
    var <- vcov(reg1)[2, 2]
    se <- sqrt(var)
    tval <- alpha/sqrt(var)
    pval <- 2 * pnorm(-abs(tval))
    res <- list(epsilon = reg1$residuals, v = dr)
    results <- list(alpha = unname(alpha), se = drop(se), t = unname(tval), 
                    pval = unname(pval), coefficients = unname(alpha), coefficient = unname(alpha), 
                    coefficients.reg = coef(reg1), residuals = res, call = match.call(), 
                    samplesize = n)
  }
  class(results) <- "L2BoostEffects"
  return(results)
}