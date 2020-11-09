# useful chunks of code and notes
# Just Thiacloprid

# linear model
thiacloprid <- model_df_assigned_controls [grep(pattern = "thiacloprid", x = model_df_assigned_controls$insecticide), ]

model_4 <- lm(auc_l ~ concentration + day, data = thiacloprid)

summary(model_4)

plot(model_4)

plot(density(model_4$residuals))

# Inspect the model diagnostic metrics
model_metrics_thia <- augment(model_4) 

shapiro_test(model_metrics_thia$.resid)

# mixed model
library(lme4)

thiacloprid_mm <- lmer(auc_l ~ concentration + (1|day), data = thiacloprid)

summary(thiacloprid_mm)

# Day explains 56.7% of the variance remaining after the variance explained by fixed effects. Intercept and slope comparable between linear and mixed model. 

formatted_growthcurver_df_r <- aucl_formatting_function(growthcurver_data = growthcurver_data, control_conc = 0.0001, aucl_or_r = 4)

assigned_controls_df_r <- insecticides_assigned_controls(formatted_growthcurver_df_r)

by_insecticide_dfs_r <- by_insecticide_df_function(assigned_controls_df_r)

plot_list <- list()

for (insecticide in 1:length(by_insecticide_dfs_r)) {
  
  title <- paste0(names(by_insecticide_dfs_r[insecticide]), " dose-response curve", sep = "" )
  
  df <- by_insecticide_dfs_r[[insecticide]]
  
  drc <- ggplot(df, aes(x=concentration,y=r, color=day)) +
    geom_point() +
    geom_line() +
    scale_x_log10(breaks = c(0.0001, 10^(-3:10)), 
                  labels = c(0, math_format()(-3:10))) +
    ylim(0, NA) +
    ggtitle(title) +
    labs(x="Concentration (log scale)", y="AUC",size=1) +
    theme(panel.background = element_rect(fill = "white"), plot.margin = margin(1, 1, 1, 1, "cm"),
          axis.line = element_line(), strip.text.x = element_blank(), plot.background = element_rect(
            fill = "grey90",
            colour = "black",
            size = 1
          )
    )
  
  plot_list [[insecticide]] <- drc
  
}

plot_list

# All displayed at once

title <- "replicates by day for insecticides"

drc <- ggplot(assigned_controls_df, aes(x=concentration,y=auc_l, color=day)) +
  facet_wrap(~ insecticide) +
  geom_point() +
  geom_line() +
  scale_x_log10(breaks = c(0.0001, 10^(-3:10)), 
                labels = c(0, math_format()(-3:10))) +
  ylim(0, NA) +
  ggtitle(title) +
  labs(x="Concentration (log scale)", y="AUC",size=1) +
  theme(panel.background = element_rect(fill = "white"), plot.margin = margin(1, 1, 1, 1, "cm"),
        axis.line = element_line(), plot.background = element_rect(
          fill = "grey90",
          colour = "black",
          size = 1
        )
  )

drc

# Plot with axis breaks
require(scales)

plot_list <- list()

for (insecticide in 1:length(by_insecticide_dfs)) {
  
  title <- paste0(names(by_insecticide_dfs[insecticide]), " dose-response curve", sep = "" )
  
  df <- by_insecticide_dfs[[insecticide]]
  
  # introduces axis break.
  df$facet <- ifelse(df$concentration == min(df$concentration), 1, 2)
  
  drc <- ggplot(df, aes(x=concentration,y=auc_l, color=day)) +
    geom_point(data = subset(df, facet == 1)) +
    geom_point(data = subset(df, facet == 2)) +
    geom_line() +
    scale_x_log10(breaks = c(0.0001, 10^(-3:10)), 
                  labels = c(0, math_format()(-3:10))) +
    ylim(0, NA) +
    ggtitle(title) +
    labs(x="Concentration (log scale)", y="AUC",size=1) +
    facet_grid(~facet, scales = 'free', space = 'free') +
    theme(panel.background = element_rect(fill = "white"), plot.margin = margin(1, 1, 1, 1, "cm"),
          axis.line = element_line(), strip.text.x = element_blank(), plot.background = element_rect(
            fill = "grey90",
            colour = "black",
            size = 1
          )
    )
  
  plot_list [[insecticide]] <- drc
  
}

plot_list