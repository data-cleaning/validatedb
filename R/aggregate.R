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
  key <- lapply(x$key, as.symbol)

  switch( by,
          rule   = aggregate_by_rule(x, ...),
          aggregate_by_record(x, ...)
        )
}

aggregate_by_rule <- function(x, ...){
  # CRAN checks
  fail <- NULL
  rule <- NULL
  n <- NULL
  nfail <- NULL
  nNA <- NULL
  npass <- NULL
  
  rules <- names(x$exprs)[x$working]
  
  N <- dplyr::collect(dplyr::count(x$tbl))$n
  
  a <- dplyr::count(x$query, rule, fail)
  fails <- dplyr::filter(a, fail == 1)
  fails <- transmute(fails, rule, nfail=n)
  
  nas <- dplyr::filter(a, is.na(fail))
  nas <- transmute(nas, rule, nNA = n)
  
  r <- dplyr::auto_copy(x$tbl, data.frame(rule = rules), copy =TRUE)
  r <- dplyr::left_join(r, fails, by = "rule")
  r <- dplyr::left_join(r, nas, by = "rule")
  r <- dplyr::mutate( r
                      , nfail = coalesce(nfail, 0L)
                      , nNA = coalesce(nNA, 0L)
  )
  r <- dplyr::transmute(r
                       , rule
                       , npass = !!N - nfail - nNA
                       , nfail
                       , nNA
                       , rel.pass = as.numeric(npass)/!!N
                       , rel.fail = as.numeric(nfail)/!!N
                       , rel.NA = as.numeric(nNA)/!!N
  )
  r
}
  
aggregate_by_record <- function(x, ...){
  qry <- unsparse(x)
  rules <- tbl_vars(qry)
  
  if (length(x$key)){
    key_idx <- seq_along(x$key)
    rules <- rules[-key_idx]
  }
  
  vars <- lapply(rules, as.symbol)
  add <- function(e1,e2){bquote(.(e1) + .(e2))}
  
  is_fail <- lapply(vars, function(v){
    bquote(coalesce(1L - .(v), 0L))
  })
  
  fails <- Reduce(add, is_fail)
  
  is_na <- lapply(vars, function(v){
    bquote(coalesce(.(v) %% 1L, 1L))
  })
  nas <- Reduce(add, is_na)
  key_expr <- list()
  if (length(x$key)){
    key_expr <- lapply(x$key, as.symbol)
  }
  qry <- dplyr::transmute(qry, !!!key_expr, nfails = !!fails, nNA = !!nas)
  qry
}
