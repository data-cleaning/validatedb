unsparse <- function(cf){
 key <- lapply(cf$key, as.symbol)
 fails <- cf$tbl
 fails <- dplyr::select(fails, !!!key)
 fails <- dplyr::left_join(fails, cf$query, by = cf$key)
 
 rnms <- names(cf$exprs)
 c_cols <- 
   lapply(rnms, function(n){
   bquote(switch(rule, ..(elist(n = !fail)), TRUE), splice = TRUE)
 })
 names(c_cols) <- rnms
 
 passes <- dplyr::transmute(fails, !!!key, !!!c_cols)
 passes <- dplyr::group_by(passes, !!!key)
 passes <- dplyr::summarise(passes, across(!!rnms, min, na.rm=TRUE))
 passes
}