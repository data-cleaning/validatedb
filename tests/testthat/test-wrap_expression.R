describe("wrap an expression with ifelse", {
  exprs <- expression(a=x > 1, b=y < x)
  cw_exprs <- wrap_expression(exprs)
  expect_equal( cw_exprs,
               list( a = quote(ifelse(x>1, 1L, 0L))
                   , b = quote(ifelse(y < x, 1L, 0L))
                   )
              )
})
