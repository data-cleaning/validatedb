income <- data.frame(id = 1:2, age=c(12,35), salary = c(1000,NA))
# create a table in SQLite memory
tbl_income <- dbplyr::memdb_frame(income)

# Let's define a rule set and confront the table with it:
f <- function(x) x
rules <- validator( is_adult   = age >= 18
                    , has_income = salary > 0
                  , mean(salary, na.rm=TRUE) > 0
                  , f(x) < 0
)

# and confront!
# in general with a db table it is handy to use a key
cf <- confront(tbl_income, rules)
summary(cf)


cf_s <- confront(tbl_income, rules, sparse=TRUE)
summary(cf_s)
