# data processing script

# functions source before proper integration
source("./functions.R")

# package imports
library(tidyverse)
library(rvg)
library(broom)
library(officer)
library(flextable)
library(sensitivity)
library(lm.beta)
library(igraph)
library(ggraph)
library(janitor)
library(tidygraph)
library(patchwork)

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
lhs$composition_scope <- "M"
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

# Instantiate processing 28/5/26
## update 2/6/26, easier loading based on config update
## update 30/6/26 added valence metrics
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
    
  } else {
    target_path    <- if (config$version_scope == "v1") config$batch$v1$path else config$batch$v2$path
    target_version <- if (config$version_scope == "v1") config$batch$v1$version else config$batch$v2$version
    
    df_batch     <- if (!is.null(target_path)) load_and_prepare(target_path, config, target_version) else NULL
    lhs_versions <- NULL
  }
  
  # AGent level loading
  if (config$version_scope == "v2" && !is.null(config$agent$v2$path)) {
    target_agent_path = config$agent$v2$path
  } else {
    target_agent_path = config$agent$v1$path
  }
  df_ag = load_and_prepare(target_agent_path, config)
  
  # INTERACTION LEVEL
  # prepare_interactions + left_join pro_reduction from df_ag
  # derive df_influence and df_susceptibility
  # canonical output: df_interactions, df_influence, df_susceptibility
  if (config$version_scope == "v2" && !is.null(config$interaction$v2$path)) {
    target_int_path = config$interaction$v2$path
  } else {
    target_int_path = config$interaction$v1$path
  }
  
  # declare nulls before guard
  df_interactions <- NULL
  df_influence <- NULL
  df_susceptibility <- NULL
  
  # guard to execute if file exists
  if (!is.null(target_int_path) && file.exists(target_int_path)) {
    df_interactions <- prepare_interactions(target_int_path)
    
    if (!is.null(df_ag)) {
      
      # 1. standardize RHS join table columns
      df_ag_clean <- df_ag %>%
        select(agent_id, pro_reduction) %>%
        distinct() %>%
        mutate(agent_id = as.character(agent_id))
      
      # 2. standardize LHS join table and execute safe merge
      df_interactions <- df_interactions %>%
        mutate(receiver_id = as.character(receiver_id)) %>%
        left_join(df_ag_clean, by = c("receiver_id" = "agent_id")) %>%
        filter(!is.na(pro_reduction)) # 11/6/26 filter out rows where pro_reduc is not matched by receiver_id
    }
    df_susceptibility = compute_susceptibility_scores(df_interactions)
    df_influence = compute_influence_scores(df_interactions)
  }

  # # EMPIRICAL
  # empirical_prep — same path regardless of run_type
  # canonical output: df_empirical
  df_empirical <- NULL
  empirical_path <- "./data/data_complete_anonymised.csv"
  if (file.exists(empirical_path)) {
    df_empirical <- empirical_prep(empirical_path)
  }
  
  # DERIVED (first written 29/4/26)
  # prepare_directional + summarize_directional from df_ag
  # canonical output: df_directional_agents, df_directional
  df_directional_agents <- NULL
  df_directional <- NULL
  
  if (!is.null(df_ag)) {
    df_directional_agents <- prepare_directional(df_ag) # unsummarized directional
    df_directional <- summarize_directional(df_directional_agents) # summarized version
  }

  # Valence/Signed error (30/6/26)
  # derive from df_directional_agents - split by pro_reduction, compute signed error
  # output: df_valence
  # df_valence <- NULL
  # if (!is.null(df_directional_agents)) {
  #     df_valence <- compute_valence_metrics(df_directional_agents)
  # }

    
  # RETURN LIST with consistent slot names regardless of run_type
  list(
    config                = config,
    df_batch              = df_batch,
    lhs_versions          = if (config$run_type == "LHS" && config$version_scope == "both") lhs_versions else NULL,
    df_ag                 = df_ag,
    df_interactions       = df_interactions,
    df_influence          = df_influence,
    df_susceptibility     = df_susceptibility,
    df_empirical          = df_empirical,
    df_directional        = df_directional,
    df_directional_agents = df_directional_agents
    #df_valence            = df_valence
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




