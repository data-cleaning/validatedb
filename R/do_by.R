rewrite_do_by <- function(tbl, e, n = 1, fun = NULL){
  
  .name <- paste0(".n", n)
  .n <- as.symbol(.name)
  
  db <- e[[1]]
  x <- e[[2]]
  by <- parse_by(e, n = 3)
  
  if (is.null(fun)){
    fun <- e[[4]]
    arg <- as.list(e[-(1:4)])
  } else {
    arg <- if (length(e) >= 4L) e[[4]] else TRUE
    arg <- setNames(as.list(arg), "na.rm")
  }

  funcall <- bquote(.(fun)(.(x), ..(arg)), splice = TRUE)
  d <- dplyr::group_by(tbl, !!!by)
  d <- dplyr::mutate(d, "{.name}" := !!funcall)

  e <- .n
  list(tbl = d, e = e, n = n + 1L)
}

