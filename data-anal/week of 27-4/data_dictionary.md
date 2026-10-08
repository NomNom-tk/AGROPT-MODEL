# Data Dictionary

## plots.R
```r
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
#' Empirical Viz for T1-T2 Change
#' 
#' Produces a bar chart for mean opinion change before and after debate
#' Intended use with empirical data csv to check opinion evolution, called with lhs_outputs$plots$empirical_col()
#' @param df Dataframe of empirical debate data processed by empirical_stats() (in functions.R)
#' \describe{
#'   \item{condition}{Character. Experimental group (among: control, heterogeneous, homogenous)}
#'   \item{mean_change}{Numerical. Empirical change between T1 (before debate) and T2 (after debate) questionnaires}
#' }
#' @return A ggplot2 object with horizontal intercept (empirical beta)
#' @note see empirical_comparison chunk in Rmd for call.
plot_empir_compar <- function(df) {
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
#' plot_viol_conv_model_type (created mid 5/26)
#' 
#' @param df A dataframe containing the columns: model_type, convergence_cycle
#'  and speaking_mode
#'
#' @return A ggplot object, violin plot describing convergence_cycle variation based on model_type
#'  faceted by speaking_mode to highlight the impact of speaking_mode on debate convergence
#' 
#' @note use with df_batch in LHS \code{analysis_scope} = "LHS", output package ref: lhs_outputs$inputs$raw 
plot_viol_conv_model_type <- function(df) {
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
```

## functions.R
```r
#' read_clean (created 7/5/26) 
#' updated 27/7/26 strip stray chars from headers
#' update 28/7/26 adjusted parquet syntax
#' 
#' Checks whether the data file is a csv or parquet (if csv convert, if parquet read parquet)
#' 
#' @param path the path specific to the input data file (csv or parquet)
#' @param col_names set of colnames to extract from base file (reduces size and memory load)
#'
#' @return df A cleaned data frame with column headers, read via duckdb (regardless of csv or parquet read)
#'
#' @note col_names is only applied during initial parquet cache generation.
#'   Subsequent calls use the existing cache regardless of col_names passed.
read_clean <- function(path, col_names = NULL) {
#' generate_parquet_cache - RUN ONCE - (created 30/7/26)
#' update 24/8/26: col_names argument is optional to bypass it for the empirical data
#'
#' ingests a csv and checks for junk header rows, removes them and replaces them with \code{col_names}
#' GAMA matched headers from save calls, then write a parquet cache for the file and returns a char path for downstream cleaning and assembly
#'
#' @param path The path of the ingested data file (csv or parquet)
#' @param col_names Optional argument in case the file is csv (to extract subset of columns from csv and convert to parquet)
#'
#' @return parquet_path file path to the generated parquet path (character string)
#'
#' @note run once at the beginning of file ingestion, will only remove stray header rows once and replace with col_names input
generate_parquet_cache <- function(path, col_names = NULL) {
#' update 6/8/26 added add_design_cell for cleaner df_ag and batch encoding
#'
#' Helper function combining smaller cleaning and helper functions to prep file paths into readable dfs for downstream analysis
#' Initialized by checking for data file path, then given duckdb connection, and \code{pull_cols} to identify columns to pull from main file and the parquet_version, follows a duckdb loading and prep, otherwise follows a basic column replacement using \code{read_clean}
#'
#' @param path Parquet or csv path of specified data file
#' @param config Spec for the data file including analysis_scope, version, run_type, path, composition_scope
#' @param version Identifier for comparison of different experimental set-ups (denoted by string var)
#' @param col_names Optional arg when replacing bad headers to match GAMA save list
#' @param con Connection set up with DuckDB if parquet path exists to reduce file size
#' @param pull_cols Columns specific to a file, necessary for different \code{analysis_scope} versions
#'
#' @return df Single cleaned data frame that has new column headers inserted, has types coerced, NAs checked, an identifier for a set of parameters (add_param_set_id) and type of experiment (from add_design_cell)
load_and_prepare <- function(path, config, version = NA, col_names = NULL, con = NULL, pull_cols = NULL) {
#' 
#' Meant to blanket clean headers and ensure that header conversion is standard
#'
#' @param df Ingested data frame to check for stray chars in column headers
#'
#' @return df A dataframe that has been passed through janitor::clean_names (to remove the stray chars)
#' and has any remaining header issues cleaned with \code{drop_leaked_headers}
#'
#' @note this function is always used in conjunction with \code{drop_leaked_headers} to ensure a double check
#' after the initial headers have been identified
clean_headers <- function(df) {
#' drop_leaked_headers (created 29/7/26)
#'
#' Filters out rows where column header text appears as data values
#'
#' @param df A dataframe for ingestion and secondary pass
#' 
#' @return df A dataframe that has had first column checked for stray chars and subsequently removed, lazily loaded in duckdb
drop_leaked_headers <- function(df) {
#' load_via_duckdb (created 2/9/26)
#' modified 3/9/26 to grep for parquet and if TRUE pull query through pull_cols and parquet_path
#' if FALSE error and suggest generating a parquet cache before proceeding
#' 
#' Meant to set up a duckdb query to select a limited amount of rows from the parquet files
#'
#' @param parquet_path Character string path that links to the ingested data file
#' @param pull_cols Columns specific to a file, necessary for different \code{analysis_scope} versions
#' @param con Connection set up with DuckDB if parquet path exists to reduce file size
#'
#' @return df Materialised dataframe that uses SQL to select columns from \code{pull_cols} using \code{parquet_path} as the link
#' @section errors: if it fails return an abort message to generate the parquet cache before attempting
load_via_duckdb <- function(parquet_path, pull_cols, con) {
#' log_step (created 3/8/26
#'
#' Used to check execution time for a specific function/chunk
#' 
#' @param msg String value identifying a section of code that requires a timestap for execution time eval
#'
#' @note can be used globally across code to evaluate how long a section takes to compute or as a benchmark
log_step <- function(msg) {
#' Write_result (created 24/8/26)
#'
#' Writes results to a .txt file for output, should be used after each hypothesis
#'
#' @param text A text declaration of what should be included in each paste
#' @param file Output file path to append to 
#' @param append Boolean that determines whether or not to write to same file where previous write_lines calls were
#'
#' @note initialize with a timestamp call
#' @examples
#' \dontrun{
#' write_result(paste("Hypothesis Results —", Sys.time()), append = FALSE)
#' write_result(paste(rep("=", 60), collapse = ""))
#' }
write_result <- function(text, file = "./hypothesis_results.txt", append = TRUE) {
#' append_metadata (created 28/5/26)
#' 
#' Provenance travels with dfs, provides objects to call in analysis files and in rmd
#' 
#' @param df Dataframe to ingest and to add config columns to
#' @param config List in file data_processing.R from which to pull the information for mutated cols
#' @param version Optional arg in case of multiple versions of a data file
#'
#' @return Input dataframe with run_type, composition_scope, and version columns appended
append_metadata <- function(df, config, version = NA) {
#' map_slots (created 24/09/26)
#'
#' Used to document and describe the output package slots and double check whether slots are filled by analysis_scope
#'
#' @param x The output of analyze_processed_run for lhs/ga to illustrate the slots that are populated or not
#' @param prefix Character. Indentation string. Leave as default.
#' @param max_depth Integer. Maximum recursion depth. Default 3,
#'   use 4+ for deeply nested slots.
#' @param depth Integer. Current recursion depth. Leave as default.
#'
#' @return Invisible NULL. Output is printed to console. Leave as default.
map_slots <- function(x, prefix = "", max_depth = 3, depth = 0) {
#' anchor_baseline_facets (created 12/6/26)
#'
#' Duplicates no_change baseline rows across both TRUE/FALSE levels of a
#' condition column so that faceted plots show the baseline in every panel.
#'
#' @param df Dataframe containing a model_type column and the condition column to facet by
#' @param condition_col Character string naming the column to duplicate across (default "speaking_mode")
#' @param baseline_val Character string identifying the baseline model_type (default "no_change")
#'
#' @return The input dataframe with baseline rows mirrored into both factor levels
#'   of condition_col, original unassigned baseline rows removed to avoid duplicates.
anchor_baseline_facets <- function(df, condition_col = "speaking_mode", baseline_val = "no_change") {
#' add_design_cell (created 6/8/29)
#' 
#' Encodes model x distinct x speaking independent of current_experiment_id
#' ensure that we have on design cell per model_type
#' mutate current_experiment_id to char as an extra label
#' 
#' @param df Dataframe for ingestion, usually base df passed from data_processing.R
#'
#' @return df Dataframe with mutated design_cell col containing labels for:
#'   use_distinct_agents and speaking_mode, separated by '_',
#'   also mutates the current_experiment_id as an extra label (not sure it is used)
add_design_cell <- function(df) {
#' add_param_set_id (created 6/8/26)
#' 
#' Intersects population parameters with names in df, 
#' allows distinct calls in framework_analysis to call one specific point in parameter space we can identify
#'
#' @param df Dataframe for ingestion, usually base df from data_processing.R
#'
#' @return Dataframe grouped by parameter columns and an added information column denoting the current group id
add_param_set_id <- function(df) {
#' empirical_prep (created 27/7/26) 
#' 
#' Prep function that calls \code{read_clean} and subsequently mutates cols for empirical analysis and 
#' downstream comparisons
#'
#' @param path Character path for the empirical data file
#'
#' @return A dataframe using the empirical csv/parquet as a baseline with additional mutated columns
#' representing the baseline opinion change for each agent in each debate
#'
#' @note Prior check to ensure that the naming convention matches downstream calls
empirical_prep <- function(path) {
#' apply_composition_filter (created 27/5/26) 
#' update 2/6/26 (dynamic column detection and stop condition)
#'
#' Filters a data frame by debate composition or debate identifier based on 
#' a scope string specified in the configuration. Dynamically identifies 
#' which column represents debate composition across varying data frame structures.
#'
#' @param df A data frame or tibble containing simulation or empirical debate data.
#' @param config A named list or configuration object containing \code{composition_scope} 
#'   (e.g., \code{"H"}, \code{"M"}, or \code{"all"}).
#'
#' @return The filtered data frame. Returns the original \code{df} unmodified if 
#'   \code{df} is empty/NULL or if \code{config$composition_scope} is missing or set to \code{"all"}.
#'
#' @details
#' The function performs early returns for edge cases:
#' \itemize{
#'   \item Returns \code{df} as-is if \code{df} is \code{NULL} or has 0 rows.
#'   \item Returns \code{df} as-is if \code{config$composition_scope} is \code{NULL} 
#'         or equals \code{"all"} (case-insensitive, whitespace-trimmed).
#' }
#' 
#' If filtering is required, it dynamically checks for column presence in the 
#' following priority order:
#' \enumerate{
#'   \item \code{"debate_composition"}
#'   \item \code{"selected_debate_id"}
#'   \item \code{"debate_label"}
#' }
#' 
#' Rows are retained where the target column's value starts with the character 
#' prefix specified in \code{config$composition_scope} (e.g., matching debate IDs or 
#' labels starting with "H" for Homogeneous or "M" for Mixed).
#'
#' @note
#' If no recognizable column is found, \code{target_col} evaluates to \code{NA_character_}. 
#' Ensure the downstream guard evaluates \code{is.na(target_col)} rather than \code{is.null(target_col)} 
#' to catch the missing identifier condition properly.
apply_composition_filter <- function(df, config) {
#' empirical_stats (created 27/7/26)
#' 
#' Function that summarizes the mean opinion change by condition and follows naming convention that downstream requires in framework_analysis.R
#' 
#' @param df Dataframe for ingestion and column mutation
#'
#' @return A dataframe with mean attitude change across T0-T2 for graphical illustration
empirical_stats <- function(df) {
#' apply_composition_filter (created approx 6/2026)
#' Apply Batch Mutations and Type Coercion to Simulation Output
#' update 6/8/26 added logical_cols coercion and trim to lowercase
#'
#' Cleans and type-converts raw GAMA batch output for downstream analysis.
#' Converts character/logical columns to numeric where applicable, derives
#' \code{normalised_convergence} and \code{debate_composition}, coerces ID
#' columns to character, and performs structural validation (required
#' columns) and NA auditing with row-level diagnostics.
#'
#' @param df A dataframe of raw GAMA batch output (one row per simulation run).
#'   Must contain \code{speaking_mode}, \code{use_distinct_agents},
#'   \code{debate_label}, and \code{convergence_cycle}.
#'
#' @return The cleaned dataframe with:
#'   \describe{
#'     \item{normalised_convergence}{Numeric. \code{convergence_cycle / 100}.}
#'     \item{debate_composition}{Character. First character of \code{debate_label}
#'       (e.g. "H" or "M"), added only if \code{debate_label} exists.}
#'     \item{selected_debate_id, seed}{Coerced to character if present.}
#'     \item{agent_wrong_direction, agent_is_saturated}{Coerced to logical if present.}
#'   }
#'   Numeric coercion is applied to: convergence_rate, confidence_threshold,
#'   repulsion_strength, repulsion_threshold (and their _sd variants), mae,
#'   initial_variance, opinion_variance, seed, polarization_index,
#'   neutral_zone_width, mean_net_repulsion_abs, convergence_cycle —
#'   restricted to columns that actually exist in \code{df}.
#'
#' @section Side effects:
#'   Prints per-column NA counts and total NA count to console. Emits a
#'   \code{warning()} per affected column listing the row indices containing
#'   NAs, or a \code{message()} confirming no NAs if none found.
#'
#' @section Errors:
#'   Throws via \code{stop()} if any of the required columns
#'   (\code{speaking_mode}, \code{use_distinct_agents}, \code{debate_label},
#'   \code{convergence_cycle}) are missing from \code{df}.
#'
#' @note Filters out any row where \code{model_type == "model_type"}
#'   (header row artifact from batch CSV concatenation).
apply_batch_mutations <- function(df) {
#' apply_composition_filter (created approx 5/2026)
#' Filter Out Bipolarization Rows Violating Neutral Zone Constraint
#'
#' Removes simulation rows where \code{model_type == "bipolarization"} and
#' \code{neutral_zone_width < 0}, which represents a structurally invalid
#' configuration (the two opinion poles have crossed/overlapped rather than
#' maintaining a separating neutral zone). Also normalizes a legacy
#' \code{debate} column name to \code{selected_debate_id} if present.
#'
#' @param df A dataframe of simulation results. Expected to contain
#'   \code{model_type} and \code{neutral_zone_width} for the filter to apply;
#'   if either is missing, the function is a no-op (returns \code{df} unchanged).
#' @param verbose Logical. If \code{TRUE} (default), prints a message
#'   reporting the number of violating rows removed, or confirms none found.
#'
#' @return The filtered dataframe, with bipolarization rows where
#'   \code{neutral_zone_width < 0} removed. All other rows (including all
#'   non-bipolarization rows) are retained unchanged.
#'
#' @note Renames \code{debate} -> \code{selected_debate_id} if \code{debate}
#'   exists in \code{df}, for consistency with the rest of the pipeline's
#'   join key naming.
#'
#' @section Side effects:
#'   Emits a \code{message()} when \code{verbose = TRUE}: either reporting
#'   violation count or confirming a clean dataset.
bipol_constraint_filter <- function(df, verbose = TRUE) {
#' combine_df_versions (created around 5/26)
#'
#' allows combination of different versions of tests for comparison e.g., convergence_threshold
#'
#' @param dfs Multiple dataframes in case of multiple versions of an experiment run
#' @param version_names String declaration of the various versions of the experiment data file
#'
#' @return A dataframe with the multiple versions combined for cross comparison in sensitivity analyses
combine_df_versions <- function(dfs, version_names) {
#' run_sensi_analysis (created 20/7/26) 
#' updated on 24/7/26 to compute PCC/PRCC/RF Sensitivity Indices per Model/Agent-Type Combination 
#' update 6/8/26 corrected key for speaking_mode (true/false) writing to same list element (added to group_by)
#' correction: two identifiers, lookup key (from param_cols_by_model) and key (result storage)
#'
#' Runs Partial Correlation Coefficient (PCC) and Partial Rank Correlation
#' Coefficient (PRCC) and Random Forest (RF) sensitivity analysis (via \code{sensitivity::pcc()})
#' separately for each combination of \code{model_type} and
#' \code{use_distinct_agents}, against each output variable in
#' \code{output_cols}. Excludes \code{model_type == "no_change"}.
#'
#' @param df A dataframe of simulation results (post \code{apply_batch_mutations()}),
#'   containing \code{model_type}, \code{use_distinct_agents}, parameter
#'   columns, and output columns.
#' @param param_cols_by_model A named list mapping
#'   \code{"<model_type>_<TRUE|FALSE>"} keys (e.g. \code{"consensus_TRUE"})
#'   to a character vector of parameter column names relevant to that
#'   model/agent-type combination.
#' @param output_cols Character vector of output variable column names to
#'   test sensitivity against (e.g. \code{c("mae", "convergence_cycle")}).
#' @param num_trees Integer. the number of decision trees to grow in each ensemble before averaging their predictions
#'   higher number: yields more stable and reproducible feature importance scores,
#'   and Rsquared estimates but increases computation time linearly
#'   lower number: faster execution for rapid testing but importance rankings have more noise
#' @param max_rows_per_cell Maximum number of rows to ingest for RF analysis to limit rows in RAM
#' @param min_rows Minimum number of rows required to start the RF tree construction
#'
#' @return A named list with three elements:
#'   \describe{
#'     \item{pcc}{Linear sensitivity results. Dataframe with columns \code{key}, \code{model_type},
#'       \code{use_distinct_agents}, \code{output}, \code{parameter}, \code{PCC}.}
#'     \item{prcc}{Monotonic Sensitivity results (spearman rank). Same structure with \code{PRCC} instead of \code{PCC}.}
#'     \item{rf}{Non-Linear/interaction importance scores and out-of-bag Rsquared values}
#'   }
#'
#' @details
#'   For single-parameter cases, PCC/PRCC reduce to a simple Pearson
#'   correlation (\code{cor()}) since \code{sensitivity::pcc()} requires
#'   \eqn{\ge 2} parameters. For multi-parameter cases, \code{pcc()} is
#'   called twice — once with \code{rank = FALSE} for PCC, once with
#'   \code{rank = TRUE} for PRCC — extracting the \code{"original"} column
#'   from each result object.
#'
#'   Skips (via \code{next}): keys not found in \code{param_cols_by_model};
#'   parameter sets that don't intersect with \code{df_piece} columns;
#'   outputs missing from \code{df_piece}; outputs with zero variance
#'   (constant values), since PCC requires variance in both X and Y.
#'
#'   Random forest permutation importance is computed across single and multi-parameter cases
#'   using \code{ranger::ranger()}, returns out-of-bag feature importance and overall
#'   variance explained (\eqn{R^2}). Skip condition is the same as above for PCC/PRCC
#'
#' @section Side effects:
#'   Prints debug output to console: current key, available
#'   \code{param_cols_by_model} names, selected \code{param_cols}, and
#'   \code{str()}/\code{head()} of the PRCC result object.
#'
#' @seealso \code{plot_pcc_heatmap()}, \code{plot_prcc_heatmap()} for
#'   visualizing the returned dataframes. \code{PCC} column name confirmed
#'   here as \code{"original"} extracted from \code{sensitivity::pcc()}.
run_sensi_analysis <- function(df, param_cols_by_model, output_cols, num_trees = 500, max_rows_per_cell = 50000, min_rows = 10) {
#' param_region_extraction (created around 8/26)
#' update 6/8/26 added speaking mode to both group_by calls / added | to range check instead of AND
#' rewrote bipol_check gap change so that it doesn't error
#'
#' Function excludes any \code{model_type} that is no change and enforces positive neutral zone width for bipolarization
#' Subsequently, filter the df for the \code{percentile} value en keeps the rows with an mae value of the top 25% percent, then summarizes each parameter with a min/max arg and applies a cap if necessary (using \code{cr_max_cap} and \code{rs_max_cap}
#' Finally, zeroes out parameters not used in the model_type, defines the columns that need clamping, performs a range check to ensure that params can be evaluted in a subsequent parameter exploration run
#'
#' @param df Dataframe for ingestion
#' @param percentile Percent of top performing runs (minimum MAE) to keep for the region extraction
#' @param cr_max_cap Optional maximum value of convergence rate to apply to region extraction
#' @param rs_max_cap Optional maximum value of repulsion strength to apply to region extraction
#' @param min_range The minimum amount of distance that params needs to have to be accepted and treated in the function
#'
#' @return list of multiple vars for param value selection
#' \describe regions Identifies the amount of regions that are retained for future parameter exploration runs
#' \describe range_check Boolean to evaluate whether the parameters passed through this function have enough of a buffer to be explored in a subsequent parameter region exploration
#' \describe bipol_check Boolean to evaluate whether the parameters considered do not cause a negative neutral zone
#'
#' @section Warnings: 
#' prints a warning if specific parameters have too narrow a range for a follow up search, as well as 
#' a warning in case the parameters violate the neutral zone width cap for bipolarization
param_region_extraction <- function(df, percentile = 0.25, cr_max_cap = NULL, rs_max_cap = NULL, min_range = 0.05) {
#' generate_gaml_bounds (created approx 6/2026)
#' Generate GAML Parameter Bound Declarations from Top-Performing Configs 24/7/26 (update to incorporate guards and initialize as characters)
#' update 6/8/26 added SD parameters so they don't get skipped in generation, header block addition
#'
#' Translates a dataframe of best-performing parameter ranges (one row per
#' model_type / use_distinct_agents combination) into GAML \code{parameter}
#' declaration strings, ready to paste into a GAMA experiment block to
#' constrain a follow-up GA or LHS run. Zero-width ranges (min == max) are
#' symmetrically expanded by \code{buffer} to avoid a degenerate search space.
#'
#' @param df A dataframe, typically the GAML Boundary Layer output (top 25%
#'   performing LHS configs), with one row per model_type/use_distinct_agents
#'   combination. Required columns: \code{model_type}, \code{use_distinct_agents},
#'   \code{best_mae}, \code{n}, \code{cr_min}, \code{cr_max}, \code{ct_min},
#'   \code{ct_max}, \code{rs_min}, \code{rs_max}, \code{rt_min}, \code{rt_max}.
#'   For rows where \code{use_distinct_agents == TRUE}, also requires the
#'   \code{_sd} variants of all the above (e.g. \code{cr_min_sd}).
#'
#' @return A character vector of GAML source lines — a header comment per
#'   row (model type, distinct agents flag, best MAE, n) followed by one
#'   \code{parameter "..." var: ... min: ... max: ...;} line per parameter
#'   that passes its inclusion guard. Intended to be written to a \code{.gaml}
#'   file or pasted directly into an experiment block.
#'
#' @param buffer Numeric. Amount (in parameter units) to expand a zero-width
#'   range symmetrically around its value. Default \code{0.05}.
#'
#' @details
#'   \code{convergence_rate} is always included. \code{confidence_threshold}
#'   is included only if \code{ct_min} is non-NA, finite, and \code{ct_max > 0.01}
#'   (guards against near-zero/irrelevant ranges for e.g. consensus, where
#'   confidence_threshold doesn't structurally apply). \code{repulsion_strength}
#'   and \code{repulsion_threshold} are included together under the same guard
#'   on \code{rs_min}/\code{rs_max} (relevant only to bipolarization). SD
#'   variants of all parameters are included only when
#'   \code{use_distinct_agents == TRUE}, under the same respective guards.
#'
#' @note Internal helper \code{expand_range(min_val, max_val, buffer)}
#'   returns \code{c(NA, NA)}-safe passthrough if either bound is NA;
#'   otherwise expands symmetrically only when \code{min_val == max_val}.
#'
#' @seealso \code{lhs-boundary-layer} / \code{gaml-boundaries} chunk in Rmd
#'   for the upstream construction of \code{df} and downstream usage of
#'   the returned GAML lines.
generate_gaml_bounds <- function(df, buffer = 0.05) {
#' compute_pdp (created 6/8/26)
#'
#' pdp is: for each grid value v of the feature, overwrite that column with 
#' v across all rows, predict, average.
#' Function computes the partial dependence profile of a single parameter on model output 
#' It thus marginalises over all other parameters by fixing the target feature at each
#' grid value, predicting with the fitted RF model, and averaging predictions
#' 
#' @param rf_fit a fitted ranger model object from \code{run_sensi_analysis$rf_mod_list}
#' @param X Dataframe of predictor columsn matching the training data for \code{rf_fit}
#' @param feature Character string naming the column in X to compute PDP for
#' @param grid_n Number of evenly spaced values to evaluate across the feature range
#' @param max_rows Maximum number of rows to subsample from X for speed (PDP averages
#' averages so 2k is sufficient)
#' @param trim Quantile trim proportion to exclude extreme tails from the grid range
#'
#' @return A dataframe with columns: feature, x (grid values), yhat (mean predicted value)
compute_pdp <- function(rf_fit, X, feature, grid_n = 40, max_rows = 2000, trim = 0.025) {
#' pdp_all_cells (created 6/8/26)
#' Compute PDP per Parameter per Design Cell
#'
#' rebuilds each cell's X the same way run_sensi_analysis did
#' column order matches what the forest was trained on. (need two identifiers
#' lookup_key (model_distinct) for param columns and key (speaking arm) for the fitted model)
#'
#' @param df_batch A dataframe consisting of batch level data for an algorithm
#' @param sensi_obj Output of \code{run_sensi_analysis} which is a list containing $rf_mod_list (itself
#'   a named list of fitted ranger models keyed by `model_distinct_speak_output` and $rf which is the R squared quality table)
#' @param param_cols_by_model A list object that contains the paramter columns for each model_type
#'   to be associated with df_batch so that PDP can be computed with the correct parameters
#' @param output A specification of the output variable that the PDP computation should use to calculate the fit
#' @param grid_n An object stating the number of evenly spaced values along each parameter's range for which partial dependence is evaluated
#'
#' @return a tibble with one row per grid point per parameter per design cell, containing columns:
#'   feature, x, yhat, key, model_type, use_distinct_agents, speaking_mode, output / empty tibble if no forests are found
#'
#' @note key naming must match between \code{run_sensi_analysis} and current function - speak/nospeak not TRUE/FALSE for speaking arm
#' @note current functio filters `no_change` from cell list since no forest exists for the baseline
pdp_all_cells <- function(df_batch, sensi_obj, param_cols_by_model, output = "mae", grid_n = 40) {
#' bounds_from_pdp Bounds Generation from PDP 6/8/26
#' 
#' Meant to keep region where pdp is within its 'tol' of its own minimum
#' this matters because a bare yhat <= threshold filter can return and min and max
#' spanning a hump between two separate basins
#'
#' Function is a complement to param_region_extraction(). Compare the two and use the union if they disagree
#' interpretation: flat near 1 means param bearely matters in that cell (forest sees near horizontal surface)
#'   pdp_argmin sitting on either end of searched range is boundary solution
#'
#' @param pdp_df output from \code{pdp_all_cells} a tibble containing partial dependence per parameter per design cell
#' @param tol a threshold to determine the range of minimum acceptable values for each parameter
#'
#' @return a dataframe that records the partial dependence for each parameter per design cell that is ready to be plotted,
#'  containing: \code{pdp_min} the minimum pdp value for a parameter (i.e. the best value), \code{pdp_argmin} the x axis (parameter value)
#'  that minimizes MAE, \code{lo} the starting position of parameter value which is within the tolerance of the minimum, \code{hi} the ending 
#'  position where the parameter value stays within the range of the minimum, \code{flat} the ratio of the range between starting and ending positions of parameter values
#'  as a fraction of the total vertical range where the parameters are 'ok' (fraction of searched param range that is good enough)
#'
#' @note think of PDP as x (param values) and y (predicted MAE)
bounds_from_pdp <- function(pdp_df, tol = 0.02) {
#' compute_influence_scores (created 27/4/26) 
#' update 27/7/26 empty df and row guard
#'
#' @param df Dataframe for ingestion
#'
#' @return Dataframe grouped by model_type, current_condition, selected_debate_id, and sender_id that summarizes
#' the influence that one agent had on another in one particular debate, and the amount of broadcasts they had to other agents
#'
#' @note used with \code{df_interactions} to establish broadcasts and influence
compute_influence_scores <- function(df) {
#' compute_susceptibility_scores (for receivers) (created 27/4/26) 
#' updated 23/7/26 to include guard for the first row
#' 
#' Aggregates interaction-level dialogue data to compute mean susceptibility 
#' metrics per agent across debate conditions. Calculates total exposure counts, 
#' average shift magnitudes (\code{delta}), and saturation rates.
#' 
#' @param df Data frame or tibble. The cleaned interaction data log (typically 
#'   produced by \code{prepare_interactions}).
#' 
#' @details 
#' Includes an early-exit check for empty data sets (\code{nrow(df) == 0}) to prevent 
#' non-numeric evaluation errors on \code{abs(delta)} when processing baseline 
#' or non-speaking model runs.
#' 
#' @return A summarized \code{tbl_df} with receiver-level susceptibility metrics, 
#'   or \code{NULL} if the input data frame contains zero observations.
#'   Will also return NULL for NULL input (in case of design_cells with no speaking_mode so df_interactions does not exist)
compute_susceptibility_scores <- function(df) { # use with df_interactions
#' prepare_directional (Agent-Level) (created 29/4/26)
#' updated 5/8/26 include \code{direction_class} and \code{agent_against_stance}.
#'
#' Processes agent-level aggregated data (`df_ag`) to compute direction-of-change 
#' vectors and evaluate whether simulated opinion movements match empirical movements. 
#' Filters strictly for speaking runs where empirical opinion shift occurred.
#'
#' @param df A data frame or tibble (typically \code{df_ag}) containing paired empirical 
#'   and simulated trajectory variables (\code{speaking_mode}, \code{initial_opinion}, 
#'   \code{final_attitude}, \code{opinion}).
#'
#' @return A transformed tibble (\code{df_directional_agents}) retained at the 
#'   individual agent level with added direction indicators:
#'   \describe{
#'     \item{empirical_dir}{Numeric (-1, 0, 1). Sign of empirical shift (\code{final_attitude - initial_opinion}).}
#'     \item{simulated_dir}{Numeric (-1, 0, 1). Sign of simulated shift (\code{opinion - initial_opinion}).}
#'     \item{correct_dir}{Logical. \code{TRUE} if simulated movement sign matches empirical movement sign.}
#'     \item{empirical_moved}{Logical. \code{TRUE} if empirical opinion actually changed (\code{empirical_dir != 0}).}
#'     \item{agent_against_stance}{Logical. \code{TRUE} if the agent is pro_reduction and their opinion_change < 0. \code{TRUE} anti reduction with positive change}
#'     \item{direction_class}{Character. "stationary" if \code{simulated_dir} = 0, "correct" if \code{correct_dir} evals to TRUE, "wrong" is fallback when agent moved but not in empirical direction}
#'   }
#'
#' @details
#' Operates as the first stage in the directional processing pipeline:
#' \enumerate{
#'   \item Restricts scope strictly to active dialogue conditions (\code{speaking_mode == TRUE}).
#'   \item Uses \code{sign()} to reduce continuous changes to direction vectors.
#'   \item Drops agents whose empirical baseline opinion did not move (\code{empirical_moved == FALSE}) 
#'         to eliminate zero-division or undefined directional alignment states.
#' }
#'
#' @seealso \code{\link{summarize_directional}}
prepare_directional <- function(df) { # use with df_ag
#' summarize_directional (created sometime in 7/26)
#' updated 5/8/26 clarification of direction_class and mutations
#' Aggregate Directional Opinion Performance Metrics by Debate
#'
#' Collapses agent-level directional observations (\code{df_directional_agents}) 
#' into debate-level summary statistics, calculating directional accuracy, error 
#' rates, and baseline MAE comparison.
#'
#' @param df A data frame of agent-level directional data produced by 
#'   \code{\link{prepare_directional}}. Must contain \code{correct_dir}, 
#'   \code{opinion}, \code{final_attitude}, \code{direction_class} and 
#'   \code{initial_opinion}.
#'
#' @return A summarized tibble (\code{df_directional}) grouped by \code{model_type}, 
#'   \code{current_condition}, and \code{selected_debate_id}, containing:
#'   \describe{
#'     \item{pct_correct_dir}{Numeric [0,1]. Proportion of agents moving in the correct empirical direction based on \code{direction_class}.}
#'     \item{pct_stationary_dir}{Numeric [0,1]. Proportion of agents who did not move \code{direction_class} = "stationary"}
#'     \item{pct_wrong_dir}{Numeric [0,1]. Proportion of agents moving in the explicit wrong direction (\code{direction_class}).}
#'     \item{mean_mae}{Numeric. Mean Absolute Error between simulated opinion and empirical final attitude.}
#'     \item{mean_baseline_mae}{Numeric. Baseline Mean Absolute Error assuming zero opinion change from initial state.}
#'     \item{n}{Integer. Count of evaluated agent observations per debate grouping.}
#'   }
#'
#' @seealso \code{\link{prepare_directional}}
summarize_directional <- function(df) {
#' summarize_directional_valence (created 1/7/26)
#' 
#' Extension of summarize_directional() with a pro_reduction split./ update 23/7 to take into account homogeneous debates where all agents are pro_reduciton == 0
#' removes pro_signed error as it is irrelevant
#' Computes per-debate, per-model, per-condition, and per-valence directional
#' accuracy and signed error metrics across both heterogeneous and homogeneous debates.
#' 
#' @param df Agent-level dataframe (e.g., df_directional_agents) containing:
#'   \code{model_type}, \code{current_condition}, \code{selected_debate_id},
#'   \code{pro_reduction}, \code{correct_dir}, \code{direction_class},
#'   \code{opinion}, \code{final_attitude}, and \code{initial_opinion}, \code{design_cell}
#'
#' @return A summarized data frame in long format with one row per 
#'   \code{model_type} x \code{current_condition} x \code{selected_debate_id} x \code{pro_reduction}.
#'   Columns include \code{pct_correct_dir}, \code{pct_wrong_dir}, 
#'   \code{mean_signed_error}, \code{mean_mae}, \code{mean_baseline_mae}, and \code{n}.
#'   \describe{
#'     \item{pct_correct_dir}{Numeric [0,1]. Proportion of agents moving in the correct empirical direction based on \code{direction_class}.}
#'     \item{pct_stationary_dir}{Numeric [0,1]. Proportion of agents who did not move \code{direction_class} = "stationary"}
#'     \item{pct_wrong_dir}{Numeric [0,1]. Proportion of agents moving in the explicit wrong direction (\code{direction_class}).}
#'   }
summarize_directional_valence <- function(df) {
#' compute_valence_asymmetry (created 1/7/26) 
#' update 23/7/26 to be comprehensive for homogeneous debates as well
#' 
#' Takes the output of \code{summarize_directional_valence()} and pivots it wide 
#' to compute accuracy and error asymmetry between pro (1) and anti (0) groups.
#' Accommodates both heterogeneous and homogeneous debates; single-valence 
#' (homogeneous) debates produce \code{NA} for asymmetry metrics.
#' 
#' @param df Aggregated agent-level dataframe from \code{summarize_directional_valence()} 
#'   containing: \code{model_type}, \code{current_condition}, \code{selected_debate_id}, 
#'   \code{pro_reduction}, \code{pct_correct_dir}, \code{pct_wrong_dir}, 
#'   \code{mean_signed_error}, \code{mean_mae}, \code{mean_baseline_mae}, and \code{n}, \code{design_cell}.
#' 
#' @return A dataframe in wide format with one row per debate x model x condition. 
#'   Contains separate columns for pro (\code{_1}) and anti (\code{_0}) metrics, 
#'   alongside derived asymmetry columns (\code{accuracy_asymmetry}, \code{error_asymmetry}).
compute_valence_asymmetry <- function(df) {
#' build_influence_network (created 6/5/26)
#' Build Per-Agent Influence Network Metrics (Debate-Level and Aggregate)
#'
#' Constructs directed, weighted interaction graphs from agent-to-agent
#' influence data, computing centrality metrics at two granularities:
#' per-debate (one graph per selected_debate_id x model_type) and aggregate
#' (one graph per current_condition x model_type, pooling across debates).
#' Joins resulting node metrics with static agent attributes (pro_reduction,
#' saturation status).
#'
#' @param df A dataframe of agent-to-agent interactions (use with
#'   \code{lhs_interactions}), containing \code{sender_id}, \code{receiver_id},
#'   \code{selected_debate_id}, \code{model_type}, \code{current_condition},
#'   and \code{delta} (opinion change magnitude per interaction).
#' @param df_attributes A dataframe of static per-agent attributes containing
#'   \code{agent_id}, \code{selected_debate_id}, \code{current_condition},
#'   \code{pro_reduction}, \code{agent_is_saturated}.
#'
#' @return A named list:
#'   \describe{
#'     \item{per_debate}{Node metrics (in/out strength, betweenness, density,
#'       isolated node count) per agent per debate, joined with pro_reduction.}
#'     \item{per_debate_full}{Same as \code{per_debate} but with all joined
#'       attribute columns retained (the full \code{combined} dataframe).}
#'     \item{aggregate_full}{Node metrics computed on graphs aggregated across
#'       debates within each \code{current_condition} x \code{model_type}.}
#'     \item{aggregate}{Per-condition summary joined with static agent
#'       attributes (\code{macro_attributes}).}
#'     \item{graphs}{Named list of \code{igraph} objects, one per
#'       \code{current_condition}_\code{model_type} combination, for
#'       visualization.}
#'   }
#'
#' @details
#'   Edge weight is \code{mean(abs(delta))} between a sender/receiver pair;
#'   edges with zero weight are dropped. Two separate graph constructions
#'   occur: (1) per-debate, split by \code{selected_debate_id} and
#'   \code{model_type}; (2) aggregate, split by \code{current_condition} and
#'   \code{model_type} — pooling sender/receiver pairs across all debates
#'   sharing the same condition, which conflates agent IDs across debates
#'   since agent_id is not globally unique (see Known Issue).
#'
#'   Metrics computed per graph via \code{igraph}: weighted in-strength
#'   (susceptibility to influence), weighted out-strength (influence
#'   exerted), betweenness centrality (bridge/broker agents), edge density,
#'   and isolated node count (agents with zero interactions).
#'
#' @section Known issue:
#'   Per the project's known issues list: aggregate graphs (the
#'   \code{current_condition} x \code{model_type} split) conflate agent IDs
#'   across debates, since \code{agent_id} alone is not a unique key absent
#'   \code{selected_debate_id} in the grouping. A fix is pending to add
#'   \code{selected_debate_id} to the aggregate grouping key — until then,
#'   \code{aggregate}/\code{aggregate_full}/\code{graphs} outputs should be
#'   treated as provisional.
#'
#' @section Side effects:
#'   Prints \code{colnames(combined)} and \code{nrow(combined)} to console
#'   (debug output).
#'
#' @seealso \code{enrich_graph_vertices()}, \code{filter_top_nodes()},
#'   \code{filter_edges()} for post-processing the returned \code{graphs}.
build_influence_network <- function(df, df_attributes) { # use with lhs_interactions
#' enrich_graph_vertices (created 7/5/26)
#'
#' Joins a dataframe of agent attributes onto the vertices of an existing
#' \code{igraph} object, matching on agent ID, and removes duplicate vertex
#' rows.
#'
#' @param g An \code{igraph} object whose vertex names (\code{V(g)$name})
#'   are agent IDs stored as character strings.
#' @param df A dataframe of agent attributes containing \code{agent_id} and
#'   any additional columns to attach (e.g. \code{pro_reduction},
#'   \code{in_strength}).
#'
#' @return A \code{tbl_graph} object (tidygraph) with the node attribute
#'   table enriched by the joined columns from \code{df}.
#'
#' @details
#'   Filters \code{df} to only rows whose \code{agent_id} appears among the
#'   graph's vertex names, deduplicates to one row per \code{agent_id}, then
#'   left-joins onto graph nodes by \code{name == agent_id} (after coercing
#'   \code{agent_id} to character to match vertex name type).
#'
#' @seealso \code{build_influence_network()} for the source of \code{g} and
#'   attribute dataframes; \code{filter_top_nodes()},
#'   \code{filter_edges()} for further graph processing.
enrich_graph_vertices <- function(g, df) {
#' filter_top_nodes (created 13/5/26)
#' Filter Graph to Top-N Nodes by Out-Strength
#'
#' Reduces a graph to its \code{top_n} most influential nodes, ranked by
#' \code{out_strength} (total weighted outgoing influence).
#'
#' @param g An \code{igraph} or \code{tbl_graph} object whose nodes have an
#'   \code{out_strength} attribute (e.g. from \code{build_influence_network()}
#'   or \code{enrich_graph_vertices()}).
#' @param top_n Integer. Number of top nodes to retain.
#'
#' @return A \code{tbl_graph} object containing only the top \code{top_n}
#'   nodes by \code{out_strength} (edges not incident to retained nodes are
#'   implicitly dropped by tidygraph's node filtering).
#'
#' @seealso \code{filter_edges()} for the edge-weight equivalent;
#'   \code{enrich_graph_vertices()} for attaching \code{out_strength} prior
#'   to filtering.                
filter_top_nodes <- function(g, top_n) {
#' filter_edges (created 15/5/26)
#' Filter Graph Edges Below a Weight Threshold
#'
#' Removes edges with \code{edge_weight} at or below \code{threshold}, then
#' removes any resulting isolated nodes (nodes with no remaining edges).
#'
#' @param g An \code{igraph} or \code{tbl_graph} object whose edges have an
#'   \code{edge_weight} attribute.
#' @param threshold Numeric. Minimum edge weight to retain (exclusive —
#'   edges with \code{edge_weight <= threshold} are dropped).
#'
#' @return A \code{tbl_graph} object with low-weight edges and any newly
#'   isolated nodes removed.
#'
#' @seealso \code{filter_top_nodes()} for the node-count equivalent;
#'   typically applied after \code{enrich_graph_vertices()}.
filter_edges <- function(g, threshold) {
#' build_network_graph (created 15/5/26)
#' update, added arrows, node_text and continuous edges 
#' 
#' Function to render a network graph as a plot object illustrating individual agent
#' broadcasts across all debates
#'
#' @param g A tbl_graph object with node attributes out_strength, 
#'   pro_reduction, agent_is_saturated and edge attribute edge_weight.
#'   Typically output of enrich_graph_vertices() passed through filter_edges().
#'
#' @return A ggraph object illustrating individual agent influences and broadcasts for each debate
#' across model_type
build_network_graph <- function(g) {
#' prepare_interactions (created approx 7/26)
#' updated on 23/7/26
#' 
#' Reads interaction-level output CSV files from GAMA simulations, enforces standard
#' schema types, and filters for active speaking events. Automatically handles 
#' empty logs (e.g., non-speaking model runs) and missing headers without crashing.
#' 
#' @param path String. File path to the interaction log CSV file.
#' 
#' @details 
#' The function performs early-exit checks if the CSV file contains zero data rows 
#' (common when evaluating models without speech/dialogue mechanics). It coerces 
#' \code{selected_debate_id} and \code{seed} to character vectors, converts logical 
#' flags, ensures \code{delta}, \code{initial_opinion}, \code{opinion}, \code{final_attitude} are numerical 
#' and conditionally filters for \code{speaking_mode == TRUE} if 
#' the column is present.
#' 
#' @return A cleaned \code{tbl_df} (tibble) with validated column types and 
#'   filtered interaction records. Returns an empty (0-row) data frame with its 
#'   original structure if no interactions are present in the input file.
#' 
#' @export
prepare_interactions <- function(path) {
```

## framework_analysis.R
```r
#' Main Analysis Pipeline
#'
#' Orchestrates hypothesis tests (H1-H5), sensitivity analysis,
#' behavioral extractions, and model comparisons. Returns a 
#' standardized output package. Use map_slots() to inspect.
#'
#' @param df Bundle list with slots: sim_inputs, sim_val (optional), df_empirical.
#' @return analysis_output_package. See section 9 of this file for slot definitions.
analyze_processed_run <- function(df) {
```

## data_processing.R
```r
#' Load and process one simulation run (LHS or GA) into canonical analysis objects 28/5/26
#' 
#' updates: update 2/6/26, easier loading based on config update / 30/6/26 added valence metrics
#' 
#' Orchestrates the full per-run data pipeline: loads batch-level, agent-level,
#' and interaction-level simulation output from disk; derives directional,
#' valence/asymmetry, and UpSet-plot-ready summaries from the agent-level data;
#' and returns everything under consistent slot names regardless of whether
#' \code{config} describes an LHS or GA run. This is the single entry point
#' each run type (LHS/GA) passes through before reaching
#' \code{analyze_processed_run}.
#'
#' @param config A run configuration list (e.g. \code{run_configs$lhs_main} or
#'   \code{run_configs$ga_main}), built from \code{lhs}/\code{ga} in this
#'   script. Must contain at minimum:
#'   \describe{
#'     \item{run_type}{"LHS" or "GA" — controls only the \code{lhs_versions}
#'       slot in the return value, not the loading logic itself.}
#'     \item{version_scope}{"v1", "v2", or "both". If "both" (LHS only),
#'       both dataset versions are loaded and combined via
#'       \code{combine_df_versions}, falling back to whichever version
#'       loaded successfully if only one did. If "v1" or "v2" singly, a
#'       single version is loaded, with a fallback to v1 if "v2" is
#'       requested but \code{batch$v2$path}/\code{agent$v2$path} is
#'       \code{NULL} (see Details).}
#'     \item{batch$v1/$v2$path, $version}{Paths and version labels for
#'       batch-summary CSVs.}
#'     \item{agent$v1/$v2$path}{Paths for agent-level-results CSVs.}
#'     \item{interaction$v1/$v2$path}{Paths for interaction-log CSVs.}
#'   }
#'
#' @return A named list with consistent slots regardless of run type:
#'   \describe{
#'     \item{config}{The input config, unchanged (for provenance/traceability).}
#'     \item{df_batch}{Debate x model x seed grain. If \code{version_scope ==
#'       "both"}, this is the v2 data specifically (v1 is folded into
#'       \code{lhs_versions} instead, not discarded).}
#'     \item{lhs_versions}{Combined v1+v2 batch data, only populated when
#'       \code{run_type == "LHS"} AND \code{version_scope == "both"};
#'       \code{NULL} otherwise.}
#'     \item{df_ag}{Agent-level grain — one row per agent per parameter
#'       combination per seed (NOT deduplicated at this stage). Downstream,
#'       \code{framework_analysis.R} derives \code{df_ag_deduped} from this
#'       object specifically to fit \code{ols_model_h1}/\code{ols_model_h2}
#'       without pseudoreplication (resolved 13/7/26 — see
#'       \code{results$models$ols_h1}, \code{ols_h2}, and
#'       \code{results$comparisons$df_ols_agent_data} in the output
#'       contract). MAE-based uses of the raw (non-deduplicated) \code{df_ag}
#'       remain unaffected regardless, as established earlier.}
#'     \item{df_interactions, df_influence, df_susceptibility}{Interaction-level
#'       outputs. All three are \code{NULL} if the interaction log file for
#'       this config doesn't exist on disk — expected/normal for
#'       non-speaking-mode runs, not an error state.}
#'     \item{df_directional, df_directional_agents}{Directional (sign-of-change)
#'       summaries; \code{NULL} if \code{df_ag} failed to load.}
#'     \item{df_valence, df_sum_directional_valence}{Valence/asymmetry summaries
#'       (added 30/6/26); \code{NULL} if \code{df_directional_agents} is \code{NULL}.}
#'     \item{df_upset}{UpSet-plot-ready wide-format summary (added 6/7/26).
#'       \code{NULL} if \code{df_sum_directional_valence} is \code{NULL} —
#'       guard added 13/7/26 to match the pattern used elsewhere in this
#'       function (previously unguarded and would error, not return
#'       \code{NULL}, in that case).}
#'   }
#'
#' @details
#' \code{df_empirical} is intentionally NOT included in the return list —
#' the empirical-loading block above is commented out. ownstream,
#' \code{framework_analysis.R} derives \code{df_ag_deduped} from this
#' object specifically to fit \code{ols_model_h1}/\code{ols_model_h2}
#' without pseudoreplication.
#'
#' Batch-level and agent-level loading now share the same fallback rule
#' when \code{version_scope == "v2"} (fixed 13/7/26 — previously batch-level
#' had no fallback at all and would return \code{NULL} outright, while
#' agent-level silently fell back to v1; batch-level now mirrors
#' agent-level's behavior): if \code{v2$path} is \code{NULL}, both fall
#' back to the corresponding \code{v1} path/version, and a \code{message()}
#' is emitted so a genuine v2-path misconfiguration doesn't silently
#' masquerade as a successful v2 run.
#'
#' @examples
#' \dontrun{
#' processed_lhs <- process_run(run_configs$lhs_main)
#' processed_ga  <- process_run(run_configs$ga_main)
#' }
process_run <- function(config) {
```

