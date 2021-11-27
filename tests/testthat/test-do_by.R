describe("do_by",{
  tbl <- dbplyr::memdb_frame( id  = letters[c(1,1,2)]
                            , age = c(14, 18, 11)
                            )
  df <- as.data.frame(tbl)
  
  it("works with mean_by",{
    rules <- validator(mean_by(age, id) > 12)
    cf <- confront(tbl, rules, key = "id", sparse=TRUE)
    unsparse(cf)
  })
})
