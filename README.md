
<!-- README.md is generated from README.Rmd. Please edit that file -->

# validatedb

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/validatedb)](https://CRAN.R-project.org/package=validatedb)
[![R build
status](https://github.com/edwindj/validatedb/workflows/R-CMD-check/badge.svg)](https://github.com/edwindj/validatedb/actions)
<!-- [![CircleCI build status](https://circleci.com/gh/data-cleaning/validatedb.svg?style=svg)](https://circleci.com/gh/data-cleaning/validatedb) -->
<!-- badges: end -->

## WORK IN PROGRESS!

`validatedb` executes validation checks written with R package
`validate` on a database. This allows for checking the validity of
records in a database.

## Installation

`validatedb` is in heavy development and should not yet be used for
production. You can install a development version with

<!-- You can install the released version of validatedb from [CRAN](https://CRAN.R-project.org) with: -->

``` r
remotes::install_github("data-cleaning/validatedb")
```

## Example

``` r
library(validatedb)
#> Loading required package: validate
library(validate)
```

First we setup a table in a database (for demo purpose)

``` r
# create a table in a database
income <- data.frame(age=c(12,35), salary = c(1000,NA))
con <- DBI::dbConnect(RSQLite::SQLite())
DBI::dbWriteTable(con, "income", income)
```

We retrieve a reference/handle to the table in the DB with `dplyr`

``` r
tbl_income <- dplyr::tbl(con, "income")
print(tbl_income)
#> # Source:   table<income> [?? x 2]
#> # Database: sqlite 3.30.1 []
#>     age salary
#>   <dbl>  <dbl>
#> 1    12   1000
#> 2    35     NA
```

Let’s define a rule set and confront the table with it:

``` r
rules <- validator( is_adult   = age >= 18
                  , has_income = salary > 0
                  )

# and confront!
cf <- confront(tbl_income, rules)
print(cf)
#> Object of class 'tbl_validation'
#> Call:
#>     confront.tbl_sql(tbl = dat, x = x, ref = ref, key = key, sparse = sparse)
#> 
#> Confrontations: 2
#> Fails         : [??] (see `values`)
#> Errors        : 0
```

Values (i.e. validations on the table) can be retrieved like in
`validate` with `type="list"`

``` r
values(cf, type = "list")
#> $is_adult
#> [1] FALSE  TRUE
#> 
#> $has_income
#> [1] TRUE   NA
```

But often this seems more handy:

``` r
values(cf, type = "tbl")
#> # Source:   lazy query [?? x 2]
#> # Database: sqlite 3.30.1 []
#>   is_adult has_income
#>      <int>      <int>
#> 1        0          1
#> 2        1         NA
```

We can see the sql code by using `show_query`:

``` r
v <- values(cf, type = "tbl")
dplyr::show_query(v)
#> <SQL>
#> SELECT (`age` - 18.0) >= -1e-08 AS `is_adult`, `salary` > 0.0 AS `has_income`
#> FROM `income`
```
