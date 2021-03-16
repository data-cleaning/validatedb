#' Validation object for `tbl` object
#' 
#' Validation information for a database `tbl`, result of a [confront.tbl_sql()].
#' 
#' The `tbl_validation` object contains all information needed for the confrontation
#' of validation rules with the data in the database table. It contains:
#' 
#' * `$query`: a [dbplyr::tbl_dbi] object with the query to be executed on the database
#' * `$tbl`: the [dbplyr::tbl_dbi] pointing to the table in the database
#' * `$key`: Whether there is a key column, and if so, what it is.
#' * `$record_based`: `logical` with which rules are record based.
#' * `$exprs`: list of validation rule expressions
#' * `$working`: `logical`, which of the rules work on the database. (whether the database supports this expression)
#' * `$errors`: list of validation rules that did not execute on the database.
#' * `$sparse`: If `TRUE` the query is stored as a sparse validation object.
#' @importFrom methods new
#' @family validation
#' @family tbl_validation
#' @return `tbl_validation` object. See details.
#' @export
tbl_validation <- 
  setRefClass( "tbl_validation"
               , fields = list( ._call = "call"
                              , query  = "ANY"
                              , tbl    = "ANY"
                              , key    = "character"
                              , record_based = "logical"
                              , exprs  = "list"
                              , working = "logical"
                              , errors = "list"
                              , sparse = "logical"
                              )
#               , contains="validation"
               , methods = list(
      show = function(){
        cat(sprintf("Object of class '%s'\n",class(.self)))
        cat(sprintf("Call:\n    ")); print(.self$._call); cat('\n')
        cat(sprintf('Confrontations: %d\n', length(.self$exprs)))
        cat(sprintf('Tbl           : %s (%s)\n', tblname(tbl), dbname(tbl)))
        #cat(sprintf('Database      : "%s"\n', dbname(tbl)))
        if (length(key)){
                cat('Key column    : ',key,'\n', sep="")
        }
        cat(sprintf('Sparse        : %s\n', sparse))
        cat(sprintf('Fails         : [??] (see `values`, `summary`)\n'))
        cat(sprintf('Errors        : %d\n', length(.self$errors)))
      }
    )
  )


tblname <- function(tbl){
  id <- unclass(tbl)$ops$x
  as.character(id)
}

dbname <- function(tbl){
  unclass(tbl)$src$con@dbname
}