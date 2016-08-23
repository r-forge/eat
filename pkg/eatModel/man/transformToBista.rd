\name{transformToBista}
\alias{transformToBista}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{Transformation of item parameters to the Bista metric.}
\description{Function uses output of \code{equat1pl} to provide a data.frame 
with item parameters on the bista metric. }
\usage{
transformToBista ( equatingList, refPop, cuts)}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{equatingList}{
%%     ~~Describe \code{file} here~~
The object returned by \code{equat1pl}.
}
  \item{refPop}{
%%     ~~Describe \code{file} here~~
Data frame with at least three columns. First column indicates the domain name. 
Note that this name must match the domain names in the output of \code{getResults}.
Second column contains the mean of the referece population. Third column contains
the standard deviation of the reference population. Fourth column optionally contains 
the transformed mean on the Bista metric of the reference population. Fifth column 
optionally contains the transformed standard deviation on the Bista metric of the 
reference population. If the fourth and fifth columns are missing, values will be 
defaulted to 500/100. 
}
  \item{cuts}{
%%     ~~Describe \code{file} here~~
A named list with cut scores. Names of the list must match the domain names in the 
output of \code{getResults}. Each element of the list is a list with one or two 
elements---the cut scores (in ascending order) and (optionally) the labels of the 
stages. See the examples of \code{defineModel} for further details. 
}
}
\details{
}
\value{
%%  ~Describe the value returned
%%  If it is a LIST, use
%%  \item{comp1 }{Description of 'comp1'}
%%  \item{comp2 }{Description of 'comp2'}
%% ...
A data frame with original and transformed item parameters and competence levels. 
}
\references{
%% ~put references to the literature/web site here ~
}
\author{
Sebastian Weirich
}
\note{
%%  ~~further notes~~
}

%% ~Make other sections like Warning with \section{Warning }{....} ~

\seealso{
%% ~~objects to See Also as \code{\link{help}}, ~~~
}
\examples{
# see example 5 in the help file of defineModel()
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line