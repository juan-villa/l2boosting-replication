# DGP for IV estimation as as described in the Supplement

DGP <- function() {x

# parameter setting
nu <- 0.1
nRep <- 50
#n <- c(100)
nn <- length(n)
#p <- 100
pnz <- s
indp <- 0:(p-1)
Fstat <- c(30)
nF <- length(Fstat)
s2e <- 1
Cev <- .0 #0.6
s2z <- 1
szz <- .5
pi1  <- .7
alpha <- 1
K <- 15

# Common design elements
SZ <- s2z*toeplitz((szz)^indp)
cSZ <- chol(SZ)
#cFS <- pi1^indp # exponential design
cFS <- c(rep(1,pnz), rep(0,p-pnz)) # cutoff design
scale <- matrix(0, nrow=nF, ncol=nn)
s2v <- matrix(0, nrow=nF, ncol=nn)
for (ii in 1:nn) {
  for (jj in 1:nF) {
    scale[jj,ii] <- sqrt(Fstat[jj]/((Fstat[jj]+n[ii])*t(cFS)%*%SZ%*%cFS))
    s2v[jj,ii] <- 1-(scale[jj,ii]^2)*t(cFS)%*%SZ%*%cFS
  }
}

#######
sev <- Cev*sqrt(s2e)*sqrt(s2v)


nUse <- n
SU <- matrix(c(s2e,sev,sev,s2v), ncol=2)
cSU <- chol(SU)

zorig <- matrix(rnorm(nUse*p), nrow=nUse,ncol=p)%*%cSZ
U <- matrix(rnorm(nUse*2), ncol=2)%*%cSU
xorig <- scale[jj,ii]*zorig%*%cFS+U[,2]
yorig <- alpha*xorig+U[,1]
Z <- zorig - rep(1,nUse)*mean(zorig)
X <- xorig - mean(xorig)
Y <- yorig - mean(yorig)
return(list(Z=Z, X=X, Y=Y))
}

################################################################################################################
# hist with normal function (function)

histnormal <- function(g, breaks=20, ...) {
  h<-hist(g, breaks=breaks, density=10, freq=FALSE, ...) 
  xfit<-seq(min(g),max(g),length=40) 
  yfit<-dnorm(xfit,mean=mean(g),sd=sd(g)) 
  #yfit <- yfit*diff(h$mids[1:2])*length(g) 
  lines(xfit, yfit, col="black", lwd=2)
}

