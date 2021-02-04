#' Handling NA Values.
#'
#' ABMI specific missing value indicators
#' complicate data processing because numeric variables are treated as character.
#' These helpers handle these indicators. There are 4 kinds of missing value
#' indicators in ABMI data tables:
#'
#' VNA: Variable Not Applicable. Some ABMI data is collected in a nested manner.
#' For example Tree Species is a parent variable. This variable has a number of child
#' variables that are used to describe the parent variable in more detail
#' (e.g., condition, DBH, decay stage). When the parent variable is recorded as None,
#' child variables are no longer applied and are recorded as VNA. VNA is also used
#' when the protocol calls for a modified sampling procedure based on site conditions
#' (e.g., surface substrate protocol variant for hydric site conditions). The use of
#' VNA implies that users of the data should not expect that any data could be present.
#'
#' DNC: Did Not Collect. DNC is used to describe variables that should have been collected
#' but were not. There are a number of reasons that data might not have been collected
#' (e.g. staff oversight, equipment failure, safety concerns, environmental conditions,
#' or time constraints). Regardless of the reason data was not collected, if under ideal
#'  conditions it should have been, the record in the data entry file reads DNC.
#'  The use of DNC implies that users should expect the data to be present - though
#'  it is not.
#'
#' PNA: Protocol Not Available. The ABMI's protocols were, and continue to be,
#' implemented in a staged manner. As a result, the collection of many variables
#' began in years subsequent to the start of the prototype or operational phases or
#' where discontinued after a few years of trial. When a variable was not collected
#' because the protocol had yet to be implemented by the ABMI (or was discontinued by the ABMI),
#' the data entry record reads PNA. This is a global constraint to the data (i.e. a protocol
#' was not implemented until 2006, therefore, previous years cannot have this variable).
#' PNA is to be used to describe the lack of data collection for entire years.
#'
#' SNI: Species Not Identified. In various fields related to species identification,
#' SNI is used to indicate that the organism was not identified to the species level.
#' Some possible reasons that identification to the species level of resolution was not
#' possible include, insufficient or deficient sample collected and lack of field time.
#'
#' @param x A vector.
#'
#' @examples
#' \dontrun{
#'
#' z <- ad_get_table("T01A", year=2010)
#' x <- z[["Aspect (degrees)"]][1:100]
#' x
#' ad_convert_na(x)
#' summary(ad_process_na(x))
#'
#' }
#'
#' @return
#'
#' `ad_convert_na` returns a numeric vector, ABMI's special missing value indicators set to `NA`.
#'
#' `ad_process_na` returns a data frame with ABMI's special missing value
#' indicators as their own indicator columns (1 or 0) and the `value` column
#' containing the numeric output from `ad_convert_na(x)`.
#'
#' @seealso [ad_get_table()].
#'
#' @name helpers
#'
#'
NULL

#' @export
#' @rdname helpers
## this sets NAs and returns a numeric
## useful when we don't care about why there was an NA
ad_convert_na <- function(x) {
    if (is.numeric(x))
        return(x)
    if (!is.character(x))
        x <- as.character(x)
    x[x %in% .ad_specials()] <- NA_character_
    as.numeric(x)
}

#' @export
#' @rdname helpers
## this makes dummies besides returning the numeric
## useful when we want to understand the NA patterns
ad_process_na <- function(x) {
    if (!is.character(x))
        x <- as.character(x)
    l <- lapply(.ad_specials(), function(i) ifelse(x == i, 1L, 0L))
    names(l) <- .ad_specials()
    l$value <- ad_convert_na(x)
    as.data.frame(l)
}
