% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/sits_patterns.R
\name{sits_patterns_from_data}
\alias{sits_patterns_from_data}
\title{Do not create patterns for classification}
\usage{
sits_patterns_from_data(data.tb = NULL, timeline = NULL,
  interval = "12 month")
}
\arguments{
\item{data.tb}{a SITS tibble time series}

\item{timeline}{timeline with the all dates for the coverage}

\item{interval}{the interval to obtain the patterns}
}
\value{
patterns.tb       a SITS tibble time series used as reference for traning the model
}
\description{
This function is to be used when oen does not want to create
a set of idealised patterns from the input data, but prefers to use the
input series themselves as training data from estimating a prediction model.
It should be used in connection with sits_distances_from_data.
}
\author{
Rolf Simoes, \email{rolf.simoes@inpe.br}

Gilberto Camara, \email{gilberto.camara@inpe.br}
}
