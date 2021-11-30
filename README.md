
<!-- README.md is generated from README.Rmd. Please edit that file -->

# validatedb

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/validatedb)](https://CRAN.R-project.org/package=validatedb)
[![R build
status](https://github.com/data-cleaning/validatedb/workflows/R-CMD-check/badge.svg)](https://github.com/data-cleaning/validatedb/actions)
[![Codecov test
coverage](https://codecov.io/gh/data-cleaning/validatedb/branch/master/graph/badge.svg)](https://codecov.io/gh/data-cleaning/validatedb?branch=master)
[![Mentioned in Awesome Official
Statistics](https://awesome.re/mentioned-badge.svg)](http://www.awesomeofficialstatistics.org)
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
income <- data.frame(id=1:2, age=c(12,35), salary = c(1000,NA))
con <- DBI::dbConnect(RSQLite::SQLite())
DBI::dbWriteTable(con, "income", income)
```

We retrieve a reference/handle to the table in the DB with `dplyr`

``` r
tbl_income <- tbl(con, "income")
print(tbl_income)
#> # Source:   table<income> [?? x 3]
#> # Database: sqlite 3.35.5 []
#>      id   age salary
#>   <int> <dbl>  <dbl>
#> 1     1    12   1000
#> 2     2    35     NA
```

Let’s define a rule set and confront the table with it:

``` r
rules <- validator( is_adult   = age >= 18
                  , has_income = salary > 0
                  , mean_age   = mean(age,na.rm=TRUE) > 24
                  )

# and confront!
cf <- confront(tbl_income, rules, key = "id")

print(cf)
#> Object of class 'tbl_validation'
#> Call:
#>     confront.tbl_sql(tbl = dat, x = x, ref = ref, key = key, sparse = sparse)
#> 
#> Confrontations: 3
#> Tbl           : income ()
#> Key column    : id
#> Sparse        : FALSE
#> Fails         : [??] (see `values`, `summary`)
#> Errors        : 0

summary(cf)
#>                  name items npass nfail nNA warning error
#> is_adult     is_adult     2     1     1   0   FALSE FALSE
#> has_income has_income     2     1     0   1   FALSE FALSE
#> mean_age     mean_age     1     0     1   0   FALSE FALSE
#>                              expression
#> is_adult             age - 18 >= -1e-08
#> has_income                   salary > 0
#> mean_age   mean(age, na.rm = TRUE) > 24
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
#> # Source:   lazy query [?? x 4]
#> # Database: sqlite 3.35.5 []
#>      id is_adult has_income mean_age
#>   <int>    <int>      <int>    <int>
#> 1     1        0          1        0
#> 2     2        1         NA        0
```

or

``` r
values(cf, type = "tbl", sparse=TRUE)
#> # Source:   lazy query [?? x 3]
#> # Database: sqlite 3.35.5 []
#>      id rule        fail
#>   <int> <chr>      <int>
#> 1     1 is_adult       1
#> 2     2 has_income    NA
#> 3     1 mean_age       1
#> 4     2 mean_age       1
```

We can see the sql code by using `show_query`:

``` r
show_query(cf)
#> <SQL>
#> SELECT `id`, NULLIF(MIN(`is_adult`), -1) AS `is_adult`, NULLIF(MIN(`has_income`), -1) AS `has_income`, NULLIF(MIN(`mean_age`), -1) AS `mean_age`
#> FROM (SELECT `id`, CASE `rule` WHEN ('is_adult') THEN (COALESCE(NOT(`fail`), -1)) ELSE (1) END AS `is_adult`, CASE `rule` WHEN ('has_income') THEN (COALESCE(NOT(`fail`), -1)) ELSE (1) END AS `has_income`, CASE `rule` WHEN ('mean_age') THEN (COALESCE(NOT(`fail`), -1)) ELSE (1) END AS `mean_age`
#> FROM (SELECT `LHS`.`id` AS `id`, `rule`, `fail`
#> FROM (SELECT `id`
#> FROM `income`) AS `LHS`
#> LEFT JOIN (SELECT `id`, 'is_adult' AS `rule`, 1 AS `fail`
#> FROM (SELECT `id`, `age`
#> FROM `income`)
#> WHERE (`age` - 18.0 < -1e-08)
#> UNION ALL
#> SELECT `id`, 'is_adult' AS `rule`, NULL AS `fail`
#> FROM (SELECT `id`, `age`
#> FROM `income`)
#> WHERE (((`age`) IS NULL))
#> UNION ALL
#> SELECT `id`, 'has_income' AS `rule`, 1 AS `fail`
#> FROM (SELECT `id`, `salary`
#> FROM `income`)
#> WHERE (`salary` <= 0.0)
#> UNION ALL
#> SELECT `id`, 'has_income' AS `rule`, NULL AS `fail`
#> FROM (SELECT `id`, `salary`
#> FROM `income`)
#> WHERE (((`salary`) IS NULL))
#> UNION ALL
#> SELECT `id`, 'mean_age' AS `rule`, 1 AS `fail`
#> FROM (SELECT `id`, `age`
#> FROM (SELECT `id`, `age`, AVG(`age`) OVER () AS `q01`
#> FROM (SELECT `id`, `age`
#> FROM `income`))
#> WHERE (`q01` <= 24.0))
#> UNION ALL
#> SELECT `id`, 'mean_age' AS `rule`, NULL AS `fail`
#> FROM (SELECT `id`, `age`
#> FROM `income`)
#> WHERE (((`age`) IS NULL))) AS `RHS`
#> ON (`LHS`.`id` = `RHS`.`id`)
#> ))
#> GROUP BY `id`
```

Or write the sql to a file for documentation (and inspiration)

``` r
dump_sql(cf, "validation.sql")
```

``` sql
------------------------------------------------------------
-- Do not edit, automatically generated with R package validatedb.
-- validatedb: 0.3.0.9001
-- validate: 1.1.0
-- R version 4.1.2 (2021-11-01)
-- Database: '', Table: 'income'
-- Date: 2021-11-30
------------------------------------------------------------

--------------------------------------
--  is_adult:  
--  validation rule:  age >= 18

SELECT `id`, 'is_adult' AS `rule`, 1 AS `fail`
FROM (SELECT `id`, `age`
FROM `income`)
WHERE (`age` - 18.0 < -1e-08)
UNION ALL
SELECT `id`, 'is_adult' AS `rule`, NULL AS `fail`
FROM (SELECT `id`, `age`
FROM `income`)
WHERE (((`age`) IS NULL))

--------------------------------------

UNION ALL

--------------------------------------
--  has_income:  
--  validation rule:  salary > 0

SELECT `id`, 'has_income' AS `rule`, 1 AS `fail`
FROM (SELECT `id`, `salary`
FROM `income`)
WHERE (`salary` <= 0.0)
UNION ALL
SELECT `id`, 'has_income' AS `rule`, NULL AS `fail`
FROM (SELECT `id`, `salary`
FROM `income`)
WHERE (((`salary`) IS NULL))

--------------------------------------

UNION ALL

--------------------------------------
--  mean_age:  
--  validation rule:  mean(age, na.rm = TRUE) > 24

SELECT `id`, 'mean_age' AS `rule`, 1 AS `fail`
FROM (SELECT `id`, `age`
FROM (SELECT `id`, `age`, AVG(`age`) OVER () AS `q01`
FROM (SELECT `id`, `age`
FROM `income`))
WHERE (`q01` <= 24.0))
UNION ALL
SELECT `id`, 'mean_age' AS `rule`, NULL AS `fail`
FROM (SELECT `id`, `age`
FROM `income`)
WHERE (((`age`) IS NULL))

--------------------------------------
```

### Aggregate example

``` r
income <- data.frame(id = 1:2, age=c(12,35), salary = c(1000,NA))
con <- dbplyr::src_memdb()
tbl_income <- dplyr::copy_to(con, income, overwrite=TRUE)
print(tbl_income)
#> # Source:   table<income> [?? x 3]
#> # Database: sqlite 3.35.5 [:memory:]
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
#> # Source:   lazy query [?? x 7]
#> # Database: sqlite 3.35.5 [:memory:]
#>   rule       npass nfail   nNA rel.pass rel.fail rel.NA
#>   <chr>      <int> <int> <int> <lgl>       <dbl>  <dbl>
#> 1 is_adult       1     1     0 NA            0.5    0  
#> 2 has_income     1     0     1 NA            0      0.5
aggregate(cf, by = "record")
#> # Source:   lazy query [?? x 3]
#> # Database: sqlite 3.35.5 [:memory:]
#>      id nfails   nNA
#>   <int>  <int> <int>
#> 1     1      1     0
#> 2     2      0     1

# to tweak performance of the db query the following options are available
# 1) store validation result in db
cf <- confront(tbl_income, rules, key="id", compute = TRUE)
# or identical
cf <- confront(tbl_income, rules, key="id")
cf <- compute(cf)

# 2) Store the validation sparsely
cf_sparse <- confront(tbl_income, rules, key="id", sparse=TRUE )

show_query(cf_sparse)
#> <SQL>
#> SELECT `id`, 'is_adult' AS `rule`, 1 AS `fail`
#> FROM (SELECT `id`, `age`
#> FROM `income`)
#> WHERE (`age` - 18.0 < -1e-08)
#> UNION ALL
#> SELECT `id`, 'is_adult' AS `rule`, NULL AS `fail`
#> FROM (SELECT `id`, `age`
#> FROM `income`)
#> WHERE (((`age`) IS NULL))
#> UNION ALL
#> SELECT `id`, 'has_income' AS `rule`, 1 AS `fail`
#> FROM (SELECT `id`, `salary`
#> FROM `income`)
#> WHERE (`salary` <= 0.0)
#> UNION ALL
#> SELECT `id`, 'has_income' AS `rule`, NULL AS `fail`
#> FROM (SELECT `id`, `salary`
#> FROM `income`)
#> WHERE (((`salary`) IS NULL))
values(cf_sparse, type="tbl")
#> # Source:   lazy query [?? x 3]
#> # Database: sqlite 3.35.5 [:memory:]
#>      id rule        fail
#>   <int> <chr>      <int>
#> 1     1 is_adult       1
#> 2     2 has_income    NA
```

## TODO

-   [x] `is_complete`, `all_complete`
-   [x] `is_unique`, `all_unique`
-   [x] `exists_any`, `exists_one`
-   [x] `do_by`, `sum_by`, `mean_by`, `min_by`, `max_by`

Some newly added `validate` utility functions are (still) missing from
`validatedb`.

-   [ ] `contains_exactly`
-   [ ] `is_linear_sequence`
-   [ ] `hierachy`
