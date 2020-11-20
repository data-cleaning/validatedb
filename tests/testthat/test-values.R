describe("values", {
  it("returns a list of values",{
    rules <- validator( a %in% c("A1", "A2")
                      , b %in% c("B1", "B2")
                      , mean(x, na.rm=TRUE) > 0
    )
    con <- dbplyr::src_memdb()
    
    d <- data.frame(a = c("A1", "A3", NA), b = c("B3", NA, "B2"), x = 0)
    tbl_d <- dplyr::copy_to(con, d, overwrite=TRUE)
    cf <- confront(tbl_d, rules)
    res <- values(cf, type = "list", simplify=FALSE)
    expect_true(is.list(res))
    expect_equal(res, list( V1 = c(TRUE, FALSE,NA)
                          , V2 = c(FALSE, NA, TRUE)
                          , V3 = FALSE
                          )
                )
  })
  
  it("simplifies...", {
    rules <- validator( a %in% c("A1", "A2")
                        , b %in% c("B1", "B2")
    )
    
    con <- dbplyr::src_memdb()
    
    d <- data.frame(a = c("A1", "A3", NA), b = c("B3", NA, "B2"))
    tbl_d <- dplyr::copy_to(con, d, overwrite=TRUE)
    cf <- confront(tbl_d, rules)
    res <- values(cf, type = "list", simplify=TRUE)
    expect_true(is.matrix(res))
    expect_equal(res[,1], c(TRUE, FALSE,NA))
    expect_equal(res[,2],  c(FALSE, NA, TRUE))
  })
  
  it("returns a tbl of values",{
    
    rules <- validator( a %in% c("A1", "A2")
                        , b %in% c("B1", "B2")
    )
    
    con <- dbplyr::src_memdb()
    d <- data.frame(a = c("A1", "A3", NA), b = c("B3", NA, "B2"))
    tbl_d <- dplyr::copy_to(con, d, overwrite=TRUE)
    
    cf <- confront(tbl_d, rules)
    res <- values(cf, type = "tbl")
    
    expect_true(inherits(res, "tbl_sql"))
    res_df <- as.data.frame(res)
    expect_equal(res_df, data.frame(V1 = c(1,0,NA), V2 = c(0,NA,1)))
  })
  
  it("returns a data.frame of values",{
    
    rules <- validator( a %in% c("A1", "A2")
                        , b %in% c("B1", "B2")
    )
    
    con <- dbplyr::src_memdb()
    d <- data.frame(a = c("A1", "A3", NA), b = c("B3", NA, "B2"))
    tbl_d <- dplyr::copy_to(con, d, overwrite=TRUE)
    
    cf <- confront(tbl_d, rules)
    res <- values(cf, type = "data.frame")
    
    expect_true(is.data.frame(res))
    expect_equal(res, data.frame(V1 = c(TRUE,FALSE,NA), V2 = c(FALSE,NA,TRUE)))
  })
  
  it("returns a matrix...", {
    rules <- validator( a %in% c("A1", "A2")
                        , b %in% c("B1", "B2")
    )
    
    con <- dbplyr::src_memdb()
    
    d <- data.frame(a = c("A1", "A3", NA), b = c("B3", NA, "B2"))
    tbl_d <- dplyr::copy_to(con, d, overwrite=TRUE)
    cf <- confront(tbl_d, rules)
    res <- values(cf, type = "matrix")
    expect_true(is.matrix(res))
    expect_equal(res[,1], c(TRUE, FALSE,NA))
    expect_equal(res[,2],  c(FALSE, NA, TRUE))
  })
  
  it("returns identical result as validate",{
    rules <- validator( a %in% c("A1", "A2")
                        , b %in% c("B1", "B2")
                        , mean(x, na.rm=TRUE) > 0
    )
    con <- dbplyr::src_memdb()
    
    d <- data.frame(a = c("A1", "A3", NA), b = c("B3", NA, "B2"), x = 0)
    tbl_d <- dplyr::copy_to(con, d, overwrite=TRUE)
    cf <- confront(tbl_d, rules)
    cf_df <- confront(d, rules)
    
    res <- values(cf, type = "matrix")
    res_df <- values(cf_df, simplify=TRUE)
    expect_equal(res, res_df)
    
    res <- values(cf, type = "list")
    res_df <- values(cf_df, simplify=FALSE)
    expect_equal(res, res_df)
  })
  
  it("returns identical results as validate with key set",{
    rules <- validator( a %in% c("A1", "A2")
                        , b %in% c("B1", "B2")
                        , mean(x, na.rm=TRUE) > 0
    )
    con <- dbplyr::src_memdb()
    
    d <- data.frame( a = c("A1", "A3", NA)
                   , b = c("B3", NA, "B2")
                   , x = 0
                   , id = letters[1:3]
                   )
    tbl_d <- dplyr::copy_to(con, d, overwrite=TRUE)
    cf <- confront(tbl_d, rules, key="id")
    cf_df <- confront(d, rules, key="id")
    
    res <- values(cf, type = "matrix")
    res_df <- values(cf_df, simplify=TRUE)
    expect_equal(res, res_df)
    
    res <- values(cf, type = "list")
    res_df <- values(cf_df, simplify=FALSE)
    expect_equal(res, res_df)
  })
  
  
  
})