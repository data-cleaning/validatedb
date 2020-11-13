#' Show generated sql code
#' 
#' Shows the generated sql code for the validation of the tbl.
#' @param x [tbl_validation()] object, result of a [confront.tbl_sql()].
#' @param ... passed through.
#' @importFrom dplyr show_query
#' @export
show_query.tbl_validation <- function(x, ...){
  dplyr::show_query(x$query, ...)
}

#'@importFrom dplyr show_query
#'@export
dplyr::show_query