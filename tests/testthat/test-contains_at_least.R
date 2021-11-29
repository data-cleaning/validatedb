describe("contains_at_least", {
  tbl <- dbplyr::memdb_frame(id = letters[1:3], cat = LETTERS[c(1,1:2)], z = 1:3)
  df <- as.data.frame(tbl)
  
  it("works with contains_at_least",{
    
    d <- data.frame(cat = c("A"))
    keys <- dplyr::auto_copy(tbl, d, copy=TRUE)
    v <- tbl_vars(keys)
    keys <- dplyr::mutate(keys, .key = n())
    
    d2 <- dplyr::distinct(tbl, !!!{lapply(v, as.symbol)})
    d2 <- dplyr::mutate(d2, .table = n())
    dplyr::full_join(d2, keys, by = v)
    
  })
  
  it("works with contains_at_exactly",{
    d <- data.frame(cat = c("A", "D"))
  })
  
})
