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
})