#' Validation object
#' 
#' Validation information
#' @importFrom methods new
#' @export
tbl_validation <- 
  setRefClass( "tbl_validation"
               , fields = list( ._call = "call"
                              , query  = "ANY"
                              , tbl    = "ANY"
                              , record_based = "logical"
                              , nexprs = "numeric"
                              , errors = "list"
                              , sparse = "logical"
                              )
#               , contains="validation"
               , methods = list(
      show = function(){
        cat(sprintf("Object of class '%s'\n",class(.self)))
        cat(sprintf("Call:\n    ")); print(.self$._call); cat('\n')
        cat(sprintf('Confrontations: %d\n', .self$nexprs))
        cat(sprintf('Fails         : [??] (see `values`)\n'))
        cat(sprintf('Errors        : %d\n', length(.self$errors)))
      }
    )
  )

