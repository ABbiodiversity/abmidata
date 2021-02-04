# abmidata

> Public data from the Alberta Biodiversity Monitoring Institute

## Setup

Install the package:

```
remotes::install_github("ABbiodiversity/abmidata")
```

## Usage

```
## load the package
library(abmidata)

## List table names
ad_get_table_names()

## Get table
ad_get_table("T01A", year=2010)
```

## Documentation

Metadata for the field protocols and the tables can be found
in [this zip file](https://github.com/ABbiodiversity/abmidata/raw/master/metadata/DESCRIPTIONDATA.zip).

## Issues

[https://github.com/ABbiodiversity/abmidata/issues](https://github.com/ABbiodiversity/abmidata/issues)

## License

[MIT](LICENSE) © 2020 Peter Solymos, ABMI
