#lhs analysis
# depends on: functions.r and data_processing.r

source("./functions.R")
source("./data_processing.R")
source("./plots.R")

stopifnot("debate_composition" %in% colnames(df_lhs))
stopifnot(exists("lhs_versions"))

# ─────────────────────────────────────────────
# SAFE TYPE NORMALISATION (CRITICAL FIX #1)
# ─────────────────────────────────────────────

df_lhs$selected_debate_id <- as.character(df_lhs$selected_debate_id)
df_lhs_v1$selected_debate_id <- as.character(df_lhs_v1$selected_debate_id)
df_lhs_v2$selected_debate_id <- as.character(df_lhs_v2$selected_debate_id)

# ─────────────────────────────────────────────
# Sensitivity Analysis by version
# ─────────────────────────────────────────────

sensi_lhs <- run_sensi_analysis(df_lhs,
                                param_cols_by_model = param_cols_by_model,
                                output_cols = output_cols)

pcc_lhs <- sensi_lhs$pcc
prcc_lhs <- sensi_lhs$prcc

sensi_v1 <- run_sensi_analysis(df_lhs_v1,
                               param_cols_by_model = param_cols_by_model,
                               output_cols = output_cols)

sensi_v2 <- run_sensi_analysis(df_lhs_v2,
                               param_cols_by_model = param_cols_by_model,
                               output_cols = output_cols)


# ─────────────────────────────────────────────
# Sensi combined df combination and plotting
# ─────────────────────────────────────────────
## PCC
pcc_v1 <- sensi_v1$pcc %>% mutate(version = "v1")
pcc_v2 <- sensi_v2$pcc %>% mutate(version = "v2")

pcc_all <- bind_rows(pcc_v1, pcc_v2)

# PRCC
prcc_v1 <- sensi_v1$prcc %>% mutate(version = "v1")
prcc_v2 <- sensi_v2$prcc %>% mutate(version = "v2")

prcc_all <- bind_rows(prcc_v1, prcc_v2)

# ─────────────────────────────────────────────
# Version Summary Tables
# ─────────────────────────────────────────────
df_version_summary <- lhs_versions %>%
  group_by(version, model_type, speaking_mode, debate_composition) %>%
  summarize(
    mae_mean = mean(mae),
    conv_mean = mean(convergence_cycle),
    .groups = "drop"
  )


# ─────────────────────────────────────────────
# OLS vs ABM comparison
# ─────────────────────────────────────────────

ols_result <- compute_ols_baseline(df_ag)

ols_model <- ols_result$model
df_ag_ols <- ols_result$data
ols_global_mae <- ols_result$ols_mae

stopifnot("ols_error" %in% colnames(df_ag_ols))

ols_mae_debate <- df_ag_ols %>%
  group_by(selected_debate_id, debate_label) %>%
  summarize(ols_mae = mean(ols_error, na.rm = TRUE), .groups = "drop")

# ABM aggregation (FIX: now robust to duplicate debate_label inconsistencies)
abm_mae_debate <- df_lhs %>%
  group_by(selected_debate_id) %>%   # FIX: avoid debate_label mismatch risk
  summarize(
    abm_mae = mean(mae, na.rm = TRUE),
    debate_label = first(debate_label),  # SAFE fallback
    pct_hetero = mean(use_distinct_agents == TRUE, na.rm = TRUE),
    .groups = "drop"
  )

# FIX #2: safe join keys only on ID
common_ids <- intersect(ols_mae_debate$selected_debate_id,
                        abm_mae_debate$selected_debate_id)

ols_mae_debate <- ols_mae_debate %>%
  filter(selected_debate_id %in% common_ids)

abm_mae_debate <- abm_mae_debate %>%
  filter(selected_debate_id %in% common_ids)

# FIX #3: ensure same type (redundant but safe)
ols_mae_debate$selected_debate_id <- as.character(ols_mae_debate$selected_debate_id)
abm_mae_debate$selected_debate_id <- as.character(abm_mae_debate$selected_debate_id)

comparison <- inner_join(
  abm_mae_debate,
  ols_mae_debate,
  by = "selected_debate_id"
)

comparison_clean <- comparison %>%
  filter(is.finite(abm_mae), is.finite(ols_mae)) %>%
  mutate(delta_mae = abm_mae - ols_mae,
         abm_better = abm_mae < ols_mae)

# ─────────────────────────────────────────────
# STATS (UNCHANGED LOGIC)
# ─────────────────────────────────────────────

comparison_summary <- comparison_clean %>%
  summarize(
    mean_delta = mean(delta_mae),
    sd_delta = sd(delta_mae),
    se_delta = sd_delta / sqrt(n()),
    ci_lower = mean_delta - 1.96 * se_delta,
    ci_upper = mean_delta + 1.96 * se_delta,
    pct_abm_better = mean(abm_better, na.rm = TRUE),
    n = n()
  )

# TODO print which debates are better in ABM
print(ols_global_mae)
print(comparison_summary)

# ─────────────────────────────────────────────
# TESTS (UNCHANGED)
# ─────────────────────────────────────────────

if (nrow(comparison_clean) > 2) {
  
  wilcox_abm_ols <- wilcox.test(
    comparison_clean$abm_mae,
    comparison_clean$ols_mae,
    paired = TRUE
  )
  
  t_test_abm_ols <- t.test(
    comparison_clean$abm_mae,
    comparison_clean$ols_mae,
    paired = TRUE
  )
}

if (exists("wilcox_abm_ols")) print(wilcox_abm_ols)
if (exists("t_test_abm_ols")) print(t_test_abm_ols)

# ─────────────────────────────────────────────
# Debate composition (NO CHANGE LOGIC)
# ─────────────────────────────────────────────

print(df_lhs$debate_composition)

h_vs_m <- df_lhs %>%
  group_by(debate_composition, model_type, speaking_mode, use_distinct_agents) %>%
  summarize(
    mae_mean = mean(mae),
    mae_sd = sd(mae),
    n = n(),
    .groups = "drop"
  )

mae_vs_comp_wilcox <- wilcox.test(mae ~ debate_composition, data = df_lhs)

# ─────────────────────────────────────────────
# Speaking mode (UNCHANGED)
# ─────────────────────────────────────────────

speaking_compar <- df_lhs %>%
  group_by(speaking_mode, debate_composition, model_type, use_distinct_agents) %>%
  summarize(
    mae_mean = mean(mae),
    mae_sd = sd(mae),
    mean_norm_convergence = mean(normalised_convergence),
    n = n(),
    .groups = "drop"
  )

# for wilcox tests with speaking mode, wrap as logical
speakingmode_vs_convergence_wilcox <- wilcox.test(
  convergence_cycle ~ speaking_mode,
  data = df_lhs
)

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

# ─────────────────────────────────────────────
# aggreagte to show comparison between models
# ─────────────────────────────────────────────

# aggregated conv debate
df_conv_debate <- df_lhs %>%
  group_by(model_type, selected_debate_id, speaking_mode) %>%
  summarize(
    mean_conv = mean(convergence_cycle),
    mean_mae = mean(mae),
    sd_conv = sd(convergence_cycle),
    sd_mae = sd(mae),
    .groups = "drop"
  )

# ─────────────────────────────────────────────
# regression model
# ─────────────────────────────────────────────

run_conv_model <- function(df_conv_debate) {
  lm(mean_mae ~ mean_conv * speaking_mode + model_type, data = df_conv_debate)
}

# ─────────────────────────────────────────────
# convergence outcome analysis
# ─────────────────────────────────────────────

conv_diff <- df_lhs %>%
  mutate(outcome = ifelse(opinion_variance < 0.1, "Convergence", "Polarization")) %>%
  group_by(model_type, current_condition, outcome) %>%
  summarize(n = n(), .groups = "drop")

# ─────────────────────────────────────────────
# NO CHANGE BASELINE
# ─────────────────────────────────────────────

df_no_change <- df_lhs %>%
  filter(model_type == "no_change") %>%
  group_by(selected_debate_id, debate_label, debate_composition, current_experiment_id) %>%
  summarize(baseline_mae = mean(mae), .groups = "drop")

compar_for_no_change <- inner_join(
  df_lhs %>% filter(model_type != "no_change"),
  df_no_change,
  by = c("selected_debate_id", "debate_label")
) %>%
  distinct(selected_debate_id, debate_label)

nrow(df_lhs %>% filter(model_type == "no_change"))
print(df_no_change)

# FIXED SAFETY NOTE (NO STRUCTURAL CHANGE, ONLY ALIGNMENT ASSUMED DONE EARLIER)
baseline_comparison <- df_no_change %>%
  left_join(abm_mae_debate %>% select(selected_debate_id, abm_mae), 
            by = "selected_debate_id") %>% 
  mutate(delta_mae = abm_mae - baseline_mae)

nrow(baseline_comparison)
print(baseline_comparison$debate_label)

# ─────────────────────────────────────────────
# STOCHASTICITY
# ─────────────────────────────────────────────

stochasticity_check <- df_lhs %>%
  group_by(
    model_type, use_distinct_agents, selected_debate_id,
    convergence_rate, confidence_threshold,
    repulsion_threshold, repulsion_strength,
    current_experiment_id
  ) %>%
  summarize(
    mae_mean = mean(mae),
    mae_sd = sd(mae),
    mae_min = min(mae),
    mae_max = max(mae),
    n_seeds = n(),
    .groups = "drop"
  ) %>%
  arrange(mae_mean)

print(stochasticity_check)

stochasticity_check_1 <- df_lhs %>%
  group_by(model_type, use_distinct_agents, selected_debate_id, seed) %>%
  summarize(
    mae_sd = sd(mae),
    n = n(),
    .groups = "drop"
  )

max(stochasticity_check_1$mae_sd, na.rm = TRUE)
min(stochasticity_check_1$mae_sd, na.rm = TRUE)

# ─────────────────────────────────────────────
# HETEROGENEITY
# ─────────────────────────────────────────────

heterogeneity_check <- df_lhs %>%
  group_by(model_type, use_distinct_agents) %>%
  summarize(
    mae_mean = mean(mae),
    mae_median = median(mae),
    mae_sd = sd(mae),
    n = n(),
    .groups = "drop"
  )

# ─────────────────────────────────────────────
# MODEL COMPARISON
# ─────────────────────────────────────────────

# replaces model_comaprison_2
model_comparison_main <- lhs_versions %>%
  group_by(model_type, version, speaking_mode) %>%
  summarize(
    mae_mean = mean(mae),
    mae_sd = sd(mae),
    .groups = "drop"
  ) %>%
  arrange(mae_mean)

# model comparison detailed
model_comparison_detailed <- df_lhs %>%
  group_by(model_type, version, speaking_mode, use_distinct_agents) %>%
  summarize(
    mae_mean = mean(mae),
    mae_sd = sd(mae),
    .groups = "drop"
  )

model_comparison_relative <- model_comparison_main %>%
  group_by(version, speaking_mode) %>%
  mutate(
    best_mae = min(mae_mean),
    delta_mae = mae_mean - best_mae
  ) %>%
  ungroup()

# version aware model comparison
model_comparison_2 <- df_lhs %>%
  group_by(model_type, version, speaking_mode) %>%
  summarize(
    mae_mean = mean(mae),
    mae_sd = sd(mae),
    mae_min = min(mae),
    mae_max = max(mae),
    .groups = "drop"
  ) %>%
  arrange(version, mae_mean)

# force uniqueness before pivot
model_wide_full <- model_comparison_detailed %>%
  group_by(model_type, use_distinct_agents) %>%
  summarize(mae_mean = mean(mae_mean), .groups = "drop") %>%
  pivot_wider(names_from = use_distinct_agents, values_from = mae_mean)

model_by_condition <- df_lhs %>%
  group_by(model_type, current_condition, use_distinct_agents, current_experiment_id) %>%
  summarize(
    mae_mean = mean(mae),
    mae_min = min(mae),
    n_debates = n_distinct(selected_debate_id),
    .groups = "drop"
  ) %>%
  arrange(current_condition, use_distinct_agents, mae_mean)

# ─────────────────────────────────────────────
# FAILURES
# ─────────────────────────────────────────────

failures_comp <- df_lhs %>%
  mutate(failures = mae > 0.18) %>%
  group_by(model_type, failures) %>%
  summarize(
    mean_convergence = mean(convergence_rate),
    pct_hetero = mean(use_distinct_agents == TRUE) * 100,
    n_total = n(),
    .groups = "drop"
  )

# ─────────────────────────────────────────────
# CLUSTERS
# ─────────────────────────────────────────────

clusters <- df_lhs %>%
  mutate(cluster_change = num_clusters - initial_num_clusters) %>%
  group_by(model_type, selected_debate_id) %>%
  summarize(mean_cluster_change = mean(cluster_change), .groups = "drop")

# ─────────────────────────────────────────────
# DEBATE LEVEL ANALYSIS
# ─────────────────────────────────────────────

hardest_debates <- df_lhs %>%
  group_by(current_experiment_id, current_condition, use_distinct_agents, debate_label) %>%
  summarize(
    mae_mean = mean(mae),
    mae_min = min(mae),
    best_model = model_type[which.min(mae)],
    .groups = "drop"
  ) %>%
  arrange(desc(mae_mean)) %>%
  head(10)

easiest_debates <- df_lhs %>%
  group_by(current_experiment_id, current_condition, use_distinct_agents, debate_label) %>%
  summarize(
    mae_mean = mean(mae),
    mae_min = min(mae),
    best_model = model_type[which.min(mae)],
    .groups = "drop"
  ) %>%
  arrange(mae_mean) %>%
  head(10)


# ─────────────────────────────────────────────
# NETWORK GENERATION
# ─────────────────────────────────────────────

network_outputs <- build_influence_network(df_lhs_interactions)

# ─────────────────────────────────────────────
# FINAL OUTPUTS
# ─────────────────────────────────────────────

final_recommendations <- df_lhs %>%
  group_by(model_type) %>%
  slice_min(mae, n = 3) %>%
  select(
    model_type, mae, convergence_rate,
    confidence_threshold, repulsion_threshold,
    repulsion_strength, use_distinct_agents,
    current_condition
  ) %>%
  arrange(mae)

results_table <- df_lhs %>%
  group_by(model_type, use_distinct_agents) %>%
  summarize(MAE = mean(mae), .groups = "drop") %>%
  arrange(model_type, use_distinct_agents)

write.csv(results_table, "results-presentation.csv")

# ─────────────────────────────────────────────
# GA REGION EXTRACTION
# ─────────────────────────────────────────────

lhs_regions <- param_region_extraction(df_lhs, percentile = 0.25)
gaml_ga <- generate_gaml_bounds(lhs_regions$regions)
writeLines(gaml_ga, "gaml_GA_bounds.txt")

# lhs outputs list for rmd
lhs_outputs <- list(
  inputs = list(
    raw = df_lhs,
    versions = lhs_versions,
    version_summary = df_version_summary,
    influence = df_lhs_influence
  ),
  results = list(
    sensitivity = list(
      combined = list(pcc = pcc_lhs, prcc = prcc_lhs),
      v1 = list(pcc = sensi_v1$pcc, prcc = sensi_v1$prcc),
      v2 = list(pcc = sensi_v2$pcc, prcc = sensi_v2$prcc)),
    models = list(conv = run_conv_model(df_conv_debate), ols = ols_model),
    comparisons = list(
      ols = comparison_clean,
      summary = comparison_summary,
      ranking = model_comparison_main,
      version_ranking = model_comparison_2,
      baseline = baseline_comparison,
      directional = df_lhs_directional
    ),
    behavioral = list(
      composition = h_vs_m,
      speaking = speaking_compar,
      convergence = convergence_anal,
      stochastic = stochasticity_check_1,
      heterogen = heterogeneity_check
    ),
    dynamics = list(
      conv_debate = df_conv_debate,
      conv_diff = conv_diff,
      failures = failures_comp,
      clusters = clusters
    ),
    regions = list(
      bounds = lhs_regions$regions,
      range_check = lhs_regions$range_check,
      bipol_check = lhs_regions$bipol_check
    ),
    networks = list (
      per_debate = network_outputs$per_debate,
      aggregate = network_outputs$aggregate,
      graphs = network_outputs$graphs
    )
  ),
  plots = list(
    pcc = function() plot_pcc_heatmap(pcc_lhs),
    prcc = function() plot_prcc_heatmap(prcc_lhs),
    
    # combined pcc and prcc vis for v1 and v2
    pcc_all = function() plot_pcc_all_heatmap(pcc_all),
    prcc_all = function() plot_prcc_all_heatmap(prcc_all),
    
    pcc_v1 = function() plot_pcc_heatmap(sensi_v1$pcc),
    prcc_v1 = function() plot_prcc_heatmap(sensi_v1$prcc),
    
    pcc_v2 = function() plot_pcc_heatmap(sensi_v2$pcc),
    prcc_v2 = function() plot_prcc_heatmap(sensi_v2$prcc),
    
    abm_vs_ols = function() plot_ols_abm_comp(comparison_clean),
    
    
    model_rank_versions = function() plot_model_rank_versions(model_comparison_main), 
    model_performance_rank_main = function() plot_model_performance_rank_main(model_comparison_main),
    model_performance_uncertainty = function() plot_model_comparison_uncertainty(model_comparison_detailed),
    model_performance_gap = function() plot_model_performance_rank_gap(model_comparison_relative),
    
    debate_comp_errors = function() plot_h_m_errors(df_lhs),
    
    opin_var_versions = function() plot_opin_var_versions(lhs_versions), # can debug by adding in df_versions from rmd
    
    # convergence and speaking
    convergence_compar = function() plot_box_conv_compar_speak(df_conv_debate),
      
    convergence = function() plot_viol_conv_model_type(df_lhs),
    tradeoff_agg = function() plot_tradeoff_aggregated(df_conv_debate),
    tradeoff_raw = function() plot_tradeoff_raw(df_lhs),
    
    # Interaction plots
    influence_model_type = function() plot_influence_by_model(df_lhs_influence),
    saturation_by_condition = function() plot_satur_by_condition(df_lhs_susceptibility),
    direction_by_position = function() plot_dir_by_pro(df_lhs_susceptibility),
    directional_accuracy = function() plot_directional_accuracy(df_lhs_directional),
    delta_direction_sim_vs_empir = function() plot_delta_direction_scatter(df_lhs_directional_agents)
  )
)

lhs_outputs

# check that everything worked
message("lhs_outputs built successfully, inputs/dataframes: ", length(lhs_outputs$inputs))
message("lhs_outputs built successfully, tables: ", length(lhs_outputs$results))
message("lhs_outputs built successfully, plots: ", length(lhs_outputs$plots))
