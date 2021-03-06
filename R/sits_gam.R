#' @title Create temporal patterns using a generalised additive model (gam)
#' @name sits_gam
#' @author Victor Maus, \email{vwmaus1@@gmail.com}
#' @author Gilberto Camara, \email{gilberto.camara@@inpe.br}
#' @author Rolf Simoes, \email{rolf.simoes@@inpe.br}
#'
#' @description This function takes a set of time series samples as input
#' estimates a set of patterns. The patterns are calculated based in a GAM model.
#' The idea is to use a formula of type y ~ s(x), where x is a temporal
#' reference and y if the value of the signal. For each time, there will be as many predictions
#' as there are sample values. The GAM model predicts a suitable
#' approximation that fits the assumptions of the statistical model.
#' By default, the gam methods  produces an approximation based on a smooth function.
#'
#' This method is based on the "createPatterns" method of the dtwSat package, which is also
#' described in the reference paper.
#'
#' @references Maus V, Camara G, Cartaxo R, Sanchez A, Ramos FM, de Queiroz GR (2016).
#' A Time-Weighted Dynamic Time Warping Method for Land-Use and Land-Cover Mapping.
#' IEEE Journal of Selected Topics in Applied Earth Observations and Remote Sensing, 9(8):3729-3739,
#' August 2016. ISSN 1939-1404. doi:10.1109/JSTARS.2016.2517118.
#'
#' @param  data.tb       a tibble in SITS format with time series
#' @param  timeline      timeline with the all dates for the coverage
#' @param  from          starting date of the estimate (month-day)
#' @param  to            end data of the estimated (month-day)
#' @param  freq          int - the interval in days for the estimates to be generated
#' @param  formula       the formula to be applied in the estimate
#' @param  interval      the interval to obtain the patterns
#' @param  ...           any additional parameters
#' @return patterns.tb   a SITS tibble with the patterns
#' @export
#'
sits_gam <- function (data.tb = NULL, timeline = NULL, from = NULL, to = NULL,
                      freq = 8, formula = y ~ s(x), interval = "12 month", ...){


    # function that is used to be called as a value from another function
    result_fun <- function(tb, timeline){

        # does the input data exist?
        .sits_test_tibble (tb)

        # ensure timeline is not null
        ensurer::ensure_that(timeline, !purrr::is_null(.), err_desc = "sits_patterns : please provide the timeline of the coverage")

        times <- timeline

        # find the bands of the data
        bds <- sits_bands(tb)


        ensurer::ensure_that(tb[1,]$start_date, .sits_is_valid_start_date(., timeline),
                             err_desc = ".sits_gam: expected start date in not inside timeline of observations")

        ensurer::ensure_that(tb[1,]$end_date, .sits_is_valid_end_date(., timeline),
                             err_desc = ".sits_gam: expected end date in not inside timeline of observations")


        # create a tibble to store the results
        patterns.tb <- sits_tibble_patterns()

        # what are the variables in the formula?
        vars <-  all.vars(formula)

        # align all samples to the same time series intervals
        sample_dates <- lubridate::as_date(tb[1,]$time_series[[1]]$Index)
        tb           <- .sits_align (tb, sample_dates)

        # if "from" and "to" are not given, extract them from the data samples
        if (purrr::is_null (from) || purrr::is_null (to)) {
            from <- lubridate::as_date(utils::head(sample_dates, n = 1))
            to   <- lubridate::as_date(utils::tail(sample_dates, n = 1))
        }

        # determine the sequence of prediction times
        pred_time = seq(from = lubridate::as_date(from),
                        to   = lubridate::as_date(to),
                        by   = freq)

        # how many different labels are there?
        labels <- dplyr::distinct (tb, label)$label

        #
        message("Applying GAM to get time series patterns...")

        # add a progress bar
        i <- 0
        progress_bar <- utils::txtProgressBar(min = 0, max = length(labels) * length(bands), style = 3)

        # traverse labels
        labels %>%
            purrr::map(function (lb){

                # filter only those rows with the same label
                label.tb <- dplyr::filter (tb, label == lb)

                # create a data frame to store the time instances
                time <- data.frame(as.numeric(pred_time))

                # name the time as the second variable of the formula (usually, this is x)
                names(time) = vars[2]

                # create a tibble to store the time series associated to the pattern
                res.tb <- tibble::tibble (Index = lubridate::as_date(pred_time))

                # calculate the fit for each band
                bds %>%
                    purrr::map(function (bd) {

                        # retrieve the time series for each band
                        label_b.tb <- sits_select_bands (label.tb, bd)
                        ts <- label_b.tb$time_series

                        # melt the time series for each band into a long table
                        # with all values together
                        ts2 <- ts %>%
                            reshape2::melt   (id.vars = "Index") %>%
                            dplyr::select    (Index, value)      %>%
                            dplyr::transmute (x = as.numeric(Index), y = value)

                        #calculate the best fit for the data set
                        fit <-  mgcv::gam(data = ts2, formula = formula)

                        # Takes a fitted gam object and produces predictions
                        # for the desired dates in the sequence of prediction times
                        pred_values <- mgcv::predict.gam(fit, newdata = time)

                        #include the predicted values for the band in the results tibble
                        res.tb <- tibble::add_column(res.tb, b = pred_values)

                        # rename the column to match the band names
                        names(res.tb)[names(res.tb) == "b"] <- bd
                        # return the value out of the function scope
                        res.tb <<- res.tb

                        # update progress bar
                        i <<- i + 1
                        utils::setTxtProgressBar(progress_bar, i)
                    }) # for each band

                # put the pattern in a list to store in a sits tibble
                ts <- tibble::lst()
                ts[[1]] <- res.tb

                ref_dates.lst <- .sits_match_timelines(timeline, as.Date(from), as.Date (to), interval = interval)


                # add the pattern to the results tibble
                patterns.tb <<- tibble::add_row (patterns.tb,
                                                 start_date     = as.Date(from),
                                                 end_date       = as.Date(to),
                                                 label          = lb,
                                                 coverage       = label.tb[1,]$coverage,
                                                 timeline       = list(times),
                                                 ref_dates      = list(ref_dates.lst),
                                                 time_series    = ts)
            })

        close(progress_bar)
        return (patterns.tb)
    }

    result <- .sits_factory_function2 (data.tb, timeline, result_fun)
}
