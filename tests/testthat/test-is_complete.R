describe("is_complete",{
  tbl <- dbplyr::memdb_frame( id = letters[1:3]
                            , age = c(NA, 12,20)
                            , child= c(FALSE, NA, TRUE)
                            )
  df <- as.data.frame(tbl)

  it("works with is_complete", {
    rules <- validator(r1 = is_complete(age, child), r2 = is_complete(id))
    cf <- confront(tbl, rules, key = "id", sparse=TRUE)
    cf_df <- confront(df, rules, key = "id")
    values(cf_df)
  })
})
