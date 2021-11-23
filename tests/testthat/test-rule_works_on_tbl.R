describe("rule_works_on_tbl", {
  it ("works with numeric checks",{
    con <- dbplyr::src_memdb()
    rules <- validator(x > 1, y < x, x == 0)
    
    d <- data.frame(id=letters[1], x = 1, y = 2)
    #tbl_d <- dplyr::copy_to(con, d, overwrite=TRUE)
    tbl_d <- dbplyr::memdb_frame(id=letters[1], x = 1, y = 2)
    
    res <- rule_works_on_tbl(tbl_d, rules, key = "id")
    expect_equal(res, c(TRUE, TRUE, TRUE))
  })
  
  it ("fails on function not on db",{
    f <- function(x) x
    rules <- validator(x > 1, f(x) > 0)
    con <- dbplyr::src_memdb()
    
    d <- data.frame(id=letters[1], x = 1, y = 2)
    tbl_d <- dplyr::copy_to(con, d, overwrite=TRUE)
    
    res <- rule_works_on_tbl(tbl_d, rules, key = "id")
    expect_equal(res, c(TRUE, FALSE))
  })
})
