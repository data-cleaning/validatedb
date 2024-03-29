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
#' @param drop not used at the moment
#' @param type whether to return a list/matrix or to return a query on the database.
#' @param sparse whether to show the results as a sparse query (only fails and `NA`)
#' or all results for each record.
#' @param ... not used
#' @importFrom validate values
#' @export
#' @family validation
#' @example ./example/confront.R
#' @return depending on `type` the result is different, see details
setMethod("values", signature = c("tbl_validation"), function( x
                                                             , simplify = type == "matrix"
                                                             , drop = FALSE
                                                             , type = c("tbl", "matrix", "list","data.frame")
                                                             , sparse = x$sparse
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
  qry <- if (isTRUE(sparse)){
    x$query
  } else {
    unsparse(x)
  }
  
  if (type == "tbl"){
    return(qry)
  }
  
  if (type == "data.frame"){
    df <- as.data.frame(qry)
    if (sparse){
      df$fail <- as.logical(df$fail)
      return(df)
    }
    # turn into logical
    idx <- !logical(ncol(df))
    idx[seq_along(x$key)] <- FALSE
    df[idx] <- lapply(df[idx], function(x){x > 0})
    return(df)
  }
  
  if (type == "matrix"){
    simplify <- TRUE
  }

  if (sparse){
    stop("type='",type,"' for sparse validation not implemented: it seems\n"
        ,"not wise to expand a sparse validation result into a full validation result."
        , "Either use `type` with `tbl` or `data.frame`, method `aggregate`, or \n"
        , "set `sparse` to false."
        )
  }
  
  val_df <- dplyr::collect(qry)
  
  # first column is row_number, should also remove key column
  if (length(x$key)){
    key_cols <- seq_along(x$key)
    val_df <- val_df[-key_cols]
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

