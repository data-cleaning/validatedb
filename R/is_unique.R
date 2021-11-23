rewrite_is_unique <- function(tbl, e, n = 1, has_window = TRUE){
  .name <- paste0(".n", n)
  arg <- as.list(e[-1])
  
  .n <- setNames(list(quote(n())), .name)
  tbl_q <- bquote({
    d <- group_by(tbl, ..(arg))
    mutate(d, ..(.n))
  },splice=TRUE)
    
  e <- bquote(.(as.name(.name)) == 1)
  list(tbl = eval(tbl_q), e = e, n = n + 1)
}

rewrite_all_unique <- function(tbl, e, n = 1, has_window=TRUE){
  .name <- paste0(".n", n)
  arg <- as.list(e[-1])
  
  .n <- setNames(list(quote(max(n, na.rm=TRUE))), .name)
  tbl_q <- bquote({
    d <- count(tbl, ..(arg))
    d <- ungroup(d)
    d <- summarize(d, ..(.n))
  },splice=TRUE)

  e <- bquote(.(as.name(.name)) == 1)
  
  list(tbl = eval(tbl_q), e = e, n = n + 1)
}