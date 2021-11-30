person <- dbplyr::memdb_frame(id = letters[1:2], age = c(12, 20))
rules <- validator(age >= 18)

check_rules(person, rules, key = "id")

# use the result of check_rules to find out more on the translation
res <- check_rules(person, rules, key = "id")

print(res[-4])
writeLines(res$sql)
