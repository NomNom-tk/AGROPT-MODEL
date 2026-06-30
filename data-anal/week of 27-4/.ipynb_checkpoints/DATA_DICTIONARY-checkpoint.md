#' Output Contract — analysis_output_package
#'
#' The single nested list returned by analyze_processed_run() (or
#' equivalent top-level analysis function), structured as:
#'
#' inputs
#'   raw               - df_batch, raw simulation batch output
#'   versions          - lhs_versions, LHS version metadata (LHS only)
#'   version_summary   - df_version_summary
#'   influence         - df_influence, influence-derived interaction metrics
#'   raw_interactions  - df_interactions, raw agent-to-agent interaction data
#'
#' results
#'   sensitivity (LHS only)
#'     combined        - list(pcc, prcc) across all versions
#'     v1              - list(pcc, prcc) for threshold v1 (0.001), NULL if absent
#'     v2              - list(pcc, prcc) for threshold v2 (0.01), NULL if absent
#'   models
#'     conv            - run_conv_model(df_conv_debate) output
#'     ols             - ols_model, baseline OLS regression
#'   comparisons
#'     empirical           - empirical_stat_check
#'     empirical_cohen     - empir_cohen, Cohen's d effect sizes
#'     ols                 - comparison_clean, ABM vs OLS MAE comparison
#'     summary             - comparison_summary
#'     ranking             - model_comparison_main
#'     mae_delta_compar    - model_comparison_relative
#'     baseline            - baseline_comparison (vs no_change)
#'     directional         - df_directional, directional accuracy results
#'     directional_agents  - df_directional_agents, agent-level directional accuracy
#'     beta_distance        - beta empirical distance relative to simulated data (3/6/26)
#'     beta_distance_raw    - simulated_betas_raw
#'   behavioral
#'     composition     - h_vs_m, H vs M debate composition comparison
#'     speaking        - speaking_compar, speaking mode comparison
#'     convergence     - convergence_anal
#'     stochastic      - stochasticity_check_1
#'     heterogen       - heterogeneity_check
#'   dynamics
#'     conv_debate     - df_conv_debate
#'     conv_diff       - conv_diff
#'     failures        - failures_comp
#'     clusters        - clusters
#'   regions  - ga_bounds_export (LHS only, output of param_region_extraction())
#'   networks - network_data_package (output of build_influence_network())
#'
#' plots
#'   Zero-argument closures with data pre-bound at construction time, e.g.
#'   outputs$plots$pcc(). Covers sensitivity (pcc/prcc, pcc_all/prcc_all),
#'   ABM vs OLS comparison, empirical comparisons (col/cross), model
#'   performance ranking (versions/main/uncertainty/gap), H/M debate
#'   composition errors, convergence (compar/violin/tradeoff agg+raw),
#'   influence/saturation/direction-by-position, directional accuracy,
#'   beta distance vs empirical, and pre-combined homogeneous/heterogeneous
#'   network plot grids.
#'
#' @note This supersedes build_analysis_outputs() in functions.R, which is
#'   marked NOTUSED and should be removed — this block is the actual,
#'   current output contract in production use.