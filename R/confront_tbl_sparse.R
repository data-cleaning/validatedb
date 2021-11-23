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
    working <- rule_works_on_tbl(tbl, x, key = key)
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
  
  colnms <- dplyr::tbl_vars(tbl)
  
  key_expr <- list()
  if (is.character(key)){
    key_in_table <- key %in% colnms
    if (!all(key_in_table)){
      key_nf <- paste0("'", key[!key_in_table], "'", collapse = ", ")
      stop("key(s) ", key_nf," not recognized as a column", call. = FALSE)
    }
    key_expr <- lapply(key, as.symbol)
  } else {
    warning("Use the 'key' argument to indicate the columns that identify a row.")
  }

  #cw_exprs <- wrap_expression(exprs)
  cw_exprs <- as.expression(exprs)
  qry_e <- lapply(names(cw_exprs), function(rule_name){
    
    e <- cw_exprs[[rule_name]][]
    # replace validate functions with sql construct
    # l <- rewrite(tbl, e, n = 1)
    # tbl <- l$tbl
    # e <- l$e
    
    bquote({
      d <- dplyr::transmute( tbl
                           , ..(key_expr)
                           , rule = .(rule_name)
                           , fail = 1L - .(e)
                           )
      d <- dplyr::filter(d, coalesce(fail, 1L) == 1L)
      d
      # d_na <- dplyr::transmute( tbl
      #                         , ..(key_expr)
      #                         , rule = .(rule_name)
      #                         , fail = NA
      #                         )
      # d_na <- dplyr::filter(d_na, is.na(.(e)))
      # dplyr::union_all(d, d_na)
    }, splice=TRUE)
  })

  qry <- lapply(qry_e, eval.parent, n=1)
  browser()
  
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
