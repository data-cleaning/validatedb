rewrite_is_unique <- function(tbl, e, n = 1, has_window = TRUE){
  .name <- paste0(".n", n)
  arg <- as.list(e[-1])
  
  un <- dplyr::group_by(tbl, !!!arg)
  un <- dplyr::mutate(un, "{.name}" := n())
  
  e <- bquote(.(as.name(.name)) == 1L)
  list(tbl = un, e = e, n = n + 1)
}

rewrite_all_unique <- function(tbl, e, n = 1, has_window=TRUE){
  .name <- paste0(".n", n)
  .n <- as.symbol(.name)
  arg <- as.list(e[-1])
  
  un <- dplyr::group_by(tbl, !!!arg)
  un <- dplyr::mutate(un, "{.name}" := n())
  un <- dplyr::ungroup(un)
  un <- dplyr::mutate(un, "{.name}" := max(!!.n, na.rm=TRUE))
  
  e <- bquote(.(.n) == 1L)
  list(tbl = un, e = e, n = n + 1)
}


elist <- function(...){
  l <- substitute(list(...))[-1]
  nms <- names(l)
  if (length(nms)){
    nms <- mget(nms, mode="character", envir=parent.frame()
               , inherits = TRUE, ifnotfound = as.list(nms)
               )
    names(l) <- nms
  }
  as.list(l)
}

.arg <- function(...){
  l <- substitute(list(...))[-1]
  nms <- names(l)
  if (length(nms)){
    nms <- mget(nms, mode="character", envir=parent.frame()
                , inherits = TRUE, ifnotfound = as.list(nms)
    )
    names(l) <- nms
  }
  as.list(l)
}

