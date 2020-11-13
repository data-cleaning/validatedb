#' testing 1, 1,2 
setMethod("values", signature = c("tbl_validation"), function( x
                                                             , simplify = FALSE
                                                             , type = c("list", "tbl")
                                                             , ...
                                                             ){
  if (missing(type)){
    warning("Please specify 'type' argument. Default setting (matrix) is identical to ",
            "'validate' on a data.frame, but may be undesired when working with
            data in a data base")
  }
  type = match.arg(type)
  
  # TODO something with sparse? warn
  if (type == "tbl"){
    return(x$query)
  }
  
  #TODO implement simplify
  val_df <- dplyr::collect(x$query)
  # first column is row_number, should also remove key column
  vals <- lapply(val_df[, -1], function(x){
    x > 0
  })
  names(vals) <- names(val_df[,-1])
  vals
})

