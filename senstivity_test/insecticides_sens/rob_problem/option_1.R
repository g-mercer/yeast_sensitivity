# option 1. Controls assigned to insecticide levels with new concentration level 0.
model_df_anomalies_removed <- model_df_assigned_controls

# convert to factor
model_df_anomalies_removed$insecticide <- as.factor(model_df_anomalies_removed$insecticide)

# convert concentration to factor
model_df_anomalies_removed$concentration <- as.factor(model_df_anomalies_removed$concentration)

# reorder concentration factor so "0" (control) comes first
model_df_anomalies_removed$concentration <- relevel(model_df_anomalies_removed$concentration, "0")

mixed.lmer <- lmer(auc_l ~ insecticide + concentration + insecticide*concentration + (1|day), data = model_df_anomalies_removed)

summary(mixed.lmer)

plot(mixed.lmer)

# model and term significance.
full.lmer <- lmer(auc_l ~ insecticide + concentration + (insecticide*concentration) + (1|day), data = model_df_anomalies_removed, REML = FALSE)

reduced.lmer <- lmer(auc_l ~ insecticide + concentration + (1|day), data = model_df_anomalies_removed, REML = FALSE)

anova(reduced.lmer, full.lmer) 

drop1(full.lmer,test="Chisq")
