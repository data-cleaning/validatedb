# as.data.frame.tbl_validation <- function(x, row.names = NULL, optional = FALSE, ...){
#   as.data.frame(x$query)
# }
#' Retrieve validation results as a data.frame
#' 
#' Retrieve validation results as a data.frame
#' @include tbl_validation.R
#' @param x [tbl_validation()], result of a `confront()` of `tbl` with a rule set.
#' @param row.names ignored
#' @param optional ignored
#' @param ... ignored
#' @example ./example/as-data-frame.R
#' @return `data.frame`, result of the query on the database.
#' @export
as.data.frame.tbl_validation <- function( x
                                        , row.names = NULL
                                        , optional = FALSE, ...){
  values(x, type="data.frame")
}