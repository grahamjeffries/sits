# A script for testing different ML methods together with the TWDTW distances for classification of time series
# Gilberto Camara, revised 03.08.2017

#load the sits library
library (sits)
# get information about the coverage
URL <- "http://www.dpi.inpe.br/tws/wtss"
wtss_inpe <- sits_infoWTSS(URL)
coverage  <- "mod13q1_512"

coverage.tb <- sits_coverageWTSS(URL, coverage)
timeline    <- sits_timeline (coverage.tb)

#load a data set for with samples for EMBRAPA data set
embrapa.tb <- readRDS(system.file ("extdata/time_series/embrapa_mt.rds", package = "sits"))

results <- list()

# test accuracy of TWDTW to measure distances
conf_svm.tb <- sits_kfold_fast_validate(embrapa.tb, folds = 5, timeline, multicores = 2,
                                   pt_method   = sits_patterns_from_data(),
                                   dist_method = sits_distances_from_data(),
                                   tr_method   = sits_svm (kernel = "radial", cost = 1))
print("==================================================")
print ("== Confusion Matrix = SVM =======================")
conf_svm.mx <- sits_accuracy(conf_svm.tb)

conf_svm.mx$name <- "svm_10"

results[[length(results) + 1]] <- conf_svm.mx


# =============== GLM ==============================

# generalized liner model (glm)
conf_glm.tb <- sits_kfold_fast_validate(embrapa.tb, folds = 5, timeline, multicores = 2,
                                        pt_method   = sits_patterns_from_data(),
                                        dist_method = sits_distances_from_data(),
                                        tr_method   = sits_glm())

# print the accuracy of the generalized liner model (glm)
print("===============================================")
print ("== Confusion Matrix = GLM  =======================")
conf_glm.mx <- sits_accuracy(conf_glm.tb)

conf_glm.mx$name <- "glm"

results[[length(results) + 1]] <- conf_glm.mx

# =============== RFOR ==============================

# test accuracy of TWDTW to measure distances
conf_rfor.tb <- sits_kfold_fast_validate(embrapa.tb, folds = 5, timeline, multicores = 2,
                                         pt_method   = sits_patterns_from_data(),
                                         dist_method = sits_distances_from_data(),
                                         tr_method   = sits_rfor ())
print("==================================================")
print ("== Confusion Matrix = RFOR =======================")
conf_rfor.mx <- sits_accuracy(conf_rfor.tb)
conf_rfor.mx$name <- "rfor"

results[[length(results) + 1]] <- conf_rfor.mx

# =============== LDA ==============================

# test accuracy of TWDTW to measure distances
conf_lda.tb <- sits_kfold_fast_validate(embrapa.tb, folds = 5, timeline, multicores = 2,
                                        pt_method   = sits_patterns_from_data(),
                                        dist_method = sits_distances_from_data(),
                                        tr_method   = sits_lda ())

print("==================================================")
print ("== Confusion Matrix = LDA =======================")
conf_lda.mx <- sits_accuracy(conf_lda.tb)
conf_lda.mx$name <- "lda"

results[[length(results) + 1]] <- conf_lda.mx

# =============== MLR ==============================
# "multinomial log-linear (mlr)
conf_mlr.tb <- sits_kfold_fast_validate(embrapa.tb, folds = 5, timeline, multicores = 1,
                                        pt_method   = sits_patterns_from_data(),
                                        dist_method = sits_distances_from_data(),
                                        tr_method   = sits_mlr())

# print the accuracy of the Multinomial log-linear
print("===============================================")
print ("== Confusion Matrix = MLR =======================")
conf_mlr.mx <- sits_accuracy(conf_mlr.tb)
conf_mlr.mx$name <- "mlr"

results[[length(results) + 1]] <- conf_mlr.mx

# =============== GBM ==============================
# Gradient Boosting Machine
conf_gbm.tb <- sits_kfold_fast_validate(embrapa.tb, folds = 5, timeline, multicores = 1,
                                        pt_method   = sits_patterns_from_data(),
                                        dist_method = sits_distances_from_data(),
                                        tr_method   = sits_gbm())

# print the accuracy of the Gradient Boosting Machine
print("===============================================")
print ("== Confusion Matrix = GBM =======================")
conf_gbm.mx <- sits_accuracy(conf_gbm.tb)
conf_gbm.mx$name <- "gbm"

results[[length(results) + 1]] <- conf_gbm.mx

# =============== SVM full validate ==============================

# test accuracy of TWDTW to measure distances
conf_svm_full.tb <- sits_kfold_validate(embrapa.tb, folds = 5, timeline, multicores = 2,
                                        pt_method   = sits_patterns_from_data(),
                                        dist_method = sits_distances_from_data(),
                                        tr_method   = sits_svm (cost = 10, kernel = "radial",
                                                                tolerance = 0.001, epsilon = 0.1))
print("==================================================")
print ("== Confusion Matrix = SVM =======================")
conf_svm_full.mx <- sits_accuracy(conf_svm_full.tb)
conf_svm_full.mx$name <- "svm_full"

results[[length(results) + 1]] <- conf_svm_full.mx

WD = getwd()

sits_toXLSX(results, file = paste0(WD, "/accuracy_embrapa_spread.xlsx"))

