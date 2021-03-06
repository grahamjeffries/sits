% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/sits_filters.R
\name{sits_envelope}
\alias{sits_envelope}
\title{Envelope filter}
\usage{
sits_envelope(data.tb, operations = "UULL", bands_suffix = "env")
}
\arguments{
\item{data.tb}{a valid sits tibble}

\item{operations}{character sequence indicating which operations must be taken. "U" for upper filter, "D" for down filter.}

\item{bands_suffix}{the suffix to be appended to the resulting data (default "env")}
}
\value{
result.tb   a sits tibble with same samples and the new bands
}
\description{
This function computes the envelope of a time series using the
streaming algorithm proposed by Lemire (2009). This functions calls `dtwclust::compute_envelop` function.
}
\author{
Rolf Simoes, \email{rolf.simoes@inpe.br}
}
