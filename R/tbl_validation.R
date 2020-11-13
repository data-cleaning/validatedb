tbl_validation <- 
  setRefClass( "tbl_validation"
               , fields = list(._query = "tbl_sql")
               , contains="validation"
  )

# vl <- tbl_validation(._calls = list())
# vl <- new("validation")
# validate:::.show_confrontation
