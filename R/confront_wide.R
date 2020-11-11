
#' create a table with per record if it abides to the rule.
confront_wide <- function(tbl, x, compute = FALSE, ...){
  exprs <- x$exprs( replace_in = FALSE
                  , vectorize=FALSE
                  , expand_assignments = TRUE
                  )
  
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
  valid_qry <- bquote(dplyr::transmute(tbl, ..(exprs)), splice = TRUE)
  valid_qry <- eval(valid_qry)
  valid_qry
}


# x <- validator(x > 1, y > 1)
# d <- data.frame(x = 1:2, y = c(2,NA))
# confront_wide(tbl_d, x)
