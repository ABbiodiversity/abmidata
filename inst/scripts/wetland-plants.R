ROOT   <- "e:/peter/AB_data_v2017/data/raw/species"
OUTDIR <- "e:/peter/AB_data_v2017/data/analysis/species"
REJECT <- unique(c(1640, ## from JimS email Oct 6, 2011
    33, 1573, 1618, 1252, 1148, 1253, 1254, ## from Jill
    1149, 1150, 1252, 1621, 1201, 1525))
getwd()
if (interactive())
    source("~/repos/abmianalytics/species/00globalvars.R") else source("00globalvars.R")
if (interactive())
    source("~/repos/abmianalytics/species/00globalvars_wetland.R") else source("00globalvars_wetland.R")

T <- "AqPlants"
if (do.prof) {
    proffile <- paste(D, "/OUT_", tolower(T), d, ".Rprof",sep="")
    Rprof(proffile)
}

if (FALSE) {## extablish connection
con <- odbcConnectAccess2007(DBVERSION)
## queries
res <- sqlQuery(con, paste("SELECT * FROM CSVDOWNLOAD_A_RW_VASCULAR_PLANT"))
lookup <- sqlQuery(con, paste("SELECT * FROM RAWDATA_G_OFFGRID_SITE_LABEL"))
taxo <- sqlQuery(con, paste("SELECT * FROM PUBLIC_ACCESS_PUBLIC_DETAIL_TAXONOMYS"))
## close connection
close(con)
}

res <- read.csv(file.path(ROOT, "wplants-20170404.csv"))
gis <- read.csv("~/repos/abmianalytics/lookup/sitemetadata.csv")
taxo <- read.csv(file.path(ROOT, "taxonomy.csv"))
cap <- read.csv(file.path(ROOT, "wsitecap-20170407.csv"))
phc <- read.csv(file.path(ROOT, "wphychem-20170407.csv"))

table(cap$OLD_ZONE, cap$NEW_ZONE)
cap <- droplevels(cap[cap$OLD_ZONE != "Upland" & !(cap$WTD_TRANSECT_CODE %in%
    c("DNC","Transition Transect")),])
cap$Label <- with(cap, interaction(SITE, YEAR, OLD_ZONE, sep="_", drop=TRUE))
table(cap$WTD_TRANSECT_CODE)
xtc <- as.matrix(Xtab(~Label + WTD_TRANSECT_CODE, cap))
xtc[xtc>0] <- 1
xtc <- rowSums(xtc)
table(xtc)

res$Label <- with(res, interaction(SITE, YEAR, OLD_ZONE, sep="_", drop=TRUE))
#compare_sets(res$capLabel, cap$Label)

#rr <- LabelFun(res)
#rr <- nonDuplicated(cap, Label, TRUE)
#res <- data.frame(res, rr[match(res$capLabel, rr$Label),])

## exclude parts here if necessary
## remove bad wetlands
keep <- !(res$SITE %in% REJECT)
res <- droplevels(res[keep,])

keep <- rep(TRUE, nrow(res))
keep[res$OLD_ZONE == "Upland"] <- FALSE
keep[res$TRANSECT == "Transition Transect"] <- FALSE
res <- res[keep,]
res$TRANSECT <- droplevels(res$TRANSECT)
res$OLD_ZONE <- droplevels(res$OLD_ZONE)
res$Label <- droplevels(res$Label)
res$Label2 <- with(res, interaction(SITE, YEAR, sep="_", drop=TRUE))

## crosstab

## using species only
res$SPECIES_OLD <- res$SCIENTIFIC_NAME
levels(res$SCIENTIFIC_NAME) <- gsub("X ", "", levels(res$SCIENTIFIC_NAME))
levels(res$SCIENTIFIC_NAME) <- gsub(" x ", " ", levels(res$SCIENTIFIC_NAME))
levels(res$SCIENTIFIC_NAME) <- sapply(strsplit(levels(res$SCIENTIFIC_NAME), " "), function(z) {
    paste(z[1:min(2, length(z))], collapse=" ")
})
levels(res$SCIENTIFIC_NAME) <- nameAlnum(levels(res$SCIENTIFIC_NAME), capitalize="mixed", collapse="")
res$SCIENTIFIC_NAME <- droplevels(res$SCIENTIFIC_NAME)

## getting rid of duplicate rows for species
res$uid <- paste(res$Label, res$TRANSECT, res$SCIENTIFIC_NAME, sep="::")
dim(res)
nlevels(res$SCIENTIFIC_NAME)
res <- nonDuplicated(res, uid)
dim(res)
nlevels(res$SCIENTIFIC_NAME)

## SNR ?new sentinel value?
xt <- Xtab(~ Label + SCIENTIFIC_NAME, res,
    cdrop=c("NONE","SNI", "VNA", "DNC", "PNA", "SNR"),
    drop.unused.levels = FALSE)
range(xt)
#xt[xt>0] <- 1

#xtcap <- Xtab(~ Label + WTD_TRANSECT_CODE, cap)
#rowSums(xtcap[,2:6])

## get taxonomy
z <- nonDuplicated(res[!(res$SCIENTIFIC_NAME %in% c("VNA", "DNC")),],
    res$SCIENTIFIC_NAME[!(res$SCIENTIFIC_NAME %in% c("VNA", "DNC"))], TRUE)
## add here higher taxa too
z <- z[,c("TSN_ID","COMMON_NAME","SCIENTIFIC_NAME","SPECIES_OLD","RANK_NAME")]
#z2 <- taxo[taxo$SCIENTIFIC_NAME %in% z$PECIES_OLD,]
z2 <- taxo[match(z$SPECIES_OLD, taxo$SCIENTIFIC_NAME),]
z <- data.frame(z, z2[,setdiff(colnames(z2), colnames(z))])
levels(z$RANK_NAME)[levels(z$RANK_NAME) %in% c("Subspecies","Variety")] <- "Species"
#z[] <- lapply(z, function(z) z[drop=TRUE])
#summary(z)

x <- nonDuplicated(res[,c("Label", "Label2", "ROTATION", "SITE", "YEAR",
    "FIELDDATE", "CREWMEMBER", "OLD_ZONE")], res$Label, TRUE)

## crosstab on PC level
m <- Mefa(xt, x, z)
## exclude not species level taxa
table(m@taxa$RANK_NAME) # here are sub-specific levels
m <- m[,m@taxa$RANK_NAME %in% c("Genus", "Species")]
## exclude not species level taxa
#m <- m[,m@taxa$TAXONOMICRESOLUTION == "Species"]
#xtab(m) <- as(xtab(m) > 0, "dgCMatrix")

## site level info
m2 <- groupSums(m, 1, m@samp$Label2)
xtab(m2) <- as(xtab(m2) > 0, "dgCMatrix")


## crosstabs
if (!combine.tables) {
    res1 <- as.matrix(m)
    res2 <- as.matrix(m2)
    rntw <- TRUE
} else {
    samp(m)$TotlaNoOfTransects <- xtc[match(samp(m)$Label, names(xtc))]
    res1 <- data.frame(samp(m), as.matrix(m))
    mmm <- Mefa(xtab(m2), data.frame(nonDuplicated(samp(m)[,-which(colnames(samp(m))=="Label")],
        Label2, TRUE)))
    res2 <- data.frame(samp(mmm), as.matrix(mmm))
    rntw <- FALSE
}
tax <- taxa(m)
tax[] <- lapply(tax, function(z) z[drop=TRUE])
str(res1)
str(res2)
m
m2
str(tax)
range(xtab(m))
range(xtab(m2))

## write static files into csv
write.csv(res1, file=paste(D, "/OUT_", T, "_Species_WZ-Binomial", d,
    ".csv",sep=""), row.names = rntw)
write.csv(res2, file=paste(D, "/OUT_", T, "_Species_Site", d, ".csv",sep=""), row.names = rntw)
write.csv(tax, file=paste(D, "/OUT_", T, "_Species_Taxa", d, ".csv",sep=""), row.names = TRUE)


if (do.prof)
    summaryRprof(proffile)
if (do.image)
    save.image(paste(D, "/OUT_", tolower(T), d, ".Rdata",sep=""))
## quit without saving workspace
quit(save="no")

## old notes --------

sss <- read.csv("y:/Oracle_access/src2/sitesummary_download.csv")[,c(1,2,3,5)]
setdiff(samp(m)$SiteLabel[samp(m)$YEAR==2011],sss[sss$Wetland=="Completed","SiteLabel"])
setdiff(sss[sss$Wetland=="Completed","SiteLabel"],samp(m)$SiteLabel[samp(m)$YEAR==2011])

setdiff(setdiff(sss[sss$Wetland=="Completed","SiteLabel"],samp(m)$SiteLabel[samp(m)$YEAR==2011]), REJECT)

"OGW-ABMI-1058-2" is missing from summaries but expected based on SSWB

