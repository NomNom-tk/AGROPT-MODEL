#lhs analysis
# depends on: functions.r and data_processing.r

# source files
source("./functions.R")
source("./data_processing.R")
stopifnot("debate_composition" %in% colnames(df_lhs))

###########
# TODO
# debug why debate_composition is not created in df_lhs
# the rest runs fine

# Sensitivity Analysis
sensi_lhs <- run_sensi_analysis(df_lhs, param_cols_by_model = param_cols_by_model, output_cols = output_cols)
pcc_lhs <- sensi_lhs$pcc
prcc_lhs <- sensi_lhs$prcc

# PCC and PRCC results and plots
pcc_heatmap <- ggplot(pcc_lhs, mapping = aes(x = parameter, y = output, fill = PCC)) +
  geom_tile() +
  scale_fill_gradient2(low = "blue", mid = "grey", high = "red", midpoint = 0) +
  facet_wrap(~ key, scales = "free_x", ncol = 3) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

print(pcc_heatmap)

prcc_heatmap <- ggplot(prcc_lhs, mapping = aes(x = parameter, y = output, fill = PRCC)) +
  geom_tile() +
  scale_fill_gradient2(low = "blue", mid = "grey", high = "red", midpoint = 0) +
  facet_wrap(~ key, scales = "free_x", ncol = 3) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# ── Parameter Importance Ranking ----
# compute mean absolute PRCC per parameter per model
# classify as high/moderate/insensitive
# store as importance_ranking_lhs

# ── Basic Exploration ----
nrow(df_lhs)
table(df_lhs$model_type)
unique(df_lhs$debate_label)
lhs_constraint_filter <- bipol_constraint_filter(df_lhs)

# report
summary(lhs_constraint_filter)

# nrow, table(model_type), unique debates
# constraint violation summary

# ── OLS vs ABM Comparison ─────────────────────────
# ols_model
# ols_mae_debate
# abm_mae_debate
# comparison_ols
# delta_summary
# wilcox and t tests

# linear regression comparison - EMPIRICAL vs ABM####
# initial comparison using ag data (compares empirical and ABM: final - from csv, initial - from csv)
# then generalizes to batch_abm_mae so that abm mae gets compared with ols_mae
ols_model <- lm(final_attitude ~ initial_opinion, data = df_ag)
df_ag$ols_error <- abs(df_ag$final_attitude - predict(ols_model, df_ag))

print(ols_model)

# ols aggregation to debate level
ols_mae_debate <- df_ag %>%
  group_by(selected_debate_id, debate_label) %>%
  summarize(
    ols_mae = mean(ols_error),
    .groups = "drop"
  )

# aggregate ABM mae to debate level from df_batch
abm_mae_debate <- df_lhs %>%
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

print(comparison_ols$delta_mae)

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

# ── Debate Composition ----
# h_vs_m
# mae_vs_comp_wilcox

print(df_lhs$debate_composition)

# based on initial mutation to create h and m groups
h_vs_m <- df_lhs %>%
  group_by(debate_composition, model_type, speaking_mode, use_distinct_agents) %>%
  summarize(
    mae_mean = mean(mae),
    mae_sd = sd(mae),
    n = n()
  )

# wilcoxon test over debate_level mae
mae_vs_comp_wilcox <- wilcox.test(mae ~ debate_composition, data = df_lhs)
# interpret: W = 23152, p-value < 2.2e-16 ----> sig diference, homogeneous debates systematiclal ylower mae


# ── Speaking Mode ----
# speaking_compar
# speakingmode_vs_convergence_wilcox
# effect size

speaking_compar <- df_lhs %>%
  group_by(speaking_mode, debate_composition, model_type, use_distinct_agents) %>%
  summarize(
    mae_mean = mean(mae),
    mae_sd = sd(mae),
    mean_norm_convergence = mean(normalised_convergence),
    n = n()
  )
# interp: speaking_mode = true, higher normalised convergence
# speaking true and distinct true, higher normalised convergence (takes longer)

levels(factor(df_lhs$speaking_mode))
table(df_lhs$speaking_mode)

# wilcox test speaking_mode predicting convergence_cycle
speakingmode_vs_convergence_wilcox <- wilcox.test(convergence_cycle ~ speaking_mode, data = df_lhs)
# interpretation: data:  convergence_cycle by speaking_mode
# W = 18970, p-value < 2.2e-16 ---> significant differnece in convergence by speaking_cycle (probably mechanic, slower simulaiton)
# speaking mode takes significantly more cycles to converge

# ── Convergence Analysis ----
# convergence_anal
# conv_model regression
# conv_diff

# convergence analysis
convergence_anal <- df_lhs %>%
  group_by(model_type, speaking_mode, selected_debate_id) %>%
  summarize(
    cycles_mean = mean(convergence_cycle),
    cycles_sd = sd(convergence_cycle),
    cycles_min = min(convergence_cycle),
    cycles_max = max(convergence_cycle),
    cycles_normalised = mean(normalised_convergence),
    .groups = 'drop'
  )

# violin plot for convergence cycle distribution per model type (distribution only)
viol_conv_model_type <- ggplot(df_lhs, aes(x=model_type, y=convergence_cycle)) +
  geom_violin(trim=TRUE, scale = "width", fill = "grey85") +
  # add boxplot for robust summary
  geom_boxplot(width=0.12, outlier.shape=NA, fill="white") +
  # median point
  stat_summary(fun = median, geom = "point", color = "red", size = 2) +
  facet_wrap(~ speaking_mode) +
  # labels
  labs(
    title = "Distribution of Convergence Cycle by Model Type",
    x = "Model Type",
    y = "Convergence Cycles (lower = faster convergence)"
  ) +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 30, hjust = 1))

print(viol_conv_model_type)

# aggreagte to show comparison between models
df_conv_debate <- df_lhs %>%
  group_by(model_type, selected_debate_id, speaking_mode) %>%
  summarize(mean_conv = mean(convergence_cycle), mean_mae = mean(mae), .groups = "drop")

# violin plot comparisoin
box_conv_compar <- ggplot(df_conv_debate, aes(x=model_type, y=mean_conv, fill = speaking_mode)) +
  geom_boxplot(position = position_dodge(width = 0.8)) +
  labs(title = "Convergence Rate Comparison by model type and speaking mode",
       fill = "speaking mode") +
  theme_bw()

# violin plot comparison with speaking mode facet wrap
box_conv_compar_speak <- ggplot(df_conv_debate, aes(x=model_type, y=mean_conv, fill = speaking_mode)) +
  geom_boxplot(position = position_dodge(width = 0.8)) +
  facet_wrap(~ speaking_mode) +
  labs(title = "Convergence Rate Comparison by model type and speaking mode",
       fill = "speaking mode") +
  theme_bw()

print(box_conv_compar_speak)

# trade off plot of convergence by model type and speaking mode, impact on mae
tradeoff_plot <- ggplot(df_conv_debate,
                        aes(x = mean_conv, y = mean_mae, color = speaking_mode)) +
  geom_point(alpha = 0.7) +
  geom_smooth(method = "lm", se = TRUE) +
  facet_wrap(~ model_type) +
  labs(
    title = "Speed–Accuracy Trade-off",
    x = "Convergence Cycles",
    y = "Mean Absolute Error (MAE)",
    color = "Speaking Mode"
  ) +
  theme_bw()

print(tradeoff_plot)

#lm model regression full
# setimating effect of convergence (mean conv), speaking mode / interaction does convergence matter differently depending on speakign mode
# control for model type
conv_model <- lm(mean_mae ~ mean_conv * speaking_mode + model_type, data = df_conv_debate)
summary(conv_model)
# conclusions: there is no speed-accuracy trade-off, conv alone and interaciton with speakign mode is insignificant
# model type significatnly predicts predictive accuracry -> complex models don't necessarily outperform simple baselines
# model dynamics matter more than convergence rate!!!

# debate evolution
# convergence vs divergence, shows which models and under which exp conditions models achieve convergence/bipol
conv_diff <- df_lhs %>%
  mutate(outcome = ifelse(opinion_variance < 0.1, "Convergence", "Polarization")) %>%
  group_by(model_type, current_condition, outcome) %>%
  summarize(n = n())

# ── No Change Baseline ────────────────────────────
# df_no_change
# baseline_comparison
# limitation flag

df_no_change <- df_lhs %>%
  filter(model_type == "no_change") %>%
  group_by(selected_debate_id, debate_label, debate_composition, current_experiment_id) %>%
  summarize(baseline_mae = mean(mae))


compar_for_no_change <- inner_join(df_lhs %>% filter(model_type != "no_change"),
                                   df_no_change,
                                   by = c("selected_debate_id", "debate_label")) %>%
  distinct(selected_debate_id, debate_label)
# shows tha tonly 6 debates cna be compared, need to rerun no_change_exp

#ppt <- add_to_ppt(ppt, compar_for_no_change, "GA use of no_change, not always comparable", type = "table")


nrow(df_lhs %>% filter(model_type == "no_change"))
print(df_no_change)

# join with df_batch for baseline comparison
baseline_comparison <- df_no_change %>%
  left_join(abm_mae_debate, by = c("selected_debate_id", "debate_label"))

nrow(baseline_comparison)

baseline_comparison <- baseline_comparison %>%
  mutate(delta_mae = abm_mae - baseline_mae)
# interp: no change baselie is very competitive with regards to abm (better for the time being)

# ── Stochasticity ----
# stochasticity_check
# stochasticity_check_1
# heterogeneity_check
# TODO CV convergence plot data

# stochasticity check -- do different seeds give a different mae?
stochasticity_check <- df_lhs %>%
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
stochasticity_check_1 <- df_lhs %>%
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
heterogeneity_check <- df_lhs %>%
  group_by (model_type, use_distinct_agents) %>%
  summarize (
    mae_mean = mean(mae),
    mae_median = median(mae),
    mae_sd = sd(mae),
    n = n(),
    .groups = 'drop'
  )

# write_csv(heterogeneity_check, "./results/hetero-impact.csv")

# ── Model Comparison ----
# TODO include form main file - boss_table
# model_comparison
# model_wide_full
# model_by_condition

# which model performs the best overall
model_comparison <- df_lhs %>%
  group_by(model_type, current_experiment_id, speaking_mode, use_distinct_agents) %>%
  summarize(
    mae_mean = mean(mae),
    mae_sd = sd(mae),
    mae_min = min(mae),
    mae_max = max(mae)
  ) %>%
  arrange(mae_mean)

print(model_comparison)

# which model performs the best overall ///// for presentaiton plot (either delete or refactor)
model_comparison_1 <- df_lhs %>%
  group_by(model_type) %>%
  summarize(
    mae_mean = mean(mae),
    mae_sd = sd(mae),
    mae_min = min(mae),
    mae_max = max(mae),
    .groups = "drop"
  ) %>%
  mutate(model_type = factor(model_type, levels = model_type[order(mae_mean)])) %>%
  arrange(mae_mean)

print(model_comparison_1)

# reformating in wide format
model_wide_full <- model_comparison %>%
  select(model_type, use_distinct_agents, mae_mean) %>%
  pivot_wider(names_from = use_distinct_agents, values_from = mae_mean)

names(model_wide_full)

## which model is best for each condition
model_by_condition <- df_lhs %>%
  group_by(model_type, current_condition, use_distinct_agents, current_experiment_id) %>%
  summarize (
    mae_mean = mean(mae),
    mae_min = min(mae),
    n_debates = n_distinct(selected_debate_id),
    .groups = 'drop'
  ) %>%
  arrange(current_condition, use_distinct_agents, mae_mean)
print(model_by_condition)

#write_csv(model_by_condition, "./results/model-by-condition.csv")

# ── Failures ----
# failure threshold from distribution
# failures_comp
# constraint violation proportion for bipol

# failure predictions
failures_comp <- df_lhs %>%
  mutate(failures = mae > 0.18) %>%
  group_by(model_type, failures) %>%
  summarize(
    mean_convergence = mean(convergence_rate),
    pct_hetero = mean(use_distinct_agents == "true") * 100,
    n_total = n()
  )

#ppt <- add_to_ppt(ppt, failures_comp, "Overpredictions", type = "table")
#write_csv(failures_comp, "./results/debate_failures.csv")

# ── Cluster Formation ----
# clusters with extended metrics

# TODO REWORK and IMPROVE cluster formation changes
clusters <- df_lhs %>%
  mutate(cluster_change = num_clusters - initial_num_clusters) %>%
  group_by(model_type, selected_debate_id) %>%
  summarize(mean_cluster_change = mean(cluster_change))

#ppt <- add_to_ppt(ppt, clusters, "Cluster formations and changes", type = "table")


# ── Debate Level ----
# hardest_debates
# easiest_debates

## hardest debate to predict
hardest_debates <- df_lhs %>%
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
#write_csv(hardest_debates, "./results/hardes-debates.csv")

## easiest debates to predict
easiest_debates <- df_lhs %>%
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
#write_csv(easiest_debates, "./results/easiest-debates.csv")


# ── Final Recommendations ----
# TODO improve granularity of tables
# final_recommendations
# results_table

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


# ── GA Region Extraction & Save Results ----
lhs_regions <- param_region_extraction(df_lhs, percentile = 0.25)
gaml_ga     <- generate_gaml_bounds(lhs_regions$regions)
writeLines(gaml_ga, "gaml_GA_bounds.txt")
