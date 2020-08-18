library(tidyverse)
library(plyr)
library(knitr)

sens_data_form <- function(sens_data) {
  # transpose
  sens_data_trans <- t(sens_data)
  # save first row as colnames
  colnames(sens_data_trans) <- sens_data_trans [1, ]
  # delete first row, which is now duplicate of colnames
  sens_data_colnames <- sens_data_trans [-1, ]
  # remove any empty rows. Sometimes created when importing csv file 
  sens_data_no_blanks <- sens_data_colnames[rowSums(is.na(sens_data_colnames)) != ncol(sens_data_colnames),]
  # save first column as rownames
  rownames(sens_data_no_blanks) <- sens_data_no_blanks [ ,1]
  # delete first column, which is now duplicate of rownames
  sens_data_rownames <- sens_data_no_blanks [ ,-1]
  # convert matrix into dataframe
  sens_data_df <- as.data.frame(sens_data_rownames)
  # extract blanks and save as separate dataframe
  blanks <- sens_data_df %>% select(starts_with("blank"))
  # convert blanks from factor to numeric
  indx <- sapply(blanks, is.factor)
  blanks[indx] <- lapply(blanks[indx], function(x) as.numeric(as.character(x)))
  # blanks mean for each time point
  blanks_mean <- rowMeans(blanks[,c(1:ncol(blanks))])
  # remove blanks from sens_data_df
  sens_data_nb <- sens_data_df %>% select(-(starts_with("blank")))
  # add blank_means
  sens_data_nb$blanks_mean = blanks_mean
  # convert into numerics from factors for whole dataframe
  indx2 <- sapply(sens_data_nb, is.factor)
  sens_data_nb[indx2] <- lapply(sens_data_nb[indx2], function(x) as.numeric(as.character(x)))
  # substract blank_means from other columns
  sens_data_nb[1:ncol(sens_data_nb)] <- sens_data_nb[1:ncol(sens_data_nb)] - sens_data_nb$blanks_mean
  # remove empty blanks_mean column 
  sens_data_corr <- sens_data_nb %>% select(-(starts_with("blank")))
}

dmso_meth_sens <- read.csv(file = "./results/dmso_meth_no_blanks_2020_08_14_formatted.csv", header = FALSE, stringsAsFactors = FALSE)

sens_data_corr <- sens_data_form(dmso_meth_sens)

treatments <- colnames(sens_data_corr)

maximum_growth_rate <- function(treatments, sens_data_corr) {
  
  max_slopes_table <- tibble()
  
    # create time 
    time <- seq(0, 960, 5)
    # log transform everything
    log_treatment <<- log(sens_data_corr)
   
    for (i in 1:length(log_treatment)) {
    time_mean_treatment <<- data.frame(time = time, OD = log_treatment[, i])  

    # calcularing gradient of 5 time point windows along linearised treatment growth curve. 
    VAR <- seq(1, 189, 1)
    treatment_tframeslope <<- data.frame(matrix(nrow = 189, ncol = 1))
    
    for (k in 1:length(VAR)) {
      treatment_window <- time_mean_treatment [((VAR[k]):(VAR[k]+4)), ]
      treatment_lm <- lm(formula = OD ~ time, data = treatment_window)
      treatment_slope <- treatment_lm$coefficients[2]
      treatment_tframeslope[VAR[k] , ] <- treatment_slope
    }
    
    start <- seq (0, 940, 5)
    
    end <- seq (20, 960, 5)
    
    treatment_gradients <- data.frame(start_time=start, end_time=end, slope=treatment_tframeslope)
    
    colnames(treatment_gradients) <- c("start_time", "end_time", "slope")
    
    colMax <- function(data) sapply(data, max, na.rm = TRUE)
    
    # find the maximum slope and return windows that are ≥ 90% of the maximum gradient
    treatment_max <- colMax(treatment_gradients)
    
    treatment_max_df <- data.frame(treatment_max)
    
    treatment_max_slope <- treatment_max_df [3, 1]
    
    treatment_expo_phase_timepoints <- which(treatment_gradients$slope >= (0.90*treatment_max_slope))
    
    max_slopes_table [i , 1] <- treatment_max_slope
    
    max_slopes_table [i , 2] <- treatments[i]
    
    max_slopes_table [i , 3] <- list(list(treatment_expo_phase_timepoints))
    
  }
  colnames(max_slopes_table) <- c("Maximum Gradient", "Treatment", "Timepoint Windows ≥90% of Maximum Gradient")
  
  max_slopes_table
}
maximum_growth_rate_table <- maximum_growth_rate(treatments, sens_data_corr)

kable(maximum_growth_rate_table, caption = "Maximum Gradients of DMSO, Methanol and DMSO+Methanol Treated Yeast Cells and Associated Timepoint Windows")

