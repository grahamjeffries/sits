#!/usr/bin/env Rscript

con_in <- file("stdin", "rb")
con_out <- pipe("cat", "wb")

while(TRUE) {

  input_list <- unserialize(con_in)
  ncol <- length(input_list)
  if(ncol == 0) {
    sits::exitConnection(list(), con_out)
    break
  }

  attach(input_list)

  # read and parse arguments
  args <- commandArgs(trailingOnly=TRUE)
  lapply(args, function(x) {l <- unlist(strsplit(x, "=")); assign(l[1], l[2], envir = .GlobalEnv)})

  # get unique column and row values
  sits_tb <- sits::createColRowSequence(colid, rowid)

  # read patterns and get label names
  patterns_tb <- sits::sits_getdata(patterns_json)
  label_names <- dplyr::select(patterns_tb, label)

  split_processing <- function(line_tb, patterns_tb, scale_factor, bands, dist_method, alpha, beta, theta, span, keep, interval, overlap, dates) {

    # get index streaming data
    index <- which(colid == line_tb$longitude & rowid == line_tb$latitude)

    # if timeid has less than 9 indexes
    if(length(timeid[index]) < 9)
       return(list())

    # build time series object using attribute values and the dates
    line_tb$time_series[[1]] <- sits::createZooObject(bands = bands,
                                                      dates = dates[timeid[index]+1],
                                                      scale_factor = scale_factor,
                                                      idx = index)

    # align twdtw
    matches <- sits::sits_TWDTW_matches(line_tb,
                                           patterns_tb,
                                           bands = bands,
                                           alpha = alpha,
                                           beta = beta,
                                           dist.method = dist_method,
                                           theta = theta,
                                           span = span,
                                           keep = keep)

    best_matches_tb <- sits::sits_TWDTW_classify(matches,
                                                 line_tb,
                                                 start_date = start_date,
                                                 end_date = end_date,
                                                 interval = interval)

    k = nrow(best_matches_tb$best_matches[[1]][])

    return(data.frame(
         colid = as.double(rep(best_matches_tb$longitude, k)),
         rowid = as.double(rep(best_matches_tb$latitude, k)),
         timeid  = as.double(seq_len(k)),
         from  = as.integer(best_matches_tb$best_matches[[1]][]$from),
         to    = as.integer(best_matches_tb$best_matches[[1]][]$to),
         label = match(best_matches_tb$best_matches[[1]][]$label, label_names[[1]]),
         distance  = best_matches_tb$best_matches[[1]][]$distance
    ))

  }

  # Output
  out = do.call("rbind", parallel::mclapply(X = split(sits_tb, seq(nrow(sits_tb))),
					                   mc.cores = parallel::detectCores(),
					                   FUN = split_processing,
					                   patterns_tb = patterns_tb,
					                   scale_factor = as.numeric(scale_factor),
					                   bands = unlist(strsplit(bands, split = ",")),
					                   dist_method = dist_method,
					                   alpha = as.numeric(alpha),
					                   beta = as.numeric(beta),
					                   theta = as.numeric(theta),
					                   span = as.numeric(span),
					                   keep = as.logical(keep),
					                   interval = gsub(",", " ", interval),
					                   overlap = as.numeric(overlap),
					                   dates = as.Date(unlist(strsplit(dates, split = ",")))))

  writeBin(serialize(c(out), NULL, xdr=FALSE), con_out)
  flush(con_out)

}

close(con_in)

