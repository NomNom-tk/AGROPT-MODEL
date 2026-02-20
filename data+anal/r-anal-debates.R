# load packages
install.packages("tidyverse")
install.packages("dplyr")
install.packages("fixest") # use for regression given clustered data (i don't think so) 
install.packages("gtsummary") # use for regression tables for regression comparison and models
install.packages("performance") # used to compare models "compare_performance(m_sim, m_real)
install.packages("broom") # used to extract regression characteristics and create a tidy table for plotting
library(ggplot2)
library(tidyverse)
library(dplyr)

# csv import for debate level and agent-level
df_batch <- read.csv("data-outputs-GA/batch_summary.csv")
df_ag <- read.csv("data-outputs-GA/agent_level_results.csv")

# basic exploration
# use nrow to check rows, what type of model, unique debates, distribution of conditions
nrow(df_batch)

# check model type
table(df_batch$model_type)

# find unique debates
length(unique(df_batch$selected_debate_id))

# distribution of conditions
table(df_batch$current_condition)

# stochasticity check -- do different seeds give a different mae? group by model, params then summarize by mae and seeds
stochasticity_check <- df_batch %>%
  group_by(model_type, selected_debate_id, convergence_rate,
           confidence_threshold, repulsion_threshold, repulsion_strength) %>%
  summarize(
    mae_mean = mean(mae),
    mae_sd = sd(mae),
    mae_min = min(mae),
    mae_max = max(mae),
    n_seeds = n(),
    .groups = 'drop'
  )

# min and max stochasticity
max(stochasticity_check$mae_sd, na.rm = TRUE)
min(stochasticity_check$mae_sd, na.rm = TRUE)

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
  

# which model performs the best overall
model_comparison <- df_batch %>%
  group_by(model_type) %>%
  summarize(
    mae_mean = mean(mae),
    mae_sd = sd(mae),
    mae_min = min(mae),
    mae_max = max(mae)
  ) %>%
  arrange(mae_mean)

print(model_comparison)
## which model is best for each condition
model_by_condition <- df_batch %>%
  group_by(model_type, current_condition) %>%
  summarize (
    mae_mean = mean(mae),
    mae_min = min(mae),
    n_debates = n_distinct(selected_debate_id),
    .groups = 'drop'
  ) %>%
  arrange(current_condition, mae_mean)

print(model_by_condition)

# debate level insights
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

# parameter sensitivity // come back to this

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

# final recommendations
final_recommendations <- df_batch %>%
  group_by(model_type) %>%
  slice_min(mae, n=1) %>%
  select(model_type, convergence_rate, confidence_threshold,
         repulsion_threshold, repulsion_strength, mae, convergence_cycle,
         current_condition, selected_debate_id
  ) %>%
  mutate (
    recommendation = case_when(
      model_type == "consensus" ~ "Best for homogeneous debates",
      model_type == "clustering" ~ "Best for moderate heterogeneity",
      model_type == "bipolarization" ~ "Best for high heterogeneity",
      TRUE ~ "Unknown"
    )
  )

print("Final Recommendations")
print(final_recommendations)

# save results to csv
write.csv(final_recommendations, "calibration_test_parameters.csv")
write.csv(model_comparison, "model_comparison_summary.csv")
