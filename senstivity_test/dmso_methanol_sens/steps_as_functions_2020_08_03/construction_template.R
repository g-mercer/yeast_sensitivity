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

treatments <- c("control", "dmso", "methanol", "mixture")

dmso_meth_sens <- read.csv(file = "./results/dmso_meth_no_blanks_2020_08_14_formatted.csv", header = FALSE, stringsAsFactors = FALSE)

sens_data_corr <- sens_data_form(dmso_meth_sens)

treatments <- c("control", "dmso", "methanol", "mixture")

