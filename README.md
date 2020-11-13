
<!-- README.md is generated from README.Rmd. Please edit that file -->

# validatedb

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/validatedb)](https://CRAN.R-project.org/package=validatedb)
[![R build
status](https://github.com/edwindj/validatedb/workflows/R-CMD-check/badge.svg)](https://github.com/edwindj/validatedb/actions)
<!-- badges: end -->

## WORK IN PROGRESS!

`validatedb` executes validation checks written with R package
`validate` on a database. This allows for checking the validity of
records in a database.

## Installation

You can install the released version of validatedb from
[CRAN](https://CRAN.R-project.org) with:

``` r
remotes::install_github("edwindj/validatedb")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(validatedb)
#> Loading required package: validate
library(validate)

rules <- validator( is_adult   = age >= 18
                  , has_income = salary > 0
                  )

# create a table in a database
income <- data.frame(age=c(12,35), salary = c(1000,NA))

# demo in memory db
con <- DBI::dbConnect(RSQLite::SQLite())
DBI::dbWriteTable(con, "income", income)

tbl_income <- dplyr::tbl(con, "income")
print(tbl_income)
#> # Source:   table<income> [?? x 2]
#> # Database: sqlite 3.30.1 []
#>     age salary
#>   <dbl>  <dbl>
#> 1    12   1000
#> 2    35     NA
#confront(tbl_income, rules)
```
