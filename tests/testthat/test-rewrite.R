describe("rewrite", {
  library(dplyr)
  tbl <- dbplyr::memdb_frame(age = c(10,12,11), name = letters[c(1,1,2)])
  df <- as.data.frame(tbl)
  
  it("rewrites is_unique", {
    e <- quote(is_unique(age, name))
    l <- rewrite(tbl, e, n = 2)
    
    tab <- as.data.frame(l$tbl)
    expect_true(all(tab$.n2 == 1))
    expect_equal(names(tab), c("age", "name", ".n2"))
    
    expect_equal(l$e, quote(.n2 == 1L))
    expect_equal(l$n, 3L)
    
    e <- quote(is_unique(name))
    l <- rewrite(tbl, e, n = 4)
    
    tab <- as.data.frame(l$tbl)
    expect_equal(tab$.n4, c(2,2,1))
    expect_equal(names(tab), c("age", "name", ".n4"))
    
    expect_equal(l$e, quote(.n4 == 1L))
    expect_equal(l$n, 5L)
  })
  
  it("rewrites all_unique", {
    e <- quote(all_unique(age, name))
    l <- rewrite(tbl, e, n = 2)
    
    tab <- as.data.frame(l$tbl)
    expect_equal(tab$.n2, c(1L, 1L, 1L))
    expect_equal(l$e, quote(.n2 == 1L))
    expect_equal(l$n, 3L)
    
    e <- quote(all_unique(name))
    l <- rewrite(tbl, e, n = 2)
    
    tab <- as.data.frame(l$tbl)
    expect_equal(tab$.n2, c(2,2,2))
    expect_equal(l$e, quote(.n2 == 1L))
    expect_equal(l$n, 3L)
  })
  
  it("rewrites mean_by", {
    e <- quote(mean_by(age, name, na.rm=TRUE) > 10)
    l <- rewrite(tbl, e, n = 2L)
    
    tab <- as.data.frame(l$tbl)
    expect_equal(names(tab), c("age", "name", ".n2"))
    expect_equal(nrow(tab), 3)
    expect_true(all(tab$.n2 == 11))
    expect_equal(l$e, quote(.n2 > 10))
    expect_equal(l$n, 3L)
  })
  
  it("rewrites exists_any",{
    e <- quote(exists_any(age > 11, by=name))
    l <- rewrite(tbl, e, n = 2L)
    
    tab <- as.data.frame(l$tbl)
    expect_equal(names(tab), c("age", "name", ".n2"))
    expect_equal(nrow(tab), 3)
    expect_equal(tab$.n2, c(1L, 1L, 0L))
    expect_equal(l$e, quote(.n2 >= 1L))
    expect_equal(l$n, 3L)
    
    
    dd <- dbplyr::memdb_frame(
      hhid   = c(1,  1,  2,  1,  2,  2,  3 )
      , person = c(1,  2,  3,  4,  5,  6,  7 )
      , hhrole = c("h","h","m","m","h","m","m")
    )
    e <- quote(exists_one(hhrole=="h", hhid))
    l <- rewrite(dd, e, n = 5)
  })
  
  it("rewrites is_complete",{
    e <- quote(is_complete(sector, size))
    l <- rewrite(tbl, e, n = 3)
    
    tab <- as.data.frame(l$tbl)
    expect_equal(df, tab)
    expect_equal(l$e, quote(!(is.na(sector) | is.na(size))))
    expect_equal(l$n, 3L)
  })
  
  it("rewrites all_complete",{
    e <- quote(all_complete(sector, size))
    l <- rewrite(tbl, e, n = 3)
    
    tab <- as.data.frame(l$tbl)
    expect_equal(df, tab)
    expect_equal(l$e, quote(max(is.na(sector) | is.na(size), na.rm=TRUE) < 1L))
  })
  
})
