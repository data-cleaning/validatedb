#' Show generated sql code
#' 
#' Shows the generated sql code for the validation of the tbl.
#' @param x [tbl_validation()] object, result of a [confront.tbl_sql()].
#' @param ... passed through.
#' @param sparse `logical` if `FALSE` the query will be a dense query. 
#' @return Same result as [dplyr::show_query], i.e. the SQL text of the query.
#' @importFrom dplyr show_query
#' @export
show_query.tbl_validation <- function(x, ..., sparse=x$sparse){
  qry <- if (isTRUE(sparse)){
    x$query
  } else {
    unsparse(x$query)
  }
  dplyr::show_query(qry, ...)
}

#'@importFrom dplyr show_query
#'@export
dplyr::show_query