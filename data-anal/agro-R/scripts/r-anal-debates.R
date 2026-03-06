# load packages
install.packages("tidyverse")
install.packages("dplyr")
install.packages("fixest") # use for regression given clustered data (i don't think so) 
install.packages("gtsummary") # use for regression tables for regression comparison and models
install.packages("performance") # used to compare models "compare_performance(m_sim, m_real)
install.packages("broom") # used to extract regression characteristics and create a tidy table for plotting
install.packages("tidyr")
install.packages("kable")
library(ggplot2)
library(tidyverse)
library(dplyr)

# csv import for debate level and agent-level
# change from . to .. or the reverse if it doesn't work
df_batch <- read.csv("./data/batch_summary.csv")

## EXEC SUMMARY
exec_summary <- data.frame(
  Model = c("Consensus", "Clustering", "Bipolarization"),
  Best_Mae = pmin(model_wide_full$`false`, model_wide_full$`true`),
  Best_Heterogeneous_mae = model_wide_full$`true`,
  Best_Homogeneous_mae = model_wide_full$`false`,
  Winner = c("X", "", "")
)
  

#### basic exploration ####
# use nrow to check rows, what type of model, unique debates, distribution of conditions
nrow(df_batch)

# check model type
table(df_batch$model_type)

# find unique debates
length(unique(df_batch$selected_debate_id))

# if neutral zone > 0 for bipolarization then need to filter out these rows
neutral_zone_exp <- df_batch %>%
  filter(model_type == "bipolarization" & neutral_zone_width < 0.0) 

# homophily impact check (could lower homophily allow for better convergence to empirical targets?)
cor(df_batch$homophily_strength, df_batch$mae)

# check constraint violations (in bipol) check whenther repulsion threshold <= confidenc ethreshold
constraint_violations <- df_batch %>%
  filter(model_type == "bipolarization") %>%
  filter(repulsion_threshold <= confidence_threshold)

print(paste("Constraint violations (repulsion <= confidence):",
            nrow(constraint_violations)))

if (nrow(constraint_violations) > 0) {
  print("WARNING found invalid parameter combinations")
  print(constraint_violations)
}


#### parameters ####
# parameter correlations with mae
params_cor_full <- df_batch %>%
  group_by(model_type, use_heterogeneous_agents) %>%
  summarize(
    cor_convergence = cor(convergence_rate, mae),
    cor_homophily = cor(homophily_strength, mae),
    cor_confidence = cor(confidence_threshold, mae),
    cor_repulsion_strength = cor(repulsion_strength, mae, use = "complete.obs"), # complete.obs correlations for complete observations
    cor_repulsion_threshold = cor(repulsion_threshold, mae, use = "complete.obs")
  )

# reshape params for heatmap
params_long <- params_cor_full %>%
  pivot_longer(cols = starts_with("cor_"),
               names_to = "parameter",
               values_to = "correlation")

# parameter interaction regimes
param_regimes <- df_batch %>%
  mutate(regimes = paste0(
    ifelse(homophily_strength > 0.5, "High_hom", "Low_hom"), "_",
    ifelse(convergence_rate > 0.3, "Fast", "Slow"))) %>%
  group_by(regimes, model_type) %>%
  summarize(mae_mean = mean(mae))

# convergence analysis
convergence_anal <- df_batch %>%
  group_by(model_type, current_condition) %>%
  summarize(
    cycles_mean = mean(convergence_cycle),
    cycles_sd = sd(convergence_cycle),
    cycles_min = min(convergence_cycle),
    cycles_max = max(convergence_cycle),
    .groups = 'drop'
  )

print("Convergence cycle analysis")
print(convergence_anal)

# debate evolution
# convergence vs divergence, shows which models and under which exp conditions models achieve convergence/bipol
conv_diff <- df_batch %>%
  mutate(outcome = ifelse(opinion_variance < 0.1, "Convergence", "Polarization")) %>%
  group_by(model_type, current_condition, outcome) %>%
  summarize(n = n())

print(conv_diff)

#### failures of models and predictions ####
# best parameters per model
# use slice_min(mae, n=1) and then select by model and params
best_params <- df_batch %>%
  group_by(model_type) %>%
  slice_min(mae, n=1) %>%
  select(model_type, convergence_rate, confidence_threshold, repulsion_strength,
         repulsion_threshold, mae, current_condition, selected_debate_id)

print("Best parameters per model")
print(best_params)

# top 10 best parameter sets for each model / group by moel, distinct, then slice_min(mae, n=10), then select model and params, mae
top10_per_model <- df_batch %>%
  group_by(model_type) %>%
  distinct(convergence_rate, confidence_threshold, repulsion_strength,
           repulsion_threshold, .keep_all = TRUE) %>%
  slice_min(mae, n=10) %>%
  select(model_type, convergence_rate, confidence_threshold, repulsion_strength,
         repulsion_threshold, mae)

print("top 10 parameters for each model")
print(top10_per_model)

#### cluster formation NEED TO WORK ON IMPROVING ####
# cluster formation changes
clusters <- df_batch %>%
  mutate(cluster_change = num_clusters - initial_num_clusters) %>%
  group_by(model_type, selected_debate_id) %>%
  summarize(mean_cluster_change = mean(cluster_change))

#### debate level insights ####
## hardest debate to predict
hardest_debates <- df_batch %>%
  group_by(selected_debate_id, current_condition) %>%
  summarize(
    mae_mean = mean(mae),
    mae_min = min(mae),
    best_model = model_type[which.min(mae)],
    .groups = 'drop'
  ) %>%
  arrange(desc(mae_mean)) %>%
  head(10)

print("Hardest debates to predict")
print(hardest_debates)

## easiest debates to predict
easiest_debates <- df_batch %>%
  group_by(selected_debate_id, current_condition) %>%
  summarize(
    mae_mean = mean(mae),
    mae_min = min(mae),
    best_model = model_type[which.min(mae)],
    .groups = 'drop'
  ) %>%
  arrange(mae_mean) %>%
  head(10)

print("Easiest debates to predict")
print(easiest_debates)

# failure predictions
failures_comp <- df_batch %>%
  mutate(failures = mae > 0.18) %>%
  group_by(model_type, failures) %>%
  summarize(
    mean_convergence = mean(convergence_rate),
    mean_homophily = mean(homophily_strength),
    pct_hetero = mean(use_heterogeneous_agents == "true") * 100,
    n_total = n()
  )

# predicting bipolarization does opinion variance chance bipol predictions?
range(df_batch$opinion_variance)

var_compar <- df_batch %>%
  mutate(var_slice = cut(opinion_variance, 
                         breaks = c(0, 0.05, 0.1, 0.15),
                         labels = c("Low", "Medium", "High"))) %>%
  group_by(model_type, var_slice) %>%
  summarize(
    n_debates = n(),
    mean_mae = mean(mae),
    mean_convergence = mean(convergence_cycle),
    .groups = 'drop')

#### stochasticity impact ####
# stochasticity check -- do different seeds give a different mae?
stochasticity_check <- df_batch %>%
  group_by(model_type, selected_debate_id, seed, convergence_rate,
           confidence_threshold, repulsion_threshold, repulsion_strength) %>%
  summarize(
    mae_mean = mean(mae),
    mae_sd = sd(mae),
    mae_min = min(mae),
    mae_max = max(mae),
    n_seeds = n(),
    .groups = 'drop'
  )

print(stochasticity_check)

# min and max stochasticity
max(stochasticity_check$mae_sd, na.rm = TRUE)
min(stochasticity_check$mae_sd, na.rm = TRUE)

## Heterogeneity impact
## does adding SD > 0 improve mae?
heterogeneity_check <- df_batch %>%
  mutate (
    has_heterogeneity = convergence_rate_sd > 0 |
      confidence_threshold_sd > 0 |
      repulsion_threshold > 0 |
      repulsion_strength > 0 
  ) %>%
  group_by (model_type, has_heterogeneity) %>%
  summarize (
    mae_mean = mean(mae),
    mae_median = median(mae),
    n = n(),
    .groups = 'drop'
  )

# hetero vs homo comparison for mae
hetero_comparison <- df_batch %>%
  group_by(model_type, use_heterogeneous_agents) %>%
  summarize(mae_mean = mean(mae), n = n(), .groups = 'drop')

print(hetero_comparison)

#### BEST ####
## BOSS summary -- need model+hetero combinations, MAE (mean and best), convergence speed, failure rate
## sample size
boss_table <- df_batch %>%
  group_by(model_type, use_heterogeneous_agents) %>%
  summarize(
    MAE = mean(mae),
    Best_MAE = min(mae),
    Convergence_Speed = mean(convergence_cycle), # speed (cycles)
    Failure_Rate = mean(mae > 0.15) * 100, # failure rate (%)
    n = n()
      ) %>%
  arrange(MAE)

write.csv(boss_table, "boss_summary.csv")
view(boss_table)

# which model performs the best overall
model_comparison <- df_batch %>%
  group_by(model_type, use_heterogeneous_agents) %>%
  summarize(
    mae_mean = mean(mae),
    mae_sd = sd(mae),
    mae_min = min(mae),
    mae_max = max(mae)
  ) %>%
  arrange(mae_mean)

print(model_comparison)

# reformating in wide format
model_wide_full <- model_comparison %>%
  select(model_type, use_heterogeneous_agents, mae_mean) %>%
  pivot_wider(names_from = use_heterogeneous_agents, values_from = mae_mean)

names(model_wide_full)

## which model is best for each condition
model_by_condition <- df_batch %>%
  group_by(model_type, current_condition, use_heterogeneous_agents) %>%
  summarize (
    mae_mean = mean(mae),
    mae_min = min(mae),
    n_debates = n_distinct(selected_debate_id),
    .groups = 'drop'
  ) %>%
  arrange(current_condition, use_heterogeneous_agents, mae_mean)

print(model_by_condition)
  
#### Plots ####
# plot of SD vs MAE for each parameter - started with convergence rate SD
ggplot(data = df_batch, mapping = aes(convergence_rate_sd, mae, color = model_type)) +
  geom_point(alpha = 0.5) +
  geom_smooth(method = "loess") + # could change this later
  labs(title = "SD vs MAE for Convergence Rate", 
       x = "SD of Convergence Rate", 
       y = "MAE") +
  theme_bw()

ggsave("SD-MAE-convergence.png",
       path = "../graphics",
       dpi = 300)

# parameter heatmap with geomtile
ggplot(params_long, mapping = aes(x = parameter, y = model_type, fill = correlation)) +
         geom_tile() +
         scale_fill_gradient2(low = "blue", mid = "grey", high = "red", midpoint = 0) +
         facet_wrap(~use_heterogeneous_agents) +
         theme_minimal()
ggsave("Parameter heatmap.png",
       path = "../graphics",
       dpi = 300)

# model comparison chart
ggplot(model_comparison, aes(x = model_type, y = mae_mean), reorder(model_type, mae_mean)) +
  coord_flip() +
  geom_col(fill = "steelblue") +
  labs(title = "Model Performance Comparison", x = "Model Type", y = "MAE") +
  theme_minimal()
ggsave("Model Comparison.png",
       path = "../graphics",
       dpi = 300)

# hetero impact plot
ggplot(model_comparison, aes(x=model_type, y = mae_mean, fill=use_heterogeneous_agents)) +
  geom_col(position = "dodge") +
  scale_fill_discrete() +
  labs(title = "Heterogeneity Impact", x = "Model Type", y = "MAE", fill = "Agent Type") +
  theme_minimal()
ggsave("Hetero Impact.png",
       path = "../graphics",
       dpi = 300)

# convergences vs accuracy scatter / geom_point
ggplot(df_batch, aes(x=convergence_cycle, y=mae, color = model_type)) +
  geom_point(alpha=0.3) +
  geom_smooth(method="loess")
ggsave("Convergence vs Accuracy.png",
       path = "../graphics",
       dpi = 300)

# parameter regime comparison
ggplot(param_regimes, aes(x=regimes, y=mae_mean, fill=model_type)) +
  coord_flip() +
  geom_col(position = "dodge") +
  labs(title = "Parameter Regimes", x = "Regimes", y = "MAE") +
  theme_minimal()
ggsave("Param-REgimes vs MAE.png",
       path = "../graphics",
       dpi = 300)

#### final recommendations ####
final_recommendations <- df_batch %>%
  group_by(model_type) %>%
  slice_min(mae, n=3) %>%
  select(model_type, mae, convergence_rate, confidence_threshold,
         repulsion_threshold, repulsion_strength, homophily_strength,
         use_heterogeneous_agents, current_condition
  ) %>%
  arrange(mae)

print("Final Recommendations")
print(final_recommendations)

# final results table
results_table <- df_batch %>%
  group_by(model_type, use_heterogeneous_agents) %>%
  summarize(
    MAE = mean(mae), .groups = 'drop'
  ) %>%
  arrange(model_type, use_heterogeneous_agents)

write.csv(results_table, "results-presentation.csv")

#### save results to csv ####
write.csv(final_recommendations, "calibration_test_parameters.csv")
write.csv(model_comparison, "model_comparison_summary.csv")
