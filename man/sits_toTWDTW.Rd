% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/sits_export.R
\name{sits_toTWDTW}
\alias{sits_toTWDTW}
\title{Export data to be used by the dtwSat package}
\usage{
sits_toTWDTW(data.tb)
}
\arguments{
\item{data.tb}{a table in SITS format with time series to be converted to TWTDW time series}
}
\value{
ts.twdtw      a time series in TWDTW format (an object of the twdtwTimeSeries class)
}
\description{
Converts data from a SITS table to an instance of a TWDTW time series class,
Returns a twdtwTimeSeries object (S4)
}
\author{
Victor Maus, \email{vwmaus1@gmail.com}

Gilberto Camara, \email{gilberto.camara@inpe.br}
}
