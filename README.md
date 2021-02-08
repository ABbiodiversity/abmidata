# abmidata

> Public data from the Alberta Biodiversity Monitoring Institute

[![check](https://github.com/ABbiodiversity/abmidata/workflows/check/badge.svg)](analythium/covid-19)

## Setup

Install the package:

``` r
remotes::install_github("ABbiodiversity/abmidata")
```

## Usage

Load the package

``` r
library(abmidata)
#> abmidata 0.0.1    2021-02-11
```

List table names

``` r
n <- ad_get_table_names()
data.frame(Description = head(n))
#>                               Description
#> T01A   T01A Site Physical Characteristics
#> CT01A CT01A Site Physical Characteristics
#> T01B                T01B Site Suitability
#> CT01C               CT01C Site Capability
#> CT01B              CT01B Site Suitability
#> T01C                 T01C Site Capability
```

Get a table

``` r
x <- ad_get_table("T01A", year=2010)
str(x)
#> 'data.frame':    1026 obs. of  14 variables:
#>  $ Rotation              : chr  "Rotation 1" "Rotation 1" "Rotation 1" "Rotation 1" ...
#>  $ ABMI Site             : chr  "149" "149" "149" "149" ...
#>  $ Year                  : int  2010 2010 2010 2010 2010 2010 2010 2010 2010 2010 ...
#>  $ Field Date            : chr  "27-May-10" "27-May-10" "27-May-10" "27-May-10" ...
#>  $ Field Crew Member(s)  : chr  "TGR" "TGR" "TGR" "TGR" ...
#>  $ Nearest Town          : chr  "DNC" "DNC" "DNC" "DNC" ...
#>  $ Public Latitude       : num  58.9 58.9 58.9 58.9 58.9 ...
#>  $ Public Longitude      : num  -112 -112 -112 -112 -112 ...
#>  $ Collection Methodology: int  1 1 1 1 1 1 1 1 1 1 ...
#>  $ Point Count Station   : int  1 2 3 4 5 6 7 8 9 1 ...
#>  $ Subpoint              : chr  "P" "P" "P" "P" ...
#>  $ Elevation (metres)    : int  213 213 213 213 213 213 213 213 213 212 ...
#>  $ Slope (degrees)       : chr  "0" "0" "0" "0" ...
#>  $ Aspect (degrees)      : chr  "VNA" "VNA" "VNA" "VNA" ...
```

Handling missing value indicators

``` r
y <- x[["Aspect (degrees)"]][1:100]
y
#>   [1] "VNA" "VNA" "VNA" "VNA" "VNA" "VNA" "VNA" "VNA" "VNA" "VNA" "VNA" "VNA"
#>  [13] "VNA" "VNA" "VNA" "VNA" "VNA" "VNA" "VNA" "100" "260" "VNA" "VNA" "80" 
#>  [25] "VNA" "220" "VNA" "VNA" "VNA" "VNA" "VNA" "VNA" "VNA" "VNA" "VNA" "VNA"
#>  [37] "DNC" "DNC" "DNC" "DNC" "VNA" "DNC" "VNA" "VNA" "DNC" "VNA" "VNA" "VNA"
#>  [49] "VNA" "VNA" "VNA" "VNA" "VNA" "VNA" "VNA" "VNA" "VNA" "VNA" "VNA" "VNA"
#>  [61] "VNA" "VNA" "VNA" "VNA" "VNA" "VNA" "VNA" "VNA" "VNA" "VNA" "VNA" "VNA"
#>  [73] "VNA" "VNA" "VNA" "VNA" "VNA" "VNA" "VNA" "VNA" "VNA" "VNA" "VNA" "VNA"
#>  [85] "VNA" "VNA" "VNA" "VNA" "VNA" "VNA" "VNA" "87"  "VNA" "9"   "VNA" "VNA"
#>  [97] "VNA" "VNA" "VNA" "VNA"
ad_convert_na(y)
#>   [1]  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA
#>  [19]  NA 100 260  NA  NA  80  NA 220  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA
#>  [37]  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA
#>  [55]  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA
#>  [73]  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA
#>  [91]  NA  87  NA   9  NA  NA  NA  NA  NA  NA
summary(ad_process_na(y))
#>       VNA            DNC            PNA         SNI        value       
#>  Min.   :0.00   Min.   :0.00   Min.   :0   Min.   :0   Min.   :  9.00  
#>  1st Qu.:1.00   1st Qu.:0.00   1st Qu.:0   1st Qu.:0   1st Qu.: 81.75  
#>  Median :1.00   Median :0.00   Median :0   Median :0   Median : 93.50  
#>  Mean   :0.88   Mean   :0.06   Mean   :0   Mean   :0   Mean   :126.00  
#>  3rd Qu.:1.00   3rd Qu.:0.00   3rd Qu.:0   3rd Qu.:0   3rd Qu.:190.00  
#>  Max.   :1.00   Max.   :1.00   Max.   :0   Max.   :0   Max.   :260.00  
#>                                                        NA's   :94
```

## Documentation

See the [package website](https://abbiodiversity.github.io/abmidata) for
documentation. A list of tables and associated metadata can be found
[here](https://abbiodiversity.github.io/abmidata/articles/abmidata02-metadata.html).
Field protocols and the table metadata can be found in [this zip
file](https://github.com/ABbiodiversity/abmidata/raw/master/metadata/DESCRIPTIONDATA.zip)
as well.

## Issues

<https://github.com/ABbiodiversity/abmidata/issues>

## Citation

Solymos P, Fang J, ABMI (2021). *abmidata: Accessing Public Data from
the ABMI*. R package version 0.0.1, \<URL:
<https://github.com/abbiodiversity/abmidata>\>.

## License

[MIT](LICENSE) © 2020 Peter Solymos, Joan Fang, ABMI
