
#' create a table with per record if it abides to the rule.
#' 
#' create a table with per record if it abides to the rule.
#' @inheritParams confront.tbl_sql
confront_tbl <- function(tbl, x, key = NULL
                        # , ...
                        ){
  
  exprs <- x$exprs( replace_in = FALSE
                  , vectorize=FALSE
                  , expand_assignments = TRUE
                  )
  
  working <- rule_works_on_tbl(tbl, x)
  nw <- exprs[!working]
  if (length(nw)){
    # should this be in the error object?
    warning("Detected rules that do not work on this table/db.\n",
    "Ignoring:\n",
    paste0("\t", names(nw),": ", nw, collapse="\n")
    )
  }
  exprs <- exprs[working]
  key_expr <- list()
  if (is.character(key)){
    if (!key[1] %in% dplyr::tbl_vars(tbl)){
      stop("key='",key[1],"' is not recognized as a column", call. = FALSE)
    }
    # TODO put key column first
    key_expr <- list(as.symbol(key[1]))
  }
  valid_qry <- bquote(dplyr::transmute(tbl, ..(key_expr),  ..(exprs)), splice = TRUE)
  valid_qry <- eval(valid_qry)
  
  list( query        = valid_qry
#     , tbl          = tbl
#     , key          = key
#     , record_based = record_based
      , nexprs       = length(working)
      , errors       = nw
      )
}


# x <- validator(x > 1, y > 1)
# d <- data.frame(x = 1:2, y = c(2,NA))
# confront_wide(tbl_d, x)
