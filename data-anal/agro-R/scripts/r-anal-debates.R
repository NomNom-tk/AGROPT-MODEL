# load packages
install.packages("tidyverse")
install.packages("dplyr")
install.packages("fixest") # use for regression given clustered data (i don't think so) 
install.packages("gtsummary") # use for regression tables for regression comparison and models
install.packages("performance") # used to compare models "compare_performance(m_sim, m_real)
install.packages("broom") # used to extract regression characteristics and create a tidy table for plotting
install.packages("tidyr")
install.packages("kable")
install.packages("olsrr")
library(ggplot2)
library(tidyverse)
library(dplyr)
library(olsrr)

# csv import for debate level and agent-level
# change from . to .. or the reverse if it doesn't work
df_batch <- read.csv("./data/batch_summary.csv")
df_orig <- read.csv("./data/data_complete_anonymised.csv")
df_ag <- read.csv("./data/agent_level_results.csv")

# agent conv speaking and distinct to bool (from string)
df_ag <- df_ag %>%
  mutate(
    speaking_mode = speaking_mode == "true",
    use_distinct_agents = use_distinct_agents == "true"
  )

# batch conv speaking and distinct to bool (from string)
df_batch <- df_batch %>%
  mutate(
    speaking_mode = speaking_mode == "true",
    use_distinct_agents = use_distinct_agents == "true"
  )

## EXEC SUMMARY
exec_summary <- data.frame(
  Model = c("Consensus", "Clustering", "Bipolarization"),
  Best_Mae = pmin(model_wide_full$`false`, model_wide_full$`true`),
  Best_Heterogeneous_mae = model_wide_full$`true`,
  Best_Homogeneous_mae = model_wide_full$`false`,
  Winner = c("X", "", "")
)
write_csv(exec_summary, "./results/exec-summary.csv")

#### saving-to-be-done ####
install.packages("flextable")
install.packages("officer")
library(flextable)
library(officer)

# Create formatted table
ft <- flextable(boss_summary) %>%
  theme_vanilla() %>%
  autofit()

# Save to PowerPoint
ppt <- read_pptx()
ppt <- add_slide(ppt, layout = "Title and Content", master = "Office Theme")
ppt <- ph_with(ppt, value = ft, location = ph_location_type(type = "body"))
print(ppt, target = "results.pptx")


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


#### linear regression comparison ####
ols_model <- lm(final_attitude ~ initial_opinion, data = df_ag)
df_ag$ols_error <- abs(final_attitude - predict(ols_model))

# ols aggregation to debate level
ols_mae_debate <- df_ag %>%
  group_by(selected_debate_id, debate_label) %>%
  summarize(
    ols_mae = mean(ols_error)
  )

# aggregate ABM mae to debate level from df_batch
abm_mae_debate <- df_batch %>%
  group_by(selected_debate_id, model_type, debate_label,
           speaking_mode, use_distinct_agents) %>%
  summarize(
    abm_mae = mean(mae))

# join on selected deabte id and debate_label
comparison_ols <- abm_mae_debate %>%
  left_join(ols_mae_debate, by = c("selected_debate_id", "debate_label"))

# compute delta / negative delta implies that ABM improve upon ols
comparison <- comparison %>%
  mutate(delta_mae = abm_mae - ols_mae)

# significan of ols_model
summary(ols_model)

# wilcoxon test for abm and ols
wilcox.text(comparison$abm_mae, comparison$ols_mae, paired = TRUE)

# paired t-test
t.test(comparison$abm_mae, comparison$ols_mae, paired = TRUE)

### plot ABM mae vs regression mae scatter with debate_level as identifier

#### parameters ####
# parameter correlations with mae
params_cor_full <- df_batch %>%
  group_by(model_type, use_distinct_agents) %>%
  summarize(
    cor_convergence = cor(convergence_rate, mae),
    cor_confidence = cor(confidence_threshold, mae),
    cor_repulsion_strength = cor(repulsion_strength, mae, use = "complete.obs"), # complete.obs correlations for complete observations
    cor_repulsion_threshold = cor(repulsion_threshold, mae, use = "complete.obs")
  )
# save
write_csv(params_cor_full, "./results/parameter-analyses.csv")

# reshape params for heatmap
params_long <- params_cor_full %>%
  pivot_longer(cols = starts_with("cor_"),
               names_to = "parameter",
               values_to = "correlation")

# parameter interaction regimes
param_regimes <- df_batch %>%
  mutate(regimes = paste0(
    ifelse(convergence_rate > 0.3, "Fast", "Slow"))) %>%
  group_by(regimes, model_type) %>%
  summarize(mae_mean = mean(mae))
write_csv(param_regimes, "./results/param-regimes.csv")

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
write_csv(conv_diff, "./results/outcomes_by_condition.csv")

#### debate composition ####
# initial mutation create h and m groups
df_batch <- df_batch %>%
  mutate(debate_composition = substr(debate_label, 1, 1),
         normalised_convergence = convergence_cycle / 300) # divided by 300 to normalize (max_cycles is constant)

h_vs_m <- df_batch %>%
  group_by(debate_composition, model_type, speaking_mode, use_distinct_agents) %>%
  summarize(
    mae_mean = mean(mae),
    mae_sd = sd(mae),
    n = n()
  )

# wilcoxon test over debate_level mae
wilcox.test(mae ~ debate_composition, data = df_batch)
# interpret: W = 23152, p-value < 2.2e-16 ----> sig diference, homogeneous debates systematiclal ylower mae

#### speaking mode comparisons ####
speaking_compar <- df_batch %>%
  group_by(speaking_mode, debate_composition, model_type, use_distinct_agents) %>%
  summarize(
    mae_mean = mean(mae),
    mae_sd = sd(mae),
    mean_norm_convergence = mean(normalised_convergence),
    n = n()
  )
# interp: speaking_mode = true, higher normalised convergence
# speaking true and distinct true, higher normalised convergence (takes longer)
# 

# wilcox test speaking_mode predicting convergence_cycle
wilcox.test(convergence_cycle ~ speaking_mode, data = df_batch)
# interpretation: data:  convergence_cycle by speaking_mode
# W = 18970, p-value < 2.2e-16 ---> significant differnece in convergence by speaking_cycle (probably mechanic, slower simulaiton)
# speaking mode takes significantly more cycles to converge

#### no change baseline ####
inner_join(df_batch %>% filter(model_type != "no_change"),
           df_no_change,
           by = c("selected_debate_id", "debate_label")) %>%
  distinct(selected_debate_id, debate_label)
# shows tha tonly 6 debates cna be compared, need to rerun no_change_exp

df_no_change <- df_batch %>%
  filter(model_type == "no_change") %>%
  group_by(selected_debate_id, debate_label, debate_composition, current_experiment_id) %>%
  summarize(baseline_mae = mean(mae))

nrow(df_batch$model_type == "no_change")
print(df_no_change)


# join with df_batch for baseline comparison
baseline_comparison <- df_no_change %>%
  left_join(abm_mae_debate, by = c("selected_debate_id", "debate_label"))

nrow(baseline_comparison)

baseline_comparison <- baseline_comparison %>%
  mutate(delta_mae = abm_mae - baseline_mae)
# interp: no change baselie is very competitive with regards to abm (better for the time being)
write_csv(baseline_comparison, "./results/abm-baseline-compar.csv")


#### failures of models and predictions ####
# best parameters per model
# use slice_min(mae, n=1) and then select by model and params
best_params <- df_batch %>%
  group_by(model_type, use_distinct_agents) %>%
  slice_min(mae, n=1) %>%
  select(model_type, use_distinct_agents, convergence_rate, confidence_threshold, repulsion_strength,
         repulsion_threshold, mae, current_condition, selected_debate_id)

print("Best parameters per model")
print(best_params)

# top 10 best parameter sets for each model / group by moel, distinct, then slice_min(mae, n=10), then select model and params, mae
top10_per_model <- df_batch %>%
  group_by(model_type, use_distinct_agents) %>%
  distinct(convergence_rate, confidence_threshold, repulsion_strength,
           repulsion_threshold, .keep_all = TRUE) %>%
  slice_min(mae, n=10) %>%
  select(model_type, use_distinct_agents, convergence_rate, confidence_threshold, repulsion_strength,
         repulsion_threshold, mae, selected_debate_id)

print("top 10 parameters for each model")
print(top10_per_model)
write_csv(top10_per_model, "./results/10-params-model.csv")

#### cluster formation NEED TO WORK ON IMPROVING ####
# cluster formation changes
clusters <- df_batch %>%
  mutate(cluster_change = num_clusters - initial_num_clusters) %>%
  group_by(model_type, selected_debate_id) %>%
  summarize(mean_cluster_change = mean(cluster_change))

#### debate level insights ####
## hardest debate to predict
hardest_debates <- df_batch %>%
  group_by(selected_debate_id, current_condition, use_distinct_agents) %>%
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
write_csv(hardest_debates, "./results/hardes-debates.csv")

## easiest debates to predict
easiest_debates <- df_batch %>%
  group_by(selected_debate_id, current_condition, use_distinct_agents) %>%
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
write_csv(easiest_debates, "./results/easiest-debates.csv")

# failure predictions
failures_comp <- df_batch %>%
  mutate(failures = mae > 0.18) %>%
  group_by(model_type, failures) %>%
  summarize(
    mean_convergence = mean(convergence_rate),
    pct_hetero = mean(use_distinct_agents == "true") * 100,
    n_total = n()
  )
write_csv(failures_comp, "./results/debate_failures.csv")

# predicting bipolarization does opinion variance chance bipol predictions?
range(df_batch$opinion_variance)

var_compar <- df_batch %>%
  mutate(variance_slice = cut(opinion_variance, 
                         breaks = c(0, 0.05, 0.1, 0.15),
                         labels = c("Low", "Medium", "High"))) %>%
  group_by(model_type, variance_slice) %>%
  summarize(
    n_debates = n(),
    mean_mae = mean(mae),
    mean_convergence = mean(convergence_cycle),
    .groups = 'drop')
write_csv(var_compar, "./results/variance-debates.csv")

# investigating why bipol runs fail?
df_check <- df_batch %>%
  filter(opinion_variance > 0.1) %>%
  select(model_type, repulsion_threshold, confidence_threshold, use_distinct_agents)
### all bipol runs have homophily=1.0, repulsion_thresholhd & confidence < 0.2
### causes network fragmentation and extreme bipolarization
### 5x worse predictions

#### stochasticity impact ####
# stochasticity check -- do different seeds give a different mae?
stochasticity_check <- df_batch %>%
  group_by(model_type, use_distinct_agents, selected_debate_id, convergence_rate,
           confidence_threshold, repulsion_threshold, repulsion_strength) %>%
  summarize(
    mae_mean = mean(mae),
    mae_sd = sd(mae),
    mae_min = min(mae),
    mae_max = max(mae),
    n_seeds = n(),
    .groups = 'drop'
  ) %>%
  arrange(mae_mean)

print(stochasticity_check)

## USE THIS OVER PREV STOCH
stochasticity_check_1 <- df_batch %>%
  group_by(model_type, use_distinct_agents, selected_debate_id) %>%
  summarize(mae_sd = sd(mae), n = n())
## COMMENTS
### stochasticity is negligible (>90% of debates show SD=0 across seeds)
### MAX SD = 0.026, high model stability
### seed replication can be reduce din future runs


# min and max stochasticity
max(stochasticity_check_1$mae_sd, na.rm = TRUE)
min(stochasticity_check_1$mae_sd, na.rm = TRUE)

## Heterogeneity impact
## does adding SD > 0 improve mae?
heterogeneity_check <- df_batch %>%
  group_by (model_type, use_distinct_agents) %>%
  summarize (
    mae_mean = mean(mae),
    mae_median = median(mae),
    mae_sd = sd(mae),
    n = n(),
    .groups = 'drop'
  )
write_csv(heterogeneity_check, "./results/hetero-impact.csv")

#### BEST ####
## BOSS summary -- need model+hetero combinations, MAE (mean and best), convergence speed, failure rate
## sample size
boss_table <- df_batch %>%
  group_by(model_type, use_distinct_agents) %>%
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
  group_by(model_type, use_distinct_agents) %>%
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
  select(model_type, use_distinct_agents, mae_mean) %>%
  pivot_wider(names_from = use_distinct_agents, values_from = mae_mean)

names(model_wide_full)

## which model is best for each condition
model_by_condition <- df_batch %>%
  group_by(model_type, current_condition, use_distinct_agents) %>%
  summarize (
    mae_mean = mean(mae),
    mae_min = min(mae),
    n_debates = n_distinct(selected_debate_id),
    .groups = 'drop'
  ) %>%
  arrange(current_condition, use_distinct_agents, mae_mean)
print(model_by_condition)
write_csv(model_by_condition, "./results/model-by-condition.csv")

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
### interpretation
### convergence rate heterogeneity alone doesn't predict MAE
### outlier at SD = 0.05 (homophily=1 case previously) / bipol run (MAE = 0.46)
### models overlap heavily


# parameter heatmap with geomtile
ggplot(params_long, mapping = aes(x = parameter, y = model_type, fill = correlation)) +
         geom_tile() +
         scale_fill_gradient2(low = "blue", mid = "grey", high = "red", midpoint = 0) +
         facet_wrap(~use_heterogeneous_agents) +
         theme_minimal() +
         theme(axis.text.x = element_text(angle = 45, hjust = 1))
ggsave("Parameter heatmap.png",
       path = "../graphics",
       width = 12,
       height = 6,
       dpi = 600)

### interpretation
### false shows stronger correlations (convergence strong pos for consensus / homohily srong posi for bipol)
### // false side: bipol -> negative corr with repulsion dynamics / consensus -> neg with confidence_thresh, repul
### true side: adding agetn variation wipes out correlations // noise is more difficult ot calibrate

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
ggplot(model_comparison, aes(x=model_type, y = mae_mean, fill=use_distinct_agents)) +
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
### interpretation
### models have similar pattern (slight inverted U for consensus)
### outlier for bipol run / no speed-accuracry trade-off --> speed does not predict accuracy

# parameter regime comparison
ggplot(param_regimes, aes(x=regimes, y=mae_mean, fill=model_type)) +
  coord_flip() +
  geom_col(position = "dodge") +
  labs(title = "Parameter Regimes", x = "Regimes", y = "MAE") +
  theme_minimal()
ggsave("Param-REgimes vs MAE.png",
       path = "../graphics",
       dpi = 300)
### interpretation
### high homophily and fast (worse over all models) / best is low homophily and slow convergence
### use homophily <= 0.5 + convergence rate <= 0.2

#### final recommendations ####
final_recommendations <- df_batch %>%
  group_by(model_type) %>%
  slice_min(mae, n=3) %>%
  select(model_type, mae, convergence_rate, confidence_threshold,
         repulsion_threshold, repulsion_strength,
         use_distinct_agents, current_condition
  ) %>%
  arrange(mae)

print("Final Recommendations")
print(final_recommendations)

# final results table
results_table <- df_batch %>%
  group_by(model_type, use_distinct_agents) %>%
  summarize(
    MAE = mean(mae), .groups = 'drop'
  ) %>%
  arrange(model_type, use_distinct_agents)

write.csv(results_table, "results-presentation.csv")

#### save results to csv ####
write.csv(final_recommendations, "calibration_test_parameters.csv")
write.csv(model_comparison, "model_comparison_summary.csv")
