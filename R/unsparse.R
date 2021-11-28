unsparse <- function(cf){
 key <- lapply(cf$key, as.symbol)

 # join the table (keys) with the failures
 fails <- cf$tbl
 fails <- dplyr::select(fails, !!!key)
 fails <- dplyr::left_join(fails, cf$query, by = cf$key)
 
 # cran checks
 fail <- NULL
 
 # derive columns for each rules (pivoting)
 rnms <- names(cf$exprs)
 c_cols <- 
   lapply(rnms, function(n){
    bquote(switch(rule, ..(elist(n = dplyr::coalesce(!fail, -1L))), TRUE), splice = TRUE)
 })
 names(c_cols) <- rnms
 
 passes <- dplyr::transmute(fails, !!!key, !!!c_cols)
 passes <- dplyr::group_by(passes, !!!key)
 # and summarise to have the same rows are the original table
 passes <- dplyr::summarise(passes, dplyr::across(!!rnms, ~ dplyr::na_if(min(.x, na.rm=TRUE), -1L), na.rm=TRUE))
 passes
}