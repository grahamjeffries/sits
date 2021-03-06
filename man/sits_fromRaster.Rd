% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/sits_raster.R
\name{sits_fromRaster}
\alias{sits_fromRaster}
\title{Extract a time series from a ST raster data set}
\usage{
sits_fromRaster(raster.tb, file = NULL, longitude = NULL, latitude = NULL,
  xcoord = NULL, ycoord = NULL, xmin = NULL, xmax = NULL, ymin = NULL,
  ymax = NULL, start_date = NULL, end_date = NULL, label = "NoClass",
  coverage = NULL)
}
\arguments{
\item{raster.tb}{A tibble with metadata describing a spatio-temporal data set}

\item{file}{A CSV file with lat/long locations to be retrieve}

\item{longitude}{double - the longitude of the chosen location}

\item{latitude}{double - the latitude of the chosen location}

\item{xcoord}{X coordinate of the point where the time series is to be obtained}

\item{ycoord}{Y coordinate of the point where the time series is to be obtained}

\item{xmin}{Minimum X coordinates of bounding box}

\item{xmax}{Maximum X coordinates of bounding box}

\item{ymin}{Minimum Y coordinates of bounding box}

\item{ymax}{Maximum Y coordinates of bounding box}

\item{start_date}{date - the start of the period}

\item{end_date}{date - the end of the period}

\item{label}{string - the label to attach to the time series}

\item{coverage}{string - the name of the coverage to be retrieved}
}
\value{
data.tb        a SITS tibble with the time series
}
\description{
Reads metadata about a raster data set to retrieve a set of
time series.

This function creates a tibble to store the information
about a raster time series
}
\author{
Gilberto Camara, \email{gilberto.camara@inpe.br}
}
