\name{diagnostic plots}
\alias{diagnostic plots}
\alias{diagPlot}
\alias{tracePlot}
\alias{densityPlot}
\alias{acfPlot}
\title{
Diagnostic graphics for MCMC output
}
\description{
Display trace plots, density plots or autocorrelation plots for the chains in the MCMC output. Each chain is plotted with a different colour. See also \code{\link{crosscorrPlot}}.
}
\usage{

diagPlot(x, params=NULL, howMany, chains, ask=NULL, maxRow=4, RhatBad=1.05, ...)

tracePlot(object, ask=NULL, ...)

densityPlot(object, ask=NULL, ...)

acfPlot(object, lag.max=NULL, ask=NULL, ...)

}
\arguments{
  \item{x}{
A matrix or data frame with MCMC output, or one of the following classes: \code{Bwiqid, mcmc.list, jagsUI, bugs, rjags, runjags}.
}
  \item{params}{
An optional vector of column numbers or names; names are partially matched, so \code{params="alpha"} will match all of \code{alpha, alpha0, alpha[1], alphanew}; negative indices indicate parameters to exclude, positive and negative indices cannot be mixed.
}
  \item{object}{
An object of class \code{Bwiqid}.
}
  \item{howMany}{
How many iterations to plot; if negative, the iterations at the end of the chains will be plotted.
}
  \item{chains}{
Which chains to plot, a numeric vector.
}
  \item{ask}{
If \code{TRUE}, the user will be prompted before the next page of output is displayed. The default is to ask if the plotting device is the screen, not if it is a file.
}
  \item{maxRow}{
Maximum number of rows to display in one window; each row consists of a trace plot
 and a density plot for one parameter.
}
  \item{RhatBad}{
Threshold for Rhat; parameters with \code{Rhat > RhatBad} are highlighted in red.
}
  \item{lag.max}{
Maximum lag at which to calculate the acf; see \code{\link{acf}}.
}
  \item{\dots}{
Additional graphical parameters.
}
}

\value{
Return nothing, used for their plotting side effect.
}
\author{
Mike Meredith
}

\seealso{
\code{\link{crosscorrPlot}}, \code{\link{plotPost}} for a histogram and summary statistics.
}
\examples{
\donttest{
# Create a fake Bwiqid object:
fake <- data.frame(
  mu0 = rnorm(3000),         # normal, mean zero
  mu10 = rnorm(3000, rep(9:11, each=1000), 1),
                             # normal, mean 10, but poor mixing
  sigma=rlnorm(3000),        # non-negative, skewed
  prob = rbeta(3000, 2, 2),  # probability, central mode
  prob0 = rbeta(3000, 1,2),  # probability, mode = 0
  N = rpois(3000, rep(c(24, 18, 18), each=1000)),
                             # large integers (no zeros), poor mixing
  n = rpois(3000, 2),        # small integers (some zeros)
  allNA = NA,                # all values NA
  someNA = suppressWarnings(log(rnorm(3000, 2, 2))),
                             # some NaNs
  const1 = rep(1, 3000),     # all values = 1
  const3.2 = rep(10/3, 3000))# all values the same but not integer
class(fake) <- c("Bwiqid", "data.frame")
attr(fake, "n.chains") <- 3
attr(fake, "Rhat") <- c(1, 1.3, 1.05, 0.98, 1, 1.2, NA, NA, 1, 1, NA)
attr(fake, "n.eff") <- c(2345, NA, 457, 63, 1234, 324, 543, NA, 1, 1, 1)

fake
diagPlot(fake)
diagPlot(fake, params=3:6, main="params=3:6")
diagPlot(fake, params=c("mu", "prob"), main="params=c('mu', 'prob')")
diagPlot(fake, params=c("mu", "prob"), howMany=200, main="howMany=200")
diagPlot(fake, params=c("mu", "prob"), howMany=-200, main="howMany= -200")
diagPlot(fake, params=c("mu", "prob"), chains=1:2, main="chains=1:2")

par(mfrow=c(3,3))
densityPlot(fake, col=1:5, lwd=2)
acfPlot(fake, lag.max=10)
tracePlot(fake)
par(mfrow=c(1,1))
}
}
\keyword{hplot}