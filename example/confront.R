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
