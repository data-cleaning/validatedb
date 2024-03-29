% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/confront_tbl_sparse.R
\name{confront_tbl_sparse}
\alias{confront_tbl_sparse}
\title{Create a sparse confrontation query}
\usage{
confront_tbl_sparse(tbl, x, key, union_all = TRUE, check_rules = TRUE)
}
\arguments{
\item{tbl}{\code{\link[dbplyr:tbl.src_dbi]{dbplyr::tbl_dbi()}} table in a database, retrieved with \code{\link[=tbl]{tbl()}}}

\item{x}{\code{\link[validate:validator]{validate::validator()}} object with validation rules.}

\item{key}{\code{character} with key column name, must be specified}

\item{union_all}{if \code{FALSE} each rule is a separate query.}

\item{check_rules}{if \code{TRUE} it is checked which rules 'work' on the db.}
}
\value{
A object with the necessary information: see details
}
\description{
Create a sparse confrontation query. Only errors and missing are stored.
This stores all results
of a \code{tbl} validation in a table with \code{length(rules)} columns and \code{nrow(tbl)}
rows. Note that the result of this function is a (lazy) query object that
still needs to be executed in the database, e.g. with \code{\link[dplyr:compute]{dplyr::collect()}}, \code{\link[dplyr:compute]{dplyr::collapse()}} or
\code{\link[dplyr:compute]{dplyr::compute()}}.
}
\details{
The return value of the function is a list with:
\itemize{
\item \verb{$query}: A \code{\link[dbplyr:tbl.src_dbi]{dbplyr::tbl_dbi()}} object that refers to the confrontation query.
\item \verb{$errors}: The validation rules that are not working on the database
\item \verb{$working}: A \code{logical} with which expression are working on the database.
\item \verb{$exprs}: All validation expressions.
}
}
\examples{
# create a table in a database
income <- data.frame(id = letters[1:2], age=c(12,35), salary = c(1000,NA))
con <- dbplyr::src_memdb()
tbl_income <- dplyr::copy_to(con, income, overwrite=TRUE)
print(tbl_income)

# Let's define a rule set and confront the table with it:
rules <- validator( is_adult   = age >= 18
                  , has_income = salary > 0
                  , mean_age   = mean(age,na.rm=TRUE) > 20
                  )

# and confront! (we have to use a key, because a db...)
cf <- confront(tbl_income, rules, key = "id")
print(cf)
summary(cf)

# Values (i.e. validations on the table) can be retrieved like in `validate` 
# with`type="matrix"` (simplify = TRUE)
values(cf, type = "matrix")

# But often this seems more handy:
values(cf, type = "tbl")

# We can see the sql code by using `show_query`:
show_query(cf)

# identical
show_query(values(cf, type = "tbl"))

# sparse results in db (that the default)
values(cf, type="tbl", sparse=TRUE)

# or if you like data.frames
values(cf, type="data.frame", sparse=TRUE)
}
\seealso{
Other validation: 
\code{\link{tbl_validation-class}},
\code{\link{values,tbl_validation-method}}
}
\concept{confront}
