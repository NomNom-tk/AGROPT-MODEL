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
#' @param df Dataframe containing at least the following columns:
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
#' @param df Dataframe containing at least the following columns:
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
#' @param df Dataframe containing at least the following columns:
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
#' @param df Dataframe containing at least the following columns:
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
#' @param df Dataframe of empirical debate data processed by empirical_stats() (in functions.R)
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
    geom_hline(yintercept = df %>% filter(condition == "Control") %>%
                 pull(mean_change_t1_t2), linetype = "dashed") +
    theme_minimal() +
    #scale_fill_manual(values = c("t0_t1" = "#2C3E50", "t1_t2" = "#E74C3C")) +
    labs(x = "Condition", y = "Avg Change T1->T2", 
         title = "Opinion Change from T1 to T2")
}

#' Column Viz for cross-time comparisons
#' 
#' Produces a column chart to illustrate empirical opinion change across experimental conditions
#' Intended use with empirical data csv called with lhs_outputs$plots$empirical_cross()
#' @param df Dataframe (empirical_stat_pivot) pivot of empirical stats() (in functions.R), expected columns:
#'   condition, mean, sd, period.
#' \describe{
#'   \item{condition}{Character. Experimental group (among: control, heterogeneous, homogenous)}
#'   \item{mean}{Numerical. Pivoted mean change assigned to value}
#'   \item{period}{Factor. Change for time period (e.g., mean_change_t0_t1)}
#' }
#' @return A ggplot2 object with opinion change for different timeframes
#' @note see empirical_comparison chunk in Rmd for call. Pivot structure updated 23/9/26 — 
#' columns are mean/sd/period, not value/change_type. See empirical_stat_pivot in framework_analysis.R.
plot_empir_cross <- function(df) {
  ggplot(df, aes(x = condition, y = mean, fill = period)) +
    geom_col(position = "dodge") +
    geom_errorbar(aes(ymin = mean - sd, 
                  ymax = mean + sd),
				 position = position_dodge(0.9), width = 0.2) +
    geom_hline(yintercept = 0) +
    labs(x = "Condition", y = "Average Change",
         title = "Opinion Change Across T0-T1-T2")
}

#' OLS VS ABM Model Comparison (GA,LHS,PSO,etc)
#' 
#' Produces a scatter plot comparing empirical ABM (between T1 and T2) and simulated MAE
#' Intended use with empirical and simulated datae (e.g., LHS, GA) to check whether ABM 
#' improves upon the empirical regression.
#' @param df Dataframe (df that has an inner join between simulation and empirical data by selected_debate_id)
#' \describe{
#'   \item{ols_mae}{Numerical. Linear regression between initial and final empirical attitudes}
#'   \item{abm_mae}{Numerical. Mean of simulated MAE for an exploration algorithm}
#' }
#' @return A ggplot scatter plot comparing in which debates ABM improves over OLS or vice-versa.
#' @note y=x dashed line represents proportion of ABM debates that improves on OLS baseline / see directional-accuracy chunk in Rmd for call.
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

#' Version aware Model Performance Ranking
#' 
#' Produces a horizontally flipped bar chart ranking mean mae for each model_type
#' faceted by speaking_mode and version (if it exists). Global sort order computed
#' across all speaking_modes to ensure consistent ranking across facets
#' Baseline (no_change) is injected using \code{anchor_baseline_facets()} before plotting
#' @param df Dataframe (used with \code{model_compar_main}), containing:
#'   \describe{
#'     \item{model_type}{Character. Model type identifier (e.g., consensus, clustering, bipolarization)}
#'     \item{mae_mean}{Numerical. Mean MAE across debates for that model_type}
#'     \item{speaking_mode}{Boolean. Debate speaking mode condition}
#'     \item{version}{Character. Optional. LHS/GA if present facets by version AND speaking mode (\code{facet_grid})}
#'   }
#' @return A ggplot2 object \code{scale_x_discrete(drop = FALSE)} ensure \code{no_change} is preserved when absent from one facet.
#' @note Global sort order is derived across ALL speaking_modes to avoid inconsistent facet ordering
#' \code{anchor_baseline_facets()} handles this so that both facets level simultaneously
#' @seealso \code{anchor_baseline_facets()} (in functions.R) AND model-performance chunk in Rmd for call.
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
    labs(title = "Model Performance by Version and Speaking Mode (TRUE/FALSE",
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

#' Scatter Plot of Model Performance Considering Distinct Agents (Optional version aware)
#'
#' Creates a flipped coordinate scatter plot with error bars to illustrate the impact of using SDs for each agent across model types
#' Optionally version aware (through use of \code{facet_wrap})
#' 
#' @param df A dataframe (usually \code{model_comparison_detailed}), a version of df_batch
#' grouped by \{model_type, version, speaking_mode, use_distinct_agents} aand then summarized in terms of mean MAE
#' \describe{
#'   \item{reordered model_type, mae_mean}{Numerical. Meant to sort mae_mean by model_type}
#'   \item{mae_mean}{Numerical. MAE for each model_type}
#'   \item{version}{Character. Optional only if for different LHS/GA versions add this to speaking_mode and use_distinct_agents with \code{facet_wrap}}
#' }
#' @return a ggplot object with \code{coord_flip()} and \code{geom_errorbar()}
#' @note see (framework_analysis.R for calls in outputs list) / not used in Rmd.
plot_model_comparison_uncertainty <- function(df) {
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
#' Bar Chart of Model Performance Compared to Best Model
#'
#' Takes the best model (lowest mae and eliminates it from the plot), then displays
#' how far the rest of the models are from this "best" model
#'
#' @param df Dataframe use with \code{model_comparison_relative} which groups model_comparison_main by 
#' speaking mode and then calculates the delta_mae (mae wrt to the "best" model)
#' \describe{
#'   \item{reordered model_type and delta_mae}{Numerical. MAE relative to the lowest mae of the model, reordered to display per model_type}
#'   \item{delta_mae}{Numerical. MAE of the model_type relative to the model with the lowest MAE for speaking_mode}
#'   \item{version}{Character. Will facet by version AND speaking_mode if several versions of LHS or GA are present}
#' }
#' @return a ggplot object with \code{coord_flip()}
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

#' Scatter Plot of Model Performance (Rank) with Version Adaptation
#'
#' Used to establish if different versions of the same exploration algorithm have an impact on model performance.
#' Defines a grouping variable for color set to different versions if present.
#' Injects a color (through string conversion to a variable symbol) if the different verisons are available and otherwise collapses to a static "darkblue"
#' 
#' @param df Dataframe used with \code{model_comparison_main} which is grouped by \code{model_type} and \code{speaking_mode} AND \code{version} IF present.
#' @param color_col Variable Symbol IF different versions are present
#' \describe{
#'   \item{model_type}{Character. Distinguishes between different models in the experiment}
#'   \item{mae_mean}{Numerical. Average of MAE for the specific \code{model_type}}
#' }
#' @return a ggplot object comparing the model performance (mean MAE) across different versions, with different \code{color_sym} based on versions and faceted by speaking_mode.
#' @note not currently used in Rmd. See (framework_analysis.R for calls).
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
    # update 23/9/26 fallback to default using aes and scale color manual instead of duplicating geom_point&errorbar
    p <- p + aes(color = "single") +
	  scale_color_manual(values = c("single" = "darkblue")) +
	  theme(legend.position = "none")
    
    message("No variable color (version) column found. Default to darkblue")
  }
  return(p)
}

# Debate Composition
#' plot_h_m_errors (created mid 5/26)
#'
#' update mid 6/26 upgraded with model type (within composition comparison), 
#' facet(speaking mode to control for behavioral regime and avoids confounding)
#'
#' @param df A dataframe containing the columns: debate_composition, mae, model_type, speaking_mode
#' 
#' @return a ggplot object illustrating mae prediction error by model_type, faceted by speaking_mode
#'
#' @note use with df_batch in LHS \code{analysis_scope} = "LHS", output package ref: lhs_outputs$inputs$raw
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
#' plot_viol_conv_model_type (created mid 5/26)
#' 
#' @param df A dataframe containing the columns: model_type, convergence_cycle
#'  and speaking_mode
#'
#' @return A ggplot object, violin plot describing convergence_cycle variation based on model_type
#'  faceted by speaking_mode to highlight the impact of speaking_mode on debate convergence
#' 
#' @note use with df_batch in LHS \code{analysis_scope} = "LHS", output package ref: lhs_outputs$inputs$raw 
## Violin for convergence
plot_viol_conv_model_type <- function(df) {
  ggplot(df, aes(x=model_type, y=convergence_cycle)) +
    geom_violin(trim=TRUE, scale="width", fill="grey85") +
    geom_boxplot(width=0.12, outlier.shape=NA, fill="white") +
    stat_summary(fun = median, geom="point", color="red", size=2) +
    facet_wrap(~ speaking_mode) +
    theme_bw()
}

#' plot_box_conv_compar
#'
#' Boxplot comparing convergence rates across model types,
#' colored by speaking mode. No faceting — both speaking
#' modes appear side by side within each model_type.
#'
#' @param df Dataframe. Expected columns: model_type,
#'   mean_conv, speaking_mode.
#'
#' @return A ggplot boxplot object.
#'
#' @note Use with df_conv_debate.
#'   Output package ref: lhs_outputs$results$dynamics$conv_debate
plot_box_conv_compar <- function(df) { # use with df_conv_debate
  ggplot(df, aes(x=model_type, y=mean_conv, fill = speaking_mode)) +
    geom_boxplot(position = position_dodge(width = 0.8)) +
    labs(title = "Convergence Rate Comparison by model type and speaking mode",
         fill = "speaking mode") +
    theme_bw()
}

#' plot_box_conv_compar_speak
#'
#' Faceted variant of plot_box_conv_compar. Same boxplot
#' of convergence rates by model type and speaking mode,
#' but faceted by speaking_mode to separate the two regimes.
#'
#' @param df Dataframe. Expected columns: model_type,
#'   mean_conv, speaking_mode.
#'
#' @return A ggplot boxplot object faceted by speaking_mode.
#'
#' @note Use with df_conv_debate.
#'   Output package ref: lhs_outputs$results$dynamics$conv_debate
plot_box_conv_compar_speak <- function(df) {
  ggplot(df, aes(x=model_type, y=mean_conv, fill = speaking_mode)) +
    geom_boxplot(position = position_dodge(width = 0.8)) +
    facet_wrap(~ speaking_mode) +
    labs(title = "Convergence Rate Comparison by model type and speaking mode",
         fill = "speaking mode") +
    theme_bw()
}

# Convergence outcome analysis
#' plot_opin_var_versions (created 10/6/26)
#'
#' Boxplot of opinion variance by model type. Version-aware:
#' if a version column exists, fills by version and facets;
#' otherwise falls back to a single-color boxplot.
#'
#' @param df Dataframe. Expected columns: model_type,
#'   opinion_variance. Optional: version.
#'
#' @return A ggplot boxplot object, optionally faceted by version.
#'
#' @note Use with df_versions when multiple LHS versions are present.
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

# Trade-offs
#' plot_tradeoff_aggregated
#'
#' Scatter plot of the speed-accuracy trade-off at the debate level.
#' Plots mean convergence cycles against mean MAE with a linear
#' trend line, colored by speaking mode and faceted by model type.
#'
#' @param df Dataframe. Expected columns: mean_conv, mean_mae,
#'   speaking_mode, model_type.
#'
#' @return A ggplot scatter plot with geom_smooth(method = "lm").
#'
#' @note Use with df_conv_debate.
#'   Output package ref: lhs_outputs$results$dynamics$conv_debate
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

#' plot_tradeoff_raw
#'
#' Raw scatter plot variant of the speed-accuracy trade-off.
#' Plots individual convergence_cycle against MAE rather than
#' debate-level aggregates. Higher point density, lower alpha.
#'
#' @param df Dataframe. Expected columns: convergence_cycle,
#'   mae, speaking_mode, model_type.
#'
#' @return A ggplot scatter plot with geom_smooth(method = "lm").
#'
#' @note Use with df_batch.
#'   Output package ref: lhs_outputs$inputs$raw
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
#' plot_influence_by_model
#'
#' Violin plot of influence score distribution for each model type.
#' Intended for interaction-level analysis of how much each speaking
#' agent shifts others' opinions.
#'
#' @param df Dataframe. Expected columns: model_type, influence_score.
#'
#' @return A ggplot violin plot.
#'
#' @note Use with df_influence.
#'   Output package ref: lhs_outputs$inputs$influence.
#'   NULL when interactions are commented out.
plot_influence_by_model <- function(df) { # use with df_lhs_influence
  ggplot(df, aes(x = model_type, y = influence_score, fill = model_type)) +
    geom_violin() +
    #theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
    labs(x = NULL, y = "Influence Score")
}

#' plot_satur_by_condition
#'
#' Bar chart of mean cognitive saturation rate by experimental
#' condition, grouped by model type. Aggregates pct_saturated
#' within model_type and current_condition before plotting.
#'
#' @param df Dataframe. Expected columns: model_type,
#'   current_condition, pct_saturated.
#'
#' @return A ggplot grouped bar chart.
#'
#' @note Use with df_susceptibility.
#'   Closure-captured in output package.
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

#' plot_directional_accuracy
#'
#' Bar chart of directional accuracy (% of agents whose simulated
#' change matches the sign of empirical change) by condition and
#' model type. The 0.5 dashed line represents chance-level accuracy.
#'
#' @param df Dataframe. Expected columns: current_condition,
#'   pct_correct_dir, model_type.
#'
#' @return A ggplot grouped bar chart with chance baseline.
#'
#' @note Use with df_directional.
#'   Output package ref: lhs_outputs$results$comparisons$directional.
#'   top right and bottom left are correct direction / top let and bottom right are wrong
plot_directional_accuracy <- function(df) { # use with df_lhs_directional
  ggplot(df, aes(x = current_condition, y = pct_correct_dir, fill = model_type)) +
    geom_bar(stat = "identity", position = "dodge") +
    geom_hline(yintercept = 0.5, linetype = "dashed", color = "red") +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
    labs(x = "Condition", y = "% accurate agents")
}

#' plot_delta_direction_scatter
#'
#' Scatter plot comparing simulated vs empirical opinion change
#' per agent, colored by pro_reduction stance. The y=x line
#' represents perfect prediction. Faceted by model type.
#' Computes simulated_delta and empirical_delta internally.
#'
#' @param df Dataframe. Expected columns: opinion, initial_opinion,
#'   final_attitude, pro_reduction, model_type.
#'
#' @return A ggplot faceted scatter plot.
#'
#' @note Use with df_directional_agents.
#'   Output package ref: lhs_outputs$results$comparisons$directional_agents
plot_delta_direction_scatter <- function(df) { # use with df_lhs_directional
  df <- df %>%
    mutate(
      simulated_delta = opinion - initial_opinion,
      empirical_delta = final_attitude - initial_opinion
    )
  
  ggplot(df, aes(x = simulated_delta, y = empirical_delta, color = pro_reduction)) +
    geom_point(alpha = 0.3) +
    geom_abline(slope = 1, intercept = 0) + # perfect prediction line
    geom_hline(yintercept = 0, linetype = "dashed") + # no empirical change
    geom_vline(xintercept = 0, linetype = "dashed") + # no simulated change
    facet_wrap(~ model_type) +
    theme_minimal() +
    labs(x = "Simulated Change", y = "Empirical Change")
}

#' plot_dir_by_pro
#'
#' Bar chart of wrong-direction rate split by pro/anti stance.
#' Tests whether overestimation is asymmetric between pro and
#' anti agents. Aggregates pct_wrong_direction within model_type
#' and pro_reduction before plotting.
#'
#' @param df Dataframe. Expected columns: model_type,
#'   pro_reduction, pct_wrong_direction.
#'
#' @return A ggplot grouped bar chart.
#'
#' @note Use with df_susceptibility.
#'   Closure-captured in output package.
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

#' plot_beta_distance
#'
#' Density plot of simulated regression betas by model type,
#' overlaid with the empirical beta as a dashed vertical line.
#' Shows how closely each model's simulated pro_reduction effect
#' matches the empirical relationship.
#'
#' @param df_raw Dataframe. Expected columns: std_estimate, model_type.
#' @param empirical_beta Numeric. The empirical beta value for
#'   comparison (dashed red line).
#'
#' @return A ggplot density plot faceted by model_type.
#'
#' @note Use with simulated_betas_raw and empirical_beta_scalar.
#'   Output package ref: lhs_outputs$results$comparisons$beta_distance_raw
plot_beta_distance <- function(df_raw, empirical_beta) {
    ggplot(df_raw, aes(x = std_estimate, fill = model_type)) +
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

#' Grouped Bar Chart for Valence plot_valence_accuracy (created mid 6/26) 
#' modified 6/7/26
#' 
#' Separates population into anti/pro reduction and illustrates
#' directional accuracy (pct_correct_dir) for each model_type.
#' The 0.5 reference line represents chance-level accuracy.
#'
#' @param df Valence summary dataframe. Expected columns: 
#'   model_type, pro_reduction (factor), pct_correct_dir.
#'
#' @return A ggplot grouped bar chart, one bar per pro/anti 
#'   stance within each model type.
#'
#' @note Use with df_sum_directional_valence from
#'   lhs_outputs$comparisons$sum_dir_valence
plot_valence_accuracy <- function(df) {
    df %>%
    mutate(pro_reduction = as.factor(pro_reduction)) %>%
    ggplot(aes(x = model_type, y = pct_correct_dir, fill = pro_reduction)) +
    geom_col(position = "dodge") +
    geom_hline(yintercept = 0.5, linetype = "dashed", color = "red") + # chance baseline, anything below is worse than random
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
    labs(x = "Model Type", y = "% Correct Direction", title = "Directional Accuracy by Model and Valence",
        fill = "Pro Reduction")
}

#' Asymmetry Lollipop gap plot 6/7/26
#' 
#' Used to identify the tendency of which debates (aggregated from agents) for each model are systematically biased
#' towards one direction (pro/anti), end of line indicates magnitude on x-axis
#'
#' @param df Valence dataframe used with \code{df_sum_directional_valence} containing:
#' model_type, current_condition, selected_debate_id, pro_reduction, pct_correct_dir,
#' pct_wrong_dir, mean_signed_error, pro_signed_error, mean_mae, mean_baseline_mae, n 
#'
#' \describe{
#'  \item{accuracy_asymmetry}{Numerical. Pct of agents where simulated direction change is in accordance with empirical (for pro_reduction) - those of anti_reduction}
#'  \item{selected_debate_id}{String. Identifier of current debate for experiment}
#' }
#'
#' @return ggplot object that illustrates how far off model predictions are by population
#'
#' @note Color indicates bias direction: blue (accuracy_asymmetry > 0)
#'   for pro-reduction bias, red for anti-reduction bias.
plot_asymmetry_gap <- function(df) {
    # If the df has multiple replicates per debate, aggregate to a single mean per debate first
    df_plot <- df %>%
      group_by(model_type, current_condition, selected_debate_id) %>%
      summarize(accuracy_asymmetry = mean(accuracy_asymmetry, na.rm = TRUE), .groups = "drop")
    
    ggplot(df_plot, aes(x = accuracy_asymmetry, y = reorder(selected_debate_id, accuracy_asymmetry), color = accuracy_asymmetry > 0)) +
    geom_point(size = 2.5) +
    geom_vline(xintercept = 0, linetype = "dashed", color = "darkgray", size = 0.8) +
    geom_segment(aes(x = 0, xend = accuracy_asymmetry,
                     y = selected_debate_id, yend = selected_debate_id), linewidth = 0.6) +
    facet_wrap(~ model_type) +
    scale_color_manual(values = c("TRUE" = "#377eb8", "FALSE" = "#e41a1c"),
                       labels = c("TRUE" = "Pro-Reduction Bias", "FALSE" = "Anti-Reduction Bias")) +
    theme_minimal() +
    labs(title = "Model Type Directional Asymmetry per Debate Group",
         subtitle = "Positive space implies better tracking of pro-reduction shifts | Negative implies anti-reduction tracking shifts",
         x = "Accuracy Asymmetry Delta (Pro - Anti % Correct Direction)",
         y = "Debate Group ID (Ordered by Asymmetry Magnitude)",
         color = "Model Bias Vector") +
    theme(axis.text.y = element_text(size = 6), # shrinks text so large batch debate lists fit cleanly
          panel.spacing = unit(1, "lines"))
}

#' Colord Scatter Directional Agents 6/7/26
#'
#' Scatter plot to distinguish between pro/anti agents clustering relative to perfect 
#' model prediction
#'
#' @param df Dataframe. Expected columns: opinion, initial_opinion,
#'   final_attitude, pro_reduction, model_type.
#'
#' @return A ggplot faceted scatter plot.
#'
#' @note Use with df_directional_agents.
#'   Output package ref: lhs_outputs$results$comparisons$directional_agents
plot_delta_color_direction_scatter <- function(df) { # use with df_directional_agents
  df <- df %>%
    mutate(
      simulated_delta = opinion - initial_opinion,
      empirical_delta = final_attitude - initial_opinion,
      pro_reduction = as.factor(pro_reduction) 
    )
  
  ggplot(df, aes(x = simulated_delta, y = empirical_delta, color = pro_reduction)) +
    geom_point(alpha = 0.3) +
    geom_abline(slope = 1, intercept = 0) + # perfect prediction line
    geom_hline(yintercept = 0, linetype = "dashed") + # no empirical change
    geom_vline(xintercept = 0, linetype = "dashed") + # no simulated change
    facet_wrap(~ model_type) +
    theme_minimal() +
    labs(title = "Directional Agents Clustering for Pro/Anti Population",
         x = "Simulated Change", y = "Empirical Change")
}

#' Simulated Delta to check opinion - initial opinion distribution 6/7/26
#'
#' Density plot of simulated variance in opinion change by valence
#' Illustrates whether the distribution of variance is centered around zero (implies random walk behavior from the model)
#' for pro and anti agents
#'
#' @param df Dataframe. Expected columns: opinion, initial_opinion,
#'   pro_reduction, model_type.
#'
#' @return A ggplot density plot faceted by model_type.
#'
#' @note Use with df_directional_agents.
#'   Output package ref: lhs_outputs$results$comparisons$directional_agents
plot_simulated_delta_dist <- function(df) { # use with df_directional_agents
  df %>%
    mutate(
      simulated_delta = opinion - initial_opinion,
      pro_reduction = as.factor(pro_reduction)
    ) %>%
    ggplot(aes(x = simulated_delta, fill = pro_reduction)) +
    geom_density(alpha = 0.5) +
    geom_vline(xintercept = 0, linetype = "dashed") +
    facet_wrap(~ model_type) +
    scale_fill_brewer(palette = "Set1") +
    theme_minimal() +
    labs(x = "Simulated Delta (opinion - initial_opinion)",
         y = "Density",
         title = "Distribution of Simulated Opinion Change by Valence")
}

#' RF Importance Across Model Types 6/8/26
#' 
#' Takes the RF output from \code{run_sensi_analysis} and plots the individual variable
#' importance for each model_type
#'
#' @param rf_df Dataframe. Expected columns: parameter, importance,
#'   output, speaking_mode, model_type, use_distinct_agents.
#' @param output_filter Character. Output variable to filter on.
#'   Defaults to "mae".
#'
#' @return A ggplot grouped bar chart faceted by model_type
#'   and use_distinct_agents.
#'
#' @note Use with sensi_lhs$rf from sensitivity analysis.
plot_rf_importance_by_cell <- function(rf_df, output_filter = "mae") {
  rf_df %>%
    filter(output == output_filter) %>%
    ggplot(aes(x = reorder(parameter, importance), y = importance,
               fill = speaking_mode)) +
    geom_col(position = "dodge") +
    coord_flip() +
    facet_grid(model_type ~ use_distinct_agents, scales = "free_y") +
    theme_minimal() +
    labs(title = paste("RF permutation importance for", output_filter),
         x = "Parameter", y = "Importance", fill = "speaking_mode")
}
 
#plot_rf_importance_by_cell(sensi_lhs$rf, "mae")

#' plot_pdp_grid created (6/8/26)
#'
#' Displays partial dependence curves for each parameter,
#' faceted by model_type and feature. Free y-scales per panel
#' because cells differ in absolute MAE — a shared scale
#' flattens within-cell structure.
#'
#' @param pdp_df PDP dataframe. Expected columns: x, yhat,
#'   feature, model_type, speaking_mode, use_distinct_agents, output.
#' @param model_filter Optional. Character string to filter to
#'   a single model_type (e.g., "bipolarization"). NULL shows all.
#'
#' @return A ggplot faceted line plot.
#'
#' @note Use with pdp_all from sensitivity analysis.
 
plot_pdp_grid <- function(pdp_df, model_filter = NULL) {
  d <- if (is.null(model_filter)) pdp_df else filter(pdp_df, model_type == model_filter)
 
  ggplot(d, aes(x = x, y = yhat,
                colour = speaking_mode,
                linetype = use_distinct_agents)) +
    geom_line(linewidth = 0.8) +
    facet_grid(model_type ~ feature, scales = "free") +
    theme_minimal() +
    labs(title = paste("Partial dependence of", unique(d$output), "on each parameter"),
         subtitle = "One line per design cell; flat-and-low regions are candidate GA bounds",
         x = "Parameter value", y = paste("Predicted", unique(d$output)),
         colour = "speaking_mode", linetype = "distinct agents")
}
 
#plot_pdp_grid(pdp_df)
#plot_pdp_grid(pdp_df, model_filter = "bipolarization")

