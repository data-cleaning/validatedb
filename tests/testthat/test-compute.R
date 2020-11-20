test_that("multiplication works", {
  rules <- validator( a %in% c("A1", "A2")
                      , b %in% c("B1", "B2")
                      , mean(x, na.rm=TRUE) > 0
  )
  con <- dbplyr::src_memdb()
  
  d <- data.frame( a = c("A1", "A3", NA)
                   , b = c("B3", NA, "B2")
                   , x = 0
                   , id = letters[1:3]
  )
  tbl_d <- dplyr::copy_to(con, d, overwrite=TRUE)
  cf <- confront(tbl_d, rules, key="id")
  df <- as.data.frame(cf$query)
  compute(cf, name="result")
  
  con <- unclass(tbl_d)$src$con
  in_db <- as.data.frame(tbl(con, "result"))
  expect_equal(df, in_db)
})
