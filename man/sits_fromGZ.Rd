% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/sits_import.R
\name{sits_fromGZ}
\alias{sits_fromGZ}
\title{Obtain timeSeries from a compressed JSON file.}
\usage{
sits_fromGZ(file)
}
\arguments{
\item{file}{string  - name of a compressed JSON file with sits data and metadata}
}
\value{
data.tb    a SITS tibble
}
\description{
reads a set of data and metadata for satellite image time series from a compressed JSON file
}
