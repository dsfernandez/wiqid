# Print, summary, plot, window, head and tail methods for class Bwiqid, ie. MCMC output


print.Bwiqid <- function(x, digits=4, ...)  {
  if(!inherits(x, "data.frame"))
    stop("x is not a valid Bwiqid object")
  call <- attr(x, "call")
  header <- attr(x, "header")
  MCerror <- attr(x, "MCerror")
  Rhat <- attr(x, "Rhat")
  n.eff <- attr(x, "n.eff")
  timetaken <- attr(x, "timetaken")

  toPrint <- cbind(
    mean = colMeans(x),
    sd = apply(x, 2, sd),
    median = apply(x, 2, median),
    t(hdi(x)))
  colnames(toPrint)[4:5] <- c("HDIlo", "HDIup")
  if(!is.null(MCerror))
    toPrint <- cbind(toPrint, 'MCE%' = round(100 * MCerror/toPrint[, 'sd'], 1))
  if(!is.null(Rhat))
    toPrint <- cbind(toPrint, Rhat = Rhat)
  if(!is.null(n.eff))
    toPrint <- cbind(toPrint, n.eff = round(n.eff))

  toPrint0 <- unique(toPrint)

  # if(!is.null(call))
    # cat("Call:", call, "\n")
  if(is.null(header))
    header <- "MCMC fit results:"
  cat(header, "\n")
  cat(nrow(x), "simulations saved.\n")
  if(nrow(toPrint0) < nrow(toPrint))
    cat("(Duplicate rows removed.)\n")
  print(toPrint0, digits = digits)
  cat("\n'HDIlo' and 'HDIup' are the limits of a 95% HDI credible interval.\n")
  if(!is.null(MCerror))
    cat("'MCE%' is the Monte Carlo error as a %age of the SD (should be less than 5%).\n")
  if(!is.null(Rhat))
    cat("'Rhat' is the potential scale reduction factor (at convergence, Rhat=1).\n")
  if(!is.null(n.eff))
    cat("'n.eff' is a crude measure of effective sample size.\n")
  if(!is.null(timetaken)) {
    took <- format(round(timetaken, 1))
    cat("MCMC chain generation:", took, "\n")
  }
}
# .........................................................


summary.Bwiqid <- function(object, digits=3, ...)  {
  if(!inherits(object, "data.frame"))
    stop("object is not a valid Bwiqid object")
  call <- attr(object, "call")
  header <- attr(object, "header")
  n.chains <- attr(object, "n.chains")
  MCerror <- attr(object, "MCerror")
  Rhat <- attr(object, "Rhat")
  n.eff <- attr(object, "n.eff")
  timetaken <- attr(object, "timetaken")

  toPrint <- cbind(
    mean = colMeans(object),
    sd = apply(object, 2, sd),
    median = apply(object, 2, median),
    t(hdi(object)))
  colnames(toPrint)[4:5] <- c("HDIlo", "HDIup")

  if(!is.null(MCerror))
    toPrint <- cbind(toPrint, 'MCE%' = round(100 * MCerror/toPrint[, 'sd'], 1))
  if(!is.null(Rhat))
    toPrint <- cbind(toPrint, Rhat = Rhat)
  if(!is.null(n.eff))
    toPrint <- cbind(toPrint, n.eff = round(n.eff))

  if(is.null(header))
    header <- "MCMC fit results:"
  cat(header, "\n")
  if(is.null(n.chains)) {
    cat(nrow(object), "simulations saved.\n")
  } else {
    cat(sprintf("%.0f chains x %.0f simulations = %.0f total.\n",
        n.chains, nrow(object)/n.chains, nrow(object)))
  }
  if(!is.null(timetaken)) {
    took <- format(round(timetaken, 1))
    cat("MCMC chain generation:", took, "\n")
  }

  if(!is.null(MCerror)) {
    MCEpc <- round(100 * MCerror/apply(object, 2, sd), 1)
    t1 <- sum(MCEpc > 5, na.rm=TRUE)
    t2 <- sum(is.na(MCEpc))
    txt <- sprintf("\nMCerror (%% of SD): largest is %.1f%%", max(MCEpc, na.rm=TRUE))
    if(t1) {
      txt <- c(txt, sprintf("; %.0f (%.0f%%) are greater than 5", t1, 100*t1/length(MCEpc)))
    } else {
      txt <- c(txt, "; NONE are greater than 5%")
    }
    if(t2 > 0)
      txt <- c(txt, sprintf("; %.0f (%.0f%%) are NA", t2, 100*t2/length(MCEpc)))
    txt <- c(txt, ".\n")
    cat(paste0(txt, collapse=""))
  }

  if(!is.null(Rhat)) {
    t1 <- sum(Rhat>1.1, na.rm=TRUE)
    t2 <- sum(is.na(Rhat))
    txt <- sprintf("\nRhat: largest is %.2f", max(Rhat, na.rm=TRUE))
    if(t1) {
      txt <- c(txt, sprintf("; %.0f (%.0f%%) are greater than 1.10", t1, 100*t1/length(Rhat)))
    } else {
      txt <- c(txt, "; NONE are greater than 1.10")
    }
    if(t2 > 0)
      txt <- c(txt, sprintf("; %.0f (%.0f%%) are NA", t2, 100*t2/length(Rhat)))
    txt <- c(txt, ".\n")
    cat(paste0(txt, collapse=""))
  }

  if(!is.null(n.eff)) {
    n.eff[n.eff == 1] <- NA
    t1 <- sum(n.eff < 1000, na.rm=TRUE)
    t2 <- sum(is.na(n.eff))
    txt <- sprintf("\nn.eff: smallest is %.0f", min(n.eff, na.rm=TRUE))
    if(t1) {
      txt <- c(txt, sprintf("; %.0f (%.0f%%) are smaller than 1000", t1, 100*t1/length(n.eff)))
    } else {
      txt <- c(txt, "; NONE are smaller than 1000")
    }
    if(t2 > 0)
      txt <- c(txt, sprintf("; %.0f (%.0f%%) are 1 or NA", t2, 100*t2/length(Rhat)))
    txt <- c(txt, ".\n")
    cat(paste0(txt, collapse=""))
  }
  cat("\n")
  return(invisible(round(toPrint, digits=digits)))
}
# .........................................................

plot.Bwiqid <-
function(x, which=NULL, credMass=0.95,
          ROPE=NULL, compVal=NULL, showCurve=FALSE,  showMode=FALSE,
          shadeHDI=NULL, ...) {
  # This function plots the posterior distribution for one selected item.
  # Description of arguments:
  # x is mcmc.list object of the type returned by B* functions in 'wiqid'.
  # which indicates which item should be displayed; if NULL, looks for a 'toPlot'
  #   attribute in x; if missing does first column.
  # ROPE is a two element vector, such as c(-1,1), specifying the limit
  #   of the ROPE.
  # compVal is a scalar specifying the value for comparison.
  # showCurve if TRUE the posterior should be displayed as a fitted density curve
  #   instead of a histogram (default).

  # TODO additional sanity checks.
  # Sanity checks:
  if(!inherits(x, "data.frame"))
    stop("x is not a valid Bwiqid object")

  # Deal with ... argument
  dots <- list(...)
  if(length(dots) == 1 && class(dots[[1]]) == "list")
    dots <- dots[[1]]

  if(is.null(which)) # && !is.null(attr(x, "defaultPlot")))
      which <- attr(x, "defaultPlot")
  if(is.null(which))
    which <- colnames(x)[1]
  if(!is.character(which))
    stop("'which' must be an object of class 'character'.") # Added 2017-09-27
  if(is.na(match(which, colnames(x))))
    stop(paste("Could not find", which, "in the output"))
  if(is.null(dots$xlab))
    dots$xlab <- which
  # Plot posterior distribution of selected item:
  out <- plotPost(x[[which]], credMass=credMass, ROPE=ROPE, compVal=compVal,
                  showCurve=showCurve, showMode=showMode, shadeHDI=shadeHDI,
                  graphicPars=dots)

  return(invisible(out))
}

# .........................................................

window.Bwiqid <- function(x, start=NULL, end=NULL, thin=1, ...)  {
  if(!inherits(x, "Bwiqid"))
    stop("x is not a valid Bwiqid object")
  n.chains <- attr(x, "n.chains")
  if(is.null(n.chains) || nrow(x) %% n.chains != 0)
    stop("n.chains attribute of x is missing or invalid.")
  chain.length <- nrow(x) / n.chains
  if(is.null(start) || start > chain.length)
    start <- 1
  if(is.null(end) || end > chain.length || end <= start)
    end <- chain.length
  if(start < 1 || end < 1 || thin < 1)
    stop("Arguments start, end, and thin must be integers > 1")

  x_new <- vector('list', ncol(x))
  for( i in 1:ncol(x)) {
    mat <- matrix(x[, i], ncol=n.chains)
    mat_new <- mat[seq(start, end, by=thin), ]
    x_new[[i]] <- as.vector(mat_new)
  }
  names(x_new) <- colnames(x)
  x_df <- as.data.frame(x_new)
  rownames(x_df) <- NULL
  class(x_df) <- class(x)
  attr(x_df, "header") <- attr(x, "header")
  attr(x_df, "n.chains") <- attr(x, "n.chains")
  attr(x_df, "defaultPlot") <- attr(x, "defaultPlot")
  attr(x_df, "timetaken") <- attr(x, "timetaken")
  if(n.chains > 1)
    attr(x_df, "Rhat") <- simpleRhat(x_df, n.chains=n.chains)
  attr(x_df, "n.eff") <- safeNeff(x_df)

  return(x_df)
}

# .........................................................

head.Bwiqid <- function(x, n=6L, ...) {
  head(as.data.frame(x), n=n, ...)
}

tail.Bwiqid <- function(x, n=6L, ...) {
  tail(as.data.frame(x), n=n, ...)
}


