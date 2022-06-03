describe("Confront", {
  tbl <- dbplyr::memdb_frame(id = letters[1:2], x = 1:2)
  df <- as.data.frame(tbl)
  
  it("returns a validation object", {
    rules <- validator(x > 1, y < x, x == 0)
    con <- dbplyr::src_memdb()
    
    d <- data.frame(id = 1, x = 1, y = 2)
    tbl_d <- dplyr::copy_to(con, d, overwrite=TRUE)
    cf <- confront(tbl_d, rules, key = "id")
    #expect_true(is(cf, "validation"))
    expect_true(is(cf, "tbl_validation"))
  })
  
  it("handles linear constraints", {
    rules <- validator(x > 1, y < x, y == 2)
    con <- dbplyr::src_memdb()
    
    d <- data.frame(id = 1:2, x = c(2, NA), y = 2:1)
    tbl_d <- dplyr::copy_to(con, d, overwrite=TRUE)
    cf <- confront(tbl_d, rules, key = "id")
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
    
    d <- data.frame(id = 1:3, a = c("A1", "A3", NA), b = c("B3", NA, "B2"))
    tbl_d <- dplyr::copy_to(con, d, overwrite=TRUE)
    cf <- confront(tbl_d, rules, key = "id")
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
    
    d <- data.frame(id=1:3, a = c("A1", "A3", NA), b = c("B3", NA, "B2"), x = c(NA, 1,-1))
    tbl_d <- dplyr::copy_to(con, d, overwrite=TRUE)
    cf <- confront(tbl_d, rules, key = "id")
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
    
    d <- data.frame(id = letters[1:3], x=c(NA, 1, -1))
    tbl_d <- dplyr::copy_to(con, d, overwrite=TRUE)
    expect_warning(cf <- confront(tbl_d, rules, key = "id"))
    res <- values(cf, type = "list", simplify=FALSE)
    expect_equal(res, list(
       V1 = NULL,
       V2 = c(NA, TRUE, FALSE),
       V3 = NULL
    ))
    expect_equal(length(cf$errors), 2)
  })
  
  it("handles multiple key columns", {
    rules <- validator(x > 1, y < x, x == 0)
    con <- dbplyr::src_memdb()
    
    d <- data.frame(id1 = 1, id2 = 1, x = 1, y = 2)
    tbl_d <- dplyr::copy_to(con, d, overwrite=TRUE)
    cf <- confront(tbl_d, rules, key = c("id1", "id2"))
    df <- as.data.frame(cf)
    expect_equal(names(df)[1:2], c("id1", "id2"))
    
    cf <- confront(tbl_d, rules, key = c("id1", "id2"), sparse=TRUE)
    df <- as.data.frame(cf)
    expect_equal(names(df)[1:2], c("id1", "id2"))
  })

  it("stops when missing a key column", {
    rules <- validator(x > 1, y < x, x == 0)
    tbl_d <- dbplyr::memdb_frame(id = letters[1], x = 1, y = 2)
    d <- as.data.frame(tbl_d)
    expect_error({
      cf <- confront(tbl_d, rules)
    })
  })
  
  it("stops when missing a specified key column", {
    rules <- validator(x > 1, y < x, x == 0)
    con <- dbplyr::src_memdb()
    
    d <- data.frame(x = 1, y = 2)
    tbl_d <- dplyr::copy_to(con, d, overwrite=TRUE)
    expect_error({
      cf <- confront(tbl_d, rules, key=c("test", "test2"))
    })
  })
  
  it("works with is.na",{
    rules <- validator(r1 = !is.na(x))
    tbl <- dbplyr::memdb_frame(id = letters[1:2], x = c(1,NA))
    cf <- confront(tbl, rules, key = "id")
    v <- values(cf, type="data.frame")
    expect_equal(v$r1, c(TRUE, FALSE))
  })
  
  it("works with a simple rule",{
    rules <- validator(r1 = x + 1 > 0)
    cf <- confront(tbl, rules, key = "id", sparse=TRUE)
    cf_df <- confront(df, rules, key="id")
    v <- values(cf, sparse=FALSE, type="matrix")
    v_df <- values(cf_df)
    expect_equal(v, v_df)
  })
  
  it("works with an if statement", {
    rules <- validator(if (x > 1) id == "a")
    cf <- confront(tbl, rules, key = "id")
    
    vls <- values(cf, type="data.frame")
    expect_equal(vls, data.frame(id = c("a","b"), V1=c(TRUE, FALSE)))
  })
  
})
