setOldClass("tbl_sql")

#' Validate data in database `tbl` with `validator` rules.
#' 
#' Confront [dbplyr::tbl_dbi()] objects with [validate::validator()] rules, making it 
#' possible to execute `validator()` rules on database tables. Validation results
#' can be stored in the db or retrieved into R.
#' 
#' `validatedb` builds upon `dplyr` and `dbplyr`, so it works on all databases
#' that have a dbplyr compatible database driver (DBI / odbc).
#' `validatedb` translates `validator` rules into `dplyr` commands resulting in
#' a lazy query object. The result of a validation can be stored in the database
#' using `compute` or retrieved into R with `values`.
#' 
#' @param tbl [dbplyr::tbl_dbi()] table in a database, retrieved with [tbl()]
#' @param x [validate::validator()] object with validation rules.
#' @param ref reference object (not working)
#' @param key `character` with key column name.
#' @param sparse `logical` should only fails be stored in the db?
#' @param compute `logical` if `TRUE` the check stores a temporary table in the database.
#' @param ... passed through to [compute()], if `compute` is `TRUE`
#' @example ./example/confront.R
#' @return a [tbl_validation()] object, containing the confrontation query and processing information.
#' @family validation
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
  
  tbl_validation( ._call  = match.call()
                , query   = res$query
                , tbl     = tbl
                , key     = as.character(key)
                , record_based = record_based
                , exprs   = res$exprs
                , working = res$working
                , errors  = res$errors
                , sparse  = sparse
                )
}

#' Implementation for database tables.
#' This method is used for objects that implement the `tbl_sql` interface used in
#' `dbplyr`.
#' 
#' @param dat an object of class `tbl_sql``.
#' @importFrom validate confront
#' @rdname confront.tbl_sql
#' @export
setMethod("confront", signature("ANY","validator"), function(dat, x, ref, key = NULL, sparse = FALSE, ...){
  if (inherits(dat, "tbl_sql")){
    cf <- confront.tbl_sql(dat, x, ref = ref, key = key, sparse = sparse, ...)
    #cf$._call <- sys.call(1)
    return(cf)
  }
  stop("No implementation found for type ", paste0(class(dat), ", "))
})



  