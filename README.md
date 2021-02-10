# abmidata

> Public data from the Alberta Biodiversity Monitoring Institute

[![check](https://github.com/ABbiodiversity/abmidata/workflows/check/badge.svg)](https://github.com/ABbiodiversity/abmidata/actions)

## Setup

Install the package:

``` r
remotes::install_github("ABbiodiversity/abmidata")
```

## Usage

### Pulling monitoring data

The ABMI public data API pulls information from one of ABMI’s main
databases.

Load the R package:

``` r
library(abmidata)
#> abmidata 0.0.1    2021-02-11
```

List names of tables available via the API:

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

Get a table by its ID, possibly filtered by site ID or by year:

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

ABMI data has specific placeholders for missing data indicating the
[reason for the
missingness](https://abbiodiversity.github.io/abmidata/reference/helpers.html).
This poses challenges in R when the information is numeric. Here is how
you can handle these missing value indicators:

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

### Processing data

Once tables are loaded using the ABMI public data API, the data usually
needs to be processed further. The tables are in ‘long format’ which
means that e.g. sites and species are all in in their own columns:

| Site   | Species | Count |
| ------ | ------- | ----- |
| Site 1 | A       | 1     |
| Site 1 | B       | 2     |
| Site 1 | C       | 3     |
| Site 2 | B       | 1     |
| Site 2 | D       | 2     |
| Site 3 | E       | 1     |

There are other R packages that can be used to turn the ‘long format’
data into a ‘wide format’ where e.g. sites represent rows and species
represent columns:

| Site | A | B | C | D | E |
| ---- | - | - | - | - | - |
| 1    | 1 | 2 | 3 | 0 | 0 |
| 2    | 0 | 1 | 0 | 2 | 0 |
| 3    | 0 | 0 | 0 | 0 | 1 |

Check out examples of how to do this for vascular plants, mites, mosses,
lichens, and birds in [this
article](https://abbiodiversity.github.io/abmidata/articles/abmidata03-commontasks.html)
about common data processing tasks.

### Matching monitoring data with predictors

Once the monitoring data is in the desired format, one can match the
site locations (and possibly years) with location/year specific
predictor variables. One can use the **field data** about site condition
to explain the distribution, abundance, or other measures of species and
habitat elements at the ABMI sites.

One can also use **geospatial information** extracted at the site
coordinates. This, however, poses some challenges because exact site
coordinates are not publicly available. However, restrictions around
site confidentiality have been substantially relaxed and coordinates for
most sites will soon be available for research purposes upon request. We
will provide relevant information here as soon as it is available. In
the meantime, please reach out to
[ABMI](https://www.abmi.ca/home/contact-us.html) for more information.

## Documentation

See the [package website](https://abbiodiversity.github.io/abmidata) for
documentation. A list of tables and associated metadata can be found
[here](https://abbiodiversity.github.io/abmidata/articles/abmidata02-metadata.html).

See also:

  - [Terrestrial Field Data Collection
    Protocols](https://abmi.ca/home/publications/501-550/549)
  - [Wetland Field Data Collection
    Protocols](https://abmi.ca/home/publications/501-550/548)
  - [Terrestrial ABMI Autonomous Recording Unit (ARU) and Remote Camera
    Trap Protocols](https://abmi.ca/home/publications/551-600/565)

## Issues

<https://github.com/ABbiodiversity/abmidata/issues>

## Citation

Solymos P, Fang J, ABMI (2021). *abmidata: Accessing Public Data from
the ABMI*. R package version 0.0.1, \<URL:
<https://github.com/abbiodiversity/abmidata>\>.

## License

[MIT](LICENSE) © 2020 Peter Solymos, Joan Fang, ABMI
