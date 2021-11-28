#' dump sql statements
#' 
#' Write sql statements of a tbl confrontation.
#' @export
#' @param x `tbl_validation` object
#' @param sql_file filename/connection where the sql code should be written to.
#' @param sparse not used
#' @param ... not used
dump_sql <- function(x, sql_file = stdout(), sparse=x$sparse, ...){
  if (!inherits(x, "tbl_validation")){
      stop("Only works on a tbl_validation object.
           Use `confront(tbl, rules)` as input", call. = FALSE)
  }
  qry <- lapply(names(x$subqueries), function(rule_name){
    rule <- x$rules[rule_name][[1]]
    desc <- validate::description(rule)
    rule_qry <- x$subqueries[[rule_name]]
    c( "--------------------------------------"
     , sprintf("--  %s:  %s", rule_name, validate::label(rule))
     , sprintf("--  validation rule:  %s", deparse(rule@expr))
     , if(nchar(desc)) sprintf("--      %s", desc)
     , ""
     , dbplyr::sql_render(rule_qry)
     , ""
     , "--------------------------------------"
    )
  })
  qry <- Reduce(function(l, r){
    c( l
     , ""
     , "UNION ALL"
     , ""
     , r
     )}, qry)
  
  header <- 
    c( "------------------------------------------------------------"
     , sprintf("-- Do not edit, automatically generated with R package validatedb.")
     , sprintf("-- validatedb: %s", utils::packageVersion("validatedb"))
     , sprintf("-- validate: %s", utils::packageVersion("validate"))
     , sprintf("-- %s", R.version.string)
     , sprintf("-- Database: '%s', Table: '%s'", dbname(x$tbl), tblname(x$tbl))
     , sprintf("-- Date: %s", Sys.Date())
     , "------------------------------------------------------------"
    )
  writeLines(
    c( header
     , ''
     , qry
     )
    , con = sql_file
  )
}
