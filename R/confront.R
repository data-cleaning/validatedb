setOldClass("tbl_sql")

#' Confront `tbl_sql` with `validator` rules.
#' 
#' Confront `tbl_sql` objects with `validator` rules. This function makes it 
#' possible to execute `validator()` rules on database tables. 
#' 
#' @param tbl tbl_sql object, table in a database, retrieved with [dplyr::tbl()]
#' @param x [validate::validator()] object with validation rules.
#' @param ref reference object (not working)
#' @param key `character` with key column name.
#' @param sparse `logical` should only fails be stored in the db?
#' @param compute `logical` if `TRUE` the check stores a temporary table in the database.
#' @param ... passed through to [compute()], if `compute` is `TRUE`
#' @example ./example/confront.R
#' @family confront
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
    confront_tbl_sparse(tbl = tbl, x = x, key = key)
  } else {
    confront_tbl(tbl = tbl, x = x, key = key)
  }
  
  # store the result in the DB
  if (isTRUE(compute)){
    res$query <- dplyr::compute(res$query, ...)
  }
  # TODO promote n to argument?
  record_based <- is_record_based(tbl, x, n = 5)
  
  tbl_validation( ._call = match.call()
                , query  = res$query
                , tbl    = tbl
                , key    = as.character(key)
                , record_based = record_based
                , nexprs = res$nexprs
                , errors = res$errors
                , sparse = sparse
                )
}

#' Implementation for database tables.
#' This method is used for objects that implement the `tbl_sql` interface used in
#' `dbplyr`.
#' 
#' @inheritParams confront.tbl_sql
#' @param dat an object of class `tbl_sql``.
#' @importFrom validate confront
#' @export
setMethod("confront", signature("ANY","validator"), function(dat, x, ref, key = NULL, sparse = FALSE, ...){
  if (inherits(dat, "tbl_sql")){
    return(confront.tbl_sql(dat, x, ref = ref, key = key, sparse = sparse, ...))
  }
  stop("No implementation found for type ", paste0(class(dat), ", "))
})



  