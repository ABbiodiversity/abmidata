#' Get Methods for the ABMI Data API.
#'
#' Function names are prepended with `ad_` referring to ABMI data.
#'
#' `ad_get_table_names` lists names of tables available for download,
#' `ad_get_table_header` lists table headers,
#' `ad_get_table_size` gives the size of the table,
#' `ad_get_table_data` gets a chunk of a table,
#' `ad_get_table` gets the entire table.
#'
#' @param table Title of a given table, e.g. `"T01A"`, es returned by `ad_get_table_names()`.
#' @param site Site name (return sites contains the given value).
#' @param year Year (return records in the given year).
#' @param skip Start from which row (default 0).
#' @param take Total rows to return (default 1000).
#'
#' @examples
#' \dontrun{
#'
#' ad_get_table_names()
#' ad_get_table_header("T01A")
#' ad_get_table_data("T01A", take=10)
#' ad_get_table_size("T01A")
#' str(ad_get_table("T01A", year=2010))
#'
#' }
#'
#' @return
#'
#' `ad_get_table_names` returns a named character vector with table names and descriptions.
#'
#' `ad_get_table_header` returns a character vector with header names.
#'
#' `ad_get_table_size` returns a single numeric value with the size of the table.
#'
#' `ad_get_table_data` returns a data frame.
#'
#' `ad_get_table` returns a data frame.
#'
#' @seealso [ad_convert_na()] for dealing with missing value indicators.
#'
#' @name getmethods
#'
#'
NULL

#' @export
#' @rdname getmethods
## return all table titles
## need to filter out ones that won't load: test
ad_get_table_names <- function() {
    out <- .ad_get("getTableNames")
    out <- unlist(out)
    names(out) <- sapply(strsplit(out, " "), function(z) z[1L])
    out
}

#' @export
#' @rdname getmethods
## return the table header
## parameters:
## table: title of a given table, e.g. T01A, since we also have CT01A in the
##        database, the table value input will be queried as starting with the
##        given value
ad_get_table_header <- function(table) {
    out <- .ad_get("getTableHeader", query = list(table = table))
    eval(parse(text=paste0("c(", out, ")")))
}

#' @export
#' @rdname getmethods
## return table data
## parameters:
## table: title of a given table, e.g. T01A, since we also have
##        CT01A in the database, the table value input will be queried as
##        starting with the given value
## site: site name (return sites contains the given value)
## year: year (return records in the given year)
## skip: start from which row, start from 0 (default 0)
## take: total rows to return (default 1000)
## return:
##   {
##     "total": total number of rows
##     "skip": starting row number
##     "data": [array of rows]
##   }
ad_get_table_data <- function(table, site=NULL, year=NULL, skip=0L, take=1000L) {
    out <- .ad_get("getTableData",
        query = list(
            table = table,
            site = site,
            year = year,
            skip = skip,
            take = take
        ))
    file <- tempfile()
    on.exit(unlink(file))
    writeLines(unlist(out$data), con=file, sep="")
    tab <- utils::read.csv(file, header=FALSE)
    tab <- tab[,-ncol(tab),drop=FALSE]
    colnames(tab) <- ad_get_table_header(table = table)
    attr(tab, "lines") <- c(total=out$total, skip=skip, take=take)
    tab
}

#' @export
#' @rdname getmethods
## get table size by requesting a few rows, but total is also returned
ad_get_table_size <- function(table) {
    out <- .ad_get("getTableData",
        query = list(
            table = table,
            skip = 0,
            take = 2
        ))
    out$total
}

#' @export
#' @rdname getmethods
## this gets the whole table (paging is not yet implemented)
ad_get_table <- function(table, site=NULL, year=NULL) {
    n <- ad_get_table_size(table)
    tab <- ad_get_table_data(table, site, year, skip=0L, take=n)
    colnames(tab) <- ad_get_table_header(table = table)
    attr(tab, "lines") <- NULL
    tab
}
