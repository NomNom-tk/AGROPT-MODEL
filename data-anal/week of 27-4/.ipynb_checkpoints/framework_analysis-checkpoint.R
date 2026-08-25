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
  mlm_model_h2       <- NULL # standardize lm for H2 with perceived_norms and self_control
  mlm_model_h2_cent        <- NULL # centered version to correct and decrease collinearity of variables

  # initialization of write_result 24/8/26
  write_result(paste("Hypothesis Results - ", Sys.time()), append = FALSE)
  write_result(paste(rep("=", 60), collapse = ""))
    
  if (!is.null(df_empirical)) {

    # Summary stats and long pivot for faceted plot and ABM benchmarks
    empirical_stat_check <- empirical_stats(df_empirical)
    
    empirical_stat_pivot <- empirical_stat_check %>%
      pivot_longer(
        cols = c(mean_change_t0_t1, mean_change_t1_t2, mean_change_t0_t2),
        names_to = "change_type",
        values_to = "value"
      )
    
    # Wilcoxon Rank-Sum checks on Empirical Environment
    ## significant opinion change in homogeneous groups vs zero
    wilcox_h_zero <- df_empirical %>%
      filter(composition == "H") %>%
      pull(change_t1_t2) %>%
      wilcox.test(mu = 0)

    ## difference in opinion change between homogeneous and mixed experimental conditions
    wilcox_h_vs_m <- df_empirical %>%
      filter(composition %in% c("H", "M")) %>%
      mutate(composition = as.factor(composition)) %>%
      wilcox.test(change_t1_t2 ~ composition, data = .)

    # empirical mlm for pro_reduction effect to create standardized effects
    df_emp_m <- df_empirical %>%
      filter(composition == "M") %>%
      mutate(change_t1_t2_z = as.numeric(scale(change_t1_t2)),
             pro_reduction_z = as.numeric(scale(pro_reduction))
      )

    # empirical model m for beta calculation and comparison with sim data
    log_step("Starting Empirical model MLM for beta calculations...")
    empir_model_m <- lmer(
        change_t1_t2_z ~ pro_reduction_z + (1 | id_group_all),
        data = df_emp_m
    )

    # TODO set up the empirical calls later 24/8/26
    write_result("\n## Empirical model recording")
    log_step("Finished empirical MLM") 

    # Extract empir cohen with standardized coefficients
    empir_cohen <- data.frame(
      term = "pro_reduction",
      std_estimate = fixef(empir_model_m)[["pro_reduction_z"]],
      row.names = NULL
    )


    # H2 test set up
    if (all(c("abs_change_t1_t2", "perceived_norms", "self_control") %in% colnames(df_empirical))) {
        # Uncentered H2 model and diagnostics
        log_step("Starting H2 uncentered model...")
        mlm_model_h2 <- lmer(abs_change_t1_t2 ~ (perceived_norms + self_control) * opinion_strength + (1 | id_group_all), data = df_empirical)
        log_step("Finished H2 uncentered model...")
    if (all(c("perceived_norm_cent", "self_control_cent", "opinion_strength_cent") %in% colnames(df_empirical))) {
        log_step("Starting H2 centered model...")
        mlm_model_h2_cent <- lmer(abs_change_t1_t2 ~ (perceived_norm_cent + self_control_cent) * opinion_strength_cent + (1 | id_group_all), data = df_empirical)
        log_step("Finished H2 centered model...")   
    }
}

  # Valence Calculations Introduction
  df_asymmetry_processed <- NULL
  df_valence_processed <- NULL

  if(!is.null(df_directional_agents)) {
      df_valence_processed <- summarize_directional_valence(df_directional_agents)
      df_asymmetry_processed <- compute_valence_asymmetry(df_valence_processed)
  }
}
  
  # ────────────────────────────────────────────────────────────────────────────
  # 2. SENSITIVITY ANALYSIS (LHS ONLY)
  # ────────────────────────────────────────────────────────────────────────────
  pcc_lhs  <- NULL
  prcc_lhs <- NULL
  pcc_all  <- NULL
  prcc_all <- NULL
  df_version_summary <- NULL
  sensi_lhs <- NULL
  sensi_v1 <- NULL
  sensi_v2 <- NULL
  
  if (config$run_type == "LHS") {
    df_batch_sensi <- df_batch |> collect()
    sensi_lhs <- run_sensi_analysis(df_batch_sensi,
                                    param_cols_by_model = param_cols_by_model,
                                    output_cols = output_cols, num_trees = 500)
    pcc_lhs  <- sensi_lhs$pcc
    prcc_lhs <- sensi_lhs$prcc
    rf_lhs <- sensi_lhs$rf
    
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
        sensi_v1 <- run_sensi_analysis(df_lhs_v1, param_cols_by_model, output_cols, num_trees = 500)
        pcc_v1   <- sensi_v1$pcc %>% mutate(version = "v1")
        prcc_v1  <- sensi_v1$prcc %>% mutate(version = "v1")
        rf_v1 <- sensi_v1$rf %>% mutate(version = "v1")
        sensi_v1$rf_mod_list <- sensi_v1$rf_mod_list
      }
      if (nrow(df_lhs_v2) > 0 && !is.null(config$batch$v2$path)) {
        sensi_v2 <- run_sensi_analysis(df_lhs_v2, param_cols_by_model, output_cols, num_trees = 500)
        pcc_v2   <- sensi_v2$pcc %>% mutate(version = "v2")
        prcc_v2  <- sensi_v2$prcc %>% mutate(version = "v2")
        rf_v2 <- sensi_v2$rf %>% mutate(version = "v2")
        sensi_v2$rf_mod_list <- sensi_v2$rf_mod_list
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
  mlm_model_h1a      <- NULL # standardized mlm for H1 with empirical data
  mlm_model_h1b      <- NULL # standardized mlm for H1 with simulated data
  abm_mae_debate     <- NULL
  empirical_beta_val <- NULL
  beta_distance <- NULL
  simulated_betas_raw <- NULL
  
  if (!is.null(df_ag)) { # H1a and H1b implemented 22/7/26 / updated to robust model 24/7/26
    log_step("DEBUG: sucessfully entered df_ag mutation block before lmer calculations")

    df_ag <- df_ag %>% # update on 27/7/26 coerced vars prior to further processing and collect (ensuring agent_id is a char)
      mutate(
          initial_opinion   = as.numeric(initial_opinion),
          final_attitude    = as.numeric(final_attitude),
          current_condition = as.character(current_condition),
          agent_id          = as.character(agent_id),
          debate_label      = as.character(debate_label)
    )
    log_step("OLS vs ABM comparison initial mutation complete, starting df_ag slicing")

    # --- DIAGNOSTIC CHECK ---
    message("\n[DIAGNOSTIC] Starting empirical MLM pipeline...")
    message(sprintf(" -> Initial df_ag rows: %d", nrow(df_ag)))

    if ("current_condition" %in% names(df_ag)) {
      cond_levels <- unique(df_ag$current_condition)
      message(sprintf(" -> Unique 'current_condition' levels (%d): %s", 
                  length(cond_levels), paste(cond_levels, collapse = ", ")))
    } else {
      warning(" -> 'current_condition' column missing from df_ag!")
    }

    if ("debate_label" %in% names(df_ag)) {
      debate_levels <- unique(df_ag$debate_label)
      message(sprintf(" -> Unique 'debate_label' count: %d", length(debate_levels)))
    }
    # ------------------------


    # df_ag_raw_slice base set up to collect prior to H1a/h1b and df_ag_deduped 30/7/26
    # updated 6/8/26 widen df_ag_raw_slice with population parameters and their SDs
    # agent level realised draws, and flags
    ag_slice_cols <- c(
      # identity
      "agent_id", "debate_label", "selected_debate_id", "seed",
      "model_type", "current_condition",
      # design factors
      "current_experiment_id", "speaking_mode", "use_distinct_agents",
      # population parameters
      "convergence_rate", "confidence_threshold", "repulsion_threshold", "repulsion_strength",
      # realised agent draws (differ from above only when distinct)
      "agent_convergence_rate", "agent_confidence_threshold",
      "agent_repulsion_threshold", "agent_repulsion_strength",
      # outcomes
      "initial_opinion", "final_attitude", "opinion", "opinion_change",
      "individual_error", "pro_reduction",
      # flags
      "agent_wrong_direction", "agent_is_saturated", "converged", "convergence_cycle",
      # addition of design cell and param_set_id 24/8/26
      "design_cell", "param_set_id"
    )
    
    df_ag_raw_slice <- df_ag |>
      select(any_of(ag_slice_cols)) |> # any_of so a missing column warns rather than errors
      filter(!is.na(agent_id)) |>
      collect()
      #add_design_cell() # from GA bounds patch logic

    # report what was requested but absent
    # character(0) expected, anything listed here is missing from GAML save list
    setdiff(ag_slice_cols, names(df_ag_raw_slice))

    # Branch A: empirical trajectory (H1a)
    df_ag_base <- df_ag_raw_slice |>
      distinct(agent_id, debate_label, .keep_all = TRUE) # one real T1->T2 per agent/debate

    # Branch B: simulated trajectory (H1b)
    # updated 6/8/26 compute SD first instead of summarizing sequentially
    # corrected grouping by design cell and param_set id
    # sd_opinion_seeds is NA only where n_seeds = 1
    df_sim_base <- df_ag_raw_slice |>
      group_by(agent_id, debate_label, model_type, current_condition, design_cell, param_set_id) |> # 5/8/26 added seed to check
      summarize(
        initial_opinion = first(initial_opinion),
        sd_opinion_seeds = sd(opinion, na.rm = TRUE), # before the mean calc
        n_seeds = n_distinct(seed),
        opinion = mean(opinion, na.rm = TRUE), # collapse across seed ONLY
        .groups = "drop"
      )

    # corrected H1 test
    # Nesting individuals (ID) inside debate groups (ID_Group_all) / use with debate_label in deduped data
    # empirical h1 comparison
    ## empirical long format for mlm
    log_step("starting H1a df creation")
    df_empir_long <- df_ag_base %>%
      filter(!is.na(initial_opinion), !is.na(final_attitude)) %>%
      pivot_longer(
        cols = c(initial_opinion, final_attitude),
        names_to = "Time",
        values_to = "Attitude"
      ) %>%
      mutate(
        Time = factor(if_else(Time == "initial_opinion", "T1", "T2"), levels = c("T1", "T2")),
        Condition = factor(current_condition)
      ) %>%
      filter(!is.na(Attitude), !is.na(Condition))

    # Model H1a: Empirical trajectory
    if (nrow(df_empir_long) > 0) {
      log_step("Finished df creation, now starting H1a mlm...")
      has_multi_debates <- n_distinct(df_empir_long$debate_label, na.rm = TRUE) > 1
    
      mlm_model_h1a <- if (has_multi_debates) {
        lme4::lmer(
          Attitude ~ Condition * Time + (1 | agent_id) + (1 | debate_label), 
          data = df_empir_long,
          control = lmerControl(
            optimizer = "nlminbwrap",
            optCtrl = list(maxfun = 10000)
          )
        )    
      } else {
        write("singular case, defaulting to basic lmer")
        lme4::lmer(
          Attitude ~ Condition * Time + (1 | agent_id), 
          data = df_empir_long
        )
      }
    }

    # H3 shared set up (base model) 24/8/26
    mlm_bench_h3 <- lme4::lmer(final_attitude ~ initial_opinion + (1 | debate_label),
                               data = df_ag_base)

    # validation frame set up takes empirical rows, predict and compute error 21/8/26
    if (!is.null(df$sim_val)) {
      log_step("H3 benchmark: building test frame from sim_val$df_ag")
    
      df_empir_test <- df$sim_val$df_ag %>%
        collect() %>%
        distinct(agent_id, debate_label, .keep_all = TRUE) %>%
        mutate(Condition = factor(current_condition),
               Time = factor("T2", levels = c("T1", "T2")),
               Attitude = final_attitude)

      log_step(paste("test_frame:", nrow(df_empir_test), "rows,",
                     n_distinct(df_empir_test$debate_label), "debates"))

      log_step(paste("columns:", paste(colnames(df_empir_test), collapse = ", ")))

      df_empir_test$mlm_pred <- predict(mlm_bench_h3, newdata = df_empir_test,
                                        allow.new.levels = TRUE)
      df_empir_test$mlm_error <- abs(df_empir_test$final_attitude - df_empir_test$mlm_pred)


      log_step(paste("mlm_bench_h3 fixed effects:", 
               paste(names(fixef(mlm_bench_h3)), round(fixef(mlm_bench_h3), 4), 
                     sep = "=", collapse = ", ")))
        log_step(paste("mlm_pred range:", 
                       round(min(df_empir_test$mlm_pred, na.rm = TRUE), 4), "to",
                       round(max(df_empir_test$mlm_pred, na.rm = TRUE), 4)))
        log_step(paste("initial_opinion range in test:",
                       round(min(df_empir_test$initial_opinion, na.rm = TRUE), 4), "to",
                       round(max(df_empir_test$initial_opinion, na.rm = TRUE), 4)))
        log_step(paste("final_attitude range in test:",
                       round(min(df_empir_test$final_attitude, na.rm = TRUE), 4), "to",
                       round(max(df_empir_test$final_attitude, na.rm = TRUE), 4)))

      log_step(paste("mlm_error summary — mean:", round(mean(df_empir_test$mlm_error, na.rm = TRUE), 4),
                 "range:", round(min(df_empir_test$mlm_error, na.rm = TRUE), 4), 
                 "to", round(max(df_empir_test$mlm_error, na.rm = TRUE), 4),
                 "NAs:", sum(is.na(df_empir_test$mlm_error))))
    } else {
      log_step("H3 benchmark: no sim_val supplied, skipping test frame construction")
      df_empir_test <- NULL
    }

    # MLM H1b test with simulated opinions for T2
    ## H1b long data frame
    mlm_model_h1b_list <- list()
    for (mt in unique(df_sim_base$model_type)) {
    log_step("H1b df setup starting...") 
    df_sim_long <- df_sim_base %>%
      filter(model_type == mt, !is.na(initial_opinion), !is.na(opinion), !is.na(agent_id)) %>%
      pivot_longer(
        cols = c(initial_opinion, opinion),
        names_to = "Time",
        values_to = "Attitude"
      ) %>%
      mutate(
        Time = factor(if_else(Time == "initial_opinion", "T1", "T2"), levels = c("T1", "T2")),
        Condition = factor(current_condition)
      ) %>%
      filter(!is.na(Attitude), !is.na(Condition))

    # Model H1b: Simulated trajectory
    if (nrow(df_sim_long) > 0) {
      log_step("Finished H1b df setup, starting mlm...")
      has_multi_debates_sim <- n_distinct(df_sim_long$debate_label, na.rm = TRUE) > 1
    
      mlm_model_h1b_list[[mt]] <- if (has_multi_debates_sim) {
        lme4::lmer(
          Attitude ~ Condition * Time + (1 | agent_id) + (1 | debate_label), 
          data = df_sim_long,
            control = lmerControl(
            optimizer = "nlminbwrap",
            optCtrl = list(maxfun = 10000)
          )
        )
      } else {
        write(paste("model_type", mt, ": single debate, defaulting to basic regression"))
        mlm_model_h1b_list[[mt]] <- lme4::lmer(
          Attitude ~ Condition * Time + (1 | agent_id), 
          data = df_sim_long,
          control = lmerControl(
            optimizer = "nlminbwrap",
            optCtrl = list(maxfun = 10000)
          )
        )
        }
      }
    }

    # H3a set up 24/8/26
    df_h3a <- df$sim_val$df_ag %>%
      collect() %>%
      distinct(agent_id, selected_debate_id, seed, model_type, .keep_all = TRUE) %>%
      mutate(abm_error = abs(final_attitude - opinion)) %>%
      left_join(df_empir_test %>% select(agent_id, debate_label, mlm_error), by = c("debate_label", "agent_id")) %>%
      mutate(model_type = relevel(factor(model_type), ref = "no_change"))

    log_step("Set up H3a df and starting lmer call...")
    mlm_h3a <- lme4::lmer(abm_error ~ model_type + ( 1 | debate_label),
                         data = df_h3a)

    # write results to file
    write_result("\n### H3a - Individual Level (Held out debates)")
    write_result(paste(" mode:", deparse(formula(mlm_h3a))))
    write_result(paste("n_obs:", nobs(mlm_h3a), " | n_debates:",
                       summary(mlm_h3a)$ngrps))

    coefs <- summary(mlm_h3a)$coefficients
      for (i in seq_len(nrow(coefs))) {
        write_result(sprintf("  %s: est=%.5f se=%.5f t=%.3f",
                             rownames(coefs)[i], coefs[i,1], coefs[i,2], coefs[i,3]))
    }

    vc <- as.data.frame(VarCorr(mlm_h3a))
    write_result(paste(" debate-level variance:", round(vc$vcov[1], 6)))
    write_result(paste(" residual variance:", round(vc$vcov[2], 6)))

    ci <- confint(mlm_h3a, parm = "beta_", method = "Wald")
    for (i in seq_len(nrow(ci))) {
      write_result(sprintf(" %s: 95%% CI [%.5f %.5f]",
                           rownames(ci)[i], ci[i,1], ci[i,2]))
    }
    write_result("Decision: H3a NOT SUPPORTED - no model improves/beats the no_change baseline")
      
    # H3b set up 24/8/26
    write_result("\n### H3b - Debate Level (Held out debates)")
    write_result(paste(" mode:", deparse(formula(mlm_h3a))))
    df_h3b <- df$sim_val$df_batch %>%
      group_by(design_cell, debate_label, model_type) %>%
      summarize(abm_mae = mean(mae, na.rm = TRUE), .groups = "drop")

    # mlm debate level mae set up
    mlm_debate_mae <- df_empir_test %>%
      group_by(debate_label) %>%
      summarize(mlm_mae = mean(mlm_error, na.rm = TRUE), .groups = "drop")

    # No change mae extraction prior ot left_join
    nc_mae <- df_h3b %>%
      filter(model_type == "no_change") %>%
      select(debate_label, nc_mae = abm_mae)
    
    # join on debate_label to perform sign tests
    df_h3b <- df_h3b %>%
      filter(model_type != "no_change") %>%
      left_join(nc_mae, by = "debate_label") %>%
      left_join(mlm_debate_mae, by = "debate_label")

    # two sided sign tests set up
    ## ABM < NC across 12 debates
    abm_vs_nc <- df_h3b %>%
      group_by(design_cell) %>%
      summarize(
        wins = sum(abm_mae < nc_mae, na.rm = TRUE),
        n = n(),
        mean_diff = mean(abm_mae - nc_mae,na.rm = TRUE),
        p = binom.test(wins, n, 0.5)$p.value,
        .groups = "drop")

    ## ABM < MLM MAE across 12 debates
    abm_vs_mlm <- df_h3b %>%
      group_by(design_cell) %>%
      summarize(
        wins = sum(abm_mae < mlm_mae, na.rm = TRUE),
        n = n(),
        mean_diff = mean(abm_mae - mlm_mae, na.rm = TRUE),
        p = binom.test(wins, n, 0.5)$p.value,
        .groups = "drop")
          
    # Results log to .txt 24/8/26
    write_result("\n ABM vs No-Change Across Held-out Debates")
    #write_result(" Models with the most wins:", abm_vs_nc$wins %>% sort(as.character(abm_vs_nc$wins, decreasing = TRUE)))


#     H3b — debate level:
#   - From df$sim_val$df_batch: mean MAE per (design_cell, debate_label)
#   - From df_empir_test: mean mlm_error per debate_label
#   - From no_change rows in df$sim_val$df_batch: MAE per debate_label
#   - Join all three on debate_label
#   - Per design cell: sign test on ABM_MAE < NC_MAE across 12 debates
#   - Per design cell: sign test on ABM_MAE < MLM_MAE across 12 debates
#   - Output: table with wins, mean differences, p-values

# H5 — global level:
#   - Filter df$sim_val$df_ag to primary cell only
#     (use_distinct_agents = TRUE, speaking_mode = TRUE) per model_type
#   - abm_pooled_mae per model_type = mean(individual_error)
#   - mlm_pooled_mae = mean(df_empir_test$mlm_error)
#   - Table: one row per model_type, abm vs mlm, difference
#   - Decision: supported if abm_pooled_mae < mlm_pooled_mae

    # Error Benchmarks (MAE) only deduped here because we want one row of empirical agent data

    # Branch C: MAE / OLS/ABM Comparison 
    log_step("Starting branch C df setups, ols vs abm...")

    # update 6/8/26 added best_param_cell to find best mae within each cell (not which sorted first)
    best_param_by_cell <- df_batch %>%
      filter(model_type != "no_change") %>%
      group_by(design_cell, param_set_id) %>%
      summarize(mean_mae = mean(mae, na.rm = TRUE), .groups = "drop_last") %>%
      slice_min(mean_mae, n = 1, with_ties = FALSE) %>%
      ungroup() %>%
      select(design_cell, param_set_id, mean_mae)
      
    df_ag_deduped <- df_ag_raw_slice %>%
      semi_join(best_param_by_cell, by = c("design_cell", "param_set_id")) %>%
      distinct(agent_id, selected_debate_id, seed, design_cell, .keep_all = TRUE)

    if (!is.null(mlm_model_h1a)) {
        df_t2_preds <- df_empir_long %>%
          filter(Time == "T2") %>%
          mutate(ols_pred = predict(mlm_model_h1a, newdata = ., allow.new.levels = TRUE))
    
        df_ag_ols <- df_ag_deduped %>%
          left_join(df_t2_preds %>% select(agent_id, ols_pred), by = "agent_id") %>%
          mutate(ols_error = abs(final_attitude - ols_pred))
    
        ols_global_mae <- mean(df_ag_ols$ols_error, na.rm = TRUE)
        
        ols_mae_debate <- df_ag_ols %>%
          group_by(selected_debate_id, debate_label) %>%
          summarize(ols_mae = mean(ols_error, na.rm = TRUE), .groups = "drop")
    
        # ABM simulation MAE summary update 6/8/26
        # take baseline out of treatment, added cell in the grain
        abm_mae_debate <- df_batch %>%
          filter(model_type != "no_change") %>%
          add_design_cell() %>%
          group_by(design_cell, selected_debate_id) %>%  
          summarize(
            abm_mae = mean(mae, na.rm = TRUE),
            abm_mae_min = min(mae, na.rm = TRUE),
            debate_label = first(debate_label),
            n_param_sets = n_distinct(param_set_id),
            .groups = "drop"
          ) %>%
          collect()
    
        # merge MAE scores for comparison
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
    }
    
    
    # beta distance check 3/6/26 check distribution of empirical beta compared with simulations
    # comprehensive update with MLM and checks 22/7/26
    if (!is.null(empir_cohen)) {
      log_step("finished ols vs abm delta_mae calculations, starting empirical and simulated betas...")
      
      # ensure empir is treated as a single numeric value
      empirical_beta_scalar <- as.numeric(empir_cohen$std_estimate[1])
      
      # compute simualted beta distribution per model type across pooled runs / removed no change given that opinion_change is zero
      simulated_betas_raw <- df_ag_deduped %>%
        filter(model_type != "no_change") %>%
        group_by(model_type, selected_debate_id, seed) %>% # TODO check whether removed logged_batch for testing
        do({
        dat_sim <- .

        # defensive chekc for sample size and non-zero variance for x and y
        has_var_y <- !is.na(sd(dat_sim$opinion_change, na.rm = TRUE)) && sd(dat_sim$opinion_change, na.rm = TRUE) > 0
        has_var_x <- !is.na(sd(dat_sim$pro_reduction, na.rm = TRUE)) && sd(dat_sim$pro_reduction, na.rm = TRUE) > 0

        if (nrow(dat_sim) >= 2 && has_var_y && has_var_x) {
            dat_sim$opinion_change_z <- as.numeric(scale(dat_sim$opinion_change))
            dat_sim$pro_reduction_z  <- as.numeric(scale(dat_sim$pro_reduction))
            
            fit_sim <- lm(
              opinion_change_z ~ pro_reduction_z, 
              data = dat_sim)
            beta_est <- coef(fit_sim)[["pro_reduction_z"]]
        } else {
            beta_est <- NA_real_ # assign NA for static/stalled runs
        }
            
        data.frame(
          term         = "pro_reduction",
          std_estimate = beta_est
        )
      }) %>%
      filter(!is.na(std_estimate)) %>%
      ungroup()
        
    # safe distance Z score calculation across param sweeps
    if (nrow(simulated_betas_raw) > 0 && "std_estimate" %in% colnames(simulated_betas_raw)) {
        beta_distance <- simulated_betas_raw %>%
        group_by(model_type) %>%
        summarize(
          mean_simulated_beta = mean(std_estimate, na.rm = TRUE), # added std pull to ensure comparison of standardized estimates 13/7/26
          sd_simulated_beta = sd(std_estimate, na.rm = TRUE),
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
}
  
  # ────────────────────────────────────────────────────────────────────────────
  # 4. BEHAVIORAL EXTRACTIONS (COMPOSITION & SPEAKING MODES)
  # ────────────────────────────────────────────────────────────────────────────
  h_vs_m <- df_batch %>%
    group_by(debate_composition, model_type, speaking_mode, use_distinct_agents) %>%
    summarize(mae_mean = mean(mae, na.rm = TRUE), mae_sd = sd(mae, na.rm = TRUE), n = n(), .groups = "drop")
  
  speaking_compar <- df_batch %>%
    group_by(speaking_mode, debate_composition, model_type, use_distinct_agents) %>%
    summarize(
      mae_mean = mean(mae),
      mae_sd = sd(mae),
      mean_norm_convergence = mean(normalised_convergence),
      n = n(),
      .groups = "drop"
    )

  # safe wilcoxon evaluation
  df_speaking_clean <- df_batch %>%
    filter(!is.na(convergence_cycle), !is.na(speaking_mode)) %>%
    mutate(speaking_mode = factor(speaking_mode))

  if (n_distinct(df_speaking_clean$speaking_mode) == 2) {
    speakingmode_vs_convergence_wilcox <- wilcox.test(convergence_cycle ~ speaking_mode, data = df_speaking_clean)
  } else {
    message("Skipping wilcox.test: speaking_mode does not have exactly 2 valid levels in complete cases.")
    speakingmode_vs_convergence_wilcox <- NULL
  }
  
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
    ) %>%
    { message("DEBUG - df_conv_debate speaking_mode table:"); print(table(.$speaking_mode, useNA = "always")); . } %>%
    { message("DEBUG - complete cases count:"); print(nrow(na.omit(.))); . }
  
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
    group_by(design_cell, param_set_id, selected_debate_id) %>%
    summarize(mae_sd = sd(mae, na.rm = TRUE), n_seeds = n_distinct(seed), .groups = "drop")
  
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

  # modification to estblish relative baseline 6/8/26
  baseline_by_debate <- df_batch %>%
    filter(model_type != "no_change") %>%
    group_by(selected_debate_id) %>%
    summarize(baseline_mae = mean(mae, na.rm = TRUE), .groups = "drop")

  # failure means the model did worse than assuming nothign changed 6/8/26
  failures_comp <- df_batch %>%
    filter(model_type != "no_change") %>%
    left_join(baseline_by_debate, by = "selected_debate_id") %>%
    mutate(failures = mae > baseline_mae) %>%
    group_by(design_cell, model_type, failures) %>%
    summarize(mean_convergence_cycle = mean(convergence_cycle, na.rm = TRUE), 
              pct_converged = mean(converged, na.rm = TRUE), 
              n_total = n(), 
              .groups = "drop")
  
  clusters <- NULL
    clusters <- df_batch %>%
      mutate(
          num_clusters = if ("num_clusters" %in% names(.)) as.numeric(num_clusters) else NA_real_,
          initial_num_clusters = if ("initial_num_clusters" %in% names(.)) as.numeric(initial_num_clusters) else NA_real_,
          cluster_change = case_when(
      model_type == "consensus" ~ 0,
      is.na(num_clusters) | is.na(initial_num_clusters) ~ 0,
      TRUE ~ num_clusters - initial_num_clusters)) %>%
      group_by(model_type, selected_debate_id) %>%
      summarize(mean_cluster_change = mean(cluster_change), .groups = "drop")

# TODO Request GLPK package for RcppParallel for Network analysis
  # # ────────────────────────────────────────────────────────────────────────────
  # # 7. NETWORK PIPELINE (SAFETY GUARDED)
  # # ────────────────────────────────────────────────────────────────────────────
  # network_data_package        <- NULL
  # graphs_edge_filter          <- NULL
  # homogeneous_plots_combined  <- NULL
  # heterogeneous_plots_combined <- NULL
  # network_plot_combined       <- NULL
  
  # if (!is.null(df_interactions) && !is.null(df_ag)) {
  #   network_outputs <- build_influence_network(df_interactions, df_ag)
  #   network_outputs$graphs <- map(network_outputs$graphs, enrich_graph_vertices, network_outputs$aggregate)
    
  #   graphs_top_nodes <- map(network_outputs$graphs, filter_top_nodes, top_n = 10)
    
  #   graphs_edge_filter <- map(network_outputs$graphs, function(g) { 
  #     threshold <- quantile(E(g)$edge_weight, 0.75, na.rm = TRUE)
  #     filter_edges(g, threshold)
  #   })
    
  #   edge_plots <- imap(graphs_edge_filter, function(g, name) build_network_graph(g) + labs(title = name))
    
  #   homo_keys  <- intersect(names(graphs_edge_filter), c("homogeneous_consensus", "homogeneous_clustering", "homogeneous_bipolarization"))
  #   hetero_keys <- intersect(names(graphs_edge_filter), c("heterogeneous_consensus", "heterogeneous_clustering", "heterogeneous_bipolarization"))
    
  #   if (length(homo_keys) == 3) {
  #     homogeneous_plots <- imap(graphs_edge_filter[homo_keys], function(g, name) build_network_graph(g) + labs(title = name))
  #     homogeneous_plots_combined <- wrap_plots(homogeneous_plots, ncol = 3)
  #   }
  #   if (length(hetero_keys) == 3) {
  #     heterogeneous_plots <- imap(graphs_edge_filter[hetero_keys], function(g, name) build_network_graph(g) + labs(title = name))
  #     heterogeneous_plots_combined <- wrap_plots(heterogeneous_plots, ncol = 3)
  #   }
  #   network_plot_combined <- wrap_plots(edge_plots, ncol = 1)
    
  #   network_data_package <- list(
  #     per_debate = network_outputs$per_debate,
  #     aggregate  = network_outputs$aggregate,
  #     graphs     = network_outputs$graphs
  #   )
  # }
  
  # ────────────────────────────────────────────────────────────────────────────
  # 8. GA BOUNDS EXTRACTION (ONLY RUN ON LHS SWEEPS)
  # ────────────────────────────────────────────────────────────────────────────
  ga_bounds_export <- NULL
  if (config$run_type == "LHS") {
    message("Notice: GAML GA bounds extraction started")
    lhs_regions <- param_region_extraction(df_batch, percentile = 0.25)
    gaml_ga <- generate_gaml_bounds(lhs_regions$regions)
    print(head(gaml_ga))

    # safe write guard to characters
    if (!is.null(gaml_ga) && length(gaml_ga) > 0) {
      writeLines(gaml_ga, "gaml_GA_bounds.txt")
    } else {
      message("skipping GAML bounds file export: gaml_ga is empty.")
    }
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
        combined = list(pcc = pcc_lhs, prcc = prcc_lhs, rf = sensi_lhs$rf, rf_models = sensi_lhs$rf_mod_list),
        v1       = if(!is.null(sensi_v1)) list(pcc = sensi_v1$pcc, prcc = sensi_v1$prcc, rf = sensi_v1$rf, rf_models = sensi_v1$rf_mod_list) else NULL,
        v2       = if(!is.null(sensi_v2)) list(pcc = sensi_v2$pcc, prcc = sensi_v2$prcc, rf = sensi_v2$rf, rf_models = sensi_v2$rf_mod_list) else NULL
      ),
      models = list(conv = run_conv_model(df_conv_debate), 
                    mlm_h1a = mlm_model_h1a, # deduplicated H1a (empirical) test
                    mlm_h1b = mlm_model_h1b, # deduplicated H1b (simualted) test
                    mlm_h2 = mlm_model_h2, # integrated H2 test with perceived_norms and self_control
                    mlm_h2_cent = mlm_model_h2_cent # H2 with centered values (corrects for variable inflation factors)
                   ),
      comparisons = list(
        wilcox_h_m      = wilcox_h_vs_m,
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
        upset_prep = df_upset,
        df_ols_agent_data = df_ag_deduped
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
      regions  = ga_bounds_export
      #networks = network_data_package TODO commented out because interactions took too long to compile 3/8/26
    ),
    plots = list(
      pcc        = function() {
        pcc <- sensi_lhs$pcc
        plot_pcc_heatmap(pcc)},
      prcc       = function(){
        prcc <- sensi_lhs$prcc
        plot_prcc_heatmap(prcc)},
      pcc_all    = function() plot_pcc_all_heatmap(pcc_all),
      prcc_all   = function() plot_prcc_all_heatmap(prcc_all),
      abm_vs_ols = function() {
          comparison_clean <- lhs_outputs$results$comparisons$ols_debate_mae
          plot_ols_abm_comp(comparison_clean)},
      empirical_col   = function() plot_empir_compar(empirical_stat_check),
      empirical_cross = function() plot_empir_cross(empirical_stat_pivot),

      # OLS models viz empir and sim
      mlm_h1a_viz = function() check_model(mlm_model_h1a, check = c("linearity", "homogeneity", "vif", "qq", "reqq", "outliers")),
      mlm_h1b_viz = function() check_model(mlm_model_h1b, check = c("linearity", "homogeneity", "vif", "qq", "reqq", "outliers")),
      mlm_h2_viz = function() check_model(mlm_model_h2, check = c("linearity", "homogeneity", "vif", "qq", "reqq", "outliers")),
      mlm_h2_cent_viz = function() check_model(mlm_model_h2_cent, check = c("linearity", "homogeneity", "vif", "qq", "reqq", "outliers")),
      
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

      # RF visualizations
      rf_importance_model_types = function(output_filter = NULL) {
        df <- sensi_lhs$rf
        if (!is.null(output_filter)) df <- df %>% filter(output == output_filter)
        plot_rf_importance(df)
      },
      pdp_v1 = function(model_type_val, distinct_val, output, feature_name) {
        plot_model_pdp(
          sensi_lhs,
          df_batch,
          model_type_val, distinct_val, output, feature_name
        )
      }
      #homogeneous_network_plots   = homogeneous_plots_combined, TODO commented out because interactions too long 8/3/26
      #heterogeneous_network_plots = heterogeneous_plots_combined
    )
  )
  
  return(analysis_output_package)
}