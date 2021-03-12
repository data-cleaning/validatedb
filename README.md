
<!-- README.md is generated from README.Rmd. Please edit that file -->

# validatedb

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/validatedb)](https://CRAN.R-project.org/package=validatedb)
[![R build
status](https://github.com/edwindj/validatedb/workflows/R-CMD-check/badge.svg)](https://github.com/edwindj/validatedb/actions)
<!-- [![Codecov test -->
<!-- coverage](https://codecov.io/gh/data-cleaning/validatedb/branch/master/graph/badge.svg)](https://codecov.io/gh/data-cleaning/validatedb?branch=master) -->
<!-- badges: end -->

`validatedb` executes validation checks written with R package
`validate` on a database. This allows for checking the validity of
records in a database.

## Installation

You can install a development version with

<!-- You can install the released version of validatedb from [CRAN](https://CRAN.R-project.org) with: -->

``` r
remotes::install_github("data-cleaning/validatedb")
```

## Example

``` r
library(validatedb)
#> Loading required package: validate
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
tbl_income <- tbl(con, "income")
print(tbl_income)
#> # Source:   table<income> [?? x 2]
#> # Database: sqlite 3.34.1 []
#>     age salary
#>   <dbl>  <dbl>
#> 1    12   1000
#> 2    35     NA
```

Let’s define a rule set and confront the table with it:

``` r
rules <- validator( is_adult   = age >= 18
                  , has_income = salary > 0
                  , mean_age   = mean(age,na.rm=TRUE) > 24
                  )

# and confront!
cf <- confront(tbl_income, rules)

print(cf)
#> Object of class 'tbl_validation'
#> Call:
#>     confront.tbl_sql(tbl = dat, x = x, ref = ref, key = key, sparse = sparse)
#> 
#> Confrontations: 3
#> Tbl           : income ()
#> Sparse        : FALSE
#> Fails         : [??] (see `values`, `summary`)
#> Errors        : 0

summary(cf)
#>         name items npass nfail nNA warning error                   expression
#> 1   is_adult     2     1     1   0   FALSE FALSE         (age - 18) >= -1e-08
#> 2 has_income     2     1     0   1   FALSE FALSE                   salary > 0
#> 3   mean_age     1     0     1   0   FALSE FALSE mean(age, na.rm = TRUE) > 24
```

Values (i.e. validations on the table) can be retrieved like in
`validate` with `type="matrix"` or `type="list"`

``` r
values(cf, type = "matrix")
#> [[1]]
#>      is_adult has_income
#> [1,]    FALSE       TRUE
#> [2,]     TRUE         NA
#> 
#> [[2]]
#>      mean_age
#> [1,]    FALSE
```

But often this seems more handy:

``` r
values(cf, type = "tbl")
#> # Source:   lazy query [?? x 3]
#> # Database: sqlite 3.34.1 []
#>   is_adult has_income mean_age
#>      <int>      <int>    <int>
#> 1        0          1        0
#> 2        1         NA        0
```

We can see the sql code by using `show_query`:

``` r
show_query(cf)
#> <SQL>
#> SELECT (`age` - 18.0) >= -1e-08 AS `is_adult`, `salary` > 0.0 AS `has_income`, AVG(`age`) OVER () > 24.0 AS `mean_age`
#> FROM `income`
```

### Aggregate example

``` r
income <- data.frame(id = 1:2, age=c(12,35), salary = c(1000,NA))
con <- dbplyr::src_memdb()
tbl_income <- dplyr::copy_to(con, income, overwrite=TRUE)
print(tbl_income)
#> # Source:   table<income> [?? x 3]
#> # Database: sqlite 3.34.1 [:memory:]
#>      id   age salary
#>   <int> <dbl>  <dbl>
#> 1     1    12   1000
#> 2     2    35     NA

# Let's define a rule set and confront the table with it:
rules <- validator( is_adult   = age >= 18
                    , has_income = salary > 0
)

# and confront!
# in general with a db table it is handy to use a key
cf <- confront(tbl_income, rules, key="id")
aggregate(cf, by = "rule")
#> # Source:   lazy query [?? x 4]
#> # Database: sqlite 3.34.1 [:memory:]
#>   rule       npass nfail   nNA
#>   <chr>      <int> <int> <int>
#> 1 is_adult       1     1     0
#> 2 has_income     1     0     1
aggregate(cf, by = "record")
#> # Source:   lazy query [?? x 3]
#> # Database: sqlite 3.34.1 [:memory:]
#>      id nfails   nNA
#>   <int>  <dbl> <dbl>
#> 1     1      1     0
#> 2     2      0     1

# to tweak performance of the db query the following options are available
# 1) store validation result in db
cf <- confront(tbl_income, rules, key="id", compute = TRUE)
# or identical
cf <- confront(tbl_income, rules, key="id")
cf <- compute(cf)

# 2) Store the validation sparsely
cf <- confront(tbl_income, rules, key="id", sparse=TRUE )

show_query(compute(cf))
#> <SQL>
#> SELECT *
#> FROM `dbplyr_005`
values(cf, type="tbl")
#> # Source:   table<dbplyr_005> [?? x 3]
#> # Database: sqlite 3.34.1 [:memory:]
#>      id rule        fail
#>   <int> <chr>      <int>
#> 1     1 is_adult       1
#> 2     2 has_income    NA
```
