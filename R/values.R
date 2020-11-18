#' Retrieve the result of a validation/confront
#' 
#' Retrieve the result of a validation/confront
#' @param x object of type `tbl_validation`
#' @param simplify only use when `type` = "list" see `validate::values`
#' @param type whether to return a list/matrix or to return a query on the database.
#' @param ... not used
#' @importFrom validate values
#' @export
#' @family confront
#' @example ./example/confront.R
setMethod("values", signature = c("tbl_validation"), function( x
                                                             , simplify = TRUE
                                                             , type = c("tbl", "list")
                                                             , ...
                                                             ){
  if (missing(type)){
    warning("Please specify 'type' argument. Default setting `type = 'tbl'` ", 
     "returns a query to the database.\nTo retrieve identical results as ",
     "`validate` on a data.frame, use `type = 'list'`.\n",
     call. = FALSE
     )
  }
  type = match.arg(type)
  
  # TODO something with sparse? warn
  if (type == "tbl"){
    return(x$query)
  }
  
  if (x$sparse){
    stop("Not implemented")
  }
  
  val_df <- dplyr::collect(x$query)
  
  # first column is row_number, should also remove key column
  if (length(x$key)){
    val_df <- val_df[-1]
  }
  # to cope with non working rules / missing variables...
  record_based <- x$record_based[names(val_df)]
  if (simplify){
    if (all(record_based)){
      return(val_df > 0)
    }
    return(list(
      val_df[record_based] > 0,
      val_df[1,!record_based] > 0
    ))
  }
  
  vals <- lapply(val_df, function(x){
    x > 0
  })
  vals[!record_based] <- lapply(vals[!record_based], function(v) v[1])
  
  names(vals) <- names(val_df)
  # TODO add rules that were missed due to missing variables?
  vals
})

