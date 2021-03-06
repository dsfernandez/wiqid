# Some of the plotting code taken from package BEST, originally by John Kruschke.

postPriorOverlap <-
function( paramDraws, prior, ..., yaxt="n", ylab="",
           xlab="Parameter", main="", cex.lab=1.5, cex=1.4,
           xlim=range(paramDraws), ylim=NULL, # xpd=NA,
           colors=c("skyblue", "yellow", "green", "white"),
           breaks=NULL) {

  # Does a posterior histogram for a single parameter, adds the prior,
  #   displays and calculates the overlap.
  # Returns the overlap.

  if(!is.null(list(...)$paramSampleVec)) {
    message("*The 'paramSampleVec' argument is deprecated, please use 'paramDraws'.*")
    paramDraws <- list(...)$paramSampleVec
  }

  # oldpar <- par(xpd=xpd) ; on.exit(par(oldpar))

  # get breaks: a sensible number over the hdi; cover the full range (and no more);
  #   equal spacing.
  if (is.null(breaks)) {
    nbreaks <- ceiling(diff(range(paramDraws)) / as.numeric(diff(hdi(paramDraws))/18))
    breaks <- seq(from=min(paramDraws), to=max(paramDraws), length.out=nbreaks)
  }
  # plot posterior histogram.
  histinfo <- hist(paramDraws, xlab=xlab, yaxt=yaxt, ylab=ylab,
                   freq=FALSE, border=colors[4], col=colors[1],
                   xlim=xlim, ylim=ylim, main=main, cex=cex, cex.lab=cex.lab,
                   breaks=breaks)

  if (is.numeric(prior))  {
    # plot the prior if it's numeric
    priorInfo <- hist(prior, breaks=c(-Inf, breaks, Inf), add=TRUE,
      freq=FALSE, col=colors[2], border=colors[4])$density[2:length(breaks)]
  } else if (is.function(prior)) {
    if(class(try(prior(0.5, ...), TRUE)) == "try-error")
      stop(paste("Incorrect arguments for the density function", substitute(prior)))
    priorInfo <- prior(histinfo$mids, ...)
  }
  # get (and plot) the overlap
  minHt <- pmin(priorInfo, histinfo$density)
  rect(breaks[-length(breaks)], rep(0, length(breaks)-1), breaks[-1], minHt,
    col=colors[3], border=colors[4])
  overlap <- sum(minHt * diff(histinfo$breaks))
  # Add curve if prior is a function
  if (is.function(prior))
    lines(histinfo$mids, priorInfo, lwd=2, col='brown')
  # Add text
  text(mean(breaks), 0, paste0("overlap = ", round(overlap*100), "%"), pos=3, cex=cex)

  return(overlap)
}
