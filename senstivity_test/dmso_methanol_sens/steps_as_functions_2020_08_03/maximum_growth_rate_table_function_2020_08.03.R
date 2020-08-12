treatments <- c("control", "dmso", "methanol", "mixture")

maximum_growth_rate <- function(treatments, sens_data_corr) {
  
  max_slopes_table <- tibble()
  
  
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
    
    # calcularing gradient of 5 time point windows along linearised treatment growth curve. 
    time_mean_treatment <- summ_stats_treatment [ , c(1,4)]
    VAR <- seq(1, 189, 1)
    treatment_tframeslope <- data.frame(matrix(nrow = 189, ncol = 1))
    
    
    for (k in 1:length(VAR)) {
      treatment_window <- time_mean_treatment [((VAR[k]):(VAR[k]+4)), ]
      treatment_lm <- lm(formula = mean ~ time, data = treatment_window)
      treatment_slope <- treatment_lm$coefficients[2]
      treatment_tframeslope[VAR[k] , ] <- treatment_slope
      
    }
    
    start <- seq (0, 940, 5)
    
    end <- seq (20, 960, 5)
    
    treatment_gradients <- data.frame(start_time=start, end_time=end, slope=treatment_tframeslope)
    
    colnames(treatment_gradients) <- c("start_time", "end_time", "slope")
    
    colMax <- function(data) sapply(data, max, na.rm = TRUE)
    
    # find the maximum slope and return windows that are ≥ 95% of the maximum gradient
    treatment_max <- colMax(treatment_gradients)
    
    treatment_max_df <- data.frame(treatment_max)
    
    treatment_max_slope <- treatment_max_df [3, 1]
    
    treatment_expo_phase_timepoints <- which(treatment_gradients$slope >= (0.95*treatment_max_slope))
    
    # mistake here. Not populating dataframe cell with more than one value
    
    
    max_slopes_table [i , 1] <- treatment_max_slope
    
    max_slopes_table [i , 2] <- treatments[i]
    
    max_slopes_table [i , 3] <- list(list(treatment_expo_phase_timepoints))
    
  }
  colnames(max_slopes_table) <- c("Maximum Gradient", "Treatment", "Timepoint Windows ≥95% of Maximum Gradient")
  
  max_slopes_table
}