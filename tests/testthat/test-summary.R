vv <- packageVersion("validate")

describe("summary", {
  it("works on a simple case", {
    rules <- validator(x > 1, y < x, x == 0)
    con <- dbplyr::src_memdb()
    
    d <- data.frame(id=1:3, x = c(NA,0,3), y = 2)
    tbl_d <- dplyr::copy_to(con, d, overwrite=TRUE)
    cf <- confront(tbl_d, rules, key = "id")
    s <- summary(cf)
    skip_on_cran()
    if (vv < "1.1.0"){
      expect_known_value(s, "summary1old.rds")
    } else {
      expect_known_value(s, "summary1.rds")
    }
  })
  
  it("works with non-record rules",{
    tbl <- dbplyr::memdb_frame(id = 1:3, age = c(12, 35, NA))
    rules <- validator( age >= 0)
    cf <- confront(tbl, rules, key = "id", sparse=TRUE)
  })

  it("works with non-record rules",{
    tbl <- dbplyr::memdb_frame(id = 1:3, age = c(12, 35, NA))
    rules <- validator( age > 0, mean(age, na.rm = TRUE) > 20)
    cf <- confront(tbl, rules, key = "id", sparse=TRUE)
  })
  
  it("works with failing rules",{
    
    income <- dbplyr::memdb_frame(id = 1:2, age=c(12,35), salary = c(1000,NA))
    f <- function(x) x
    rules <- validator( is_adult   = age >= 18
                        , has_income = salary > 0
                        , mean(salary, na.rm=TRUE) > 0
                        , f(x) < 0
                        , y > 0
    )
    expect_warning(cf <- confront(income, rules, key = "id"))

    res <- summary(cf)
    expect_true(is.data.frame(res))
    expect_equal(res$error, c(FALSE, FALSE, FALSE, TRUE, TRUE))
    if (vv < "1.1.0"){
      expect_known_value(res, "summary2old.rds")
    } else {
      expect_known_value(res, "summary2.rds")
    }
  })
  
  it("works on a sparse confrontation", {
    rules <- validator(x > 1, y < x, x == 0)
    con <- dbplyr::src_memdb()
    
    d <- data.frame(id = 1:3, x = c(NA,0,3), y = 2)
    tbl_d <- dplyr::copy_to(con, d, overwrite=TRUE)
    cf <- confront(tbl_d, rules, sparse=TRUE, key = "id")
    s <- summary(cf)
    # same as not sparse one
    skip_on_cran()
    if (vv < "1.1.0"){
      expect_known_value(s, "summary1old.rds")
    } else {
      expect_known_value(s, "summary1.rds")
    }
  })
  
  it("works with failing rules (sparse)",{
    
    income <- data.frame(id = 1:2, age=c(12,35), salary = c(1000,NA))
    f <- function(x) x
    rules <- validator( is_adult   = age >= 18
                        , has_income = salary > 0
                        , mean(salary, na.rm=TRUE) > 0
                        , f(x) < 0
                        , y > 0
    )
    con <- dbplyr::src_memdb()
    tbl_income <- dplyr::copy_to(con, income, overwrite=TRUE)
    expect_warning(cf <- confront(tbl_income, rules, key="id", sparse=TRUE))
    
    res <- summary(cf)
    expect_true(is.data.frame(res))
    expect_equal(res$error, c(FALSE, FALSE, FALSE, TRUE, TRUE))
    skip_on_cran()
    if (vv < "1.1.0"){
      expect_known_value(res, "summary2old.rds")
    } else {
      expect_known_value(res, "summary2.rds")
    }
})
  
  
})
