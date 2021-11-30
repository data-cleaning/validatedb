#' tests for each rule if it can be executed on the database
#' 
#' tests for each rule if it can be executed on the database
#' @param tbl a `tbl` object with columns used in `x`
#' @param x a [validate::validator()] object
#' @param key `character` names of columns that identify a record
#' @param show_errors if `TRUE` errors on the database are printed.
#' @return `logical` encoding which validation rules "work" on the database.
#' @importFrom utils head
rule_works_on_tbl <- function(tbl, x, key = NULL, show_errors = FALSE){
  res <- confront_tbl_sparse(head(tbl), x, key = key, union_all = FALSE, check_rules = FALSE)
  # TODO extract information on the error...
  sapply(names(res$queries), function(n){
    qry <- res$queries[[n]]
    works <- FALSE
    try({
      if (show_errors) {
        message("\nTesting rule: '", n, ": ",deparse(res$expr[[n]]),"'...")
        detect_integer(res$expr[[n]])
      }
      dplyr::collect(head(qry))
      works <- TRUE
      if (show_errors) {
        message("...works!")
      }
    }, silent = !show_errors)
    works
  })
}
