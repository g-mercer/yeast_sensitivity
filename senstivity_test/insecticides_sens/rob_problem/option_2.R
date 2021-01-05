# option 2. Assign controls to control level insecticide factor with concentration 0.
model_df_anomalies_removed <- model_df_controls_zero

# convert to factor
model_df_anomalies_removed$insecticide <- as.factor(model_df_anomalies_removed$insecticide)

# convert concentration to factor
model_df_anomalies_removed$concentration <- as.factor(model_df_anomalies_removed$concentration)

# reorder concentration factor so "0" (control) comes first
model_df_anomalies_removed$concentration <- relevel(model_df_anomalies_removed$concentration, "0")

# reorder insecticide factor so control comes first
model_df_anomalies_removed$insecticide <- relevel(model_df_anomalies_removed$insecticide, "control")

# swapping around insecticide and concentration alters what is included in output not just order like usual. 
mixed.lmer_1 <- lmer(auc_l ~ concentration + insecticide + concentration*insecticide + (1|day), data = model_df_anomalies_removed)

summary(mixed.lmer_1)

mixed.lmer <- lmer(auc_l ~ insecticide + concentration + insecticide*concentration + (1|day), data = model_df_anomalies_removed)

summary(mixed.lmer)

# model and term significance.
full.lmer <- lmer(auc_l ~ insecticide + concentration + (insecticide*concentration) + (1|day), data = model_df_anomalies_removed, REML = FALSE)

reduced.lmer <- lmer(auc_l ~ insecticide + concentration + (1|day), data = model_df_anomalies_removed, REML = FALSE)

anova(reduced.lmer, full.lmer) 

drop1(full.lmer,test="Chisq")
