% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/sits_import.R
\name{sits_fromZOO}
\alias{sits_fromZOO}
\title{Import time series in the zoo format to a SITS tibble}
\usage{
sits_fromZOO(ts.zoo, longitude = 0, latitude = 0, label = "NoLabel",
  coverage = "unknown")
}
\arguments{
\item{ts.zoo}{A zoo time series}

\item{longitude}{Longitude of the chosen location}

\item{latitude}{Latitude of the chosen location}

\item{label}{Label to attach to the time series (optional)}

\item{coverage}{Name of the coverage where data comes from}
}
\value{
data.tb      A time series in SITS tibble format
}
\description{
Converts data from an instance of a zoo series to a SITS tibble
}
\author{
Gilberto Camara, \email{gilberto.camara@inpe.br}
}
