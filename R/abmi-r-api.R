library(mefa4)
library(curl)
library(jsonlite)
#library(pbapply)

.data_api_url <- readLines("~/.ssh/data_api_url")
options("abmi_settings" = list(data_api_url = .data_api_url))
getOption("abmi_settings")$data_api_url

get_content <- function(url) {
    fromJSON(rawToChar(curl_fetch_memory(url)$content))
}

## return all table titles
get_table_names <-
function()
{
    out <- get_content(paste0(getOption("abmi_settings")$data_api_url,
        "getTableNames"))
    names(out) <- sapply(strsplit(out, " "), function(z) z[1L])
    out
}

## return the table header
## parameters:
## table: title of a given table, e.g. T01A, since we also have CT01A in the
##        database, the table value input will be queried as starting with the
##        given value
get_table_header <-
function(table)
{
    out <- get_content(paste0(getOption("abmi_settings")$data_api_url,
        "getTableHeader?table=", table))
    eval(parse(text=paste0("c(", out, ")")))
}

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
get_table_data <-
function(table, site=NULL, year=NULL, skip=0L, take=1000L)
{
    filters <- list(table=paste0("table=", table))
    if (!is.null(site))
        filters$site <- paste0("site=", site)
    if (!is.null(year))
        filters$year <- paste0("year=", year)
    filters$skip <- paste0("skip=", skip)
    filters$take <- paste0("take=", take)

    out <- get_content(paste0(getOption("abmi_settings")$data_api_url,
        "getTableData?", paste(filters, collapse="&")))
    file <- tempfile()
    on.exit(unlink(file))
    writeLines(out$data, con=file, sep="")
    tab <- read.csv(file, header=FALSE)
    tab <- tab[,-ncol(tab),drop=FALSE]
    colnames(tab) <- get_table_header(table = table)
    attr(tab, "lines") <- c(total=out$total, skip=skip, take=take)
    tab
}

get_table_size <-
function(table, site=NULL, year=NULL, async=TRUE, file=NULL, m=10L)
{
    out <- curl_fetch_memory(paste0(getOption("abmi_settings")$data_api_url,
        "getTableData?table=", table, "&skip=0&take=2"))
    n <- fromJSON(rawToChar(out$content))$total
    n
}

## sequential requests: slow
## concurrent requests: fast, but row ordering can be different
.get_table <-
function(table, site=NULL, year=NULL, async=TRUE, file=NULL, m=10L)
{
    n <- get_table_size(table)
    size <- as.integer(max(1000, round(n/m)))
    begin <- size * (0L:(n %/% size)) + 1L

    filters <- list(table=paste0("table=", table))
    if (!is.null(site))
        filters$site <- paste0("site=", site)
    if (!is.null(year))
        filters$year <- paste0("year=", year)
    filters$skip <- paste0("skip=", 0)
    filters$take <- paste0("take=", size)

    if (async) {
        results <- list()
        done <- function(x){
            results <<- append(results, list(x))
        }
        pool <- new_pool()
        for (i in 1L:length(begin)) {
            filters$skip <- paste0("skip=", begin[i]-1)
            curl_fetch_multi(paste0(getOption("abmi_settings")$data_api_url,
                "getTableData?", paste(filters, collapse="&")),
                pool = pool, done=done)
        }
        tmp <- multi_run(pool=pool)
        dat <- unlist(lapply(results,
            function(z) fromJSON(rawToChar(z$content))$data))
    } else {
        end <- c(begin[-1L] - 1L, n)
        dat <- character(n)
        pb <- startpb(0, length(begin))
        on.exit(closepb(pb))
        for (i in 1L:length(begin)) {
            filters$skip <- paste0("skip=", begin[i]-1)
            out <- get_content(paste0(getOption("abmi_settings")$data_api_url,
                "getTableData?", paste(filters, collapse="&")))
            dat[begin[i]:end[i]] <- out$data
            setpb(pb, i)
        }
    }
    if (is.null(file)) {
        file <- tempfile()
        on.exit(unlink(file), add=TRUE)
    }
    writeLines(dat, con=file, sep="")
    tab <- read.csv(file, header=FALSE)
    tab <- tab[,-ncol(tab),drop=FALSE]
    colnames(tab) <- get_table_header(table = table)
    tab
}

get_table <-
function(table, site=NULL, year=NULL)
{
    tab <- get_table_data(table, site, year,
        skip=0L, take=get_table_size(table))
    #tab <- tab[,-ncol(tab),drop=FALSE]
    colnames(tab) <- get_table_header(table = table)
    attr(tab, "lines") <- NULL
    tab
}
