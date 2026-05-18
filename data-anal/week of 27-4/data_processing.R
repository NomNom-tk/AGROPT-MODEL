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

# data_loading
## LHS
## temp trials for different lhs versions (to compare with baseline 28/4/26)
## modif 5-4-26 --> thr_0.01 (correct cap), thr_0.001 (30-4-26 mistake with cap)
df_lhs_v1 <- prepare_data("./data/lhs_batch_summary.csv", version = "v1_7-5_100c")
df_lhs_v2 <- prepare_data("./data/lhs_batch_summary_v2.csv", version = "v2_4-5_dyn")
df_lhs <- df_lhs_v1

colnames(df_lhs)

# composition scope application 18/5/26: "all", "H", "M"
composition_scope <- "M"
df_lhs <- if (composition_scope == "all") df_lhs else df_lhs %>%
  filter(debate_composition == composition_scope)

df_raw <- read_clean("./data/lhs_batch_summary.csv")
sapply(df_raw, class)
problems(df_raw) %>% print(n = Inf)

# empirical prep call
df_empirical_check <- empirical_prep("./data/data_complete_anonymised.csv")

## TODO lhs agent level --> fix no neutral zone width and prepare_data function 
#df_lhs_ag <- apply_batch_mutations("./data/lhs_agent_level_results.csv")

# temp fix for lhs agent level
df_ag <- read_clean("./data/lhs_agent_level_results.csv") %>%
  apply_batch_mutations() %>%
  mutate(agent_wrong_direction = as.logical(agent_wrong_direction),
        agent_is_saturated = as.logical(agent_is_saturated))

df_ag %>% filter(speaking_mode == TRUE) %>%
  count(current_condition, agent_is_saturated)


## comparison for lhs, called form functions combined dfs
lhs_versions <- combine_df_versions(
  list(df_lhs_v1, df_lhs_v2),
  c("v1_7-5_100c", "v2_30-4_dyn")
)

## LHS interactions prep 27/4/26
# left join with df_ag to pull pro_reduciton before computing susceptibility
df_lhs_interactions <- prepare_interactions("./data/lhs_interaction_log.csv") %>%
  left_join(df_ag %>% select(agent_id, pro_reduction) %>% distinct(),
            by = c("receiver_id" = "agent_id"))

# Influence and susceptibility score calculations
df_lhs_influence <- compute_influence_scores(df_lhs_interactions)
df_lhs_susceptibility <- compute_susceptibility_scores(df_lhs_interactions)

## LHS interactions directional 29/4/26
df_lhs_directional_agents <- prepare_directional(df_ag) # unsummarized directional
df_lhs_directional <- summarize_directional(df_lhs_directional_agents) # summarized version

## GA
# GA equivalents 27/4/26 /// rename files for GA before analysis
#df_ga_interactions <- prepare_interactions("./data/ga_interaction_log.csv")
#df_ga_influence <- compute_influence_scores(df_ga_interactions)
#df_ga_susceptibility <- compute_susceptibility_scores(df_ga_interactions)

#df_ga <- prepare_data("./data/ga_batch_summary.csv", version = "v1")

## ANNEALING
# df_anneal < -prepare_data("./data/anneal_batch_summary.csv", version = "v1")

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




