describe("is_record_based",{
  it("works on record_based stuff",{
    rules <- validator( x > 1 , mean(x, na.rm=TRUE) > 2)
    con <- dbplyr::src_memdb()
    d <- data.frame(x = 0:10)
    tbl_d <- dplyr::copy_to(con, d, overwrite=TRUE)
    rb <- is_record_based(tbl_d, rules)
    expect_equal(rb, c(V1=TRUE, V2=FALSE))
  })
})