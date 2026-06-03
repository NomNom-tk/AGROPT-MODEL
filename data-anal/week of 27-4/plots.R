# plots
# depends on nothing

# updates
# 6/5/26 introduced all plots from lhs_analysis_1 (and tested)

# TODO feedback on which plot is better for PCC and PRCC
plot_pcc_all_heatmap <- function(df) {
  ggplot(df, aes(x=parameter, y=output, fill=PCC)) +
    geom_tile(width = 0.9, height = 0.9) +
    #facet_grid(model_type ~ version) +
    facet_wrap(~ version) +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 8),
          axis.text.y = element_text(size = 8))
}

plot_prcc_all_heatmap <- function(df) {
  ggplot(df, aes(x=parameter, y=output, fill=PRCC)) +
    geom_tile(width = 0.9, height = 0.9) +
    facet_grid(~ version) +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 8),
          axis.text.y = element_text(size = 8))
}

plot_pcc_heatmap <- function(df) {
  ggplot(df, aes(x = parameter, y = output, fill = PCC)) +
    geom_tile() +
    scale_fill_gradient2(low = "blue", mid = "grey", high = "red", midpoint = 0) +
    facet_wrap(~ key, scales = "free_x", ncol = 3) +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))
}

plot_prcc_heatmap <- function(df){
  ggplot(df, aes(x = parameter, y = output, fill = PRCC)) +
    geom_tile() +
    scale_fill_gradient2(low = "blue", mid = "grey", high = "red", midpoint = 0) +
    facet_wrap(~ key, scales = "free_x", ncol = 3) +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))
}

# Empirical comparisons
# empirical for t1_t2
plot_empir_compar <- function(df) {
  ggplot(df, aes(x = condition, y = mean_change_t1_t2)) +
    geom_col() +
    geom_errorbar(aes(ymin = mean_change_t1_t2 - sd_change_t1_t2, 
                  ymax = mean_change_t1_t2 + sd_change_t1_t2)) +
    geom_hline(yintercept = 0.042, linetype = "dashed") +
    #geom_hline(yintercept = df %>% filter(condition == "Control") %>%
   #              pull(mean_change_t1_t2), linetype = "dashed") +
    theme_minimal() +
    scale_fill_manual(values = c("t0_t1" = "#2C3E50", "t1_t2" = "#E74C3C")) +
    labs(x = "Condition", y = "Avg Change T1->T2", 
         title = "Opinion Change from T1 to T2")
}

# stacked column for cross-time comparisons
plot_empir_cross <- function(df) {
  ggplot(df, aes(x = condition, y = value, fill = change_type)) +
    geom_col(position = "dodge") +
    geom_hline(yintercept = 0) +
    labs(x = "Condition", y = "Average Change",
         title = "Opinion Change Across T0-T1-T2")
}

# Model Comparison
## OLS VS ABM
plot_ols_abm_comp <- function(df) { # use with comparison_clean
  ggplot(df, aes(x=ols_mae, y=abm_mae)) +
    geom_point(alpha = 0.6) +
    geom_abline(slope = 1, intercept = 0, linetype = "dashed", color = "red") +
    labs(
      title = "ABM vs OLS Performance",
      x = "OLS MAE",
      y = "ABM MAE"
    ) +
    theme_bw()
}

## Model performance as a rank
plot_model_performance_rank_main <- function(df) { # use with model_compar_main
  ggplot(df, aes(x= reorder(model_type, mae_mean), y=mae_mean)) +
    geom_col(fill= "blue") +
    coord_flip() +
    facet_grid(version ~ speaking_mode) +
    theme_bw() +
    labs(Title = "Model Performance by Version",
         x = "Model Type",
         y = "Mean MAE")
}

## Model performance with distinct agents
plot_model_comparison_uncertainty <- function(df) { # use detailed version
  ggplot(df, aes(x = reorder(model_type, mae_mean), y = mae_mean)) +
    geom_point(size = 2.5, color = "blue") +
    geom_errorbar(aes(
      ymin = mae_mean - mae_sd,
      ymax = mae_mean + mae_sd
    ), width = 0.2) +
    coord_flip() +
    facet_grid(version ~ speaking_mode + use_distinct_agents) +
    theme_minimal() +
    labs(
      title = "Model Performance with Distinct Agents",
      subtitle = "Error bars = +- SD",
      x = "Model Type",
      y = "Mean MAE"
    )
}

## how far is the performance gap compared to the best model
plot_model_performance_rank_gap <- function(df) { # use with model_relative
  ggplot(df, aes(x= reorder(model_type, delta_mae), y=delta_mae)) +
    geom_col(fill = "darkred") +
    coord_flip() +
    facet_wrap(version ~ speaking_mode) +
    theme_bw() +
    labs(Title = "Performance Gap to Best Model",
         subtitle = "0 = best model in each panel",
         x = "Model Type",
         y = "Delta MAE",)
}

## Version aware rank comparison
plot_model_rank_versions <- function(df) { # use with main
  ggplot(df, aes(x = model_type, y = mae_mean, color = version)) +
    geom_point(position = position_dodge(width = 0.5), size = 3) +
    geom_errorbar(aes(
      ymin = mae_mean - mae_sd,
      ymax = mae_mean + mae_sd,
      color = version
    ), width = 0.2) +
    geom_line(aes(group = model_type), alpha = 0.4) +
    coord_flip() +
    facet_wrap(~ speaking_mode) +
    theme_minimal() +
    labs(
      title = "Model Performance Across Versions",
      x = "Model Type",
      y = "Mean MAE",
      color = "version"
    )
}

# Debate Composition
# upgraded with model type (within composition comparison), facet(speaking mode to control for behavioral regime and avoids confounding)
plot_h_m_errors <- function(df) { # use with df lhs / could try with versions and compare
  ggplot(df, aes(x = debate_composition, y = mae, fill = model_type)) +
    geom_boxplot(position = position_dodge(0.8)) +
    facet_wrap(~ speaking_mode) +
    theme_bw() +
    labs(title = "Effect of Debate Composition on Prediction Error",
         x = "Debate Composition",
         y = "MAE",
         fill = "Model Type")
}

# Convergence Plots
## Violin for convergence
plot_viol_conv_model_type <- function(df) {
  ggplot(df, aes(x=model_type, y=convergence_cycle)) +
    geom_violin(trim=TRUE, scale="width", fill="grey85") +
    geom_boxplot(width=0.12, outlier.shape=NA, fill="white") +
    stat_summary(fun = median, geom="point", color="red", size=2) +
    facet_wrap(~ speaking_mode) +
    theme_bw()
}

## Box plot convergence comparison (1) generalized (2) speaking_mode aware
plot_box_conv_compar <- function(df) { # use with df_conv_debate
  ggplot(df, aes(x=model_type, y=mean_conv, fill = speaking_mode)) +
    geom_boxplot(position = position_dodge(width = 0.8)) +
    labs(title = "Convergence Rate Comparison by model type and speaking mode",
         fill = "speaking mode") +
    theme_bw()
}

plot_box_conv_compar_speak <- function(df) {
  ggplot(df, aes(x=model_type, y=mean_conv, fill = speaking_mode)) +
    geom_boxplot(position = position_dodge(width = 0.8)) +
    facet_wrap(~ speaking_mode) +
    labs(title = "Convergence Rate Comparison by model type and speaking mode",
         fill = "speaking mode") +
    theme_bw()
}

## Convergence outcome analysis
plot_opin_var_versions <- function(df) { # use with df_versions
  ggplot(df, aes(x = model_type, y = opinion_variance, fill = version)) +
    geom_boxplot(position = position_dodge(0.75), width = 0.6) +
    facet_wrap(~ version) +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1),
          strip.text = element_text(face = "bold")) +
    labs(title = "Opinion Variance by model type", y = "Opinion Variance")
}

## Trade-offs
# aggregated plot
plot_tradeoff_aggregated <- function(df) {
  ggplot(df, aes(x = mean_conv, y = mean_mae, color = speaking_mode)) +
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
}

# trade off plot raw
plot_tradeoff_raw <- function(df) {
  ggplot(df, aes(x = convergence_cycle, y = mae, color = speaking_mode)) +
    geom_point(alpha = 0.3) +
    geom_smooth(method = "lm", se = TRUE) +
    facet_wrap(~ model_type) +
    labs(title = "Speed-Accuracy Trade-off Raw",
         x = "Convergence Cycles",
         y = "MAE") +
    theme_bw()
}



# Interaction plots
## influence distribution by model type -- density of influence score faceted by model type
plot_influence_by_model <- function(df) { # use with df_lhs_influence
  ggplot(df, aes(x = model_type, y = influence_score, fill = model_type)) +
    geom_violin() +
    #theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
    labs(x = NULL, y = "Influence Score")
}

## saturation rate by condition
## bar chart of pct_saturated form df suscept, group by model type and current condition
plot_satur_by_condition <- function(df) { # use with df_lhs_susceptibility
  df %>%
    group_by(model_type, current_condition) %>% # gropu/sum to take mean instead of stacking values to 1
    summarize(pct_saturated = mean(pct_saturated), .groups = "drop") %>%
    ggplot(aes(x = current_condition, y = pct_saturated, fill = model_type)) +
      geom_bar(stat = "identity", position = "dodge") +
      theme_minimal() +
      theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
      labs(x = "Condition", y = "% saturated")
}

## plot direcitonal accuracry
### top right and bottom left are correct direction / top let and bottom right are wrong
plot_directional_accuracy <- function(df) { # use with df_lhs_directional
  ggplot(df, aes(x = current_condition, y = pct_correct_dir, fill = model_type)) +
    geom_bar(stat = "identity", position = "dodge") +
    geom_hline(yintercept = 0.5, linetype = "dashed", color = "red") +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
    labs(x = "Condition", y = "% accurate agents")
}

## delta scatter to understand in which direction gaents go
plot_delta_direction_scatter <- function(df) { # use with df_lhs_directional
  df <- df %>%
    mutate(
      simulated_delta = opinion - initial_opinion,
      empirical_delta = final_attitude - initial_opinion
    )
  
  ggplot(df, aes(x = simulated_delta, y = empirical_delta)) +
    geom_point(alpha = 0.3) +
    geom_abline(slope = 1, intercept = 0) + # perfect prediction line
    geom_hline(yintercept = 0, linetype = "dashed") + # no empirical change
    geom_vline(xintercept = 0, linetype = "dashed") + # no simulated change
    facet_wrap(~ model_type) +
    theme_minimal() +
    labs(x = "Simulated Change", y = "Empirical Change")
}

## wrong direction rate by pro/anti bar chart
## pct wrong direction from df suscept facet by model type, colored by pro_reduction
### is overestimation asymmetric between pro and anti agents
plot_dir_by_pro <- function(df) { # use with df_lhs_susceptibility
  df %>%
    group_by(model_type, pro_reduction) %>% # 30-4-26 gropu/sum to take mean instead of stacking values to 1
    summarize(pct_wrong_direction = mean(pct_wrong_direction), .groups = "drop") %>%
    ggplot(aes(x = model_type, y = pct_wrong_direction, 
                   fill = factor(pro_reduction, labels = c("Anti", "Pro")))) +
      geom_bar(stat = "identity", position = "dodge") +
      theme_minimal() +
      theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
      labs(x = "Model Type", y = "% Wrong Direction", fill = "Position")
}

# Beta distribution comparison
plot_beta_distance <- function(df_raw, empirical_beta) {
    ggplot(df_raw, aes(x = estimate, fill = model_type)) +
    geom_density(alpha = 0.4) +
    geom_vline(xintercept = empirical_beta,
               linetype = "dashed", color = "red", linewidth = 0.8) +
    facet_wrap(~ model_type) +
    labs(x = "Simulated Beta",
         y = "Density",
         title = "Simulated beta distribution vs empirical beta",
         subtitle = paste("Empirical beta =", round(empirical_beta, 3))) +
    theme_minimal() +
    theme(legend.position = "none")
}