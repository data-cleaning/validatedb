describe("unsparse", {
  tbl <- dbplyr::memdb_frame(id = letters[1:2], x = 1:2, y = 2)
  rules <- validator( r1 = x < 2
                    , r2 = y > 3
                    )
  
  it("makes a sparse set dense",{
    cf_sparse <- confront(tbl, rules, key="id", sparse=TRUE)
    unsparse(cf_sparse)
  })
})
