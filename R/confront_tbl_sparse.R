#' Create a sparse confrontation query
#' 
#' Create a sparse confrontation query. Only errors and missing are stored.
#' This stores all results
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
                               , key
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
              paste0("\t", names(nw),": ", nw, collapse="\n"),
              "\nUse function `check_rules` to inspect the non-working rules."
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
    stop("Use the 'key' argument to indicate the columns that identify a row.")
  }
  
  cw_exprs <- as.expression(exprs)
  clmnnames <- tbl_vars(tbl)
  qrys <- lapply(names(cw_exprs), function(rule_name){
    e <- cw_exprs[[rule_name]]
    
    # replace validate functions with sql construct
    sel_vars <- intersect(clmnnames, c(all.vars(e), key))
    sel_vars <- lapply(sel_vars, as.symbol)
    tbl <- dplyr::select(tbl, !!!sel_vars)
    l <- rewrite(tbl, e, n = 1)
    e_tbl <- l$tbl
    e <- l$e
    
    e_fail <- negate(e)
    d_fail <- dplyr::filter( e_tbl, !!e_fail)
    d_fail <- dplyr::transmute( d_fail
                              , !!!key_expr
                              , rule = !!rule_name
                              , fail = TRUE
                              )

    # sql server does not allow boolean expressions, bummer!!!
    #d_na <- dplyr::filter( e_tbl, is.na(!!e_fail))
    
    e_fail_is_null <- expr_is_null(e_fail)
    if (length(e_fail_is_null)){
      d_na <- dplyr::filter( e_tbl, !!e_fail_is_null)
      d_na <- dplyr::transmute( d_na
                              , !!!key_expr
                              , rule = !!rule_name
                              , fail = NA
                              )
      dplyr::union_all(d_fail, d_na)
    } else {
      d_fail
    }
  })
  names(qrys) <- names(exprs)
  qry <- Reduce(dplyr::union_all, qrys)
  
  list( query   = qry
      , queries = qrys
      , errors  = nw
      , exprs   = exprs_all
      , working = working
      )
}

expr_is_null <- function(e){
  #browser()
  if (!is.call(e)){
    return(bquote(is.na(.(e))))
  }
  
  op <- deparse(e[[1]])
  
  if (op == "is.na"){
    # return a FALSE, but has to be a comparison, since mssql does not understand
    # boolean expressions as a value.
    #return(bquote(1L == 0L))
    return(NULL)
  }
  
  if (length(e) == 2){
    return(expr_is_null(e[[2]]))
  }
  
  if (op %in% c(">", ">=", "<=", "<", "==", "!=")){
    l <- e[[2]]
    r <- e[[3]]
    if (is_number(l)){
      return(expr_is_null(r))
    }
    if (is_number(r)){
      return(expr_is_null(l))
    }
    return(substitute(l | r, list(l = expr_is_null(l), r = expr_is_null(r))))
  }
  args <- as.list(e)[-1]
  args <- args[!sapply(args, is.numeric)]
  args <- args[!sapply(args, is.logical)]

  args <- lapply(args, expr_is_null)
  args <- args[!sapply(args, is.null)]
  
  Reduce(function(l, r){bquote(.(l) | .(r))}, args)
  
  # # last resort
  # vs <- lapply(all.vars(e), function(v) bquote(is.na(.(as.symbol(v)))))
  # vs <- Reduce(function(v1, v2){bquote(.(v1) | .(v2))}, vs)
  # vs
}

is_number <- function(e){
  if (is.call(e) && length(e) == 2){
    return(is.numeric(e[[2]]))
  }
  is.numeric(e)
}

