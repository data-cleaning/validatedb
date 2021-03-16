#' @importFrom dplyr compute
#' @export
dplyr::compute

#' Store the validation result in the db
#' 
#' Stores the validation result in the db using
#' the [dplyr::compute()] of the db back-end.
#' This method changes the `tbl_validation` object!
#' Note that for most back-ends the default setting is 
#' a temporary table with a random name.
#' @param x [tbl_validation()], result of a `confront()` of `tbl` with a rule set.
#' @param name optional, when omitted, a random name is used.
#' @param ... passed through to `compute` on `x$query`
#' @family tbl_validation
#' @return A [dbplyr::tbl_dbi()] object that refers to the computed (temporary)
#' table in the database. See [dplyr::compute()].
#' @export
compute.tbl_validation <- function(x, name, ...){
  x$query <- 
    if (missing(name)){
      compute(x$query, ...)
    } else {
      compute(x$query, name = name, ...)
    }
  x$query
}
