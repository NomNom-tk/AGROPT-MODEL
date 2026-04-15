# GA analysis

#sources
source("./functions.R")
source("./data_processing.R")

# Sensitivity Analysis ----
sensi_ga <- run_sensi_analysis(df_ga, param_cols_by_model = param_cols_by_model, output_cols = output_cols)
pcc_ga <- sensi_ga$pcc
prcc_ga <- sensi_ga$prcc

# gA vs no change comparison test of h3 and h5
ga_best <- df_ga %>%
  filter(model_type != "no_change") %>%
  group_by(model_type, selected_debate_id) %>% # removed use_distinct_agetns, no change baseline never selected runs with TRUE
  slice_min(mae, n=1, with_ties = FALSE) %>%
  ungroup()

no_change_best <- df_ga %>%
  filter(model_type == "no_change") %>%
  group_by(selected_debate_id) %>%
  summarise(no_change_mae = mean(mae), .groups = "drop")

ga_vs_no_change <- ga_best %>%
  left_join(no_change_best, by = c("selected_debate_id")) %>% # join only on debate id as no_change did not take the use_distinct in its lowest mae runs
  mutate(delta_mae = mae - no_change_mae,
         abm_wins = delta_mae < 0) 

ga_vs_no_change %>%
  group_by(model_type) %>%
  summarise(n = n(), n_missing = sum(is.na(mae) | is.na(no_change_mae)), .groups = "drop")

ga_best %>% count(model_type, selected_debate_id) %>% filter(n > 1)

# summary per model
ga_baseline_summary <- ga_vs_no_change %>%
  group_by(model_type) %>%
  summarise(
    mean_delta = mean(delta_mae, na.rm = TRUE),
    pct_abm_wins = mean(abm_wins, na.rm = TRUE) * 100,
    wilcoxon_p = wilcox.test(mae, no_change_mae, paired = TRUE)$p.value,
    .groups = "drop"
  )
# interpretation: removed use_distinct as no change never selected TRUE for best runs
# no model beats the no_change baseline (bipol has 54.5% win rate but insignificant)
# consensus is closest in p value: 0.08, so it beats no change but only in 38% of cases

# plot for delta_mae per model, colored by win/loss
p_ga_delta <- ga_vs_no_change %>%
  mutate(group_label = paste0(model_type, 
                              ifelse(use_distinct_agents, " (distinct)", " (homog.)"))) %>%
  ggplot(aes(x = factor(selected_debate_id), y = delta_mae, fill = abm_wins)) +
  geom_col() +
  geom_hline(yintercept = 0, linetype = "dashed") +
  scale_fill_manual(values = c("TRUE" = "#2ecc71", "FALSE" = "#e74c3c"),
                    labels = c("TRUE" = "ABM wins", "FALSE" = "Baseline wins")) +
  facet_wrap(~ group_label, ncol = 1) +
  labs(
    title = "GA Best MAE vs No-Change Baseline per Debate",
    x     = "Debate ID",
    y     = "Δ MAE (GA − Baseline)",
    fill  = NULL
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(size = 6, angle = 45, hjust = 1))

print(p_ga_delta)
# interpretation: baseline always wins no matter what

# common debates comparison
common_debates <- intersect(
  unique(df_lhs$selected_debate_id),
  unique(df_ga$selected_debate_id)
)
length(common_debates)
# interpret: 40 common debates, only 4 were covered by lhs and not ga

# filter using common debates
df_lhs_common <- df_lhs %>% filter(selected_debate_id %in% common_debates)
df_ga_common <- df_ga %>% filter(selected_debate_id %in% common_debates)

## GA vs LHS improvement
lhs_best_comp <- df_lhs_common %>%
  group_by(model_type, use_distinct_agents) %>% # use_distinct_agetns here because we are asking across all debates did GA do better than LHS
  #slice_min(mae, n=1, with_ties = FALSE) %>%
  summarise(lhs_best_mae = min(mae), .groups = "drop")


ga_best_comp <- df_ga_common %>%
  group_by(model_type, use_distinct_agents) %>%
  summarise(ga_best_mae = min(mae), .groups = "drop")

lhs_vs_ga <- lhs_best_comp %>%
  left_join(ga_best_comp, by = c("model_type", "use_distinct_agents")) %>%
  filter(model_type != "no_change") %>% # no_change filterd out as there is are no calibration parameters
  mutate(
    improvement_pct = (lhs_best_mae - ga_best_mae) / lhs_best_mae * 100
  )

print(lhs_vs_ga)
# interpretation: LHS consistently outperforms GA despite the 4 uncovered debates
# GA struggled to optimise in the new config

# plots for GA vs lhs
p_lhs_ga <- lhs_vs_ga %>%
  pivot_longer(cols = c(lhs_best_mae, ga_best_mae),
               names_to  = "stage",
               values_to = "best_mae") %>%
  mutate(
    stage       = recode(stage,
                         "lhs_best_mae" = "LHS",
                         "ga_best_mae"  = "GA"),
    group_label = paste0(model_type,
                         ifelse(use_distinct_agents, " (distinct)", " (homog.)"))
  ) %>%
  ggplot(aes(x = group_label, y = best_mae, fill = stage)) +
  geom_col(position = "dodge") +
  scale_fill_manual(values = c("LHS" = "#3498db", "GA" = "#9b59b6")) +
  labs(
    title = "Best MAE: LHS vs GA Calibration",
    x     = NULL,
    y     = "Best MAE",
    fill  = "Stage"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 25, hjust = 1))

print(p_lhs_ga)

## selection of best parameters
ga_best_params <- df_ga %>%
  filter(model_type != "no_change") %>%
  group_by(model_type, use_distinct_agents) %>%
  slice_min(mae, n = 5, with_ties = FALSE) %>%
  summarise(
    best_mae = min(mae),
    convergence_rate_mean = mean(convergence_rate),
    convergence_rate_sd = sd(convergence_rate),
    confidence_threshold_mean = mean(confidence_threshold),
    confidence_threshold_sd = sd(confidence_threshold),
    repulsion_threshold_mean = mean(repulsion_threshold),
    repulsion_threshold_sd = sd(repulsion_threshold),
    repulsion_strength_mean = mean(repulsion_strength),
    repulsion_strength_sd = sd(repulsion_strength),
    .groups = "drop"
  )
