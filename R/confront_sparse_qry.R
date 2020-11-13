
#' create a table with only fails
confront_tbl_sparse <- function( tbl
                               , x
                               , compute = FALSE
                               , union_all = TRUE
                               , ...
                               , check_rules = TRUE){
  exprs <- x$exprs( replace_in = FALSE
                  , vectorize = FALSE
                  , expand_assigments = TRUE
                  )
  nexprs <- length(exprs)
  if (check_rules){
    working <- rule_works_on_db(tbl, x)
    if (any(!working)){
      nw <- exprs[!working]
      # should this be in the error object?
      warning("Detected rules that do not work on this table/db.\n",
              "Ignoring:\n",
              paste0("\t", names(nw),": ", nw, collapse="\n")
      )
    }
    exprs <- exprs[working]
  }

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
  list( query  = qry
      , tbl    = tbl
      , nexprs = nexprs
      )
}


# x <- validator(z := 4, x > 1, y > 1, y  < z, z2 := y+x, m = unknown_f(x) > 1)
# d <- data.frame(x = 1:2, y = c(2,NA))

# con <- src_memdb()
# tbl_d <- copy_to(con, d, overwrite=TRUE)
