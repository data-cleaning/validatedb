#' tests for each rule if it can be executed on the database
#' 
#' tests for each rule if it can be executed on the database
#' @param tbl a `tbl` object with columns used in `x`
#' @param x a [validate::validator()] object
#' @param key `character` names of columns that identify a record
#' @return `logical` encoding which validation rules "work" on the database.
#' @importFrom utils head
rule_works_on_tbl <- function(tbl, x, key = NULL){
  res <- confront_tbl_sparse(head(tbl), x, key = key, union_all = FALSE, check_rules = FALSE)
  # TODO extract information on the error...
  sapply(res$queries, function(qry){
    works <- FALSE
    try({
      dplyr::collect(head(qry))
      works <- TRUE
    }, silent = TRUE)
    works
  })
}