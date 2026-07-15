# framework_analysis.R
# depends on: functions.r, data_processing.r, and plots.R

source("./functions.R")
source("./data_processing.R")
source("./plots.R")

analyze_processed_run <- function(df) {
  
  # ────────────────────────────────────────────────────────────────────────────
  # 0. CONFIG & DATA EXTRACTION FROM UNIFIED LIST KEYS
  # ────────────────────────────────────────────────────────────────────────────
  config                <- df$sim_inputs$config
  df_batch              <- df$sim_inputs$df_batch
  lhs_versions          <- df$sim_inputs$lhs_versions
  df_ag                 <- df$sim_inputs$df_ag
  df_interactions       <- df$sim_inputs$df_interactions
  df_influence          <- df$sim_inputs$df_influence
  df_susceptibility     <- df$sim_inputs$df_susceptibility
  df_empirical          <- df$df_empirical
  df_directional        <- df$sim_inputs$df_directional
  df_directional_agents <- df$sim_inputs$df_directional_agents
  df_sum_directional_valence <- df$sim_inputs$df_sum_directional_valence
  df_valence <- df$sim_inputs$df_valence
  df_upset <- df$sim_inputs$df_upset
  
  # Master Guard: Check that core batch data was loaded successfully
  if (is.null(df_batch)) {
    stop("Analysis Execution Failed: Canonical batch data is NULL.")
  }
  
  # Safe attribute check replacing legacy stopifnot hardcoding
  if (!"debate_composition" %in% colnames(df_batch)) {
    stop("Analysis Execution Failed: Required structural column 'debate_composition' is missing.")
  }
  
  # ────────────────────────────────────────────────────────────────────────────
  # 1. EMPIRICAL COMPARISONS
  # ────────────────────────────────────────────────────────────────────────────
  empirical_stat_check <- NULL
  empirical_stat_pivot <- NULL
  empir_cohen          <- NULL
  
  if (!is.null(df_empirical)) {
    empirical_stat_check <- empirical_stats(df_empirical)
    
    empirical_stat_pivot <- empirical_stat_check %>%
      pivot_longer(
        cols = c(mean_change_t0_t1, mean_change_t1_t2, mean_change_t0_t2),
        names_to = "change_type",
        values_to = "value"
      )
    
    # Wilcoxon Rank-Sum checks on Empirical Environment
    df_empirical %>%
      filter(composition == "H") %>%
      pull(change_t1_t2) %>%
      wilcox.test(mu = 0)
    
    df_empirical %>%
      filter(composition %in% c("H", "M")) %>%
      wilcox.test(change_t1_t2 ~ composition, data = .)
    
    empir_cohen <- lm(change_t1_t2 ~ pro_reduction,
                      data = df_empirical %>% filter(composition == "M")) %>%
      lm.beta() %>%
      tidy()
  }

  # Valence Calculations Introduction
  df_asymmetry_processed <- NULL
  df_valence_processed <- NULL

  if(!is.null(df_directional_agents)) {
      df_valence_processed <- summarize_directional_valence(df_directional_agents)
      df_asymmetry_processed <- compute_valence_asymmetry(df_valence_processed)
  }
  
  # ────────────────────────────────────────────────────────────────────────────
  # 2. SENSITIVITY ANALYSIS (LHS ONLY)
  # ────────────────────────────────────────────────────────────────────────────
  pcc_lhs  <- NULL
  prcc_lhs <- NULL
  pcc_all  <- NULL
  prcc_all <- NULL
  df_version_summary <- NULL
  sensi_v1 <- NULL
  sensi_v2 <- NULL
  
  if (config$run_type == "LHS") {
    sensi_lhs <- run_sensi_analysis(df_batch,
                                    param_cols_by_model = param_cols_by_model,
                                    output_cols = output_cols)
    pcc_lhs  <- sensi_lhs$pcc
    prcc_lhs <- sensi_lhs$prcc
    
    # Version split tests: safely run only if multi-version outputs exist
    if (!is.null(lhs_versions)) {
      df_version_summary <- lhs_versions %>%
        group_by(version, model_type, speaking_mode, debate_composition) %>%
        summarize(
          mae_mean = mean(mae),
          conv_mean = mean(convergence_cycle),
          .groups = "drop"
        )
      
      # Extract individual data frames safely filtering via config version tags
      df_lhs_v1 <- lhs_versions %>% filter(version == config$batch$v1$version)
      df_lhs_v2 <- lhs_versions %>% filter(version == config$batch$v2$version)
      
      if (nrow(df_lhs_v1) > 0 && !is.null(config$batch$v1$path)) {
        sensi_v1 <- run_sensi_analysis(df_lhs_v1, param_cols_by_model, output_cols)
        pcc_v1   <- sensi_v1$pcc %>% mutate(version = "v1")
        prcc_v1  <- sensi_v1$prcc %>% mutate(version = "v1")
      }
      if (nrow(df_lhs_v2) > 0 && !is.null(config$batch$v2$path)) {
        sensi_v2 <- run_sensi_analysis(df_lhs_v2, param_cols_by_model, output_cols)
        pcc_v2   <- sensi_v2$pcc %>% mutate(version = "v2")
        prcc_v2  <- sensi_v2$prcc %>% mutate(version = "v2")
      }
      
      if (exists("pcc_v1") && exists("pcc_v2"))   pcc_all  <- bind_rows(pcc_v1, pcc_v2)
      if (exists("prcc_v1") && exists("prcc_v2")) prcc_all <- bind_rows(prcc_v1, prcc_v2)
    }
  }
  
  # ────────────────────────────────────────────────────────────────────────────
  # 3. OLS VS ABM COMPARISON (REQUIRES AGENT POPULATION DATA)
  # ────────────────────────────────────────────────────────────────────────────
  comparison_clean   <- NULL
  comparison_summary <- NULL
  ols_global_mae     <- NULL
  ols_model          <- NULL
  ols_model_h1       <- NULL # standardized lm for H1
  ols_model_h2       <- NULL # standardize lm for H2 with perceived_norms and self_control
  abm_mae_debate     <- NULL
  empirical_beta_val <- NULL
  beta_distance <- NULL
  simulated_betas_raw <- NULL
  
  if (!is.null(df_ag)) {
    ols_result     <- compute_ols_baseline(df_ag)
    ols_model      <- ols_result$model
    df_ag_ols      <- ols_result$data
    ols_global_mae <- ols_result$ols_mae

    # Hypothesis refit (fixing H1 pseudoreplication of df_ag duplicating rows for each agent) 13/7/26
    df_ag_deduped <- df_ag %>%
      distinct(agent_id, .keep_all = TRUE)

    # corrected H1 test
    ols_model_h1 <- lm(final_attitude ~ initial_opinion, data = df_ag_deduped)

    # H2 test set up
    if ("perceived_norms" %in% colnames(df_ag_deduped) && "self_control" %in% colnames(df_ag_deduped) {
        ols_model_h2 <- lm(final_attitude ~ perceived_norms + self_control, data = df_ag_deduped)
    }
    
    ols_mae_debate <- df_ag_ols %>%
      group_by(selected_debate_id, debate_label) %>%
      summarize(ols_mae = mean(ols_error, na.rm = TRUE), .groups = "drop")
    
    abm_mae_debate <- df_batch %>%
      group_by(selected_debate_id) %>%  
      summarize(
        abm_mae = mean(mae, na.rm = TRUE),
        debate_label = first(debate_label),  
        pct_hetero = mean(use_distinct_agents == TRUE, na.rm = TRUE),
        .groups = "drop"
      )
    
    common_ids <- intersect(ols_mae_debate$selected_debate_id, abm_mae_debate$selected_debate_id)
    
    if (length(common_ids) > 0) {
      ols_mae_debate <- ols_mae_debate %>% filter(selected_debate_id %in% common_ids) %>% mutate(selected_debate_id = as.character(selected_debate_id))
      abm_mae_debate <- abm_mae_debate %>% filter(selected_debate_id %in% common_ids) %>% mutate(selected_debate_id = as.character(selected_debate_id))
      
      comparison_clean <- inner_join(abm_mae_debate, ols_mae_debate, by = "selected_debate_id") %>%
        filter(is.finite(abm_mae), is.finite(ols_mae)) %>%
        mutate(delta_mae = abm_mae - ols_mae, abm_better = abm_mae < ols_mae)
      
      if (nrow(comparison_clean) > 0) {
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
        
        if (nrow(comparison_clean) > 2) {
          wilcox_abm_ols <- wilcox.test(comparison_clean$abm_mae, comparison_clean$ols_mae, paired = TRUE)
          t_test_abm_ols  <- t.test(comparison_clean$abm_mae, comparison_clean$ols_mae, paired = TRUE)
        }
      }
    }
    
    # beta distance check 3/6/26 check distribution of empirical beta compared with simulations
    if (!is.null(empir_cohen)) {
      # extract empirical beta
      empirical_beta_val <- empir_cohen %>%
        filter(term == "pro_reduction")
      
      # investigate which columns exist in empir_cohen 4/6/26 extra guard
      if ("std_estimate" %in% colnames(empirical_beta_val)) {
        empirical_beta_val <- empirical_beta_val %>% pull(std_estimate) 
      } else if ("std.estimate" %in% colnames(empirical_beta_val)) {
        empirical_beta_val <- empirical_beta_val %>% pull(std.estimate)
      } else {
        empirical_beta_val <- empirical_beta_val %>% pull(estimate) # fallback to understandardized
      }
      
      # ensure empir is treated as a single numeric value
      empirical_beta_scalar <- if(length(empirical_beta_val) > 0) as.numeric(empirical_beta_val[1]) else NA_real_
      
      # compute simualted beta distribution per model type and seed
      simulated_betas_raw <- df_ag %>%
        group_by(model_type, selected_debate_id, seed) %>%
        do(tidy(lm(opinion_change ~ pro_reduction, data = .))) %>%
        filter(term == "pro_reduction")
      
      # safe distance calculation (type-matching ensured)
      beta_distance <- simulated_betas_raw %>%
        group_by(model_type) %>%
        summarize(
          mean_simulated_beta = mean(estimate, na.rm = TRUE),
          sd_simulated_beta = sd(estimate, na.rm = TRUE),
          n = n(),
          empirical_beta = empirical_beta_scalar,
          # z score: where does empirical beta sit in simulated distribution
          z_score = if_else(
            !is.na(sd_simulated_beta) & sd_simulated_beta > 0,
            (empirical_beta_scalar - mean_simulated_beta) / sd_simulated_beta,
            NA_real_
          ),
          .groups = "drop"
        )
    }
  }
  
  # ────────────────────────────────────────────────────────────────────────────
  # 4. BEHAVIORAL EXTRACTIONS (COMPOSITION & SPEAKING MODES)
  # ────────────────────────────────────────────────────────────────────────────
  h_vs_m <- df_batch %>%
    group_by(debate_composition, model_type, speaking_mode, use_distinct_agents) %>%
    summarize(mae_mean = mean(mae), mae_sd = sd(mae), n = n(), .groups = "drop")
  
  speaking_compar <- df_batch %>%
    group_by(speaking_mode, debate_composition, model_type, use_distinct_agents) %>%
    summarize(
      mae_mean = mean(mae),
      mae_sd = sd(mae),
      mean_norm_convergence = mean(normalised_convergence),
      n = n(),
      .groups = "drop"
    )
  
  speakingmode_vs_convergence_wilcox <- wilcox.test(convergence_cycle ~ speaking_mode, data = df_batch)
  
  convergence_anal <- df_batch %>%
    group_by(model_type, speaking_mode, selected_debate_id) %>%
    summarize(
      cycles_mean = mean(convergence_cycle),
      cycles_sd = sd(convergence_cycle),
      cycles_min = min(convergence_cycle),
      cycles_max = max(convergence_cycle),
      cycles_normalised = mean(normalised_convergence),
      .groups = 'drop'
    )
  
  df_conv_debate <- df_batch %>%
    group_by(model_type, selected_debate_id, speaking_mode) %>%
    summarize(
      mean_conv = mean(convergence_cycle),
      mean_mae = mean(mae),
      sd_conv = sd(convergence_cycle),
      sd_mae = sd(mae),
      .groups = "drop"
    )
  
  run_conv_model <- function(df_nodes) {
    lm(mean_mae ~ mean_conv * speaking_mode + model_type, data = df_nodes)
  }
  
  conv_diff <- NULL
  if ("current_condition" %in% colnames(df_batch)) {
    conv_diff <- df_batch %>%
      mutate(outcome = ifelse(opinion_variance < 0.1, "Convergence", "Polarization")) %>%
      group_by(model_type, current_condition, outcome) %>%
      summarize(n = n(), .groups = "drop")
  }
  
  # ────────────────────────────────────────────────────────────────────────────
  # 5. NO-CHANGE BASELINE & STOCHASTIC CRUNCH
  # ────────────────────────────────────────────────────────────────────────────
  baseline_comparison <- NULL
  df_no_change <- df_batch %>%
    filter(model_type == "no_change")
  
  if (nrow(df_no_change) > 0 && !is.null(abm_mae_debate)) {
    df_no_change <- df_no_change %>%
      group_by(selected_debate_id, debate_label, debate_composition, current_experiment_id) %>%
      summarize(baseline_mae = mean(mae), .groups = "drop")
    
    baseline_comparison <- df_no_change %>%
      left_join(abm_mae_debate %>% select(selected_debate_id, abm_mae), by = "selected_debate_id") %>% 
      mutate(delta_mae = abm_mae - baseline_mae)
  }
  
  stochasticity_check_1 <- df_batch %>%
    group_by(model_type, use_distinct_agents, selected_debate_id, seed) %>%
    summarize(mae_sd = sd(mae), n = n(), .groups = "drop")
  
  heterogeneity_check <- df_batch %>%
    group_by(model_type, use_distinct_agents) %>%
    summarize(mae_mean = mean(mae), mae_median = median(mae), mae_sd = sd(mae), n = n(), .groups = "drop")
  
  # ────────────────────────────────────────────────────────────────────────────
  # 6. MODEL COMPARISONS
  # ────────────────────────────────────────────────────────────────────────────
  model_comparison_main <- NULL
  if (!is.null(lhs_versions)) {
    model_comparison_main <- lhs_versions %>%
      group_by(model_type, version, speaking_mode) %>%
      summarize(mae_mean = mean(mae), mae_sd = sd(mae), .groups = "drop") %>% arrange(mae_mean)
  } else {
    model_comparison_main <- df_batch %>%
      group_by(model_type, speaking_mode) %>%
      summarize(mae_mean = mean(mae), mae_sd = sd(mae), .groups = "drop") %>% arrange(mae_mean)
  }
  
  model_comparison_detailed <- df_batch %>%
    group_by(model_type, version, speaking_mode, use_distinct_agents) %>%
    summarize(mae_mean = mean(mae), mae_sd = sd(mae), .groups = "drop")
  
  model_comparison_relative <- model_comparison_main %>%
    group_by(speaking_mode) %>%
    mutate(best_mae = min(mae_mean), delta_mae = mae_mean - best_mae) %>% ungroup()
  
  failures_comp <- df_batch %>%
    mutate(failures = mae > 0.18) %>%
    group_by(model_type, failures) %>%
    summarize(mean_convergence = mean(convergence_rate), pct_hetero = mean(use_distinct_agents == TRUE) * 100, n_total = n(), .groups = "drop")
  
  clusters <- NULL
  if ("num_clusters" %in% colnames(df_batch)) {
    clusters <- df_batch %>%
      mutate(cluster_change = num_clusters - initial_num_clusters) %>%
      group_by(model_type, selected_debate_id) %>%
      summarize(mean_cluster_change = mean(cluster_change), .groups = "drop")
  }
  
  # ────────────────────────────────────────────────────────────────────────────
  # 7. NETWORK PIPELINE (SAFETY GUARDED)
  # ────────────────────────────────────────────────────────────────────────────
  network_data_package        <- NULL
  graphs_edge_filter          <- NULL
  homogeneous_plots_combined  <- NULL
  heterogeneous_plots_combined <- NULL
  network_plot_combined       <- NULL
  
  if (!is.null(df_interactions) && !is.null(df_ag)) {
    network_outputs <- build_influence_network(df_interactions, df_ag)
    network_outputs$graphs <- map(network_outputs$graphs, enrich_graph_vertices, network_outputs$aggregate)
    
    graphs_top_nodes <- map(network_outputs$graphs, filter_top_nodes, top_n = 10)
    
    graphs_edge_filter <- map(network_outputs$graphs, function(g) { 
      threshold <- quantile(E(g)$edge_weight, 0.75, na.rm = TRUE)
      filter_edges(g, threshold)
    })
    
    edge_plots <- imap(graphs_edge_filter, function(g, name) build_network_graph(g) + labs(title = name))
    
    homo_keys  <- intersect(names(graphs_edge_filter), c("homogeneous_consensus", "homogeneous_clustering", "homogeneous_bipolarization"))
    hetero_keys <- intersect(names(graphs_edge_filter), c("heterogeneous_consensus", "heterogeneous_clustering", "heterogeneous_bipolarization"))
    
    if (length(homo_keys) == 3) {
      homogeneous_plots <- imap(graphs_edge_filter[homo_keys], function(g, name) build_network_graph(g) + labs(title = name))
      homogeneous_plots_combined <- wrap_plots(homogeneous_plots, ncol = 3)
    }
    if (length(hetero_keys) == 3) {
      heterogeneous_plots <- imap(graphs_edge_filter[hetero_keys], function(g, name) build_network_graph(g) + labs(title = name))
      heterogeneous_plots_combined <- wrap_plots(heterogeneous_plots, ncol = 3)
    }
    network_plot_combined <- wrap_plots(edge_plots, ncol = 1)
    
    network_data_package <- list(
      per_debate = network_outputs$per_debate,
      aggregate  = network_outputs$aggregate,
      graphs     = network_outputs$graphs
    )
  }
  
  # ────────────────────────────────────────────────────────────────────────────
  # 8. GA BOUNDS EXTRACTION (ONLY RUN ON LHS SWEEPS)
  # ────────────────────────────────────────────────────────────────────────────
  ga_bounds_export <- NULL
  if (config$run_type == "LHS") {
    lhs_regions <- param_region_extraction(df_batch, percentile = 0.25)
    gaml_ga <- generate_gaml_bounds(lhs_regions$regions)
    writeLines(gaml_ga, "gaml_GA_bounds.txt")
    ga_bounds_export <- list(bounds = lhs_regions$regions, range_check = lhs_regions$range_check)
  }
  
  # ────────────────────────────────────────────────────────────────────────────
  # 9. STANDARDIZED ANALYSIS OBJECT PACKAGING
  # ────────────────────────────────────────────────────────────────────────────
  analysis_output_package <- list(
    inputs = list(
      raw              = df_batch, # raw batch file (per debate x speaking_mode x model)
      versions         = lhs_versions, # differentiates between different lhs version runs
      version_summary  = df_version_summary, # aggregated versions for pcc/prcc
      influence        = df_influence, # pulled from df_interactions to compute influence of each speaking agent on others
      raw_interactions = df_interactions # df of cleaned itneractions (per cycle between all agents in a debate)
    ),
    results = list(
      sensitivity = list(
        combined = list(pcc = pcc_lhs, prcc = prcc_lhs),
        v1       = if(!is.null(sensi_v1)) list(pcc = sensi_v1$pcc, prcc = sensi_v1$prcc) else NULL,
        v2       = if(!is.null(sensi_v2)) list(pcc = sensi_v2$pcc, prcc = sensi_v2$prcc) else NULL
      ),
      models = list(conv = run_conv_model(df_conv_debate), 
                    ols = ols_model, # raw pooled individual model 13/7/26
                    ols_h1 = ols_model_h1, # deduplicated H1 test
                    ols_h2 = ols_model_h2 # integrated H2 test with perceived_norms and self_control
                   ),
      comparisons = list(
        empirical       = empirical_stat_check, # from df_empirical, computed mean and SD for each time (T0,T1,T2)
        empirical_cohen = empir_cohen, # linear regression from raw df_empirical pro_reduction on changet1t2, filtered by Mixed debates)
        ols_debate_mae  = comparison_clean, # inner join abm_mae (from df_batch) and ols_mae (from df_ag) by selected_debate_id and calculates delta 
        summary         = comparison_summary, # df to calculate mean delta, SD, and CI for when ABM is better/worse than pure OLS
        ranking         = model_comparison_main, # version aware df_batch grouped by model_type and speaking mode, summarizes mean_mae and SD arranged by mean_mae
        mae_delta_compar = model_comparison_relative, # pull from model_comparison_main, creates best_mae from grouped model_type and delta_mae
        baseline        = baseline_comparison, # pulls from df_batch and filter for no_change, left_join by selected_debate_id, mutates delta_mae
        directional     = df_directional, # applies \code{summarize_directional} to df_directional_agents (from df_ag), groups by model_type, current_condition, selected_debate_id to calculate right and wrong dir
        directional_agents = df_directional_agents, # unsummarized directional, applies \code{prepare_directional} to df_ag to calculate sign of empirical and simualated direction change among agents that ACTUALLY moved 
        beta_distance = beta_distance, # based on simulated_betas_raw, grouped by model_type, summarizes mean delta compared to empirical beta and calculates zscore
        beta_distance_raw = simulated_betas_raw, # pulls from df_ag, groups by model_type, selected_debate_id and seed, linear regression of pro_reduction on opinion_change and filters by pro_reduction
        sum_dir_valence = df_sum_directional_valence, # pulls from \code{df_directional_agents}, one row per model x current_condition x selected_debate_id x pro_reduction and returns right and wrong dir/signed error of simul data
        valence_metrics = df_valence, # applies \code{compute_valence_asymmetry} to sum_dir_valence, wide pivot to calculate error_asymmetery and accuracy_asymmetry
        upset_prep = df_upset
      ),
      behavioral = list(
        composition = h_vs_m, # pulls from df_batch (grouped by debate_composition, model_type, speaking_mode, use_distinct_agents) summarizes mean_mae and SD
        speaking    = speaking_compar, # pulls from df_batch, grouped (speaking_mode, debate_composition, model_type, use_distinct_agents) summarizes mean_mae, SD and normalized convergence
        convergence = convergence_anal, # pulls from df_batch, grouped (model_type, speaking_mode, selected_debate_id) summarizes mean convergence cyle, min, max, SD and normalized
        stochastic  = stochasticity_check_1, # pulls from df_batch, grouped (model_type, use_distinct_agents, selected_debate_id, seed) summarizes SD mae
        heterogen   = heterogeneity_check # pulls from df_batch, grouped (model_type, use_distinct_agents) summarize mean MAE, median, SD
      ),
      dynamics = list(
        conv_debate = df_conv_debate, # pulls from df_batch, grouped (model_type, selected_debate_id, speaking_mode) summarizes mean convergence cycle, MAE, SD conv and SD MAE
        conv_diff   = conv_diff, # pulls from df_batch, mutates opinion variance < 0.1 for "convergence/bipolarization", grouped (model_type, current_condition, outcome)
        failures    = failures_comp, # pulls from df_batch, mutates failure = mae > 0.18, grouped (model_type, failures), summarizes mean convergence, pct_hetero in debate composition)
        clusters    = clusters # pulls from df_batch, mutates cluster change (from beginning to end), grouped (model_type, selected_debate_id), summarizes mean_cluster_change
      ),
      regions  = ga_bounds_export,
      networks = network_data_package
    ),
    plots = list(
      pcc        = function() plot_pcc_heatmap(pcc_lhs),
      prcc       = function() plot_prcc_heatmap(prcc_lhs),
      pcc_all    = function() plot_pcc_all_heatmap(pcc_all),
      prcc_all   = function() plot_prcc_all_heatmap(prcc_all),
      abm_vs_ols = function() plot_ols_abm_comp(comparison_clean),
      
      empirical_col   = function() plot_empir_compar(empirical_stat_check),
      empirical_cross = function() plot_empir_cross(empirical_stat_pivot),
      
      model_rank_versions           = function() plot_model_rank_versions(model_comparison_main), 
      model_performance_rank_main   = function() plot_model_performance_rank_main(model_comparison_main),
      model_performance_uncertainty = function() plot_model_comparison_uncertainty(model_comparison_detailed),
      model_performance_gap         = function() plot_model_performance_rank_gap(model_comparison_relative),
      
      debate_comp_errors = function() plot_h_m_errors(df_batch),
      convergence_compar = function() plot_box_conv_compar_speak(df_conv_debate),
      convergence        = function() plot_viol_conv_model_type(df_batch),
      tradeoff_agg       = function() plot_tradeoff_aggregated(df_conv_debate),
      tradeoff_raw       = function() plot_tradeoff_raw(df_batch),
      
      influence_model_type         = function() plot_influence_by_model(df_influence),
      saturation_by_condition      = function() plot_satur_by_condition(df_susceptibility),
      direction_by_position        = function() plot_dir_by_pro(df_susceptibility),
      directional_accuracy         = function() plot_directional_accuracy(df_directional),
      delta_direction_sim_vs_empir = function() plot_delta_direction_scatter(df_directional_agents),

      # VALENCE MEASURES
      asymmetry_gap = function() plot_asymmetry_gap(df_asymmetry_processed),
      delta_color_direction_shift = function() plot_delta_color_direction_scatter(df_directional_agents),
      simulated_delta_dist = function() plot_simulated_delta_dist(df_directional_agents),
      valence_accuracy = function() plot_valence_accuracy(df_valence_processed),
        
      beta_distance_vs_empir = function() plot_beta_distance(simulated_betas_raw, empirical_beta_val),
      
      homogeneous_network_plots   = homogeneous_plots_combined,
      heterogeneous_network_plots = heterogeneous_plots_combined
    )
  )
  
  return(analysis_output_package)
}