all_repli_separ <- function(sens_data_corr) {
  
time <- seq(0, 960, 5)
sens_data_corr$time <- time
sens_data_corr_long <- sens_data_corr %>% gather(condition, OD, -time)

sens_data_corr_long
}

repli_separ_long <- all_repli_separ(sens_data_corr)