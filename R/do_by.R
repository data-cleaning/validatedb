rewrite_do_by <- function(tbl, e, n = 1, fun = NULL, has_window=FALSE){
  .name <- paste0(".n", n)
  
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
  funcall <- setNames(list(funcall), .name)
  
  if (has_window){
    tbl_q <- bquote({
      d <- group_by(tbl, ..(by))
      mutate(d, ..(funcall))
    },splice = TRUE)
  } else {
    tbl_q <- bquote({
      d <- group_by(tbl, ..(by))
      d <- summarize(d, ..(funcall))
      left_join(tbl, d, by = .(sapply(by, deparse)))
    },splice = TRUE)
  }
  e <- as.symbol(.name)
  list(tbl = eval(tbl_q), e = e, n = n + 1L)
}

