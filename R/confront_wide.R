
#' create a table with per record if it abides to the rule.
confront_wide <- function(tbl_d, x, compute = FALSE, ...){
  exprs <- x$exprs(replace_in = FALSE, vectorize=FALSE)

  is_assignment <- sapply(exprs, function(e){
    e[[1]] == ":="
  })
  
  asgnmt <- exprs[is_assignment]
  names(asgnmt) <- NULL
  value <- sapply(asgnmt, function(e){
    setNames(as.expression(e[[3]]), as.character(e[[2]]))
  }) 
  .data <- bquote(mutate(tbl_d, ..(value)), splice=TRUE)
  
  exprs <- exprs[!is_assignment]
  valid_qry <- bquote(dplyr::transmute(tbl_d, ..(exprs)), splice = TRUE)
  valid_qry <- eval(valid_qry)
  collect(valid_qry)
}


# x <- validator(x > 1, y > 1)
# d <- data.frame(x = 1:2, y = c(2,NA))
confront_wide(tbl_d, x)
