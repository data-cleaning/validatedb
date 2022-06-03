violating.tbl_sql <- function(x, y, include_missing=FALSE, key  = NULL, ...){
  if (inherits(y, "validator")){
    y <- confront(x, y, key = key, ...)
  }
  
  qry <- y$query
  if (!isTRUE(include_missing)){
    qry <- dplyr::filter(qry, fail == 1)
  }
  # keys <- lapply(key, as.symbol)
  # qry <- dplyr::distinct(qry, !!!keys)
  # 
  dplyr::semi_join(y$tbl, qry,by = key)
}

satisfying.tbl_sql <- function(x,y, include_missing = FALSE, key = NULL, ...){
  if (inherits(y, "validator")){
    y <- confront(x, y, key = key, ...)
  }
  
  qry <- y$query
  if (isTRUE(include_missing)){
    qry <- dplyr::filter(qry, fail == 1)
  }
  keys <- lapply(key, as.symbol)
  qry <- dplyr::distinct(qry, !!!keys)
  
  dplyr::anti_join(y$tbl, qry,by = key)
}


lacking.tbl_sql <- function(x, y, key  = NULL, ...){
  if (inherits(y, "validator")){
    y <- confront(x, y, key = key, ...)
  }
  
  qry <- y$query
  qry <- dplyr::filter(qry, is.na(fail))
  
  # keys <- lapply(key, as.symbol)
  # qry <- dplyr::distinct(qry, !!!keys)
  dplyr::semi_join(y$tbl, qry,by = key)
}