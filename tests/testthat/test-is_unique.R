describe("is_unique", {
  tbl <- dbplyr::memdb_frame(id = letters[c(1,1,2)], x = 1:3)
  tab <- as.data.frame(tbl)
  
  it("simple is_unique",{
    
    rules <- validator(is_unique(id,x))
    cf <- confront(tbl, rules, key = "id", sparse=TRUE)
    df <- values(cf, type="data.frame")
    expect_equal(nrow(df), 0L)
    
    rules <- validator(is_unique(id))
    cf <- confront(tbl, rules, key = "id", sparse=TRUE)
    df <- values(cf, type="data.frame")
    expect_equal(nrow(df), 2L)
    expect_equal(df$id, c("a", "a"))
  })
})
