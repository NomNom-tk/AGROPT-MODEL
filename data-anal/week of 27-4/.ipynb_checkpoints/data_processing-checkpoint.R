# data processing script

# functions source before proper integration
source("./functions.R")

# package imports
#library(rvg)
#library(officer)
#library(flextable)
#library(tidygraph)
#library(igraph)
#library(ggraph)
#library(DT)
library(lme4)
library(lmerTest)
library(janitor)
library(patchwork)
library(plotly)
library(ComplexUpset)
library(arrow) # write parquet files to circumvent data sizes 27/7/26
library(tidyverse)
library(duckplyr)

# to namespace
library(broom)
#library(lm.beta)

# run config declarations
## TODO 1/6/26, consider refactoring to different layers, makes run_type agnostic of the rest
## and allows for more variable inputs without breaking downstream analyses
run_configs <- list()
lhs <- list()
ga <- list()

# ==========================================
# 2. BUILD THE LHS CONFIGURATION
# ==========================================
lhs$run_type          <- "LHS"
lhs$composition_scope <- "ALL"
lhs$version_scope     <- "v1"

lhs$batch$v1$path     <- "./data/lhs_batch_summary.csv"
lhs$batch$v1$version  <- "v1_7_5_100c"

lhs$batch$v2$path     <- NULL
lhs$batch$v2$version  <- "v2_30-4_dyn"

lhs$agent$v1$path     <- "./data/lhs_agent_level_results.csv"
lhs$agent$v2          <- NULL

lhs$interaction$v1$path <- "./data/lhs_interaction_log.csv"
lhs$interaction$v2      <- NULL

# ==========================================
# 3. BUILD THE GA CONFIGURATION
# ==========================================
ga$run_type          <- "GA"
ga$composition_scope <- "M"
ga$version_scope     <- "v1"

ga$batch$v1$path     <- "./data/ga_batch_summary.csv"
ga$batch$v1$version  <- "ga_v1"

ga$agent$v1$path     <- "./data/ga_agent_level_results.csv"
ga$interaction$v1$path <- "./data/ga_interaction_log.csv"

# ==========================================
# 4. ASSIGN TO MASTER CONTAINER
# ==========================================
run_configs$lhs_main <- lhs
run_configs$ga_main  <- ga

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
  # BATCH LEVEL
  # load via load_and_prepare (prepare_data + append_metadata + composition_filter)
  # if LHS and version_scope == "both": load v1 and v2, combine into versions
  # if LHS and version_scope != "both": load single version
  # if GA/PSO: load single file, no versions combination
  # canonical output: df_batch (and lhs_versions if LHS + both)
  
  # Batch loading with safety guard
  ## look at path sub-list
  if (config$version_scope == "both") {
    # 1. Extract data frames safely ONLY if paths exist
    df_v1 <- if(!is.null(config$batch$v1$path)) load_and_prepare(config$batch$v1$path, config, config$batch$v1$version) else NULL
    df_v2 <- if(!is.null(config$batch$v2$path)) load_and_prepare(config$batch$v2$path, config, config$batch$v2$version) else NULL
    
    # 2. Assign outputs conditionally based on what loaded successfully
    if (!is.null(df_v1) && !is.null(df_v2)) {
      df_batch <- df_v2
      lhs_versions <- combine_df_versions(
        list(df_v1, df_v2), 
        c(config$batch$v1$version, config$batch$v2$version)
      )
    } else {
      df_batch <- if (!is.null(df_v2)) df_v2 else df_v1
      lhs_versions <- NULL
    }
    
  } else { # fixed fallback to v1 bug with version_scope == v2 15/7/26
    target_path    <- if (config$version_scope == "v2" && !is.null(config$batch$v2$path)) {
        config$batch$v2$path
    } else {
        if (config$version_scope == "v2") {
          message("batch$v2$path is NULL for version_scope = v2 - falling back to batch$v1$path")
        }
        config$batch$v1$path
    }
    target_version <- if (config$version_scope == "v2" && !is.null(config$batch$v2$path)) {
        config$batch$v2$version
    } else {
        config$batch$v1$version
    }
    
    df_batch     <- if (!is.null(target_path)) load_and_prepare(target_path, config, target_version) else NULL
    lhs_versions <- NULL
  }
  
  # AGent level loading
  if (config$version_scope == "v2" && !is.null(config$agent$v2$path)) {
    target_agent_path = config$agent$v2$path
  } else {
    target_agent_path = config$agent$v1$path
  }

  log_step("Starting Agent Loading Block")
  df_ag = load_and_prepare(target_agent_path, config)
  
  # INTERACTION LEVEL
  # prepare_interactions + left_join pro_reduction from df_ag
  # derive df_influence and df_susceptibility
  # canonical output: df_interactions, df_influence, df_susceptibility
  # if (config$version_scope == "v2" && !is.null(config$interaction$v2$path)) {
  #   target_int_path = config$interaction$v2$path
  # } else {
  #   message("INTREACTION NOTICE: path exists and we testing interaciton loading")
  #   target_int_path = config$interaction$v1$path
  # }
  
  # declare nulls before guard
  df_interactions <- NULL
  df_influence <- NULL
  df_susceptibility <- NULL
  
  # guard to execute if file exists
  # if (!is.null(target_int_path) && file.exists(target_int_path)) {
  #   df_interactions <- prepare_interactions(target_int_path)

  #     # lazy check for rows in df_interactions, to avoid full loading into RAM
  #     has_rows <- df_interactions |> head(2) |> collect() |> nrow() > 0
      
  #     # guard 2 execute join and summary metric only if data rows exist
  #     if (!is.null(df_interactions) && has_rows) {
          
  #           if (!is.null(df_ag)) {
              
  #             # 1. standardize RHS join table columns
  #             # join key must be 1 row per agent (pro_reduction is a fixed empirical trait, not run-varying)
  #             # — prevents join fan-out on receiver_id; assumes no data-quality dupes via count(agent_id) %>% filter(n>1)
  #             df_ag_clean <- df_ag %>%
  #               select(agent_id, pro_reduction) %>%
  #               group_by(agent_id) %>% 
  #               summarize(pro_reduction = first(pro_reduction), .groups = "drop") %>% # guarantees 1 row/agent, prevents join fan-out
  #               mutate(agent_id = as.character(agent_id))
              
  #             # 2. standardize LHS join table and execute safe merge
  #             df_interactions <- df_interactions %>%
  #               mutate(receiver_id = as.character(receiver_id)) %>%
  #               left_join(df_ag_clean, by = c("receiver_id" = "agent_id")) %>%
  #               filter(!is.na(pro_reduction)) # 11/6/26 filter out rows where pro_reduc is not matched by receiver_id
  #           }
  #           df_susceptibility = compute_susceptibility_scores(df_interactions) %>% collect()
  #           df_influence = compute_influence_scores(df_interactions) %>% collect()
  #           message("Notice: interactions succeeded, moving on to empirical")
  #     } else {
  #       message("Notice: Interaction file exists but contains 0 data rows. Skipping susceptibility and influence metrics.")
  #     }
  # }

  # # EMPIRICAL
  # empirical_prep — same path regardless of run_type
  # canonical output: df_empirical
  # df_empirical <- NULL
  # empirical_path <- "./data/data_complete_anonymised.csv"
  # if (file.exists(empirical_path)) {
  #   df_empirical <- empirical_prep(empirical_path)
  # }
  
  # DERIVED (first written 29/4/26)
  # prepare_directional + summarize_directional from df_ag
  # canonical output: df_directional_agents, df_directional
  df_directional_agents <- NULL
  df_directional <- NULL
  
  if (!is.null(df_ag)) {
    log_step("Starting Directional dfs, unsummarized")
    df_directional_agents <- prepare_directional(df_ag) # unsummarized directional
    log_step("Starting summarized Directional df")
    df_directional <- summarize_directional(df_directional_agents) # summarized version
  }

  # Valence/Signed error (30/6/26)
  # derive from df_directional_agents - split by pro_reduction, compute signed error
  # output: df_valence
  # df_valence <- NULL
  df_sum_directional_valence <- NULL
  df_valence <- NULL
  df_upset <- NULL
  if (!is.null(df_directional_agents)) {
      log_step("Starting Valence Analysis Chunk: summarized valence for models first")
      df_sum_directional_valence <- summarize_directional_valence(df_directional_agents) # summarize directional valence for models
      df_valence <- compute_valence_asymmetry(df_sum_directional_valence) # valence df with additional valence metrics
  }

  if (!is.null(df_sum_directional_valence)) {
    log_step("Upset df calculation starting...")
    df_upset <- df_sum_directional_valence %>% # added 6/7/26 for upset plots
      group_by(design_cell, selected_debate_id, model_type) %>%
      summarize(pct_correct_dir = mean(pct_correct_dir), .groups = "drop") %>%
      pivot_wider(names_from = model_type, values_from = pct_correct_dir)

  # guard ensuring expected target columns exist as numeric vectors if missing from df
  for (col in c("bipolarization", "consensus", "clustering")) {
    if (!col %in% colnames(df_upset)) {
      df_upset[[col]] <- NA_real_
    }
  }
     
  df_upset <- df_upset %>%
    mutate(
        bipol_correct = bipolarization > 0.5,
        clust_correct = clustering > 0.5,
        cons_correct = consensus > 0.5) 
      
  #guard to safely join df_valence only if it exists and is non empty
  # update 6/8/26 widen asymmetries per model
  if (!is.null(df_valence) && nrow(df_valence) > 0) {
    valence_wide <- df_valence %>%
    group_by(selected_debate_id, model_type) %>%
    summarize(accuracy_asymmetry = mean(accuracy_asymmetry, na.rm = TRUE),
              error_asymmetry = mean(error_asymmetry, na.rm = TRUE),
              .groups = "drop") %>%
    pivot_wider(names_from = model_type,
                values_from = c(accuracy_asymmetry, error_asymmetry))
  stopifnot(!any(duplicated(valence_wide$selected_debate_id))) # guard

      
    df_upset <- df_upset %>%
    left_join(
        valence_wide,
        by = c("design_cell", "selected_debate_id")) 
  } else {
    df_upset <- df_upset %>%
      mutate(across(paste0("accuracy_asymmetry_", c("bipolarization","clustering","consensus")),
                  ~ NA_real_))
  }

  # compute bias flags safely
  log_step("Bias flag computation for df_valence starting")
  df_upset <- df_upset %>%
    mutate(across(starts_with("accuracy_asymmetry_"), ~ .x > 0,
                  .names = "pro_{.col}"),
           across(starts_with("accuracy_asymmetry_"), ~ .x < 0,
                  .names = "anti_{.col}"))
    
  # RETURN LIST with consistent slot names regardless of run_type
  list(
    config                = config,
    df_batch              = df_batch,
    lhs_versions          = if (config$run_type == "LHS" && config$version_scope == "both") lhs_versions else NULL,
    df_ag                 = df_ag,
    df_interactions       = df_interactions,
    df_influence          = df_influence,
    df_susceptibility     = df_susceptibility,
    # df_empirical          = df_empirical,
    df_directional        = df_directional,
    df_directional_agents = df_directional_agents,
    df_valence            = df_valence,
    df_sum_directional_valence = df_sum_directional_valence,
    df_upset              = df_upset
  ) 
}

# lists declaration for lm and sensitivity analyses
## define input columns
param_cols_by_model <- list(
  consensus_FALSE = c("convergence_rate"),
  consensus_TRUE = c("convergence_rate", "convergence_rate_sd"),
  clustering_FALSE = c("convergence_rate", "confidence_threshold"),
  clustering_TRUE = c("convergence_rate", "confidence_threshold",
                      "convergence_rate_sd", "confidence_threshold_sd"),
  bipolarization_FALSE = c("convergence_rate", "confidence_threshold", "repulsion_strength", "repulsion_threshold"),
  bipolarization_TRUE = c("convergence_rate", "confidence_threshold", "repulsion_strength", "repulsion_threshold",
                          "convergence_rate_sd", "confidence_threshold_sd", "repulsion_strength_sd", "repulsion_threshold_sd")
)

# define output columns
output_cols <- c("mae", "opinion_variance", "convergence_cycle")
