#' Retrieve the result of a validation/confrontation
#' 
#' Retrieve the result of a validation/confrontation.
#' 
#' Since the validation is done on a database, there are multiple options
#' for storing the result of the validation. The results show per record whether
#' they are valid according to the validation rules supplied.
#' 
#' - Use `compute` (see [confront.tbl_sql()]) to store the result in the database
#' - Use `sparse` to only calculate "fails" and "missings"
#' 
#' Default type "tbl" is that everything is "lazy", so the query and/or storage has to
#' be done explicitly by the user. 
#' The other types execute the query and retrieve the result into R. When this
#' creates memory problems, the `tbl` option is to be preferred.
#' 
#' Results for `type`:
#' 
#' * `tbl`: a [dbplyr::tbl_dbi] object, pointing to the database
#' * `matrix`: a R matrix, similar to [validate::values()].
#' * `list`: a R list, similar to [validate::values()].
#' * `data.frame`: the result of `tbl` stored in a `data.frame`.
#' @param x [tbl_validation()], result of a `confront()` of `tbl` with a rule set.
#' @param simplify only use when `type` = "list" see `validate::values`
#' @param type whether to return a list/matrix or to return a query on the database.
#' @param ... not used
#' @importFrom validate values
#' @export
#' @family validation
#' @example ./example/confront.R
#' @return depending on `type` the result is different, see details
setMethod("values", signature = c("tbl_validation"), function( x
                                                             #, simplify = TRUE
                                                             , simplify = type == "matrix"
                                                             , type = c("tbl", "matrix", "list","data.frame")
                                                             , ...
                                                             ){
  if (missing(type)){
    warning("Please specify 'type' argument. Default setting `type = 'tbl'` ", 
     "returns a query to the database.\nTo retrieve identical results as ",
     "`validate` on a data.frame, use `type = 'matrix' or 'list'`.\n",
     call. = FALSE
     )
  }
  type = match.arg(type)
  
  if (type == "tbl"){
    return(x$query)
  }
  
  if (type == "data.frame"){
    df <- as.data.frame(x$query)
    if (x$sparse){
      return(df)
    }
    # turn into logical
    is_num <- sapply(df, is.numeric)
    df[is_num] <- lapply(df[is_num], function(x){x > 0})
    return(df)
  }
  
  if (type == "matrix"){
    simplify <- TRUE
  }

  if (x$sparse){
    stop("type='",type,"' for sparse validation not implemented: it seems\n"
        ,"not wise to expand a sparse validation result into a full validation result."
        , "Either use `type` with `tbl` or `data.frame`, method `aggregate`, or \n"
        , "do a dense confrontation."
        )
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
  rules <- names(x$exprs)
  
  # adding rules that are not working
  nw <- rules[!x$working]
  vals[nw] <- list(NULL)
  
  vals[rules]
})

