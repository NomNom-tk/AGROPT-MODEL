# data processing script

# functions source before proper integration
source("./functions.R")

## df declarations
df_batch <- read.csv("./data/batch_summary.csv")
df_lhs <- read.csv("./data/lhs_batch_summary.csv")
#df_ga <- read.csv("./data/ga_batch_summary.csv")
#df_anneal <- read.csv("./data/annealing_batch_summary.csv")
#df_train <- read.csv("./data/train_data.csv")
#df_validation <- read.csv("./data/valid_batch_summary.csv")
#df_orig <- read.csv("./data/data_complete_anonymised.csv")
#df_ag <- read.csv("./data/agent_level_results.csv")

# lists declaration for lm and sensitivity analyses
# define input columns
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


