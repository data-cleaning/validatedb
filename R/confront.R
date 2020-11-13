setOldClass("tbl_sql")

#' @export
confront.tbl_sql <- function( dat
                            , x
                            , ref
                            , key = NULL
                            , sparse = FALSE
                            , compute = FALSE
                            , ...
                            ){
  res <- if (sparse){
    confront_tbl_sparse(tbl = dat, x = x, key = key, ...)
  } else {
    res <- confront_tbl(tbl = dat, x = x, key = key, ...)
  }
  
  # store the result in the DB
  if (isTRUE(compute)){
    res$query <- dplyr::compute(res$query, ...)
  }
  res
}

#' @export
setMethod("confront", signature("ANY","validator"), function(dat, x, ref, key = NULL, sparse = FALSE, ...){
  if (inherits(dat, "tbl_sql")){
    return(confront.tbl_sql(dat, x, ref = ref, key = key, sparse = sparse, ...))
  }
  stop("No implementation found for type ", paste0(class(dat), ", "))
})



  