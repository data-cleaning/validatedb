rewrite_exists_any <- function(tbl, e, n = 1, has_window = TRUE){
  .name <- paste0(".n", n)
  
  rule <- e[[2]]
  by <- parse_by(e, 3)
  na_rm <- if (length(e) >= 4L) e[[4]] else TRUE
  
  joinby <- sapply(by, deparse)
  nc <- substitute(coalesce(n, 0L), list(n = as.symbol(.name)))
  nc <- setNames(list(nc), .name)
  tbl_q <- 
      bquote({
        d <- filter(tbl, .(rule))
        .n <- count(d, ..(by), name = .(.name))
        d <- left_join(tbl, .n, by = .(joinby))
        mutate(d, ..(nc))
      }, splice = TRUE)
  e <- bquote(.(as.symbol(.name)) >= 1L)
  list(tbl = eval(tbl_q), e = e, n = n + 1L)
}

rewrite_exists_one <- function(tbl, e, n = 1, ...){
  l <- rewrite_exists_any(tbl=tbl, e=e, n=n, ...)
  l$e <- substitute( n == 1L, list(n = l$e[[2]]))
  l
}
