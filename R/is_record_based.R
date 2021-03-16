#' determine the dimensional structure of `values` so that it conforms to
#' `validate`. Only used for values `simplify`.
#' Works heuristically: get a subset out of db and executes validate::confront on it.
#' Note, this returns also a value for rules that do not work on db!
#' @keywords internal
#' @param tbl A [dbplyr::tbl_dbi] object.
#' @param x A [validate::validator()] object with validation rules.
#' @param n `integer` number of records to be used for checking.
#' @return `logical` whether a validation rule is record based or not.
is_record_based <- function(tbl, x, n = 5){
  dat <- dplyr::collect(head(tbl, n = n))
  cf <- confront(dat, x)
  vls <- values(cf, simplify = FALSE)
  # check if length of value equals n
  sapply(vls, length) == nrow(dat)
}
