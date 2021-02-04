## ABMI data API base url
.ad_baseurl <- function() {
    rawToChar(
        as.raw(c(0x68, 0x74, 0x74, 0x70, 0x73, 0x3a, 0x2f, 0x2f, 0x64,
            0x65, 0x76, 0x2d, 0x77, 0x65, 0x62, 0x2e, 0x61, 0x62, 0x6d, 0x69,
            0x2e, 0x63, 0x61))
    )
}

## ABMI data API base path
.ad_path <- function(...) {
    path <- paste(..., sep="/", collapse="/")
    path <- paste0(
        "/",
        rawToChar(as.raw(c(0x2e, 0x61, 0x6a, 0x61, 0x78, 0x2f,
                           0x64, 0x61, 0x74, 0x61, 0x41, 0x50, 0x49))),
        "/", path)
    gsub("//", "/", path)
}

## user agent to return package version, R version, build info
.ad_useragent <- function() {
    u <- getOption("HTTPUserAgent")
    if (is.null(u)) {
        u <- sprintf("R/%s; R (%s)", getRversion(),
            paste(getRversion(), R.version$platform, R.version$arch, R.version$os))
    }
    v <- try(as.character(utils::packageVersion("abmidata")), silent = TRUE)
    if (inherits(v, "try-error"))
        v <- "unreleased"
    paste0("abmidata/", v, "; ", u)
}

## convenience function to handle responses
.ad_process <- function(resp) {
    if (httr::http_error(resp)) {
        stop(
            sprintf("ABMI data API request failed [%s]",
                httr::status_code(resp)),
          call. = FALSE)
    }
    if (httr::http_type(resp) != "application/json") {
        stop("API did not return json", call. = FALSE)
    }
    cont <- jsonlite::fromJSON(
        httr::content(resp, "text"),
        simplifyVector = FALSE)
    attr(cont, "response") <- resp
    class(cont) <- "ad"
    cont
}

## convenience function for GET requests
.ad_get <- function(..., query=list()) {
    resp <- httr::GET(
            httr::modify_url(.ad_baseurl(),
                       path = .ad_path(...),
                       query = query),
            httr::content_type_json(),
            httr::accept_json(),
            httr::user_agent(.ad_useragent()))
    cont <- .ad_process(resp)
    class(cont) <- c(class(cont), "ad_get")
    cont
}

## this function collects the different types of NAs
.ad_specials <- function() {
    c(
        "Value Not Available"="VNA",
        "Did Not Collect"="DNC",
        "Protocol Not Available"="PNA",
        "Species Not Identified"="SNI"
    )
}
