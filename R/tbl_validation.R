#' Validation object
#' 
#' Validation information
#' @importFrom methods new
#' @family validation
#' @family tbl_validation
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