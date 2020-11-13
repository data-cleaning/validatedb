#' Retrieve the result of a validation/confront
#' 
#' Retrieve the result of a validation/confront
#' @param x object of type `tbl_validation`
#' @param simplify only use when `type` = "list" see `validate::values`
#' @param type whether to return a list/matrix or to return a query on the database.
#' @param ... not used
#' @export
setMethod("values", signature = c("tbl_validation"), function( x
                                                             , simplify = FALSE
                                                             , type = c("list", "tbl")
                                                             , ...
                                                             ){
  if (missing(type)){
    warning("Please specify 'type' argument. Default setting (type = 'list')\n", 
     "is identical to 'confront' on a data.frame, but type = 'tbl' is \n",
     "preferable when working with data in a data base."
     , call. = FALSE
     )
  }
  type = match.arg(type)
  
  # TODO something with sparse? warn
  if (type == "tbl"){
    return(x$query)
  }
  
  #TODO implement simplify
  val_df <- dplyr::collect(x$query)
  
  if (x$sparse){
    stop("Not implemented")
  }
  
  # first column is row_number, should also remove key column
  vals <- lapply(val_df, function(x){
    x > 0
  })
  names(vals) <- names(val_df)
  vals
})

