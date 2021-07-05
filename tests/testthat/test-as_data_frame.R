describe("as.data.frame", {
  it("returns a data.frame of values",{
    
    rules <- validator( a %in% c("A1", "A2")
                        , b %in% c("B1", "B2")
    )
    
    con <- dbplyr::src_memdb()
    d <- data.frame(a = c("A1", "A3", NA), b = c("B3", NA, "B2"))
    tbl_d <- dplyr::copy_to(con, d, overwrite=TRUE)
    
    cf <- confront(tbl_d, rules)
    res <- as.data.frame(cf)

    expect_true(is.data.frame(res))
    expect_equal(res, data.frame(V1 = c(TRUE,FALSE,NA), V2 = c(FALSE,NA,TRUE)))
  })
})