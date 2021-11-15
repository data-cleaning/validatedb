wrap_expression <- function(exprs){
  nms <- names(exprs)
  exprs <- lapply(exprs, function(expr){
    bquote(ifelse(.(expr), 1L, 0L))
  })
  names(exprs) <- nms
  exprs
}