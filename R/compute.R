#' @importFrom dplyr compute
#' @export
dplyr::compute

#' Store the result of the validation in the db
#' 
#' Stores the result of the validation in the db using
#' the [dplyr::compute()] of the db back end.
#' This method changes the `tbl_validation` object!
#' Note that for most back ends the default settings are 
#' a temporary table with a random name.
#' @param x `tbl_validation` object
#' @param name optional, when omitted, a random name is used.
#' @param ... passed through to `compute` on `x$query`
#' @family tbl_validation
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
