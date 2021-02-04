library(abmidata)

n <- ad_get_table_names()

x <- list()
for (i in names(n)) {
    cat("\n", i)
    x[[i]] <- try(ad_get_table_data(i, take=10L), silent=TRUE)
    if (inherits(x[[i]], "try-error"))
        cat("\tFAILED") else cat("\tOK")
}

tab <- data.frame(descr=n, OK=!sapply(x, inherits, "try-error"))
table(tab$OK)
tab[!tab$OK,]
