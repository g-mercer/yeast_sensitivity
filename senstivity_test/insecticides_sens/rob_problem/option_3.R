# option 3. Assign controls to control level in insecticide factor and give each concentration level 8 controls. 
# convert to factor
model_df_anomalies_removed$insecticide <- as.factor(model_df_anomalies_removed$insecticide)

# convert concentration to factor
model_df_anomalies_removed$concentration <- as.factor(model_df_anomalies_removed$concentration)

# reorder insecticide factor so control comes first
model_df_anomalies_removed$insecticide <- relevel(model_df_anomalies_removed$insecticide, "control")

mixed.lmer <- lmer(auc_l ~ insecticide + concentration + insecticide*concentration + (1|day), data = model_df_anomalies_removed)

summary(mixed.lmer)

plot(mixed.lmer)

qqnorm(resid(mixed.lmer))

qqline(resid(mixed.lmer))

# model and term significance.
full.lmer <- lmer(auc_l ~ insecticide + concentration + (insecticide*concentration) + (1|day), data = model_df_anomalies_removed, REML = FALSE)

reduced.lmer <- lmer(auc_l ~ insecticide + concentration + (1|day), data = model_df_anomalies_removed, REML = FALSE)

anova(reduced.lmer, full.lmer) 

drop1(full.lmer,test="Chisq")