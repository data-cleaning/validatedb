#' tests for each rule if it can be executed on the database
#' 
#' @param tbl a `tbl` object with columns used in `x`
#' @param x a [validate::validator()] object
rule_works_on_db <- function(tbl, x){
  l <- confront_sparse(head(tbl), x, union_all = F)
  sapply(l, function(qry){
    works <- FALSE
    try({
      collect(head(qry))
      works <- TRUE
    }, silent = TRUE)
    works
  })
}