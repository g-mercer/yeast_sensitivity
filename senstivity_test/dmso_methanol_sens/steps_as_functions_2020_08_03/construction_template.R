library(tidyverse)
library(plyr)
library(knitr)
library(ggpubr)
library(rstatix)

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

maximum_growth_rate_individual_replicates <- function(treatments, sens_data_corr) {
  
  max_slopes_table <- tibble()
  
    # create time 
    time <- seq(0, 960, 5)
    # log transform everything
    log_treatment <- log(sens_data_corr)
   
    for (i in 1:length(log_treatment)) {
    time_mean_treatment <- data.frame(time = time, OD = log_treatment[, i])  

    # calcularing gradient of 5 time point windows along linearised treatment growth curve. 
    VAR <- seq(1, 189, 1)
    treatment_tframeslope <- data.frame(matrix(nrow = 189, ncol = 1))
    
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
    
    # find the maximum slope and return windows that are ≥ 80% of the maximum gradient
    treatment_max <- colMax(treatment_gradients)
    
    treatment_max_df <- data.frame(treatment_max)
    
    treatment_max_slope <- treatment_max_df [3, 1]
    
    treatment_expo_phase_timepoints <- which(treatment_gradients$slope >= (0.80*treatment_max_slope))
    
    max_slopes_table [i , 1] <- treatment_max_slope
    
    max_slopes_table [i , 2] <- treatments[i]
    
    max_slopes_table [i , 3] <- list(list(treatment_expo_phase_timepoints))
    
  }
  colnames(max_slopes_table) <- c("Maximum Gradient", "Treatment", "Timepoint Windows ≥80% of Maximum Gradient")
  
  max_slopes_table
}
maximum_growth_rate_table <- maximum_growth_rate_individual_replicates(treatments, sens_data_corr)

kable(maximum_growth_rate_table, caption = "Maximum Gradients of DMSO, Methanol and DMSO+Methanol Treated Yeast Cells and Associated Timepoint Windows")



exponential_phase <- function(maximum_growth_rate_table, treatments, sens_data_corr) {
  
  sens_data_corr_log <- log(sens_data_corr)
  time <- seq(0, 950, 5)
  expo_phase_slope_ouput <- data.frame(matrix(nrow = length(treatments), ncol = 2))
  
  for (i in 1:length(treatments)) {
  time_windows <- maximum_growth_rate_table [i , 3]
  time_windows_vector <- unlist(time_windows, use.names=FALSE)
  
  # splits the vector where the gap between values is >5. 
  expo_phase <- split(time_windows_vector, cumsum(c(1, diff(time_windows_vector) > 5 )))
  
  # returns the longest generated list. Remember that this list contains timepoint windows.
  expo_phase_longest <- expo_phase [which.max(lengths(expo_phase))]
  expo_phase_longest_vector <- unlist(expo_phase_longest, use.names=FALSE)
  
  # extract from sens_data_corr_log the expo_phase for each replicate. Add 4 because indexing corresponds to beginning of timepoint window not end. 
  expo_phase_points <- sens_data_corr_log [expo_phase_longest_vector[which.min(expo_phase_longest_vector)]:(expo_phase_longest_vector[which.max(expo_phase_longest_vector)]+4), i]
  
  expo_phase_points_df <- as.data.frame(expo_phase_points)
  expo_phase_points_df$time <- time [expo_phase_longest_vector[which.min(expo_phase_longest_vector)]:(expo_phase_longest_vector[which.max(expo_phase_longest_vector)]+4)]
  
  expo_phase_lm <- lm(formula = expo_phase_points ~ time, data = expo_phase_points_df)
  expo_phase_slope <- expo_phase_lm$coefficients[2]
  
  expo_phase_slope_ouput [i , 2] <- expo_phase_slope
  expo_phase_slope_ouput [i , 1] <- treatments [i]
  }
  expo_phase_slope_ouput
} 

exponential_phase_slopes <- exponential_phase(maximum_growth_rate_table, treatments, sens_data_corr)

# give replicates the same name according to their treatment
exponential_phase_slopes_group_names <- str_replace_all(exponential_phase_slopes [ , 1], "\\d", "")
exponential_phase_slopes [ , 1] <- exponential_phase_slopes_group_names

colnames(exponential_phase_slopes) <- c("group", "growth_rate")

# begin the statistical analysis
exponential_phase_slopes <- exponential_phase_slopes %>%
  reorder_levels(group, order = c("control", "dmso", "methanol", "mixture"))

exponential_phase_slopes %>% group_by(group) %>% get_summary_stats(growth_rate, type = "mean_sd")

# visualisation
ggboxplot(exponential_phase_slopes, x = "group", y = "growth_rate")

# check ANOVA assumptions - 1) outliers
exponential_phase_slopes %>% group_by(group) %>% identify_outliers(growth_rate)

# there was an extreme outlier. Can include the outlier in the analysis anyway if you do not 
# believe the result will be substantially affected. This can be evaluated by comparing the 
# result of the ANOVA test with and without the outlier. It’s also possible to keep the outliers 
# in the data and perform a robust ANOVA test using the WRS2 package.

# 2) normality - Analyzing the ANOVA model residuals to check the normality for all groups together. 
# This approach is easier and it’s very handy when you have many groups or if there are few data
# points per group.

# NOTE - Note that, normality test is sensitive to sample size. Small samples most often pass normality tests.
# Therefore, it’s important to combine visual inspection and significance test in order to take the right decision.
# This is why I chose to model residuals not each group individually. 

# build the linear model
model  <- lm(growth_rate ~ group, data = exponential_phase_slopes)

# Create a QQ plot of residuals. Correlation between given data and normal distribution.
ggqqplot(residuals(model))

# Density plot: the density plot provides a visual judgment about whether the distribution is bell shaped.
library("ggpubr")
ggdensity(exponential_phase_slopes$growth_rate, 
          main = "Density plot of growth_rate",
          xlab = "growth_rate")

# Shapiro-Wilk test of normality
shapiro_test(residuals(model))

# from these three tests I conclude that the probability distribution of the data is 
# not significantly different from a normal distribution. 

# if I check the normality assumption by group DMSO isn't normally distributed. Feel like my data is borderline
# going to carry out ANOVA and Kruskal-Wallis test to see if they yield different results. 
exponential_phase_slopes %>% group_by(group) %>% shapiro_test(growth_rate)

# 3) homogeneity of variance assumption

# a "residuals versus fits plot" tests homogeneity of variance
plot(model, 1)

# the three tests below also do this. For all the null hypothesis is that variance is homogeneous (Homoscedasticity)
# Levene and fligner are robust against departures from normality. 
exponential_phase_slopes %>% levene_test(growth_rate ~ group)

fligner.test(growth_rate ~ group, data = exponential_phase_slopes)

bartlett.test(growth_rate ~ group, data = exponential_phase_slopes)

# there there is no significant difference between variance across groups. Therefore, we can assume homogeneity of variance in the different treatment groups.

# ANOVA. Groups are significantly different
res.aov <- exponential_phase_slopes %>% anova_test(growth_rate ~ group)
res.aov

# Tukey post-hoc tests to perform multiple pairwise comparisons between groups. 
pwc <- exponential_phase_slopes %>% tukey_hsd(growth_rate ~ group)
pwc

# Visualization: box plots with p-values
pwc <- pwc %>% add_xy_position(x = "group")
ggboxplot(exponential_phase_slopes, x = "group", y = "growth_rate") +
  stat_pvalue_manual(pwc, hide.ns = TRUE) +
  labs(
    subtitle = get_test_label(res.aov, detailed = TRUE),
    caption = get_pwc_label(pwc)
  )

# Tukey pairwise comparisons reveal a significant difference between control vs dmso and control vs mixture. 

# Does 1) removing the extreme outlier and then performing an ANOVA and 2) removing the extreme outlier
# and then performing a Kruskal-Wallis test affect the results?

# groups with unequal sample size can affect the statistical power of ANOVA. Can affect the homogeneity of variance.
# if the homogeneity of variance is affected perform a Welch.

# 1) identifying extreme outliers and removing them.
outlier_test <- exponential_phase_slopes %>% group_by(group) %>% identify_outliers(growth_rate)
treatments <- outlier_test [ , 1]
treatments <- as.matrix(treatments)
treatments <- as.character(treatments)

outliers <- c()
for (i in 1:length(treatments)) {
  
  if (outlier_test[i, 4] == TRUE) {
    outliers <- outlier_test[i, 2]
  }
}

outliers <- as.matrix(outliers)

for (i in 1:length(outliers)) {
  outlier_rows <- which(exponential_phase_slopes$growth_rate == outliers[i])
  exponential_phase_slopes <- exponential_phase_slopes [-c(outlier_rows), ]
}

# performing ANOVA on dataset without extreme outliers.
# test assumptions
# visualisation
ggboxplot(exponential_phase_slopes, x = "group", y = "growth_rate")

# 1) outliers - no extreme outliers
exponential_phase_slopes %>% group_by(group) %>% identify_outliers(growth_rate)

# 2) normality - no sig diff to normal distribution

#build the linear model
model  <- lm(growth_rate ~ group, data = exponential_phase_slopes)

# Create a QQ plot of residuals. Correlation between given data and normal distribution.
ggqqplot(residuals(model))

# Density plot: the density plot provides a visual judgment about whether the distribution is bell shaped.
library("ggpubr")
ggdensity(exponential_phase_slopes$growth_rate, 
          main = "Density plot of growth_rate",
          xlab = "growth_rate")

# Shapiro-Wilk test of normality
shapiro_test(residuals(model))

# 3) homogeneity of variance - Homoscedastic

# a "residuals versus fits plot" tests homogeneity of variance
plot(model, 1)

# the three tests below also do this. For all the null hypothesis is that variance is homogeneous (Homoscedasticity)
# Levene and fligner are robust against departures from normality. 
exponential_phase_slopes %>% levene_test(growth_rate ~ group)

fligner.test(growth_rate ~ group, data = exponential_phase_slopes)

bartlett.test(growth_rate ~ group, data = exponential_phase_slopes)

# ANOVA - significantly different 
res.aov <- exponential_phase_slopes %>% anova_test(growth_rate ~ group)
res.aov

# Tukey post-hoc tests to perform multiple pairwise comparisons between groups. Same groups still different. 
pwc <- exponential_phase_slopes %>% tukey_hsd(growth_rate ~ group)
pwc

# Visualization: box plots with p-values
pwc <- pwc %>% add_xy_position(x = "group")
ggboxplot(exponential_phase_slopes, x = "group", y = "growth_rate") +
  stat_pvalue_manual(pwc, hide.ns = TRUE) +
  labs(
    subtitle = get_test_label(res.aov, detailed = TRUE),
    caption = get_pwc_label(pwc)
  )

# Kruskal-Wallis test without extreme outlier
res.kruskal <- exponential_phase_slopes %>% kruskal_test(growth_rate ~ group)
res.kruskal

# eta squared, based on the H-statistic, is a measure of the Kruskal-Wallis test effect size.
# the percentage of variance in the dependent variable explained by the independent variable.
exponential_phase_slopes %>% kruskal_effsize(growth_rate ~ group)

# pairwise comparisons - again control vs dmso and control vs mixture are significantly different. 
# Compared to the Wilcoxon’s test, the Dunn’s test takes into account the rankings used 
# by the Kruskal-Wallis test. It also does ties adjustments.
pwc <- exponential_phase_slopes %>% 
  dunn_test(growth_rate ~ group, p.adjust.method = "bonferroni") 
pwc

# Visualization: box plots with p-values
pwc <- pwc %>% add_xy_position(x = "group")
ggboxplot(exponential_phase_slopes, x = "group", y = "growth_rate") +
  stat_pvalue_manual(pwc, hide.ns = TRUE) +
  labs(
    subtitle = get_test_label(res.kruskal, detailed = TRUE),
    caption = get_pwc_label(pwc)
  )

