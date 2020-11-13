# create a table in a database
income <- data.frame(age=c(12,35), salary = c(1000,NA))
con <- dbplyr::src_memdb()
tbl_income <- dplyr::copy_to(con, income, overwrite=TRUE)
print(tbl_income)

# Let's define a rule set and confront the table with it:
rules <- validator( is_adult   = age >= 18
                  , has_income = salary > 0
                  )

# and confront!
cf <- confront(tbl_income, rules)
print(cf)

# Values (i.e. validations on the table) can be retrieved like in `validate` 
# with`type="list"`
values(cf, type = "list")

# But often this seems more handy:
values(cf, type = "tbl")

# We can see the sql code by using `show_query`:
show_query(cf)

# identical
show_query(values(cf, type = "tbl"))
