rewrite_exists_any <- function(tbl, e, n = 1, has_window = TRUE){
  
  .name <- paste0(".n", n)
  rule <- e[[2]]
  by <- parse_by(e, 3)
  
  na_rm <- if (length(e) >= 4L) e[[4]] else TRUE
  
  joinby <- sapply(by, deparse)

  .n <- as.symbol(.name)
  cnt <- dplyr::filter(tbl, !!rule)
  cnt <- dplyr::count(cnt, !!!by, name = .name)
  d <- dplyr::left_join(tbl, cnt, by = joinby)
  d <- dplyr::mutate(d, "{.name}" := coalesce(!!.n, 0L))
  
  e <- bquote(.(.n) >= 1L)
  list(tbl = d, e = e, n = n + 1L)
}

rewrite_exists_one <- function(tbl, e, n = 1, ...){
  l <- rewrite_exists_any(tbl=tbl, e=e, n=n, ...)
  l$e <- substitute( n == 1L, list(n = l$e[[2]]))
  l
}
