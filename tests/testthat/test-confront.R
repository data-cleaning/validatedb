describe("Confront", {
  it("returns a validation object", {
    rules <- validator(x > 1, y < x, x == 0)
    con <- dbplyr::src_memdb()
    
    d <- data.frame(x = 1, y = 2)
    tbl_d <- dplyr::copy_to(con, d, overwrite=TRUE)
    cf <- confront(tbl_d, rules)
    #expect_true(is(cf, "validation"))
    expect_true(is(cf, "tbl_validation"))
  })
  
  it("handles linear constraints", {
    rules <- validator(x > 1, y < x, y == 2)
    con <- dbplyr::src_memdb()
    
    d <- data.frame(x = c(2, NA), y = 2:1)
    tbl_d <- dplyr::copy_to(con, d, overwrite=TRUE)
    cf <- confront(tbl_d, rules)
    res <- values(cf, type = "list", simplify=FALSE)
    expect_equal(res, list( V1 = c(TRUE, NA)
                          , V2 = c(FALSE, NA)
                          , V3=c(TRUE, FALSE))
                 )
  })
  
  it("handles categorical constraints", {
    rules <- validator( a %in% c("A1", "A2")
                      , b %in% c("B1", "B2")
                      )
    
    con <- dbplyr::src_memdb()
    
    d <- data.frame(a = c("A1", "A3", NA), b = c("B3", NA, "B2"))
    tbl_d <- dplyr::copy_to(con, d, overwrite=TRUE)
    cf <- confront(tbl_d, rules)
    res <- values(cf, type = "list", simplify=FALSE)
    expect_equal(res, list( V1 = c(TRUE, FALSE,NA)
                          , V2 = c(FALSE, NA, TRUE)
    )
    )
  })
  
  
  it("handles conditional constraints", {
    rules <- validator( a %in% c("A1", "A2")
                      , b %in% c("B1", "B2")
                      , if (a == "A1") b == "B1"
                      , if (b == "B2") x > 0
                      )
    
    con <- dbplyr::src_memdb()
    
    d <- data.frame(a = c("A1", "A3", NA), b = c("B3", NA, "B2"), x = c(NA, 1,-1))
    tbl_d <- dplyr::copy_to(con, d, overwrite=TRUE)
    cf <- confront(tbl_d, rules)
    res <- values(cf, type = "list", simplify=FALSE)
    expect_equal(res, list( V1 = c(TRUE, FALSE,NA)
                          , V2 = c(FALSE, NA, TRUE)
                          , V3 = c(FALSE, NA, NA)
                          , V4 = c(NA, NA, FALSE)
    )
    )
  })
  
  it ("warns on not working rules",{
    f <- function(x){x}
    rules <- validator(f(x) > 0, x > 0, y < 0)
    con <- dbplyr::src_memdb()
    
    d <- data.frame(x=c(NA, 1, -1))
    tbl_d <- dplyr::copy_to(con, d, overwrite=TRUE)
    expect_warning(cf <- confront(tbl_d, rules))
    res <- values(cf, type = "list", simplify=FALSE)
    expect_equal(res, list(
       V1 = NULL,
       V2 = c(NA, TRUE, FALSE),
       V3 = NULL
    ))
    expect_equal(length(cf$errors), 2)
  })
  
})
