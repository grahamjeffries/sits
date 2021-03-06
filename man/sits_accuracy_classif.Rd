% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/sits_accuracy.R
\name{sits_accuracy_classif}
\alias{sits_accuracy_classif}
\title{Evaluates the accuracy of a labelled set of data}
\usage{
sits_accuracy_classif(data.tb, patterns.tb, ml_model,
  dist_method = sits_TWDTW_distances(), interval = "12 month")
}
\arguments{
\item{data.tb}{A sits tibble containing a set of samples with known and trusted labels}

\item{patterns.tb}{A sits tibble containing a set of patterns (independent of input data)}

\item{ml_model}{A model trained by \code{\link[sits]{sits_train}}}

\item{dist_method}{Method to compute distances (e.g., sits_TWDTW_distances)}

\item{interval}{Period between two classifications}

\item{...}{Other parameters to be passed to the distance function}
}
\value{
assess        Assessment of validation
}
\description{
Tests the accuracy of a classification model by comparing an input data set
that has been obtained independently to a the predicted values of the model.
This function can be used to test the accuracy of a classification model against a
data set that is obtained independently. The quality of the accuracy assessment
depends critically of the quality of the input data set, which should be be part of the
data set used for training the model.
This function should be used when the patterns are not directly derived from the samples.
It provides an initial assessment of the validity of using this set of pattern
to classify an area whose samples are given.
This function returns the Overall Accuracy, User's Accuracy,
Producer's Accuracy, error matrix (confusion matrix), and Kappa values.
}
\author{
Gilberto Camara, \email{gilberto.camara@inpe.br}
}
