# data processing script

# functions source before proper integration
source("./functions.R")

# package imports
library(tidyverse)
library(dplyr)
library(rvg)
library(broom)
library(officer)
library(flextable)
library(sensitivity)
library(lm.beta)

# data_loading
df_lhs_v1 <- prepare_data("./data/lhs_batch_summary_v1.csv", version = "v1_threshold_0.001")
df_lhs_v2 <- prepare_data("./data/lhs_batch_summary_v2.csv", version = "v2_threshold_0.01")

df_lhs <- df_lhs_v2

names(df_lhs_v2)
str(df_lhs_v2$model_type)

## comparison for lhs, called form functions combined dfs
lhs_versions <- combine_df_versions(
  list(df_lhs_v1, df_lhs_v2),
  c("v1_threshold_0.001", "v2_threshold_0.01")
)

df_ga <- prepare_data("./data/batch_summary.csv", version = "v1")
# df_anneal < -prepare_data("./data/anneal_batch_summary.csv", version = "v1")

# agent level does not have neutral zone with do only apply batch mutations
df_ag <- read.csv("./data/agent_level_results.csv") %>%
  apply_batch_mutations()

df_agent_empir <- read.csv("./data/data_complete_anonymised.csv")

## df declarations
df_batch <- read.csv("./data/batch_summary.csv")
#df_lhs <- read.csv("./data/lhs_batch_summary.csv")
#df_ga <- read.csv("./data/ga_batch_summary.csv")
#df_anneal <- read.csv("./data/annealing_batch_summary.csv")
#df_train <- read.csv("./data/train_data.csv")
#df_validation <- read.csv("./data/valid_batch_summary.csv")
#df_orig <- read.csv("./data/data_complete_anonymised.csv")
#df_ag <- read.csv("./data/agent_level_results.csv")

# lists declaration for lm and sensitivity analyses
## define input columns ----
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




