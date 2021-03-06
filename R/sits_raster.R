#' @title Create a metadata tibble to store the description of a spatio-temporal raster dataset
#' @name sits_STRaster
#' @author Gilberto Camara, \email{gilberto.camara@@inpe.br}
#'
#' @description  This function creates a tibble containing the metadata for
#'               a set of spatio-temporal raster files, defined as a set of "Raster Bricks".
#'               These files should be of the same size and
#'               projection. Each raster file should contain a data set, one layer
#'               per time step. Different bands are archived in different raster files.
#'
#' @param  files         Vector with the file paths of the raster files
#' @param  timeline      Vector of dates with the timeline of the bands
#' @param  bands         The bands contained in the Raster Brick set (in the same order as the files)
#' @param  scale_factors Scale factors to convert each band to [0..1] range (in the same order as the files)
#' @return raster.tb   A tibble with metadata information about a raster data set
#'
#' @description This function creates a tibble to store the information
#' about a raster time series
#'
#' @export
sits_STRaster <- function (files, timeline, bands, scale_factors){

    ensurer::ensure_that (bands, length(.) == length(files), err_desc = "number of bands does not match number of files")
    ensurer::ensure_that (scale_factors, length(.) == length(files), err_desc = "scale_factors do not match number of files")

    raster.tb <- purrr::pmap(list(files, bands, scale_factors),
                function (file, band, sf){
                    # create a raster object associated to the file
                    raster.obj <- raster::brick (file)
                    # find out how many layers the object has
                    n_layers    <-  raster.obj@file@nbands
                    # check that there are as many layers as the length of the timeline
                    ensurer::ensure_that(n_layers, (.) == length(timeline),
                                         err_desc = "duration of timeline is not matched by number of layers in raster")

                    row_raster.tb <- sits_tibble_raster (raster.obj, band, timeline, sf)

                }) %>% dplyr::bind_rows()

    return (raster.tb)
}

#' @title Extract a time series from a ST raster data set
#' @name sits_fromRaster
#' @author Gilberto Camara, \email{gilberto.camara@@inpe.br}
#'
#' @description Reads metadata about a raster data set to retrieve a set of
#' time series.
#'
#' @param raster.tb       A tibble with metadata describing a spatio-temporal data set
#' @param file            A CSV file with lat/long locations to be retrieve
#' @param longitude       double - the longitude of the chosen location
#' @param latitude        double - the latitude of the chosen location
#' @param xcoord          X coordinate of the point where the time series is to be obtained
#' @param ycoord          Y coordinate of the point where the time series is to be obtained
#' @param xmin            Minimum X coordinates of bounding box
#' @param xmax            Maximum X coordinates of bounding box
#' @param ymin            Minimum Y coordinates of bounding box
#' @param ymax            Maximum Y coordinates of bounding box
#' @param start_date      date - the start of the period
#' @param end_date        date - the end of the period
#' @param label           string - the label to attach to the time series
#' @param coverage        string - the name of the coverage to be retrieved
#' @return data.tb        a SITS tibble with the time series
#'
#' @description This function creates a tibble to store the information
#' about a raster time series
#'
#' @export
sits_fromRaster <- function (raster.tb, file = NULL, longitude = NULL, latitude = NULL,  xcoord = NULL, ycoord = NULL,
                              xmin = NULL, xmax = NULL, ymin = NULL, ymax = NULL,
                              start_date = NULL, end_date  = NULL, label = "NoClass", coverage    = NULL) {

    # ensure metadata tibble exists
    .sits_test_tibble (raster.tb)

    # get data based on CSV file
    if (!purrr::is_null (file) && tolower(tools::file_ext(file)) == "csv") {
        data.tb <- sits_ts_fromRasterCSV (raster.tb, file)
        return (data.tb)
    }

    if (!purrr::is_null (longitude) && !purrr::is_null (latitude)){
        xy <- sits_latlong_to_proj(longitude, latitude, raster.tb[1,]$crs)
        data.tb <- sits_ts_fromRasterXY (raster.tb, xy, longitude, latitude, label, coverage)
    }
}

#' @title Extract a time series for a set of Raster Layers
#' @name sits_ts_fromRasterXY
#' @author Gilberto Camara, \email{gilberto.camara@@inpe.br}
#'
#' @description  This function extracts a SITS time series from a set of
#'               Raster Layers whose metadata is stored in a tibble
#'               created by the sits_STraster function
#'
#' @param raster.tb        A tibble with metadata information about a raster data set
#' @param xy               A matrix with X/Y coordinates
#' @param longitude        Longitude of the chosen location
#' @param latitude         Latitude of the chosen location
#' @param label            Label to attach to the time series
#' @param coverage         Name of the coverage to be retrieved
#' @return data.tb         SITS tibble with the time series
#'
#' @description This function creates a tibble to store the information
#' about a raster time series
#'
#' @export

sits_ts_fromRasterXY <- function (raster.tb, xy, longitude, latitude, label = "NoClass", coverage = NULL){
    # ensure metadata tibble exists
    .sits_test_tibble (raster.tb)

    timeline <- raster.tb[1,]$timeline[[1]]

    ts.tb <- tibble::tibble (Index = timeline)

    raster.tb %>%
        purrrlyr::by_row (function (row){
            # obtain the Raster Layer object
            r_obj <- row$r_obj[[1]]
            # get the values of the time series
            values <- as.vector(raster::extract(r_obj, xy))
            values.tb <- tibble::tibble(values)
            names(values.tb) <- row$band
            # correct the values using the scale factor
            values.tb <- values.tb[,1]*row$scale_factor
            # add the column to the SITS tibble
            ts.tb <<- dplyr::bind_cols(ts.tb, values.tb)
        })

    # create a list to store the time series coming from the set of Raster Layers
    ts.lst <- list()
    # transform the zoo list into a tibble to store in memory
    ts.lst[[1]] <- ts.tb
    # set a name for the coverage
    if (purrr::is_null(coverage))
        coverage = tools::file_path_sans_ext(basename (raster.tb[1,]$name))
    # create a tibble to store the WTSS data
    data.tb <- sits_tibble()
    # add one row to the tibble
    data.tb <- tibble::add_row (data.tb,
                                longitude    = longitude,
                                latitude     = latitude,
                                start_date   = as.Date(timeline[1]),
                                end_date     = as.Date(timeline[length(timeline)]),
                                label        = label,
                                coverage     = coverage,
                                time_series  = ts.lst
    )
    return (data.tb)
}

#' @title Extract a time series for a set of Raster Layers
#' @name sits_ts_fromRasterCSV
#' @author Gilberto Camara, \email{gilberto.camara@@inpe.br}
#'
#' @description  This function extracts a SITS time series from a set of
#'               Raster Layers whose metadata is stored in a tibble
#'               created by the sits_STraster function
#'
#' @param raster.tb       A tibble with metadata describing a spatio-temporal data set
#' @param file            A CSV file with lat/long locations to be retrieved
#' @return data.tb         SITS tibble with the time series
#' @export

sits_ts_fromRasterCSV <- function (raster.tb, file){
    # ensure metadata tibble exists
    .sits_test_tibble (raster.tb)

    # configure the format of the CSV file to be read
    cols_csv <- readr::cols(id          = readr::col_integer(),
                            longitude   = readr::col_double(),
                            latitude    = readr::col_double(),
                            start_date  = readr::col_date(),
                            end_date    = readr::col_date(),
                            label       = readr::col_character())
    # read sample information from CSV file and put it in a tibble
    csv.tb <- readr::read_csv (file, col_types = cols_csv)
    # create the tibble
    data.tb <- sits_tibble()
    # for each row of the input, retrieve the time series
    csv.tb %>%
        purrrlyr::by_row( function (r){
            xy <- sits_latlong_to_proj(r$longitude, r$latitude, raster.tb[1,]$crs)
            ensurer::ensure_that(xy, .sits_XY_inside_raster((.), raster.tb),
                                 err_desc = "lat-long point not inside raster")
            row.tb <- sits_ts_fromRasterXY (raster.tb, xy, r$longitude, r$latitude, r$label)
            row.tb <- .sits_extract (row.tb, r$start_date, r$end_date)
            data.tb <<- dplyr::bind_rows (data.tb, row.tb)
        })
    return (data.tb)
}

#' @title Classify a set of spatio-temporal raster bricks using machine learning models
#' @name sits_classify_raster
#' @author Gilberto Camara, \email{gilberto.camara@@inpe.br}
#'
#' @description Takes a set of spatio-temporal raster bricks, whose metadata is
#'              described by tibble (created by \code{\link[sits]{sits_fromRaster}}),
#'              a set of patterns (created by \code{\link[sits]{sits_patterns}}),
#'              a prediction model (created by \code{\link[sits]{sits_train}}), and
#'              a method to extract shape attributes from time_series (used by  \code{\link[sits]{sits_distances}} ),
#'              and produces a classified set of RasterLayers. This function is similar to
#'               \code{\link[sits]{sits_classify}} which is applied to time series stored in a SITS tibble.
#'
#'
#' @param  raster.tb       a tibble with information about a set of space-time raster bricks
#' @param  file            a general set of file names (one file per classified year)
#' @param  patterns.tb     a set of known temporal signatures for the chosen classes
#' @param  ml_model        a model trained by \code{\link[sits]{sits_train}}
#' @param  dist_method     method to compute distances (e.g., sits_TWDTW_distances)
#' @param  interval        the period between two classifications
#' @param  ...             other parameters to be passed to the distance function
#' @return raster_class.tb a SITS tibble with the metadata for the set of RasterLayers
#' @export
sits_classify_raster <- function (raster.tb, file = NULL, patterns.tb, ml_model = NULL,
                                  dist_method = sits_distances_from_data(),
                                  interval = "12 month"){

    # ensure metadata tibble exists
    .sits_test_tibble (raster.tb)
    # ensure patterns tibble exits
    .sits_test_tibble (patterns.tb)

    # ensure that file name and prediction model are provided
    ensurer::ensure_that(file,     !purrr::is_null(.), err_desc = "sits-classify-raster: please provide name of output file")
    ensurer::ensure_that(ml_model, !purrr::is_null(.), err_desc = "sits-classify-raster: please provide a machine learning model already trained")

    # create the raster objects and their respective filenames
    raster_class.tb <- .sits_create_classified_raster(raster.tb, patterns.tb, file, interval)

    # get the labels of the data
    labels <- sits_labels(patterns.tb)$label

    #initiate writing
    raster_class.tb$r_obj <- raster_class.tb$r_obj %>%
        purrr::map(function (layer) {
            raster::writeStart(layer, layer@file@name, overwrite = TRUE)
        })

    # recover the input data by blocks for efficiency
    bs <- raster::blockSize (raster_class.tb[1,]$r_obj[[1]])

    # read the input raster in blocks
    for (i in 1:bs$n){

        # extract time series from the block of RasterBrick rows
        data.tb <- .sits_data_from_block (raster.tb, row = bs$row[i], nrows = bs$nrows[i])

        # classify the time series that are part of the block
        class.tb <- sits_classify(data.tb, patterns.tb, ml_model)

        # write the block back
        raster_class.tb <- .sits_block_from_data (class.tb, raster_class.tb, labels, row = bs$row[i])
    }
    # finish writing
    raster_class.tb$r_obj <- raster_class.tb$r_obj %>%
        purrr::map(function (layer) {
            raster::writeStop(layer)
        })
    return (raster_class.tb)
}

