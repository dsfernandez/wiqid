# Mb model, capture probability dependent on a permanent behavioural response

closedCapMb <-
function(CH, ci = 0.95, ciType=c("normal", "MARK"), ...) {
  # CH is a 1/0 capture history matrix, animals x occasions
  # ci is the required confidence interval

  CH <- round(as.matrix(CH))
  if(length(dim(CH)) != 2)
    stop("CH should be a matrix, animals x occasions, or a data frame.")
  CH <- CH[rowSums(CH) > 0, ]  # remove any all-zero capture histories
  crit <- fixCI(ci)
  ciType <- match.arg(ciType)

  nOcc <- ncol(CH)    # number of capture occasions
  N.cap <- nrow(CH)   # total number of individual animals captured
  # n <- colSums(CH)    # vector of number captures on each occasion
  getFirst <- function(x)
    min(which(x > 0))
  firstCap <- apply(CH, 1, getFirst)
  n0 <- firstCap - 1         # number of misses before first capture, prob = 1 - p
  ns <- rowSums(CH) - 1      # number of hits after first capture, prob = c
  nf <- nOcc - firstCap - ns # number of misses after first capture, prob = 1 - c

  beta.mat <- matrix(NA_real_, 3, 4) # objects to hold output
  colnames(beta.mat) <- c("est", "SE", "lowCI", "uppCI")
  rownames(beta.mat) <- c("Nhat", "phat", "chat")
  logLik <- NA_real_
  varcov <- NULL

  if(N.cap > 0)  {
    nll <- function(params) {
      f0 <- min(exp(params[1]), 1e+300, .Machine$double.xmax)
      N <- N.cap + f0
      p <- plogis(params[2])
      c <- plogis(params[3])
      tmp <- lgamma(N + 1) - lgamma(N - N.cap + 1) +
        sum(n0 * log(1-p) + ns * log(c) + nf * log(1-c)) + N.cap * log(p) + # Captured animals
        f0 * nOcc * log(1-p) # Uncaptured animals
      return(min(-tmp, .Machine$double.xmax))
    }
    # res <- nlm(nll, params, hessian=TRUE, iterlim=1000)
    nlmArgs <- list(...)
    nlmArgs$f <- nll
    nlmArgs$p <- c(log(5), 0, 0)
    nlmArgs$hessian <- TRUE
    if(is.null(nlmArgs$iterlim))
      nlmArgs$iterlim <- 1000
    res <- do.call(nlm, nlmArgs)
    if(res$code > 2)   # exit code 1 or 2 is ok.
      warning(paste("Convergence may not have been reached (code", res$code, ")"))
    beta.mat[,1] <- res$estimate
    # varcov <- try(solve(res$hessian), silent=TRUE)
    varcov0 <- try(chol2inv(chol(res$hessian)), silent=TRUE)
    # if (!inherits(varcov, "try-error") && all(diag(varcov) > 0)) {
    if (!inherits(varcov0, "try-error")) {
      varcov <- varcov0
      beta.mat[, 2] <- suppressWarnings(sqrt(diag(varcov)))
      beta.mat[, 3:4] <- sweep(outer(beta.mat[, 2], crit), 1, res$estimate, "+")
      logLik <- -res$minimum
    }
  }
  if(ciType == "normal") {
    Nhat <- exp(beta.mat[1, -2]) + N.cap
  } else {
    Nhat <- getMARKci(beta.mat[1, 1], beta.mat[1, 2], ci) + N.cap
  }
  out <- list(call = match.call(),
          beta = beta.mat,
          beta.vcv = varcov,
          real = rbind(Nhat, plogis(beta.mat[-1, -2])),
          logLik = c(logLik=logLik, df=3, nobs=length(CH)))
  class(out) <- c("wiqid", "list")
  return(out)
}
