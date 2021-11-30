#' Check rules for on the database
#' 
#' Checks whether validation rules are working on the database, and gives 
#' hints on non working rules.
#' 
#' `validatedb` translates validation rules using `dbplyr` on a database. Every
#' database engine is different, so it may happen that some validation rules
#' will not work. This function helps in finding out why rules are not working.
#' 
#' In some (easy to fix) cases, this may be due to:
#' 
#' - using variables that are not present in the table
#' - using a different value type than the column in the database, e.g.using an integer 
#' value, while the database column is of type "varchar".
#' 
#' But it can also be that some R functions are not available on the database, 
#' in which case you have to reformulate the rule.
#' @example  ./example/check_rules.R
#' @inheritParams confront.tbl_sql
#' @export
#' @returns `data.frame` with `name`, `rule`, `working`, `sql` for each rule.
check_rules <- function(tbl, x, key = NULL){
  res <- confront_tbl_sparse(head(tbl), x, key = key, union_all = FALSE, check_rules = FALSE)
  rule_sql <- sapply(res$queries, function(qry){
    try({
      dbplyr::remote_query(qry)
    }, silent = TRUE)
  })
  
  working <- rule_works_on_tbl(tbl, x, key = key, show_errors = TRUE)
  exprs <- res$exprs
  message("\n\n***************************************************"
          ,"\n** This method returns a data.frame with the sql code."
          ,"\n** Please assign the return value to inspect it."
          ,"\n*****************************************************"
  )
  invisible(
    data.frame( name = names(exprs)
              , rule = as.character(as.expression(exprs))
              , working = unname(working)
              , sql = unname(rule_sql)
    )
  )
}

detect_integer <- function(e){
  if (is.call(e)){
    l <- as.list(e)
    for (n in seq_along(l)[-1]){
      detect_integer(l[[n]])
    }
  } else {
    if (is.double(e)){
      if (as.integer(e) == e){
        message(" - Did you mean '", as.character(e), "L' instead of '", as.character(e), "'?")
      }
    }
  }
  e
}
