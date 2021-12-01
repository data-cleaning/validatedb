describe("is_complete",{
  tbl <- dbplyr::memdb_frame( id = letters[1:3]
                            , age = c(NA, 12,20)
                            , child= c(FALSE, NA, TRUE)
                            )
  df <- as.data.frame(tbl)

  it("works with is_complete single column", {
    rules <- validator( r1  = is_complete(id))
    cf <- confront(tbl, rules, key = "id")
    cf_df <- confront(df, rules, key = "id")
    m <- values(cf, type="matrix")
    m_df <- values(cf_df)
    expect_equal(m,m_df)
  })
  
  it("works with is_complete", {
    rules <- validator( r1  = is_complete(age, child)
    )
    cf <- confront(tbl, rules, key = "id")
    cf_df <- confront(df, rules, key = "id")
    m <- values(cf, type="matrix")
    m_df <- values(cf_df)
    expect_equal(m,m_df)
  })
  
  it("works with is_complete", {
    rules <- validator( r1  = is_complete(age, child)
                      , r2 = is_complete(id)
                      )
    cf <- confront(tbl, rules, key = "id")
    cf_df <- confront(df, rules, key = "id")
    m <- values(cf, type="matrix")
    m_df <- values(cf_df)
    expect_equal(m,m_df)
  })
  
  
})
