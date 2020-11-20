describe("summary", {
  it("works on a simple case", {
    rules <- validator(x > 1, y < x, x == 0)
    con <- dbplyr::src_memdb()
    
    d <- data.frame(x = c(NA,0,3), y = 2)
    tbl_d <- dplyr::copy_to(con, d, overwrite=TRUE)
    cf <- confront(tbl_d, rules)
    s <- summary(cf)
    expect_known_value(s, "summary1.rds")
  })
  
  it("works with failing rules",{
    
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
    expect_warning(cf <- confront(tbl_income, rules))

    res <- summary(cf)
    expect_true(is.data.frame(res))
    expect_equal(res$error, c(FALSE, FALSE, FALSE, TRUE, TRUE))
    expect_known_value(res, "summary2.rds")
  })
  
  it("works on a sparse confrontation", {
    rules <- validator(x > 1, y < x, x == 0)
    con <- dbplyr::src_memdb()
    
    d <- data.frame(x = c(NA,0,3), y = 2)
    tbl_d <- dplyr::copy_to(con, d, overwrite=TRUE)
    cf <- confront(tbl_d, rules, sparse=TRUE)
    s <- summary(cf)
    # same as not sparse one
    expect_known_value(s, "summary1.rds")
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
    expect_warning(cf <- confront(tbl_income, rules, sparse=TRUE))
    
    res <- summary(cf)
    expect_true(is.data.frame(res))
    expect_equal(res$error, c(FALSE, FALSE, FALSE, TRUE, TRUE))
    expect_known_value(res, "summary2.rds")
  })
  
  
})