# plots
# depends on nothing

# updates
# 6/5/26 introduced all plots from lhs_analysis_1 (and tested)

# TODO feedback on which plot is better for PCC and PRCC
#' Visualize combined PCC for combined versions (e.g., v1, v2, etc)
#'
#' Produces a faceted heatmap of Partial Correlation Coefficients (PCC)
#' Intended use with LHS sensitivity analysis and called via lhs_outputs$plots$pcc_all() when
#' Multiple versions are present using lhs_outputs$inputs$versions
#' Dataframe is bound when lhs_outputs is constructed.
#'
#' @param pcc_all Dataframe containing at least the following columns:
#' (see \code{run_sensi_analysis()} for the sensitivity calc function (in functions.R)
#' \describe{
#'   \item{parameter}{Character. Input parameter name}
#'   \item{output}{Character. Output variable name}
#'   \item{PCC}{Numeric. Partial correlation coefficient}
#'   \item{versions}{Character. Version label (e.g., "v1", "v2")}
#' }
#' @return A ggplot2 object.
#' @note Only called when \code{lhs_outputs$inputs$versions} is non-null and not empty
#' see lhs-analysis-comparison chunk in Rmd for calls
plot_pcc_all_heatmap <- function(df) {
  ggplot(df, aes(x=parameter, y=output, fill=PCC)) +
    geom_tile(width = 0.9, height = 0.9) +
    #facet_grid(model_type ~ version) +
    facet_wrap(~ version) +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 8),
          axis.text.y = element_text(size = 8))
}

#' Visualize combined PRCC for combined versions (e.g., v1, v2, etc)
#'
#' Produces a faceted heatmap of Partial Rank Correlation Coefficients (PRCC)
#' Intended use with LHS sensitivity analysis and called via lhs_outputs$plots$prcc_all() when
#' Multiple versions are present using lhs_outputs$inputs$versions
#' Dataframe is bound when lhs_outputs is constructed.
#' @param prcc_all Dataframe containing at least the following columns:
#' (see \code{run_sensi_analysis()} for the sensitivity calc function (in functions.R)
#' \describe{
#'   \item{parameter}{Character. Input parameter name}
#'   \item{output}{Character. Output variable name}
#'   \item{PRCC}{Numeric. Partial correlation coefficient}
#'   \item{versions}{Character. Version label (e.g., "v1", "v2")}
#' }
#' @return A ggplot2 object.
#' @note Only called when \code{lhs_outputs$inputs$versions} is non-null and not empty
#' see lhs-analysis-comparison chunk in Rmd for calls
plot_prcc_all_heatmap <- function(df) {
  ggplot(df, aes(x=parameter, y=output, fill=PRCC)) +
    geom_tile(width = 0.9, height = 0.9) +
    facet_grid(~ version) +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 8),
          axis.text.y = element_text(size = 8))
}

#' Visualize PCC for single version
#'
#' Produces a faceted heatmap of Partial Correlation Coefficients (PCC)
#' Intended use with LHS sensitivity analysis and called via lhs_outputs$plots$pcc()
#' @param pcc_lhs Dataframe containing at least the following columns:
#' (see \code{run_sensi_analysis()} for the sensitivity calc function (in functions.R)
#' \describe{
#'   \item{parameter}{Character. Input parameter name}
#'   \item{output}{Character. Output variable name}
#'   \item{PCC}{Numeric. Partial correlation coefficient}
#' }
#' @return A ggplot2 object.
#' see lhs-analysis-comparison chunk in Rmd for calls
plot_pcc_heatmap <- function(df) {
  ggplot(df, aes(x = parameter, y = output, fill = PCC)) +
    geom_tile() +
    scale_fill_gradient2(low = "blue", mid = "grey", high = "red", midpoint = 0) +
    facet_wrap(~ key, scales = "free_x", ncol = 3) +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))
}

#' Visualize PRCC for single version
#'
#' Produces a faceted heatmap of Partial Rank Correlation Coefficients (PRCC)
#' Intended use with LHS sensitivity analysis and called via lhs_outputs$plots$prcc()
#' @param prcc_lhs Dataframe containing at least the following columns:
#' (see \code{run_sensi_analysis()} for the sensitivity calc function (in functions.R)
#' \describe{
#'   \item{parameter}{Character. Input parameter name}
#'   \item{output}{Character. Output variable name}
#'   \item{PRCC}{Numeric. Partial correlation coefficient}
#' }
#' @return A ggplot2 object.
#' see lhs-analysis-comparison chunk in Rmd for calls
plot_prcc_heatmap <- function(df){
  ggplot(df, aes(x = parameter, y = output, fill = PRCC)) +
    geom_tile() +
    scale_fill_gradient2(low = "blue", mid = "grey", high = "red", midpoint = 0) +
    facet_wrap(~ key, scales = "free_x", ncol = 3) +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))
}

#' Empirical Viz for T1-T2 Change
#' 
#' Produces a bar chart for mean opinion change before and after debate
#' Intended use with empirical data csv to check opinion evolution, called with lhs_outputs$plots$empirical_col()
#' @param empirical_stat_check Dataframe of empirical debate data processed by empirical_stats() (in functions.R)
#' \describe{
#'   \item{condition}{Character. Experimental group (among: control, heterogeneous, homogenous)}
#'   \item{mean_change}{Numerical. Empirical change between T1 (before debate) and T2 (after debate) questionnaires}
#' }
#' @return A ggplot2 object with horizontal intercept (empirical beta?)
#' @note see empirical_comparison chunk in Rmd for call.
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

#' Column Viz for cross-time comparisons
#' 
#' Produces a column chart to illustrate empirical opinion change across experimental conditions
#' Intended use with empirical data csv called with lhs_outputs$plots$empirical_cross()
#' @param empirical_stat_pivot Dataframe (empirical_stat_pivot) pivot of empirical stats() (in functions.R)
#' \describe{
#'   \item{condition}{Character. Experimental group (among: control, heterogeneous, homogenous)}
#'   \item{value}{Numerical. Pivoted mean change assigned to value}
#'   \item{change_type}{Factor. Change for time period (e.g., mean_change_t0_t1)}
#' }
#' @return A ggplot2 object with opinion change for different timeframes
#' @note see empirical_comparison chunk in Rmd for call.
plot_empir_cross <- function(df) {
  ggplot(df, aes(x = condition, y = value, fill = change_type)) +
    geom_col(position = "dodge") +
    geom_hline(yintercept = 0) +
    labs(x = "Condition", y = "Average Change",
         title = "Opinion Change Across T0-T1-T2")
}

#' OLS VS ABM Model Comparison (GA,LHS,PSO,etc)
#' 
#' Produces a scatter plot comparing empirical ABM (between T1 and T2) and simulated MAE
#' Intended use with empirical and simulated datae (e.g., LHS, GA) to check whether ABM 
#' improves upon the empirical regression.
#' @param comparison_clean Dataframe (df that has an inner join between simulation and empirical data by selected_debate_id)
#' \describe{
#'   \item{ols_mae}{Numerical. Linear regression between initial and final empirical attitudes}
#'   \item{abm_mae}{Numerical. Mean of simulated MAE for an exploration algorithm}
#' @note y=x dashed line represents proportion of ABM debates that improves on OLS baseline}
#' }
#' @return A ggplot scatter plot comparing in which debates ABM improves over OLS or vice-versa.
#' @note see directional-accuracy chunk in Rmd for call.
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

  # inject baseline across both facets simultaneously
  df <- anchor_baseline_facets(df, condition_col = "speaking_mode")

  # defensive fix: establish global sorting rank using real values (despite TRUE for speakign mode not having no_change)
  global_order <- df %>%
    group_by(model_type) %>%
    summarize(
        global_mae = mean(mae_mean, na.rm = TRUE), .groups = "drop") %>%
    arrange(global_mae) %>%
    pull(model_type)

  # force model type to be a facto with master global order
  df$model_type <- factor(df$model_type, levels = global_order)
    
  # base plot with columns that ALWAYS exist, no need for reorder since we declared global order
  p <- ggplot(df, aes(x = model_type, y = mae_mean)) +
    geom_col(fill= "#34495e", alpha = 0.85, width = 0.7) +
    coord_flip() +
    theme_bw(base_size = 12) +
    scale_x_discrete(drop = FALSE) + # 12/6/26 forces true side to keep no_change as an empty slot
    labs(title = "Model Performance by Version",
         x = "Model Type",
         y = "Mean MAE")
  
  # dynamic with versions 9/6/26
  if ("version" %in% colnames(df)) {
    # if version exists facet by version AND speaking_mode
    p <- p + facet_grid(version ~ speaking_mode)
  } else {
    # version missing collapse to 1D with speaking_mode ONLY
    p <- p + facet_wrap(~ speaking_mode)
  }
  return(p)
}

## Model performance with distinct agents
# fix version aware and defensive wrap
plot_model_comparison_uncertainty <- function(df) { # use detailed version
  p <- ggplot(df, aes(x = reorder(model_type, mae_mean), y = mae_mean)) +
    geom_point(size = 2.5, color = "blue") +
    geom_errorbar(aes(
      ymin = mae_mean - mae_sd,
      ymax = mae_mean + mae_sd
    ), width = 0.2) +
    coord_flip() +
    theme_minimal() +
    labs(
      title = "Model Performance with Distinct Agents",
      subtitle = "Error bars = +- SD",
      x = "Model Type",
      y = "Mean MAE"
    )
  
  if ("version" %in% colnames(df)) {
    p <- p + facet_grid(version ~ speaking_mode + use_distinct_agents)
  } else {
    p <- p + facet_wrap(~ speaking_mode + use_distinct_agents)
  }
  return(p)
}

## how far is the performance gap compared to the best model
plot_model_performance_rank_gap <- function(df) { # use with model_relative
  # standard version with columns that ALWAYS exist
  p <- ggplot(df, aes(x= reorder(model_type, delta_mae), y = delta_mae)) +
    geom_col(fill = "darkred") +
    coord_flip() +
    theme_bw() +
    labs(title = "Performance Gap to Best Model",
         subtitle = "0 = best model in each panel",
         x = "Model Type",
         y = "Delta MAE")
  
  # dynamic with version AND speaking_mode 9/6/26
  if ("version" %in% colnames(df)) {
    # if version exists facet by BOTH
    p <- p + facet_grid(version ~ speaking_mode)
  } else {
    # if no version exists, 1D collapse to speaking_mode
    p <- p + facet_wrap(~ speaking_mode)
  }
  return(p)
}

## Version aware rank comparison
# TODO modify with version abstraction
# needs to be injected only if declared as non NULL, convert string (var) to variable symbol
# inject with !! into aes mapping
# else use static color if no column is present and write a message 
plot_model_rank_versions <- function(df, color_col = NULL) { # use with main
  
  # define grouping var for color = version
  if (!is.null(color_col) && color_col %in% colnames(df)) {
    group_var <- bquote(interaction(model_type, .(sym(color_col))))
  } else {
    # single version
    group_var <- sym("model_type")
  }
  
  p <- ggplot(df, aes(x = model_type, y = mae_mean)) +
    geom_point(position = position_dodge(width = 0.5), size = 3) +
    geom_errorbar(aes(
      ymin = mae_mean - mae_sd,
      ymax = mae_mean + mae_sd
    ), width = 0.2, position = position_dodge(width = 0.5)) +
    geom_line(aes(group = !!group_var), alpha = 0.4) +
    coord_flip() +
    facet_wrap(~ speaking_mode) +
    theme_minimal() +
    labs(
      title = "Model Performance Across Versions",
      x = "Model Type",
      y = "Mean MAE",
      color = "version"
    )
  
  # inject color ONLY if column is provided and exists
  if (!is.null(color_col) && color_col %in% colnames(df)) {
    # conv string to variable symbol
    color_sym <- sym(color_col)
    p <- p + aes(color = !!color_sym) +
      labs(color = color_col)
  } else {
    #fallback to default
    p <- p + geom_point(color = "darkblue", position = position_dodge(width = 0.5), size = 3) +
      geom_errorbar(aes(ymin = mae_mean - mae_sd, ymax = mae_mean + mae_sd),
                    color = "darkblue", width = 0.2)
    
    message("No variable color (version) column found. Default to darkblue")
  }
  return(p)
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
### 10/6/26 version guard
plot_opin_var_versions <- function(df) { # use with df_versions
  p <- ggplot(df, aes(x = model_type, y = opinion_variance)) +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1),
          strip.text = element_text(face = "bold")) +
    labs(title = "Opinion Variance by model type", y = "Opinion Variance")
  
  # version guard
  if ("version" %in% colnames(df)) {
    p <- p + geom_boxplot(aes(fill = version), position = position_dodge(0.75), width = 0.6) +
      facet_wrap(~ version)
  } else {
    p <- p + geom_boxplot(fill = "darkblue", width = 0.6)
  }
  return(p)
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