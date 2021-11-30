#' @export
summary.tbl_validation <- function(object, ...){
  cf <- object
  df <- as.data.frame(aggregate(cf))
  s <- data.frame( name = names(cf$exprs)
                   , items = 0
                   , npass = 0
                   , nfail = 0 #ifelse(cf$working, 0, NA)
                   , nNA   = 0 #ifelse(cf$working, 0, NA)
                   , warning = FALSE
                   , error   = !cf$working
                   , expression = as.character(unname(cf$exprs))
  )
  s$items[cf$working] <- df$npass + df$nfail + df$nNA
  s$npass[cf$working] <- df$npass
  s$nfail[cf$working] <- df$nfail
  s$nNA[cf$working] <- df$nNA
  s$items[!cf$record_based] <- pmin(s$items[!cf$record_based], 1)
  s$npass[!cf$record_based] <- pmin(s$npass[!cf$record_based], 1)
  s$nfail[!cf$record_based] <- pmin(s$nfail[!cf$record_based], 1)
  s$nNA[!cf$record_based] <- pmin(s$nNA[!cf$record_based], 1)
  s
}
