# rewrite query to support specific validate functions
# assumption: extend table with extra columns and provide an rewritten expression
# using these new columns
# may depend on the support of window functions

rewrite <- function(tbl, e, n = 1L, has_window = TRUE){
  if (is.call(e)){
    # first parse the arguments to support nested validate functions
    arg <- seq_along(e)[-1]
    for (a in arg){
      e_a <- e[[a]]
      if (!is.call(e_a)){
        next
      }
      l <- rewrite(tbl, e_a, n)
      tbl <- l$tbl
      n <- l$n
      e[[a]] <-l$e 
    }
    return(
      switch( deparse(e[[1]])
            , is_unique = rewrite_is_unique(tbl, e, n)
            , all_unique = rewrite_all_unique(tbl, e, n)
            , exists_any = rewrite_exists_any(tbl, e, n)
            , exists_one = rewrite_exists_one(tbl, e, n)
            , do_by   = rewrite_do_by(tbl, e, n)
            , mean_by = rewrite_do_by(tbl, e, n, quote(mean))
            , max_by  = rewrite_do_by(tbl, e, n, quote(max))
            , list(tbl= tbl, e = e , n = n)
            )
    )
  }
  list(tbl = tbl, e = e, n = n)
}

parse_by <- function(e, n = 2){
  by <- if (length(e) >= n) e[[n]]
  if (length(by) > 1L){
    # TODO check that by[1] == list
    by <- by[-1L]
  }
  by <- as.list(by)
  by
}

`%||%` <- function(x,y){
  if (is.null(x)){
    y
  } else {
    x
  }
}
