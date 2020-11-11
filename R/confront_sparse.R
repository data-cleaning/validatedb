
#' create a table with only fails
confront_sparse <- function(tbl
                           , x
                           , compute = FALSE
                           , union_all = TRUE
                           , ...
                           , check_rules = TRUE){
  exprs <- x$exprs( replace_in = FALSE
                  , vectorize = FALSE
                  , expand_assigments = TRUE
                  )

  # # extract?
  # is_assignment <- sapply(exprs, function(e){
  #   e[[1]] == ":="
  # })
  # 
  # asgnmt <- exprs[is_assignment]
  # names(asgnmt) <- NULL
  # value <- sapply(asgnmt, function(e){
  #   setNames(as.expression(e[[3]]), as.character(e[[2]]))
  # }) 
  # .data <- bquote(mutate(tbl_d, ..(value)), splice=TRUE)
  # 
  # exprs <- exprs[!is_assignment]
  
  qry_e <- lapply(names(exprs), function(rule_name){
    e <- exprs[[rule_name]]
    fails <- substitute(dplyr::filter(tbl, dplyr::coalesce(!e, TRUE)))
    bquote(dplyr::transmute(.(fails)
                           , .r    = row_number()
                           , rule  = .(rule_name)
                           , value = .(e)
                           )
          )
  })
  qry <- lapply(qry_e, eval.parent, n=1)
  if (isTRUE(union_all)){
    qry <- Reduce(dplyr::union_all, qry)
  }
  qry
}


# x <- validator(z := 4, x > 1, y > 1, y  < z, z2 := y+x, m = unknown_f(x) > 1)
# d <- data.frame(x = 1:2, y = c(2,NA))

# con <- src_memdb()
# tbl_d <- copy_to(con, d, overwrite=TRUE)
