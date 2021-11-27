rewrite_is_complete <- function(tbl, e, n = 1){
  arg <- as.list(e[-1])
  is_na <- lapply(arg, function(x) {bquote(is.na(.(x)))})
  is_na <- Reduce(function(l,r){bquote(.(l) | .(r))}, is_na)
  # add negate
  e <- bquote(!.(is_na))
  list(tbl = tbl, e = e, n = n)
}

rewrite_all_complete <- function(tbl, e, n = 1){
  l <- rewrite_is_complete(tbl, e, n = n)
  e <- bquote(max(.(negate(l$e)), na.rm=TRUE) < 1L)
  list(tbl = l$tbl, e = e, n = l$n)
}
