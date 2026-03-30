# load packages
install.packages("tidyverse")
install.packages("dplyr")
install.packages("broom")
install.packages("officer")
install.packages("rvg")
install.packages("flextable")
library(tidyverse)
library(dplyr)
library(rvg)
library(broom)
library(officer)
library(flextable)

# collapsing logic (single - Alt+L, Shift,Alt,L / collapse all Alt,O)

# csv import for debate level and agent-level
# change from . to .. or the reverse if it doesn't work
df_batch <- read.csv("./data/batch_summary.csv")
df_orig <- read.csv("./data/data_complete_anonymised.csv")
df_ag <- read.csv("./data/agent_level_results.csv")

# agent conv speaking and distinct to bool (from string)
df_ag <- df_ag %>%
  mutate(
    #speaking_mode = speaking_mode == "true",
    use_distinct_agents = use_distinct_agents == "true"
  )

# batch conv speaking and distinct to bool (from string)
df_batch <- df_batch %>%
  mutate(
    speaking_mode = factor(speaking_mode, levels = c("true", "false")), # changed to factor for wilcox tests
    use_distinct_agents = use_distinct_agents == "true",
    debate_composition = substr(debate_label, 1, 1),
    normalised_convergence = convergence_cycle / 300) # divided by 300 to normalize (max_cycles is constant)

## EXEC SUMMARY
exec_summary <- data.frame(
  Model = c("Consensus", "Clustering", "Bipolarization"),
  Best_Mae = pmin(model_wide_full$`false`, model_wide_full$`true`),
  Best_Heterogeneous_mae = model_wide_full$`true`,
  Best_Homogeneous_mae = model_wide_full$`false`,
  Winner = c("X", "", "")
)
write_csv(exec_summary, "./results/exec-summary.csv")

# trial plotting of params over mae ####
df_params_spread_long <- df_batch %>%
  filter(model_type != "no_change") %>%
  mutate(
    confidence_threshold = ifelse(model_type == "consensus", NA, confidence_threshold),
    repulsion_threshold = ifelse(model_type %in% c("consensus", "clustering"), NA, repulsion_threshold),
    repulsion_strength = ifelse(model_type %in% c("consensus", "clustering"), NA, repulsion_strength)
  ) %>%
  pivot_longer(
    cols = c(convergence_rate, confidence_threshold,
            repulsion_strength, repulsion_threshold),
    names_to = "parameter",
    values_to = "value"
  ) %>%
  filter(!is.na(value))

range(df_batch$mae)
summary(df_params_spread_long$mae)

### SKIP THIS PLOT
ggplot(df_params_spread_long, aes(x = value, y = mae, color = current_experiment_id)) +
  geom_point(alpha = 0.4, size = 1.5) +
  geom_hline(yintercept = 0.10, linetype = "dashed", color = "red") +
  #geom_smooth(method = "loess", se = TRUE) +
  facet_grid(model_type ~ parameter, scales = "free_x") + 
  labs(title = "Parameters vs Mae by model", x = "Parameter value", y = "mae") + 
  theme_bw()

# second try conditional histogram
threshold <- 0.10

df_good <- df_batch %>% filter(mae <= threshold, model_type != "no_change")
df_all <- df_batch %>% filter(model_type != "no_change")

# helper function to pivot longer / strip useless parameters
pivot_params <- function(df) {
  df %>%
  mutate(
    confidence_threshold = ifelse(model_type == "consensus", NA, confidence_threshold),
    repulsion_threshold = ifelse(model_type %in% c("consensus", "clustering"), NA, repulsion_threshold),
    repulsion_strength = ifelse(model_type %in% c("consensus", "clustering"), NA, repulsion_strength)
  ) %>%
  pivot_longer(
    cols = c(convergence_rate, confidence_threshold,
             repulsion_strength, repulsion_threshold),
    names_to = "parameter",
    values_to = "value"
  ) %>%
  filter(!is.na(value))
}

df_all_long <- pivot_params(df_all) %>% mutate(set = "All runs")
df_good_long <- pivot_params(df_good) %>% mutate(set = "MAE < 0.10")

df_param_complete <- bind_rows(df_all_long, df_good_long)

# conditional histogram
ggplot(df_param_complete, aes(x = value, fill = set)) +
  geom_histogram(aes(y = after_stat(count)),
                 position = "identity", alpha = 0.5, bins = 15) +
  scale_fill_manual(values = c("All runs" = "grey60", "MAE < 0.10" = "steelblue")) +
  facet_grid(model_type ~ parameter, scales = "free_x") +
  labs(title = "Conditional parameter distributions",
       subtitle = "Blue = high performance runs (MAE < 0.10), Grey = all runs", 
       x = "Parameter Value", y = "Frequency", fill = "") +
  theme_bw() +
  theme(legend.position = "bottom")
ggsave("preLHS parameter sampling_1.png",
       path = "./graphics",
       dpi = 300)

#### saving logic ####
add_to_ppt <- function(ppt, content, title, type = "table") {
  ppt <- add_slide(ppt, layout = "Title and Content", master = "Office Theme")
  ppt <- ph_with(ppt, value = title, location = ph_location_type(type = "title"))
  
  if (type == "table") {
    # data frame or tidy regression output
    ft <- flextable(content) %>%
      theme_vanilla() %>%
      autofit()
    ppt <- ph_with(ppt, value = ft, location = ph_location_type(type = "body"))
  } else if (type == "regression") {
    ft <- tidy(content, conf.int = TRUE) %>%
      mutate(across(where(is.numeric), ~round(., 3))) %>%
      flextable() %>%
      theme_vanilla() %>%
      autofit()
    ppt <- ph_with(ppt, value = ft, location = ph_location_type(type = "body"))
  } else if (type == "plot") {
    ## ggplot object
    ppt <- ph_with(ppt,
                   value = dml(ggobj = content),
                   location = ph_location(width = 8, height = 5,
                                          left = 1, top = 1.5))
  }
  return(ppt)
}
ppt <- read_pptx()

## use
## ppt <- read_pptx()
## add table example: 
## ppt <- add_to_ppt(ppt, model_comparison, "Model Comparison), type = "table)
## ppt <- add_to_ppt(ppt, boss_table, "Summary Results", type = "table)
## save once
# print(ppt, target = "relative path")

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
df_batch_post_filter <- df_batch %>%
  filter(!(model_type == "bipolarization" & neutral_zone_width < 0))
# 360 observations filtered out, need to redo model conditions in exp GAMA

if (nrow(constraint_violations) > 0) {
  print("WARNING found invalid parameter combinations")
  print(constraint_violations)
}

#### GA REGION IDENTIFICATION ####
# identify best performing parameter combinations per model
# use this to set bounds for GA experiments in GAMA

mae_threshold <- quantile(df_batch$mae, 0.25) # bottom 25% MAE = good region

ga_regions <- df_batch %>%
  filter(model_type != "no_change", mae <= mae_threshold) %>%
  group_by(model_type, use_distinct_agents) %>%
  summarize(
    cr_min = min(convergence_rate),
    cr_max = max(convergence_rate),
    ct_min = min(confidence_threshold, na.rm = TRUE),
    ct_max = max(confidence_threshold, na.rm = TRUE),
    rs_min = min(repulsion_strength, na.rm = TRUE),
    rs_max = max(repulsion_strength, na.rm = TRUE),
    rt_min = min(repulsion_threshold, na.rm = TRUE),
    rt_max = max(repulsion_threshold, na.rm = TRUE),
    best_mae = min(mae),
    n = n(),
    .groups = "drop"
  )

print("GA parameter regions (use these as min/max in GAMA GA experiments):")
print(ga_regions)
write_csv(ga_regions, "./results/ga-parameter-regions.csv")

#### linear regression comparison - EMPIRICAL vs ABM####
# initial comparison using ag data (compares empirical and ABM: final - from csv, initial - from csv)
# then generalizes to batch_abm_mae so that abm mae gets compared with ols_mae
ols_model <- lm(final_attitude ~ initial_opinion, data = df_ag)
df_ag$ols_error <- abs(df_ag$final_attitude - predict(ols_model, df_ag))

# ols aggregation to debate level
ols_mae_debate <- df_ag %>%
  group_by(selected_debate_id, debate_label) %>%
  summarize(
    ols_mae = mean(ols_error),
    .groups = "drop"
  )

# aggregate ABM mae to debate level from df_batch
abm_mae_debate <- df_batch %>%
  group_by(selected_debate_id, model_type, debate_label,
           speaking_mode, use_distinct_agents) %>%
  summarize(
    abm_mae = mean(mae),
    .groups = "drop")

# join on selected deabte id and debate_label
# compute delta / negative delta implies that ABM improve upon ols
comparison_ols <- abm_mae_debate %>%
  left_join(ols_mae_debate, by = c("selected_debate_id", "debate_label")) %>%
  mutate(delta_mae = abm_mae - ols_mae,
         abm_better = factor(delta_mae < 0, levels = c(FALSE,TRUE),
                             labels = c("OLS BETTER", "ABM BETTER")))

# delta computations, descriptives
mean_delta = mean(comparison_ols$delta_mae)
se_delta = sd(comparison_ols$delta_mae) / sqrt(length(comparison_ols$delta_mae)) # SD / sqrt(n)
ci_lower = mean_delta - 1.96 * se_delta
ci_upper = mean_delta + 1.96 * se_delta


# wilcoxon test for abm and ols
wilcox_abm_ols <- wilcox.test(comparison_ols$abm_mae, comparison_ols$ols_mae, paired = TRUE)
t_test_abm_ols <- t.test(comparison_ols$abm_mae, comparison_ols$ols_mae, paired = TRUE)


# combined summary (t test - for SE, CI and mean comparison (is mean delta mae different from zero))
# Wilcoxon can confirm whether result is robust to skewed MAE distribution, median delta mae differs from zero
delta_summary <- data.frame(
  mean_delta = mean_delta,
  se_delta = se_delta,
  ci_lower = ci_lower,
  ci_upper = ci_upper,
  t_test_p_value = t_test_abm_ols$p.value,
  wilcox_test_p_value = wilcox_abm_ols$p.value
)

print(delta_summary)

# significan of ols_model
summary(ols_model)

# plot of delta mae per debate 
base_mae_debate_plot <- ggplot(comparison_ols, aes(x=debate_label, y=delta_mae, fill=abm_better)) +
  geom_col() +
  geom_hline(yintercept = 0, linetype = "dashed") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  labs(title = "Delta MAE per debate",
       x = "Debate Identifier (Label)",
       y = "Delta MAE (ABM - OLS)")

print(base_mae_debate_plot)

# plot of delta_mae per debate, faceted by model_type
model_mae_debate_plot <- ggplot(comparison_ols, aes(x=debate_label, y=delta_mae, fill=model_type)) +
  geom_col(position = position_dodge()) +
  geom_hline(yintercept = 0, linetype = "dashed") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  labs(title = "Delta MAE per debate by model type",
       x = "Debate Identifier (Label)",
       y = "Delta MAE (ABM - OLS)")

print(model_mae_debate_plot)

# add to slides
ppt <- add_to_ppt(ppt, comparison_ols, "OLS abm and empirical", type = "table")
ppt <- add_to_ppt(ppt, delta_summary, "Wilcox test for abm and empirical", type = "table")
ppt <- add_to_ppt(ppt, base_mae_debate_plot, "Delta MAE per debate", type = "plot")
ppt <- add_to_ppt(ppt, model_mae_debate_plot, "Delta MAE per debate by model_type", type = "plot")

#### parameters ####
# parameter correlations with mae 
#### SD is zero for some models as they don't all use the same parameters
params_cor_full <- df_batch %>%
  group_by(model_type, use_distinct_agents, current_experiment_id) %>%
  summarize(
    cor_convergence = cor(convergence_rate, mae),
    cor_confidence = cor(confidence_threshold, mae),
    cor_repulsion_strength = cor(repulsion_strength, mae, use = "complete.obs"), # complete.obs correlations for complete observations
    cor_repulsion_threshold = cor(repulsion_threshold, mae, use = "complete.obs")
  )

# reshape params for heatmap
params_long <- params_cor_full %>%
  pivot_longer(cols = starts_with("cor_"),
               names_to = "parameter",
               values_to = "correlation")

# parameter heatmap with geomtile
params_heatmap <- ggplot(params_long, mapping = aes(x = parameter, y = model_type, fill = correlation)) +
  geom_tile() +
  scale_fill_gradient2(low = "blue", mid = "grey", high = "red", midpoint = 0) +
  facet_wrap(~use_distinct_agents) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# parameter interaction regimes
param_regimes <- df_batch %>%
  mutate(regimes = paste0(
    ifelse(convergence_rate > 0.3, "Fast", "Slow"))) %>%
  group_by(regimes, model_type) %>%
  summarize(mae_mean = mean(mae))

# convergence analysis
convergence_anal <- df_batch %>%
  group_by(model_type, current_condition, speaking_mode) %>%
  summarize(
    cycles_mean = mean(convergence_cycle),
    cycles_sd = sd(convergence_cycle),
    cycles_min = min(convergence_cycle),
    cycles_max = max(convergence_cycle),
    .groups = 'drop'
  )

# debate evolution
# convergence vs divergence, shows which models and under which exp conditions models achieve convergence/bipol
conv_diff <- df_batch %>%
  mutate(outcome = ifelse(opinion_variance < 0.1, "Convergence", "Polarization")) %>%
  group_by(model_type, current_condition, outcome) %>%
  summarize(n = n())

# additions to ppt
ppt <- add_to_ppt(ppt, params_cor_full, "Full Parameter Correlations", type = "table")
ppt <- add_to_ppt(ppt, params_heatmap, "Parameter Heatmap", type = "plot")
ppt <- add_to_ppt(ppt, param_regimes, "Parameter Regimes", type = "table")
ppt <- add_to_ppt(ppt, convergence_anal, "Convergence Analysis", type = "table")
ppt <- add_to_ppt(ppt, conv_diff, "Convergence vs divergence - Models achieving convergence", type = "table")


#### debate composition ####
# based on initial mutation to create h and m groups
h_vs_m <- df_batch %>%
  group_by(debate_composition, model_type, speaking_mode, use_distinct_agents) %>%
  summarize(
    mae_mean = mean(mae),
    mae_sd = sd(mae),
    n = n()
  )

# wilcoxon test over debate_level mae
mae_vs_comp_wilcox <- wilcox.test(mae ~ debate_composition, data = df_batch)
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

levels(factor(df_batch$speaking_mode))
table(df_batch$speaking_mode)

# wilcox test speaking_mode predicting convergence_cycle
speakingmode_vs_convergence_wilcox <- wilcox.test(convergence_cycle ~ speaking_mode, data = df_batch)
# interpretation: data:  convergence_cycle by speaking_mode
# W = 18970, p-value < 2.2e-16 ---> significant differnece in convergence by speaking_cycle (probably mechanic, slower simulaiton)
# speaking mode takes significantly more cycles to converge

# additions to ppt
ppt <- add_to_ppt(ppt, h_vs_m, "Hetero vs homo mae", type = "table")
ppt <- add_to_ppt(ppt, mae_vs_comp_wilcox, "Wilcoxon rank sum for mae by debate composition", type = "regression")
ppt <- add_to_ppt(ppt, speaking_compar, "Convergence based on speaking", type = "table")
ppt <- add_to_ppt(ppt, speakingmode_vs_convergence_wilcox, "Convergence by speaking mode Wilcox rank sum", type = "regression")

#### no change baseline ####
df_no_change <- df_batch %>%
  filter(model_type == "no_change") %>%
  group_by(selected_debate_id, debate_label, debate_composition, current_experiment_id) %>%
  summarize(baseline_mae = mean(mae))


compar_for_no_change <- inner_join(df_batch %>% filter(model_type != "no_change"),
           df_no_change,
           by = c("selected_debate_id", "debate_label")) %>%
  distinct(selected_debate_id, debate_label)
# shows tha tonly 6 debates cna be compared, need to rerun no_change_exp

ppt <- add_to_ppt(ppt, compar_for_no_change, "GA use of no_change, not always comparable", type = "table")


nrow(df_batch$model_type == "no_change")
print(df_no_change)


# join with df_batch for baseline comparison
baseline_comparison <- df_no_change %>%
  left_join(abm_mae_debate, by = c("selected_debate_id", "debate_label"))

nrow(baseline_comparison)

baseline_comparison <- baseline_comparison %>%
  mutate(delta_mae = abm_mae - baseline_mae)
# interp: no change baselie is very competitive with regards to abm (better for the time being)

ppt <- add_to_ppt(ppt, baseline_comparison, "No change comparison with ABM", type = "table")
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

ppt <- add_to_ppt(ppt, top10_per_model, "top 10 params per model", type = "table")

print("top 10 parameters for each model")
print(top10_per_model)
write_csv(top10_per_model, "./results/10-params-model.csv")

#### cluster formation NEED TO WORK ON IMPROVING ####
# cluster formation changes
clusters <- df_batch %>%
  mutate(cluster_change = num_clusters - initial_num_clusters) %>%
  group_by(model_type, selected_debate_id) %>%
  summarize(mean_cluster_change = mean(cluster_change))

ppt <- add_to_ppt(ppt, clusters, "Cluster formations and changes", type = "table")

#### debate level insights ####
## hardest debate to predict
hardest_debates <- df_batch %>%
  group_by(current_experiment_id, current_condition, use_distinct_agents, debate_label) %>%
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
  group_by(current_experiment_id, current_condition, use_distinct_agents, debate_label) %>%
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
ppt <- add_to_ppt(ppt, failures_comp, "Overpredictions", type = "table")

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
           confidence_threshold, repulsion_threshold, repulsion_strength, current_experiment_id) %>%
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
  group_by(model_type, use_distinct_agents, selected_debate_id, seed) %>%
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
  group_by(model_type, current_experiment_id, speaking_mode, use_distinct_agents) %>%
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
  group_by(model_type, current_condition, use_distinct_agents, current_experiment_id) %>%
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
