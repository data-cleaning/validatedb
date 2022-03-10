library(validate)

describe("test on duckdb",{
  skip_if_not_installed("duckdb")
  attachNamespace("duckdb")
  
  con_dd <- DBI::dbConnect(duckdb(), dbdir=":memory:")
  con_sqlite  <- DBI::dbConnect(RSQLite::SQLite(), dbname=":memory:")
  
  it("does a simple test", {
    simple <- data.frame(id=1, age = -1)
    simple_dd <- dplyr::copy_to(con_dd, simple, overwrite=TRUE)
    simple_sqlite <- dplyr::copy_to(con_sqlite, simple, overwrite=TRUE)
    
    rules <- validator(age >=0)
    cf_dd <- confront(simple_dd, rules, key = "id", sparse=TRUE)
    cf_sqlite <- confront(simple_sqlite, rules, key = "id", sparse=TRUE)
    
    vls_dd <- values(cf_dd, type="data.frame", sparse=TRUE)
    vls_sqlite <- values(cf_sqlite, type="data.frame", sparse = TRUE)
    expect_equal(vls_dd, vls_sqlite)
    
    vls_dd <- values(cf_dd, type="data.frame", sparse=FALSE)
    vls_sqlite <- values(cf_sqlite, type="data.frame", sparse = FALSE)
    expect_equal(vls_dd, vls_sqlite)
    
  })
  
  it("works on duckdb",{
    income <- data.frame(id=1:2, age=c(12,35), salary = c(1000,NA))
    income_dd <- dplyr::copy_to(con_dd, income)
    income_sqlite <- dplyr::copy_to(con_sqlite, income)
    
    rules <- validator( is_adult   = age >= 18
                        , has_income = salary > 0
                        , mean_age   = mean(age,na.rm=TRUE) > 24
                        , has_values = is_complete(age, salary)
    )
    
    cf <- confront(income_dd, rules, key="id", sparse=TRUE)
    res_dd <- values(cf, type="data.frame")
  
    cf_sqlite <- confront(income_sqlite, rules, key="id", sparse=TRUE)
    res_sqlite <- values(cf_sqlite, type="data.frame")
    
    expect_equal(res_dd, res_sqlite)
  })

})