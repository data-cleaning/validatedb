describe("aggregate", {
  tbl <- dbplyr::memdb_frame(id = 1:3, x = c(NA, 0, 3), y = 2, z = c(NA, NA, 2))
  df <- as.data.frame(tbl)
  
  it("works by rule",{
    rules <- validator( r1 = x > 1
                      , r2 = y < x
                      , r3 = x == 0
                      , r4 = y > 1
                      , r5 = y > 2
                      , r6 = z > 2
                      )
    cf <- confront(tbl, rules, key = "id", sparse=TRUE)
    a <- aggregate(cf, by = "rule")
    a_df <- as.data.frame(a)
  
    expect_equal(names(a_df), c( "rule", "npass", "nfail", "nNA"
                               , "rel.pass", "rel.fail", "rel.NA"
                               ))
    expect_equal(nrow(a_df), length(rules))
  })
  
  it ("work by record / key",{
    rules <- validator( r1 = x > 1
                        , r2 = y < x
                        , r3 = x == 0
                        , r4 = y > 1
                        , r5 = y > 2
                        , r6 = z > 2
    )
    cf <- confront(tbl, rules, key = "id")
    cf_df <- confront(df, rules, key = "id")
    
    agg <- aggregate(cf, by = "record")
    agg_df <- validate::aggregate(cf_df, by = "record")
    
  })
})
