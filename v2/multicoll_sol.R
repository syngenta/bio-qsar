### Function to determine columns to drop due to multicollinearity
### Provides a list with results from this function and carets alternative
### before and after manipulation as well as the names of saved features

multicoll_sol <- function(data, cut) {
  
  corr_mtx <- abs(cor(data, use = "pairwise.complete.obs"))
  
  caret_drop1 <- findCorrelation(corr_mtx, cutoff = cut)
  caret_drop_names1 <- names(data)[caret_drop1]
  
  avg_corr <- rowMeans(corr_mtx) %>% enframe()
  
  dropcols <- vector()
  columns <- c("v1", "v2", "v1.target", "v2.target","corr", "drop")
  res <- data.frame(matrix(nrow = 0, ncol = length(columns)))
  
  for (row in 1:(nrow(corr_mtx)-1)) {
    for (col in (row +1):nrow(corr_mtx)) {
      if(corr_mtx[row, col] > cut) {
        if (pull(avg_corr[row, 2]) > pull(avg_corr[col, 2])){
          dropcols <- c(dropcols, row)
          drop <- colnames(corr_mtx)[row]
        } else {
          dropcols <- c(dropcols, col)
          drop <- colnames(corr_mtx)[col]
        }
        
        res <- rbind(res, c(colnames(corr_mtx)[row], colnames(corr_mtx)[col], pull(avg_corr[row, 2]),
                            pull(avg_corr[col, 2]), corr_mtx[row, col], drop))
      }
    }
  }
  
  colnames(res) <- columns
  
  all_corr_vars <- unique(c(res$v1, res$v2))
  
  poss_drop <- unique(res$drop)
  
  keep <- all_corr_vars[!(all_corr_vars %in% poss_drop)]
  
  p <- res[((res$v1 %in% keep) | (res$v2 %in% keep)), c("v1", "v2")]
  q <- unique(c(p$v1, p$v2))
  drop <- q[!(q %in% keep)]
  
  poss_drop <- poss_drop[!(poss_drop %in% drop)]
  
  m <- res[((res$v1 %in% poss_drop) | (res$v2 %in% poss_drop)) , c("v1", "v2", "drop")]
  
  more_drop <- unique(m[((!m$v1 %in% drop) & (!m$v2 %in% drop)), "drop"])
  
  drop <- sort(c(drop, more_drop))
  
  data2 <- data %>% select(-all_of(drop))
  corr_mtx2 <- abs(cor(data2, use = "pairwise.complete.obs"))
  
  caret_drop2 <- findCorrelation(corr_mtx2, cutoff = cut)
  caret_drop_names2 <- names(data2)[caret_drop2]
  
  saved <- setdiff(caret_drop_names1, drop)
  
  output <- list(drop = drop, caret_before = caret_drop_names1, 
                 caret_after = caret_drop_names2, saved = saved)
}
