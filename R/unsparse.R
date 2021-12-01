#' @importFrom dplyr na_if
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
    bquote(switch( rule
                 , ..(elist(n = dplyr::coalesce(1L - fail, -1L))) #invalid = 0, or NA = -1
                 , 1L  # valid = 1
                 ), splice = TRUE)
 })
 names(c_cols) <- rnms
 
 passes <- dplyr::transmute(fails, !!!key, !!!c_cols)
 passes <- dplyr::group_by(passes, !!!key)
 # and summarise to have the same rows are the original table
 passes <- dplyr::summarise(passes, dplyr::across(!!rnms, min, na.rm=TRUE))
 passes <- dplyr::mutate(passes, dplyr::across(!!rnms, na_if, -1L))
 passes
}