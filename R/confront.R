setOldClass("tbl_sql")

#' Confront `tbl_sql` objects with `validator` rules.
#' 
#' Confront `tbl_sql` objects with `validator` rules.
#' @param tbl tbl object
#' @param x `validator` object
#' @param ref reference object (not working)
#' @param key character of key column (not working)
#' @param sparse `logical` should only errors be stored in the db?
#' @param compute `logical` if `TRUE` the check stores a temporary table in the database.
#' @param ... not
#' @export
confront.tbl_sql <- function( tbl
                            , x
                            , ref
                            , key = NULL
                            , sparse = FALSE
                            , compute = FALSE
                            , ...
                            ){
  res <- if (sparse){
    confront_tbl_sparse(tbl = tbl, x = x, key = key, ...)
  } else {
    res <- confront_tbl(tbl = tbl, x = x, key = key, ...)
  }
  
  # store the result in the DB
  if (isTRUE(compute)){
    res$query <- dplyr::compute(res$query, ...)
  }
  tbl_validation( ._call = match.call()
                , query = res$query
                , tbl   = tbl
                , record_based = res$record_based
                , nexprs = res$nexprs
                , errors = res$errors
                , sparse = sparse
                )
}

#' Implementation for database tables.
#' This method is used for object that implement the `tbl_sql` interface used in
#' `dbplyr`.
#' 
#' @inheritParams confront.tbl_sql
#' @param dat an object of class `tbl_sql``.
#' @export
setMethod("confront", signature("ANY","validator"), function(dat, x, ref, key = NULL, sparse = FALSE, ...){
  if (inherits(dat, "tbl_sql")){
    return(confront.tbl_sql(dat, x, ref = ref, key = key, sparse = sparse, ...))
  }
  stop("No implementation found for type ", paste0(class(dat), ", "))
})



  