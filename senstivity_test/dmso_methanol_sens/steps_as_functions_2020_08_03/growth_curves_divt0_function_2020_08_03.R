treatments <- c("control", "dmso", "methanol", "mixture")

divt0_growth_curves <- function(treatments, sens_data_corr) {
  
  summ_stats_all_treatments <- data.frame(matrix(nrow = 193, ncol = length(treatments)))
  colnames(summ_stats_all_treatments) <- treatments
  
  for (i in 1:length(treatments)) {
    
    # extract only treatment x
    treatment <- sens_data_corr %>% select(starts_with(treatments[i]))
    # divide by t0
    treatment_repl <- seq(1, ncol(treatment), 1)
    treatment_from_1 <- data.frame(matrix(nrow = 193, ncol = ncol(treatment)))
    
    for (j in 1:length(treatment_repl)) {
      treatment_divide_t0 <- treatment [ , treatment_repl[j]] / treatment [1, treatment_repl[j]]
      treatment_from_1[ , treatment_repl[j]] <- treatment_divide_t0
    } 
    # create time 
    time <- seq(0, 960, 5)
    # log transform everything
    log_treatment <- log(treatment_from_1)
    # add time to first column 
    log_treatment$time <- time
    # convert from wide to long data format
    treatment_long <- log_treatment %>% gather(condition, OD, -time)
    # order treatment_long by time
    treatment_long_ord_time <- treatment_long[order(treatment_long$time),]
    # convert condition column to treatment
    treatment_long_ord_time$condition <- c("treatment")
    # summary stats
    summ_stats_treatment <- ddply(treatment_long_ord_time, c("time", "condition"), summarise, 
                                  N    = length(OD), 
                                  mean = mean(OD), 
                                  sd   = sd(OD), 
                                  se   = sd / sqrt(N)
    )
    
    summ_stats_all_treatments[ , i] <- summ_stats_treatment [ , 4]
  }
  summ_stats_all_treatments$time <- time 
  
  summ_stats_all_treatments_long <- summ_stats_all_treatments %>% gather(condition, OD, -time)
  
  summ_stats_all_treatments_long
}

meanOD_all_treatments_divt0 <- divt0_growth_curves(treatments, sens_data_corr)

