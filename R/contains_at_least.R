rewrite_contains_at_least <- function(tbl, e, n = 1){
  .name <- paste0(".n", n)
  arg <- as.list(e[-1])
  # check keys...
  keys <- arg[[1]]
  
  by <- parse_by(arg, 2)
  #allow_duplicates <- if (length(arg) >= 3) arg[[3]] else FALSE
  un <- dplyr::right_join(tbl, !!keys, by = names(!!keys), copy=TRUE)
  un <- dplyr::mutate(un, "{.name}" := n())
  
  e <- bquote(.(as.name(.name)) == 1L)
  list(tbl = un, e = e, n = n + 1)
}