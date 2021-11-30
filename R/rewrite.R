# rewrite query to support specific validate functions
# assumption: extend table with extra columns and provide an rewritten expression
# using these new columns
# may depend on the support of window functions
`:=` = `=`

rewrite <- function(tbl, e, n = 1L, sel_vars= NULL){
  if (is.call(e)){
    # first parse the arguments to support nested validate functions
    arg <- seq_along(e)[-1]
    for (a in arg){
      e_a <- e[[a]]
      if (!is.call(e_a)){
        next
      }
      l <- rewrite(tbl, e_a, n, sel_vars = sel_vars)
      tbl <- l$tbl
      n <- l$n
      e[[a]] <-l$e 
    }
    return(
      switch( deparse(e[[1]])
            , is_unique = rewrite_is_unique(tbl, e, n)
            , all_unique = rewrite_all_unique(tbl, e, n)
            , is_complete = rewrite_is_complete(tbl, e, n)
            , all_complete = rewrite_all_complete(tbl, e, n)
            , exists_any = rewrite_exists_any(tbl, e, n)
            , exists_one = rewrite_exists_one(tbl, e, n)
            , do_by   = rewrite_do_by(tbl, e, n)
            , mean_by = rewrite_do_by(tbl, e, n, quote(mean))
            , sum_by  = rewrite_do_by(tbl, e, n, quote(sum))
            , max_by  = rewrite_do_by(tbl, e, n, quote(max))
            , min_by  = rewrite_do_by(tbl, e, n, quote(min))
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

negate <- function(e){
  if (!is.call(e)){
    return(bquote(!.(e)))
  }
  op <- deparse(e[[1]])
  l <- e[[2]]
  r <- if (length(e) >= 3) e[[3]]
  switch( op
        , "!" = l
        , ">" = bquote(.(l) <= .(r))
        , ">=" = bquote(.(l) < .(r))
        , "<" = bquote(.(l) >= .(r))
        , "<=" = bquote(.(l) > .(r))
        , "!=" = bquote(.(l) == .(r))
        , "==" = bquote(.(l) != .(r))
        , bquote(!.(e))
        )
}

`%||%` <- function(x,y){
  if (is.null(x)){
    y
  } else {
    x
  }
}
