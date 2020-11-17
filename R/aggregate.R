#' Aggregate a validation
#' 
#' Create either statistics by rule or record
#' @param x `tbl_validation` object
#' @param by either by "rule" or by "record"
#' @param ... not used
#' @importFrom stats aggregate
#' @importFrom dplyr tbl_vars coalesce transmute summarize
#' @example ./example/aggregate.R
#' @export
aggregate.tbl_validation <- function(x, by = c("rule", "record"), ...){
  by = match.arg(by)
  switch( by,
          rule   = aggregate_by_rule(x, ...),
          record = aggregate_by_record(x, ...)
        )
}

aggregate_by_rule <- function(x, ...){
  rules <- tbl_vars(x$query)
  if (length(x$key)){
    # drop key column
    rules <- rules[-1]
  }
  vars <- lapply(rules, as.symbol)
  qry <- compute(x$query)
  qr_e <- lapply(vars, function(v){
    bquote(summarize(qry
                    , rule = .(as.character(v))
                    , fail = sum(.(v) == 0, na.rm=T)
                    , na   = sum(is.na(.(v)), na.rm = T)
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
                                   , fails = .(fails)
                                   , nas = .(nas))
                  , splice = TRUE
                  )
  qry <- eval(qry_e)
  qry
}