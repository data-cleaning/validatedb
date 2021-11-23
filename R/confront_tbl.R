
#' create a table with per record if it abides to the rule.
#' 
#' create a table with per record if it abides to the rule.
#' 
#' The return value of the function is a list with:
#' 
#' * `$query`: A [dbplyr::tbl_dbi()] object that refers to the confrontation query.
#' * `$errors`: The validation rules that are not working on the database
#' * `$working`: A `logical` with which expression are working on the database.
#' * `$exprs`: All validation expressions.
#' * `$nexprs`: Number of working expression.
#' 
#' @return a list with needed information, see details.
#' @inheritParams confront.tbl_sql
confront_tbl <- function(tbl, x, key = NULL
                        # , ...
                        ){
  
  working <- rule_works_on_tbl(tbl, x, key = key)
  exprs <- x$exprs( replace_in = FALSE
                  , vectorize=FALSE
                  , expand_assignments = TRUE
                  )
  nw <- exprs[!working]
  if (length(nw)){
    # should this be in the error object?
    warning("Detected rules that do not work on table<", tblname(tbl),">.\n",
    "Ignoring:\n",
    paste0("\t", names(nw),": ", nw, collapse="\n")
    , call. = FALSE
    )
  }
  key_expr <- list()
  if (is.character(key)){
    key_in_table <- key %in% dplyr::tbl_vars(tbl)
    if (!all(key_in_table)){
      key_nf <- paste0("'", key[!key_in_table], "'", collapse = ", ")
      stop("key(s) ", key_nf," not recognized as a column", call. = FALSE)
    }
    key_expr <- lapply(key, as.symbol)
  } else {
    warning("Use the 'key' argument to indicate the columns that identify a row.")
  }
  valid_qry <- bquote(dplyr::transmute(tbl, ..(key_expr),  ..(wrap_expression(exprs[working]))), splice = TRUE)
  valid_qry <- eval(valid_qry)
  
  list( query        = valid_qry
      , nexprs       = length(working)
      , errors       = nw
      , working      = working
      , exprs        = exprs
      )
}


# x <- validator(x > 1, y > 1)
# d <- data.frame(x = 1:2, y = c(2,NA))
# confront_wide(tbl_d, x)
