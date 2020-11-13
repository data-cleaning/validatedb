
#' Create a sparse confrontation query
#' 
#' Create a sparse confrontation query. Only errors and missing are stored.
#' This can be useful alternative to [confront_tbl()] which stores all results
#' of a `tbl` validation in a table with `length(rules)` columns and `nrow(tbl)`
#' rows. Note that the result of this function is a (lazy) query object that 
#' still needs to be executed in the database, e.g. with [dplyr::collect()], [dplyr::collapse()] or
#' [dplyr::compute()].
#' @inherit confront.tbl_sql
#' @param union_all if `FALSE` each rule is a separate query.
#' @param check_rules if `TRUE` it is checked which rules 'work' on the db.
#' @family confront
confront_tbl_sparse <- function( tbl
                               , x
                               , key = NULL
                               , union_all = TRUE
                               , ...
                               , check_rules = TRUE){
  exprs <- x$exprs( replace_in = FALSE
                  , vectorize = FALSE
                  , expand_assigments = TRUE
                  )
  nexprs <- length(exprs)
  if (check_rules){
    working <- rule_works_on_tbl(tbl, x)
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