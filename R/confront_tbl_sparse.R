#' Create a sparse confrontation query
#' 
#' Create a sparse confrontation query. Only errors and missing are stored.
#' This can be useful alternative to [confront_tbl()] which stores all results
#' of a `tbl` validation in a table with `length(rules)` columns and `nrow(tbl)`
#' rows. Note that the result of this function is a (lazy) query object that 
#' still needs to be executed in the database, e.g. with [dplyr::collect()], [dplyr::collapse()] or
#' [dplyr::compute()].
#' 
#' The return value of the function is a list with:
#' 
#' * `$query`: A [dbplyr::tbl_dbi()] object that refers to the confrontation query.
#' * `$errors`: The validation rules that are not working on the database
#' * `$working`: A `logical` with which expression are working on the database.
#' * `$exprs`: All validation expressions.
#' 
#' @inherit confront.tbl_sql
#' @param union_all if `FALSE` each rule is a separate query.
#' @param check_rules if `TRUE` it is checked which rules 'work' on the db.
#' @return A object with the necessary information: see details
#' @family confront
confront_tbl_sparse <- function( tbl
                               , x
                               , key = NULL
                               , union_all = TRUE
                               # , ...
                               , check_rules = TRUE){
  exprs <- x$exprs( replace_in = FALSE
                  , vectorize  = FALSE
                  , expand_assigments = TRUE
                  )
  nexprs <- length(exprs)
  exprs_all <- exprs
  working <- NA
  nw = list()
  if (check_rules){
    working <- rule_works_on_tbl(tbl, x)
    nw <- exprs[!working]
    if (any(!working)){
      # should this be in the error object?
      warning("Detected rules that do not work on this table/db.\n",
              "Ignoring:\n",
              paste0("\t", names(nw),": ", nw, collapse="\n")
      )
    }
    exprs <- exprs[working]
  }
  
  key_expr <- list(row = quote(row_number()))
  if (is.character(key)){
    if (!key[1] %in% dplyr::tbl_vars(tbl)){
      stop("key='",key[1],"' is not recognized as a column", call. = FALSE)
    }
    key_expr <- list(as.symbol(key[1]))
  }
  

  qry_e <- lapply(names(exprs), function(rule_name){
    e <- exprs[[rule_name]]
    bquote({
      d <- dplyr::transmute( tbl
                           , ..(key_expr)
                           , rule = .(rule_name)
                           , fail = !.(e)
                           )
      dplyr::filter(d, dplyr::coalesce(fail, TRUE))
    }, splice=TRUE)
  })
  qry <- lapply(qry_e, eval.parent, n=1)
  if (isTRUE(union_all)){
    qry <- Reduce(dplyr::union_all, qry)
  }
  list( query   = qry
      , errors  = nw
      , exprs   = exprs_all
      , working = working
      )
}


# x <- validator(z := 4, x > 1, y > 1, y  < z, z2 := y+x, m = unknown_f(x) > 1)
# d <- data.frame(x = 1:2, y = c(2,NA))

# con <- src_memdb()
# tbl_d <- copy_to(con, d, overwrite=TRUE)
