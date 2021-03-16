#' Count the number of invalid rules or records.
#' 
#' See the number of valid and invalid checks either by rule or by record.
#' 
#' The result of a [confront()] on a db  `tbl` results in a lazy squery. That
#' is it builds a query without executing it. To store the result in the database
#' use [compute()] or [values()].
#' @param x [tbl_validation()] object
#' @param by either by "rule" or by "record"
#' @param ... not used
#' @importFrom stats aggregate
#' @importFrom dplyr tbl_vars coalesce transmute summarize
#' @example ./example/aggregate.R
#' @return A [dbplyr::tbl_dbi()] object that represents the aggregation query 
#' (to be executed) on the database.
#' @export
aggregate.tbl_validation <- function(x, by = c("rule", "record", "id"), ...){
  by = match.arg(by)
  if (x$sparse){
    # trick to pass CRAN checks
    rule <- NULL
    fail <- NULL
    
    qry = switch( by,
                  rule = dplyr::count(x$query, rule, fail),
                  dplyr::count(x$query, row, fail)
                )
    return(qry)
  }
  
  switch( by,
          rule   = aggregate_by_rule(x, ...),
          aggregate_by_record(x, ...)
        )
}

aggregate_by_rule <- function(x, ...){
  rules <- names(x$exprs)[x$working]
  rules <- lapply(rules, as.symbol)
  qry <- compute(x$query)
  qr_e <- lapply(rules, function(v){
    bquote(summarize( qry
                    , rule = .(as.character(v))
                    , npass = sum(.(v), na.rm=T)
                    , nfail = sum(.(v) == 0, na.rm=T)
                    , nNA   = sum(is.na(.(v)), na.rm = T)
                    )
          )
  })
  qr <- lapply(qr_e, eval.parent, n=1)
  Reduce(dplyr::union_all, qr)
}
  
aggregate_by_record <- function(x, ...){ 
  rules <- tbl_vars(x$query)
  
  if (length(x$key)){
    rules <- rules[-1]
  }
  
  vars <- lapply(rules, as.symbol)
  add <- function(e1,e2){bquote(.(e1) + .(e2))}
  
  is_fail <- lapply(vars, function(v){
    bquote(coalesce(.(v) == 0, 0))
  })
  
  fails <- Reduce(add, is_fail)
  
  is_na <- lapply(vars, function(v){
    bquote(coalesce(.(v) %% 1, 1))
  })
  nas <- Reduce(add, is_na)
  key_expr <- list()
  if (length(x$key)){
    key_expr <- list(as.symbol(x$key))
  }
  qry_e <- bquote( dplyr::transmute(x$query
                                   , ..(key_expr)
                                   , nfails = .(fails)
                                   , nNA = .(nas))
                  , splice = TRUE
                  )
  qry <- eval(qry_e)
  qry
}
