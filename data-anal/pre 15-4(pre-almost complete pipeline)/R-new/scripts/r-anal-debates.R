# load packages
install.packages("tidyverse")
install.packages("dplyr")
install.packages("broom")
install.packages("officer")
install.packages("rvg")
install.packages("flextable")
install.packages("lm.beta")
install.packages("sensitivity")
install.packages("rmarkdown")
library(tidyverse)
library(dplyr)
library(rvg)
library(broom)
library(officer)
library(flextable)
library(sensitivity)
library(lm.beta)

# collapsing logic (single - Alt+L, Shift,Alt,L / collapse all Alt,O)
#### description of file ####
#[EXISTING] Basic exploration
#[EXISTING] Parameter correlations — minor tweak
#[NEW]      Sensitivity analysis SRC/PCC
#[NEW]      Parameter importance ranking
#[MODIFIED] GA regions — SD params, group percentile,
#insensitive flags, range check, 
#GAML generator
#[EXISTING] Convergence analysis — add violin plot
#[EXISTING] Debate composition — keep
#[EXISTING] Speaking mode — add effect size
#[EXISTING] No change baseline — add limitation flag
#[EXISTING] Best params — add GA bounds check
#[EXISTING] Top 10 — keep
#[EXISTING] Cluster formation — extend
#[EXISTING] Hardest/easiest debates — keep
#[MODIFIED] Failures — justify threshold, 
#add constraint violation flag
#[MODIFIED] Stochasticity — add CV convergence plot
#[EXISTING] Boss table — add VAE if keeping
#[EXISTING] Model comparison — keep
#[EXISTING] Final recommendations — keep

#### csv import for debate level and agent-level #####
# change from . to .. or the reverse if it doesn't work
df_batch <- read.csv("./data/batch_summary.csv")
df_lhs <- read.csv("./data/lhs_batch_summary.csv")
df_train <- read.csv("./data/train_data.csv")
df_validation <- read.csv("./data/valid_batch_summary.csv")
df_orig <- read.csv("./data/data_complete_anonymised.csv")
df_ag <- read.csv("./data/agent_level_results.csv")

# agent conv speaking and distinct to bool (from string)
df_ag <- df_ag %>%
  mutate(
    #speaking_mode = speaking_mode == "true",
    use_distinct_agents = use_distinct_agents == "true"
  )

# batch conv speaking and distinct to bool (from string)
df_batch <- df_batch %>%
  mutate(
    speaking_mode = factor(speaking_mode, levels = c("true", "false")), # changed to factor for wilcox tests
    use_distinct_agents = use_distinct_agents == "true",
    debate_composition = substr(debate_label, 1, 1),
    normalised_convergence = convergence_cycle / 300, # divided by 300 to normalize (max_cycles is constant)
    )

df_lhs <- df_lhs %>%
  mutate(
    speaking_mode = factor(speaking_mode, levels = c("true", "false")), # changed to factor for wilcox tests
    use_distinct_agents = use_distinct_agents == "true",
    debate_composition = substr(debate_label, 1, 1),
    normalised_convergence = convergence_cycle / 300, # divided by 300 to normalize (max_cycles is constant)
  )

# columsn to mutate to numeric
conv_cols <- c("convergence_rate", "confidence_threshold", "repulsion_strength", "repulsion_threshold",
               "convergence_rate_sd", "confidence_threshold_sd", "repulsion_strength_sd", "repulsion_threshold_sd",
               "mae", "initial_variance", "opinion_variance", "seed", "polarization_index", "neutral_zone_width", "mean_net_repulsion_abs"
               )

# df batch numeric mutation
df_batch <- df_batch %>%
  mutate(across(all_of(conv_cols), ~ as.numeric(gsub(",", ".", trimws(.)))))

df_lhs <- df_lhs %>%
  mutate(across(all_of(conv_cols), ~ as.numeric(gsub(",", ".", trimws(.)))))

## EXEC SUMMARY
exec_summary <- data.frame(
  Model = c("Consensus", "Clustering", "Bipolarization"),
  Best_Mae = pmin(model_wide_full$`false`, model_wide_full$`true`),
  Best_Heterogeneous_mae = model_wide_full$`true`,
  Best_Homogeneous_mae = model_wide_full$`false`,
  Winner = c("X", "", "")
)
write_csv(exec_summary, "./results/exec-summary.csv")

# trial plotting of params over mae ####
df_params_spread_long <- df_batch %>%
  filter(model_type != "no_change") %>%
  mutate(
    confidence_threshold = ifelse(model_type == "consensus", NA, confidence_threshold),
    repulsion_threshold = ifelse(model_type %in% c("consensus", "clustering"), NA, repulsion_threshold),
    repulsion_strength = ifelse(model_type %in% c("consensus", "clustering"), NA, repulsion_strength)
  ) %>%
  pivot_longer(
    cols = c(convergence_rate, confidence_threshold,
            repulsion_strength, repulsion_threshold),
    names_to = "parameter",
    values_to = "value"
  ) %>%
  filter(!is.na(value))

range(df_batch$mae)
summary(df_params_spread_long$mae)

# second try conditional histogram
threshold <- 0.10

df_good <- df_batch %>% filter(mae <= threshold, model_type != "no_change")
df_all <- df_batch %>% filter(model_type != "no_change")

# helper function to pivot longer / strip useless parameters
# pivot_params is in functions file
pivot_params <- function(df) {
  df %>%
    mutate(
      confidence_threshold = ifelse(model_type == "consensus", NA, confidence_threshold),
      repulsion_threshold = ifelse(model_type %in% c("consensus", "clustering"), NA, repulsion_threshold),
      repulsion_strength = ifelse(model_type %in% c("consensus", "clustering"), NA, repulsion_strength)
    ) %>%
    pivot_longer(
      cols = c(convergence_rate, confidence_threshold,
               repulsion_strength, repulsion_threshold),
      names_to = "parameter",
      values_to = "value"
    ) %>%
    filter(!is.na(value))
}

df_all_long <- pivot_params(df_all) %>% mutate(set = "All runs")
df_good_long <- pivot_params(df_good) %>% mutate(set = "MAE < 0.10")

df_param_complete <- bind_rows(df_all_long, df_good_long)

# conditional histogram
ggplot(df_param_complete, aes(x = value, fill = set)) +
  geom_histogram(aes(y = after_stat(count)),
                 position = "identity", alpha = 0.5, bins = 15) +
  scale_fill_manual(values = c("All runs" = "grey60", "MAE < 0.10" = "steelblue")) +
  facet_grid(model_type ~ parameter, scales = "free_x") +
  labs(title = "Conditional parameter distributions",
       subtitle = "Blue = high performance runs (MAE < 0.10), Grey = all runs", 
       x = "Parameter Value", y = "Frequency", fill = "") +
  theme_bw() +
  theme(legend.position = "bottom")
ggsave("preLHS parameter sampling_1.png",
       path = "./graphics",
       dpi = 300)

#### saving logic ####
add_to_ppt <- function(ppt, content, title, type = "table") {
  ppt <- add_slide(ppt, layout = "Title and Content", master = "Office Theme")
  ppt <- ph_with(ppt, value = title, location = ph_location_type(type = "title"))
  
  if (type == "table") {
    # data frame or tidy regression output
    ft <- flextable(content) %>%
      theme_vanilla() %>%
      autofit()
    ppt <- ph_with(ppt, value = ft, location = ph_location_type(type = "body"))
  } else if (type == "regression") {
    ft <- tidy(content, conf.int = TRUE) %>%
      mutate(across(where(is.numeric), ~round(., 3))) %>%
      flextable() %>%
      theme_vanilla() %>%
      autofit()
    ppt <- ph_with(ppt, value = ft, location = ph_location_type(type = "body"))
  } else if (type == "plot") {
    ## ggplot object
    ppt <- ph_with(ppt,
                   value = dml(ggobj = content),
                   location = ph_location(width = 8, height = 5,
                                          left = 1, top = 1.5))
  }
  return(ppt)
}
ppt <- read_pptx()

## use
## ppt <- read_pptx()
## add table example: 
## ppt <- add_to_ppt(ppt, model_comparison, "Model Comparison), type = "table)
## ppt <- add_to_ppt(ppt, boss_table, "Summary Results", type = "table)
## save once
# print(ppt, target = "relative path")

#### basic exploration ####
# use nrow to check rows, what type of model, unique debates, distribution of conditions
nrow(df_batch)

# check model type
table(df_batch$model_type)

# find unique debates
length(unique(df_batch$selected_debate_id))

# if neutral zone > 0 for bipolarization then need to filter out these rows
neutral_zone_exp <- df_batch %>%
  filter(model_type == "bipolarization" & neutral_zone_width < 0.0) 

# check constraint violations (in bipol) check whenther repulsion threshold <= confidenc ethreshold
df_batch_post_filter <- df_batch %>%
  filter(!(model_type == "bipolarization" & neutral_zone_width < 0))
# 360 observations filtered out, need to redo model conditions in exp GAMA

if (nrow(constraint_violations) > 0) {
  print("WARNING found invalid parameter combinations")
  print(constraint_violations)
}

#### Sensitivity LHS analysis ####
# filter to one modle type ad remove constraint violations
# select only relevant parameter columns
# standardize inputs an doutputs - subtract mean, divide by SD
# fit linear model for each output variable
# extract standardised coefficient and R square
# repeat across all model type x use_distinct_agent combinations
# combine results and plot

# SENSITIVITY ANALYSIS
# Goal: compute standardised regression coefficients (SRC) 
# and partial correlation coefficients (PCC) for each 
# model_type x use_distinct_agents combination
# Outputs: mae, opinion_variance, convergence_cycle
# (+ polarization_index for bipol, num_clusters for clustering)

#Standardize Regression Coefficients data function def
# prepare_sensitivyt is in functions.R
prepare_sensitivity_data <- function(df, param_cols, output_cols) {
  df %>%
    mutate(across(all_of(param_cols), ~(. - mean(., na.rm = TRUE)) / sd(., na.rm = TRUE)),
           across(all_of(output_cols), ~ (. - mean(., na.rm = TRUE)) / sd(., na.rm = TRUE)))
}

# define model columns
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

# data set up
sensi_start <- df_batch %>%
  filter(model_type != "no_change") %>%
  group_by(model_type, use_distinct_agents) # filter no change condition, ensure you have distinct agent/debate combinations

# df splitting for function
sensi_split <- group_split(sensi_start) # split df into groups defined by sensi_start

#### trial without sensistivity packaged####
# initialize storage
sensi_results <- list()

# initial loop for standardization and cleaning
for (df_piece in sensi_split) {
  model_type_val <- unique(df_piece$model_type)
  distinct_val <- unique(df_piece$use_distinct_agents)
  
  # key creation
  key <- paste(model_type_val, distinct_val, sep = "_")
  
  #param cols key look up
  param_cols <- param_cols_by_model[[key]]
  
  # guard for null
  if (is.null(param_cols)) {
    warning(paste("No param_cols found for key:", key, "- skipping"))
    next
  }
  
  # filter for bipol constraint violations
  if (model_type_val == "bipolarization") {
    df_piece <- df_piece %>% filter(neutral_zone_width >= 0)
  }
  
  #function call
  result <- prepare_sensitivity_data(df_piece, param_cols, output_cols)
  
  # store
  sensi_results[[key]] <- result
} 

# init src results
src_results <- list()

# Regression attempt not done using src package (instead using lm and then extracitng Rsquare)
for (i in names(sensi_results)) {
  param_cols <- param_cols_by_model[[i]]
  df <- sensi_results[[i]]
  for (var in output_cols) {
    formula_str <- paste(var, "~", paste(param_cols, collapse = " + "))
    formula_obj <- as.formula(formula_str)
    model <- lm(formula_obj, data = df)
    
    # store results
    src_results[[paste(i, var, sep = "_")]] <- data.frame(
      key = i,
      output = var,
      r_squared = summary(model)$r.squared,
      tidy(model)
    )
  }
}

src_combined <- bind_rows(src_results)
#### PCC /// SRC does not work as there is too little variation in the data#####
# Initialize storage
pcc_results <- list()  # store results per key-output combination
prcc_results <- list() # storage for prcc (pcc with rank)

# Loop over each piece in the sensi_split
for (df_piece in sensi_split) {
  
  # Generate key for lookup
  model_type_val <- as.character(unique(df_piece$model_type)) # key value for results list - unique model type -converted into char
  distinct_val   <- as.character(unique(df_piece$use_distinct_agents)) # value pair for results - distinct agents as chars
  key <- paste(model_type_val, distinct_val, sep="_") # key creation [model, val] separated by _
  
  # Retrieve relevant parameter columns
  param_cols <- param_cols_by_model[[key]]       # lookup mapping
  if (is.null(param_cols)) next                 # skip if key not found
  param_cols <- intersect(param_cols, colnames(df_piece))  # restrict param_cols to only columns existing in this df_piece
  # guard againts mismatches between lookup list and actual data columns
  # sensi split comes from df_batch (should have all columns, but just to be safe add the guard)
  if (length(param_cols) == 0) next             # skip if no valid columns remain
  
  # Prepare parameter matrix X
  X <- df_piece[, param_cols, drop=FALSE]       # inputs for PCC, list of parameter colums
  # convert to numeric in case some columns are factors/logical
  X[] <- lapply(X, function(col) as.numeric(col))
  
  # Loop over output columns
  for (output in output_cols) {
    
    if (!output %in% colnames(df_piece)) next   # skip if output missing
    y <- as.numeric(df_piece[[output]])        # define output as numeric, from df_piece associated with output key
    
    # skip outputs with constant values (PCC won't work) - requires variance in both X and Y
    ## zero variance causes division by zero in correlation calc
    if (length(unique(y)) < 2) next
    
    # PCC Handle single-parameter case
    if (ncol(X) == 1) { # if the number of columns in input X is equal to 1
      # PCC reduces to simple correlation
      pcc_values <- cor(X[[1]], y)
      prcc_values <- cor(X[[1]], y)
      
      pcc_results[[paste(key, output, sep="_")]] <- data.frame( # pasting key and pair, output defined as y, and pcc values in pcc list
        key = key,
        output = output,
        parameter = colnames(X),
        PCC = pcc_values
      )
      
      prcc_results[[paste(key, output, sep="_")]] <- data.frame( # pasting key and pair, output defined as y, and pcc values in pcc list
        key = key,
        output = output,
        parameter = colnames(X),
        PRCC = prcc_values
      )
      next
      
    }
    
    # Compute PCC for multiple parameters partial pearson
    pcc_res <- pcc(X, y) # Partial Pearson correlation coefficients using X (param cols input), and y column names converted to numeric
    prcc_res <- pcc(X, y, rank = TRUE) # PRCC
    print(str(prcc_res))
    print(head(prcc_res$PCC))
    
    # flatten pcc results properly
    param_names <- rownames(pcc_res$PCC) # extract parameter names (row labels) FIRST BEFORE VALUES
    param_names_prcc <- rownames(prcc_res$PRCC) # separate for prcc (prcc names its output after method, not standardized)
    pcc_values <- pcc_res$PCC[, "original"] # extrac pcc values column (original values)
    prcc_values <- prcc_res$PRCC[, "original"] # extract prcc values column
    
    # PRCC storage
    prcc_results[[paste(key, output, sep="_")]] <- data.frame(
      key = rep(key, length(prcc_values)),
      model_type = rep(model_type_val, length(prcc_values)),
      use_distinct_agents = rep(distinct_val, length(prcc_values)),
      output = rep(output, length(prcc_values)),
      parameter = param_names,
      PRCC = prcc_values
    )
    
    # PCC Store results
    pcc_results[[paste(key, output, sep="_")]] <- data.frame( # results paste, key, output, using "_" as a separator
      # ensure it is a df for analysis, then repeat each value for paste to match all columns (df needs same column length)
      key = rep(key, length(pcc_values)),
      model_type = rep(model_type_val, length(pcc_values)),
      use_distinct_agents = rep(distinct_val, length(pcc_values)),
      output = rep(output, length(pcc_values)),
      parameter = param_names_prcc, # distinct because prcc and pcc store cols names based on method
      PCC = pcc_values
    )
    
  }  # end output loop
}

# combined df
pcc_results_df <- do.call(rbind, pcc_results) # call a row bind for pcc_results to create a dataframe
prcc_results_df <- do.call(rbind, prcc_results) # same for prcc

# visualize
pcc_viz <- ggplot(pcc_results_df, aes(x=parameter, y=PCC, fill=output)) +
  geom_bar(stat="identity", position="dodge") +
  facet_wrap(~ key, scales="free_x") +
  theme_minimal() +
  labs(title="Partial Correlation Coefficients per Model/Output")

ggsave("pcc_viz.png",
       path = "./graphics",
       dpi = 300)

print(pcc_viz)

prcc_viz <- ggplot(prcc_results_df, aes(x=parameter, y=PRCC, fill=output)) +
  geom_bar(stat="identity", position="dodge") +
  facet_wrap(~ key, scales="free_x") +
  theme_minimal() +
  labs(title="Partial Rank Correlation Coefficient per Model/Output")

ggsave("prcc_viz.png",
       path = "./graphics",
       dpi = 300)

print(prcc_viz)

#### GA REGION IDENTIFICATION ####
# identify best performing parameter combinations per model
# use this to set bounds for GA experiments in GAMA
ga_regions <- df_batch %>%
  filter(model_type != "no_change") %>%
  group_by(model_type, use_distinct_agents) %>%
  mutate(mae_threshold = quantile(mae, 0.25)) %>%
  filter(mae <= mae_threshold) %>%
  summarize(
    cr_min = min(convergence_rate),
    cr_max = max(convergence_rate),
    cr_max_sd = max(convergence_rate_sd),
    cr_min_sd = min(convergence_rate_sd),
    ct_min = min(confidence_threshold, na.rm = TRUE),
    ct_max = max(confidence_threshold, na.rm = TRUE),
    ct_min_sd = min(confidence_threshold_sd, na.rm = TRUE),
    ct_max_sd = max(confidence_threshold_sd, na.rm = TRUE),
    rs_min = min(repulsion_strength, na.rm = TRUE),
    rs_max = max(repulsion_strength, na.rm = TRUE),
    rs_min_sd = min(repulsion_strength_sd, na.rm = TRUE),
    rs_max_sd = max(repulsion_strength_sd, na.rm = TRUE),
    rt_min = min(repulsion_threshold, na.rm = TRUE),
    rt_max = max(repulsion_threshold, na.rm = TRUE),
    rt_min_sd = min(repulsion_threshold_sd, na.rm = TRUE),
    rt_max_sd = max(repulsion_threshold_sd, na.rm = TRUE),
    best_mae = min(mae),
    mae_threshold_used = first(mae_threshold), # for reference
    n = n(),
    .groups = "drop"
  )

# clamp regions to ensure only positive values for GA
# Define the columns that need min/max clamping
min_max_cols <- c(
  "cr_min", "cr_max", "ct_min", "ct_max",
  "rs_min", "rs_max", "rt_min", "rt_max",
  "cr_min_sd", "cr_max_sd", "ct_min_sd", "ct_max_sd",
  "rs_min_sd", "rs_max_sd", "rt_min_sd", "rt_max_sd"
)

# Optional buffer to expand ranges slightly
buffer <- 0.05  # change to 0 if you don't want a buffer

# Apply clamping and buffer
ga_regions <- ga_regions %>%
  mutate(across(all_of(min_max_cols), ~ pmax(0, pmin(1, .)))) 

# diagnostic - to check that n isn't too large and grouping works
#ga_regions %>%
#  distinct(model_type, use_distinct_agents, mae_threshold_used) %>%
#  print()

# minimum range check - flags parameters that are too narrow for GA search
min_range <- 0.05

range_check <- ga_regions %>%
  mutate(
    cr_range_ok = (cr_max - cr_min) >= min_range,
    ct_range_ok = (ct_max - ct_min) >= min_range,
    rs_range_ok = (rs_max - rs_min) >= min_range,
    rt_range_ok = (rt_max - rt_min) >= min_range,
    cr_sd_range_ok = (cr_max_sd - cr_min_sd) >= min_range,
    ct_sd_range_ok = (ct_max_sd - ct_min_sd) >= min_range,
    rs_sd_range_ok = (rs_max_sd - rs_min_sd) >= min_range,
    rt_sd_range_ok = (rt_max_sd - rt_min_sd) >= min_range,
  ) 
#%>% select(model_type, use_distinct_agents, ends_with("_range_ok"))

# print warning for narrow ranges
narrow_params <- range_check %>%
  pivot_longer(
    cols = ends_with("_range_ok"),
    names_to = "paramter",
    values_to = "range_ok"
  ) %>%
  filter(!range_ok)

if (nrow(narrow_params) > 0) {
  print("WARNING: the following parameters have ranges too narrow for GA search:")
  print(narrow_params)
} else {
  print("All parameter ranges sufficient for GA search")
}


# bipolarization constraint check
bipol_check <- range_check %>%
  filter(model_type == "bipolarization") %>%
  mutate(constraint_ok = ct_max < rt_min,
         gap = rt_min - ct_max) %>%
  select(model_type, use_distinct_agents, ct_max, rt_min, gap, constraint_ok)

if (any(!bipol_check$constraint_ok)) {
  print("WARNING: bipolarization GA bounds violate repulsion/confidence constraint")
  print("Adjust ct_max or rt_min manually before running GA")
  print(bipol_check %>% filter(!constraint_ok))
} else {
  print("Bipolarization constraint satisfied in all GA bounds")
  print(bipol_check)
}

# GAML output generator (ready to insert and run for GA runs)
# FUNCTION: generate_gaml_bounds
# Purpose:
#   Convert summarized GA parameter bounds (ga_regions) into GAML-formatted
#   parameter statements ready for insertion into GAMA simulations.
#
# Special handling:
#   - If a parameter's min = max (zero-width range), automatically add a
#     small buffer to create a non-zero search space for GA optimization.
#   - SD parameters (for distinct agents) are treated similarly.
#   - NA or infinite values are ignored.
#
# Parameters:
#   ga_regions: data.frame with min/max parameter values per model_type and
#               use_distinct_agents.
#   buffer: numeric, small amount to expand zero-width ranges (default: 0.05)
#
# Returns:
#   A character vector of GAML parameter statements.

generate_gaml_bounds <- function(ga_regions, buffer = 0.05) {
  
  # Helper function: expands zero-width ranges
  expand_range <- function(min_val, max_val, buffer) {
    if (is.na(min_val) || is.na(max_val)) return(c(min_val, max_val))
    if (min_val == max_val) {
      # expand symmetrically around the original value
      min_val <- min_val - buffer
      max_val <- max_val + buffer
    }
    return(c(min_val, max_val))
  }
  
  output_lines <- c()
  
  for (i in seq_len(nrow(ga_regions))) {
    row <- ga_regions[i, ]
    
    # Header comment for reference
    header <- paste0(
      "\n// ", row$model_type, 
      " | distinct: ", row$use_distinct_agents,
      " | best_mae: ", round(row$best_mae, 4),
      " | n: ", row$n
    )
    output_lines <- c(output_lines, header)
    
    # Convergence Rate
    cr_range <- expand_range(row$cr_min, row$cr_max, buffer)
    output_lines <- c(output_lines, paste0(
      'parameter "Convergence Rate" var: convergence_rate',
      " min: ", round(cr_range[1], 3),
      " max: ", round(cr_range[2], 3), ";"
    ))
    
    # Confidence Threshold
    if (!is.na(row$ct_min) & !is.infinite(row$ct_min) & row$ct_max > 0.01) {
      ct_range <- expand_range(row$ct_min, row$ct_max, buffer)
      output_lines <- c(output_lines, paste0(
        'parameter "Confidence Threshold" var: confidence_threshold',
        " min: ", round(ct_range[1], 3),
        " max: ", round(ct_range[2], 3), ";"
      ))
    }
    
    # Repulsion Strength & Threshold
    if (!is.na(row$rs_min) & !is.infinite(row$rs_min) & row$rs_max > 0.01) {
      rs_range <- expand_range(row$rs_min, row$rs_max, buffer)
      rt_range <- expand_range(row$rt_min, row$rt_max, buffer)
      
      output_lines <- c(output_lines, paste0(
        'parameter "Repulsion Strength" var: repulsion_strength',
        " min: ", round(rs_range[1], 3),
        " max: ", round(rs_range[2], 3), ";"
      ))
      output_lines <- c(output_lines, paste0(
        'parameter "Repulsion Threshold" var: repulsion_threshold',
        " min: ", round(rt_range[1], 3),
        " max: ", round(rt_range[2], 3), ";"
      ))
    }
    
    # SD parameters — only for distinct agents
    if (row$use_distinct_agents == TRUE) {
      cr_sd_range <- expand_range(row$cr_min_sd, row$cr_max_sd, buffer)
      output_lines <- c(output_lines, paste0(
        'parameter "SD Convergence Rate" var: convergence_rate_sd',
        " min: ", round(cr_sd_range[1], 3),
        " max: ", round(cr_sd_range[2], 3), ";"
      ))
      
      if (!is.na(row$ct_min_sd) & !is.infinite(row$ct_min_sd) & row$ct_max_sd > 0.01) {
        ct_sd_range <- expand_range(row$ct_min_sd, row$ct_max_sd, buffer)
        output_lines <- c(output_lines, paste0(
          'parameter "SD Confidence Threshold" var: confidence_threshold_sd',
          " min: ", round(ct_sd_range[1], 3),
          " max: ", round(ct_sd_range[2], 3), ";"
        ))
      }
      
      if (!is.na(row$rs_min_sd) & !is.infinite(row$rs_min_sd) & row$rs_max_sd > 0.01) {
        rs_sd_range <- expand_range(row$rs_min_sd, row$rs_max_sd, buffer)
        rt_sd_range <- expand_range(row$rt_min_sd, row$rt_max_sd, buffer)
        
        output_lines <- c(output_lines, paste0(
          'parameter "SD Repulsion Strength" var: repulsion_strength_sd',
          " min: ", round(rs_sd_range[1], 3),
          " max: ", round(rs_sd_range[2], 3), ";"
        ))
        output_lines <- c(output_lines, paste0(
          'parameter "SD Repulsion Threshold" var: repulsion_threshold_sd',
          " min: ", round(rt_sd_range[1], 3),
          " max: ", round(rt_sd_range[2], 3), ";"
        ))
      }
    }
  }
  
  return(output_lines)
}

# run generator and write to file
gaml_output <- generate_gaml_bounds(ga_regions)
writeLines(gaml_output, "gaml_GA_bounds.txt")
cat(gaml_output, sep = "\n")  # also print to console

#### GA_analysis ####
# re-use initial pre-processing (col defs, up until and includign sensi_start)
# data set up (changed to different df)
df_ga <- df_batch

# split data_set into low and high confidence_threshold regimes (0.2 and 0.8), identified in basic data_exploratiuon
df_low <- df_ga %>%
  filter(confidence_threshold <= 0.4)

df_high <- df_ga %>%
  filter(confidence_threshold >= 0.6)

# sensi split for low and high
sensi_start_low <- df_low %>%
  filter(model_type != "no_change") %>%
  group_by(model_type, use_distinct_agents) # filter no change condition, ensure you have distinct agent/debate combinations

sensi_start_high <- df_high %>%
  filter(model_type != "no_change") %>%
  group_by(model_type, use_distinct_agents)

# split df into pieces for analysis (for high and low)
sensi_split_low <- group_split(sensi_start_low) # split df into groups defined by sensi_start

sensi_split_high <- group_split(sensi_start_high) # split df into groups defined by sensi_start

## LOW now also reuse same pcc and prcc logic 
# Initialize storage
pcc_results_low <- list()  # store results per key-output combination
prcc_results_low <- list() # storage for prcc (pcc with rank)

# Loop over each piece in the sensi_split
for (df_piece in sensi_split_low) {
  
  # Generate key for lookup
  model_type_val <- as.character(unique(df_piece$model_type)) # key value for results list - unique model type -converted into char
  distinct_val   <- as.character(unique(df_piece$use_distinct_agents)) # value pair for results - distinct agents as chars
  key <- paste(model_type_val, distinct_val, sep="_") # key creation [model, val] separated by _
  
  # Retrieve relevant parameter columns
  param_cols <- param_cols_by_model[[key]]       # lookup mapping
  if (is.null(param_cols)) next                 # skip if key not found
  param_cols <- intersect(param_cols, colnames(df_piece))  # restrict param_cols to only columns existing in this df_piece
  # guard againts mismatches between lookup list and actual data columns
  # sensi split comes from df_batch (should have all columns, but just to be safe add the guard)
  if (length(param_cols) == 0) next             # skip if no valid columns remain
  
  # Prepare parameter matrix X
  X <- df_piece[, param_cols, drop=FALSE]       # inputs for PCC, list of parameter colums
  # convert to numeric in case some columns are factors/logical
  X[] <- lapply(X, function(col) as.numeric(col))
  
  # Loop over output columns
  for (output in output_cols) {
    
    if (!output %in% colnames(df_piece)) next   # skip if output missing
    y <- as.numeric(df_piece[[output]])        # define output as numeric, from df_piece associated with output key
    
    # skip outputs with constant values (PCC won't work) - requires variance in both X and Y
    ## zero variance causes division by zero in correlation calc
    if (length(unique(y)) < 2) next
    
    # PCC Handle single-parameter case
    if (ncol(X) == 1) { # if the number of columns in input X is equal to 1
      # PCC reduces to simple correlation
      pcc_values <- cor(X[[1]], y)
      prcc_values <- cor(X[[1]], y)
      
      pcc_results_low[[paste(key, output, sep="_")]] <- data.frame( # pasting key and pair, output defined as y, and pcc values in pcc list
        key = rep(key, 1),
        model_type = rep(model_type_val, 1),
        use_distinct_agents = rep(distinct_val, 1),
        output = rep(output, 1),
        parameter = colnames(X),
        PCC = pcc_values
      )
      
      prcc_results_low[[paste(key, output, sep="_")]] <- data.frame( # pasting key and pair, output defined as y, and pcc values in pcc list
        key = rep(key, 1),
        model_type = rep(model_type_val, 1),
        use_distinct_agents = rep(distinct_val, 1),
        output = rep(output, 1),
        parameter = colnames(X),
        PRCC = prcc_values
      )
      next
      
    }
    
    # Compute PCC for multiple parameters partial pearson
    pcc_res <- pcc(X, y) # Partial Pearson correlation coefficients using X (param cols input), and y column names converted to numeric
    prcc_res <- pcc(X, y, rank = TRUE) # PRCC
    print(str(prcc_res))
    print(head(prcc_res$PCC))
    
    # flatten pcc results properly
    param_names_pcc <- rownames(pcc_res$PCC) # extract parameter names (row labels) FIRST BEFORE VALUES
    param_names_prcc <- rownames(prcc_res$PRCC) # separate for prcc (prcc names its output after method, not standardized)
    pcc_values <- pcc_res$PCC[, "original"] # extrac pcc values column (original values)
    prcc_values <- prcc_res$PRCC[, "original"] # extract prcc values column
    
    # safety check to ensure columns match
    if (length(param_names_prcc) != length(prcc_values)) {
      stop("PRCC rownames and values length mismatch")
    }
    
    if (length(param_names_pcc) != length(pcc_values)) {
      stop("PCC rownames and values length mismatch")
    }
    
    
    # PRCC storage
    prcc_results_low[[paste(key, output, sep="_")]] <- data.frame(
      key = rep(key, length(prcc_values)),
      model_type = rep(model_type_val, length(prcc_values)),
      use_distinct_agents = rep(distinct_val, length(prcc_values)),
      output = rep(output, length(prcc_values)),
      parameter = param_names_prcc,
      PRCC = prcc_values
    )
    
    # PCC Store results
    pcc_results_low[[paste(key, output, sep="_")]] <- data.frame( # results paste, key, output, using "_" as a separator
      # ensure it is a df for analysis, then repeat each value for paste to match all columns (df needs same column length)
      key = rep(key, length(pcc_values)),
      model_type = rep(model_type_val, length(pcc_values)),
      use_distinct_agents = rep(distinct_val, length(pcc_values)),
      output = rep(output, length(pcc_values)),
      parameter = param_names_pcc, # distinct because prcc and pcc store cols names based on method
      PCC = pcc_values
    )
    
  }  # end output loop
}

# combined df
pcc_results_ga_low_df <- do.call(rbind, pcc_results_low) # call a row bind for pcc_results to create a dataframe
prcc_results_ga_low_df <- do.call(rbind, prcc_results_low) # same for prcc


## LOW now also reuse same pcc and prcc logic 
# Initialize storage
pcc_results_high <- list()  # store results per key-output combination
prcc_results_high <- list() # storage for prcc (pcc with rank)

# Loop over each piece in the sensi_split
for (df_piece in sensi_split_high) {
  
  # Generate key for lookup
  model_type_val <- as.character(unique(df_piece$model_type)) # key value for results list - unique model type -converted into char
  distinct_val   <- as.character(unique(df_piece$use_distinct_agents)) # value pair for results - distinct agents as chars
  key <- paste(model_type_val, distinct_val, sep="_") # key creation [model, val] separated by _
  
  # Retrieve relevant parameter columns
  param_cols <- param_cols_by_model[[key]]       # lookup mapping
  if (is.null(param_cols)) next                 # skip if key not found
  param_cols <- intersect(param_cols, colnames(df_piece))  # restrict param_cols to only columns existing in this df_piece
  # guard againts mismatches between lookup list and actual data columns
  # sensi split comes from df_batch (should have all columns, but just to be safe add the guard)
  if (length(param_cols) == 0) next             # skip if no valid columns remain
  
  # Prepare parameter matrix X
  X <- df_piece[, param_cols, drop=FALSE]       # inputs for PCC, list of parameter colums
  # convert to numeric in case some columns are factors/logical
  X[] <- lapply(X, function(col) as.numeric(col))
  
  # safety check remove constant columns before entering output loop
  X <- X[, sapply(X, function(col) length(unique(col)) > 1), drop = FALSE]
  # skip if no columsn remain
  if (ncol(X) == 0) next
  
  # Loop over output columns
  for (output in output_cols) {
    
    if (!output %in% colnames(df_piece)) next   # skip if output missing
    y <- as.numeric(df_piece[[output]])        # define output as numeric, from df_piece associated with output key
    
    # skip outputs with constant values (PCC won't work) - requires variance in both X and Y
    ## zero variance causes division by zero in correlation calc
    if (length(unique(y)) < 2) next
    
    # PCC Handle single-parameter case
    if (ncol(X) == 1) { # if the number of columns in input X is equal to 1
      # PCC reduces to simple correlation
      pcc_values <- cor(X[[1]], y)
      prcc_values <- cor(X[[1]], y)
      
      pcc_results_high[[paste(key, output, sep="_")]] <- data.frame( # pasting key and pair, output defined as y, and pcc values in pcc list
        key = rep(key, 1),
        model_type = rep(model_type_val, 1),
        use_distinct_agents = rep(distinct_val, 1),
        output = rep(output, 1),
        parameter = colnames(X),
        PCC = pcc_values
      )
      
      prcc_results_high[[paste(key, output, sep="_")]] <- data.frame( # pasting key and pair, output defined as y, and pcc values in pcc list
        key = rep(key, 1),
        model_type = rep(model_type_val, 1),
        use_distinct_agents = rep(distinct_val, 1),
        output = rep(output, 1),
        parameter = colnames(X),
        PRCC = prcc_values
      )
      next
      
    }
    
    # Compute PCC for multiple parameters partial pearson
    pcc_res <- pcc(X, y) # Partial Pearson correlation coefficients using X (param cols input), and y column names converted to numeric
    prcc_res <- pcc(X, y, rank = TRUE) # PRCC
    print(str(prcc_res))
    print(head(prcc_res$PCC))
    
    # flatten pcc results properly
    param_names_pcc <- rownames(pcc_res$PCC) # extract parameter names (row labels) FIRST BEFORE VALUES
    param_names_prcc <- rownames(prcc_res$PRCC) # separate for prcc (prcc names its output after method, not standardized)
    pcc_values <- pcc_res$PCC[, "original"] # extrac pcc values column (original values)
    prcc_values <- prcc_res$PRCC[, "original"] # extract prcc values column
    
    # safety check to ensure columns match
    if (length(param_names_prcc) != length(prcc_values)) {
      stop("PRCC rownames and values length mismatch")
    }
    
    if (length(param_names_pcc) != length(pcc_values)) {
      stop("PCC rownames and values length mismatch")
    }
    
    
    # PRCC storage
    prcc_results_high[[paste(key, output, sep="_")]] <- data.frame(
      key = rep(key, length(prcc_values)),
      model_type = rep(model_type_val, length(prcc_values)),
      use_distinct_agents = rep(distinct_val, length(prcc_values)),
      output = rep(output, length(prcc_values)),
      parameter = param_names_prcc,
      PRCC = prcc_values
    )
    
    # PCC Store results
    pcc_results_high[[paste(key, output, sep="_")]] <- data.frame( # results paste, key, output, using "_" as a separator
      # ensure it is a df for analysis, then repeat each value for paste to match all columns (df needs same column length)
      key = rep(key, length(pcc_values)),
      model_type = rep(model_type_val, length(pcc_values)),
      use_distinct_agents = rep(distinct_val, length(pcc_values)),
      output = rep(output, length(pcc_values)),
      parameter = param_names_pcc, # distinct because prcc and pcc store cols names based on method
      PCC = pcc_values
    )
    
  }  # end output loop
}

# combined df
pcc_results_ga_high_df <- do.call(rbind, pcc_results_high) # call a row bind for pcc_results to create a dataframe
prcc_results_ga_high_df <- do.call(rbind, prcc_results_high) # same for prcc

# visualize for both high and low thresholds
# combined low and high split sfor plotting
#combined_ga_low <- bind_rows(
#  pcc_results_ga_low_df %>% mutate(method = "PCC"),
#  prcc_results_ga_low_df %>% mutate(method="PRCC")
#)

#combined_ga_high <- bind_rows (
#  pcc_results_ga_high_df %>% mutate(method="PCC"),
#  prcc_results_ga_high_df %>% mutate(method="PRCC")
#)

##**## step, managed to to pcc and prcc for both high and low, need to combine, visualize, define GA bounds, run annealing and see how we move
#combined_low_high_df <- bind_rows (
#  combined_ga_high %>% mutate(regime="low_ct"),
#  combined_ga_low %>% mutate(regime="high_ct")
#)
# facet viz using key and regime to cmpare param importance across two confi threhsolds
# pivot individual results
pcc_low_long <- pcc_results_ga_low_df %>%
  mutate(method="PCC", regime="low_ct") %>%
  rename(value=PCC)

pcc_high_long <- pcc_results_ga_high_df %>%
  mutate(method="PCC", regime="high_ct") %>%
  rename(value=PCC)

prcc_low_long <- prcc_results_ga_low_df %>%
  mutate(method="PRCC", regime="low_ct") %>%
  rename(value=PRCC)

prcc_high_long <- prcc_results_ga_high_df %>%
  mutate(method="PRCC", regime="high_ct") %>%
  rename(value=PRCC)


#recombine of all results after pivot
combined_long <- bind_rows(
  pcc_low_long,
  pcc_high_long,
  prcc_low_long,
  prcc_high_long
)

# combined viz
combined_viz <- ggplot(combined_long, aes(x=parameter, y=value, fill=output)) +
  geom_bar(stat="identity", position="dodge") +
  facet_wrap(~ key + regime, scales="free_x") +
  geom_hline(yintercept=0, linetype="dashed") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  theme_minimal() +
  labs(title = "test combined viz",
       x="parameter", y="correlation coefficient",
       fill="output") +
  facet_wrap(~ key + regime + method, scales = "free_x")

print(combined_viz)

ggsave("PCC-PRCC_CT_combined_bar.png",
       path = "./graphics",
       dpi = 300)

#### GA for hypotheses ####
# gA vs no change comparison test of h3 and h5
ga_best <- df_ga %>%
  filter(model_type != "no_change") %>%
  group_by(model_type, selected_debate_id) %>% # removed use_distinct_agetns, no change baseline never selected runs with TRUE
  slice_min(mae, n=1, with_ties = FALSE) %>%
  ungroup()

no_change_best <- df_ga %>%
  filter(model_type == "no_change") %>%
  group_by(selected_debate_id) %>%
  summarise(no_change_mae = mean(mae), .groups = "drop")

ga_vs_no_change <- ga_best %>%
  left_join(no_change_best, by = c("selected_debate_id")) %>% # join only on debate id as no_change did not take the use_distinct in its lowest mae runs
  mutate(delta_mae = mae - no_change_mae,
         abm_wins = delta_mae < 0) 

ga_vs_no_change %>%
  group_by(model_type) %>%
  summarise(n = n(), n_missing = sum(is.na(mae) | is.na(no_change_mae)), .groups = "drop")

ga_best %>% count(model_type, selected_debate_id) %>% filter(n > 1)

# summary per model
ga_baseline_summary <- ga_vs_no_change %>%
  group_by(model_type) %>%
  summarise(
    mean_delta = mean(delta_mae, na.rm = TRUE),
    pct_abm_wins = mean(abm_wins, na.rm = TRUE) * 100,
    wilcoxon_p = wilcox.test(mae, no_change_mae, paired = TRUE)$p.value,
    .groups = "drop"
  )
# interpretation: removed use_distinct as no change never selected TRUE for best runs
# no model beats the no_change baseline (bipol has 54.5% win rate but insignificant)
# consensus is closest in p value: 0.08, so it beats no change but only in 38% of cases

# plot for delta_mae per model, colored by win/loss
p_ga_delta <- ga_vs_no_change %>%
  mutate(group_label = paste0(model_type, 
                              ifelse(use_distinct_agents, " (distinct)", " (homog.)"))) %>%
  ggplot(aes(x = factor(selected_debate_id), y = delta_mae, fill = abm_wins)) +
  geom_col() +
  geom_hline(yintercept = 0, linetype = "dashed") +
  scale_fill_manual(values = c("TRUE" = "#2ecc71", "FALSE" = "#e74c3c"),
                    labels = c("TRUE" = "ABM wins", "FALSE" = "Baseline wins")) +
  facet_wrap(~ group_label, ncol = 1) +
  labs(
    title = "GA Best MAE vs No-Change Baseline per Debate",
    x     = "Debate ID",
    y     = "Δ MAE (GA − Baseline)",
    fill  = NULL
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(size = 6, angle = 45, hjust = 1))

print(p_ga_delta)
# interpretation: baseline always wins no matter what

# common debates comparison
common_debates <- intersect(
  unique(df_lhs$selected_debate_id),
  unique(df_ga$selected_debate_id)
)
length(common_debates)
# interpret: 40 common debates, only 4 were covered by lhs and not ga

# filter using common debates
df_lhs_common <- df_lhs %>% filter(selected_debate_id %in% common_debates)
df_ga_common <- df_ga %>% filter(selected_debate_id %in% common_debates)

## GA vs LHS improvement
lhs_best_comp <- df_lhs_common %>%
  group_by(model_type, use_distinct_agents) %>% # use_distinct_agetns here because we are asking across all debates did GA do better than LHS
  #slice_min(mae, n=1, with_ties = FALSE) %>%
  summarise(lhs_best_mae = min(mae), .groups = "drop")


ga_best_comp <- df_ga_common %>%
  group_by(model_type, use_distinct_agents) %>%
  summarise(ga_best_mae = min(mae), .groups = "drop")

lhs_vs_ga <- lhs_best_comp %>%
  left_join(ga_best_comp, by = c("model_type", "use_distinct_agents")) %>%
  filter(model_type != "no_change") %>% # no_change filterd out as there is are no calibration parameters
  mutate(
    improvement_pct = (lhs_best_mae - ga_best_mae) / lhs_best_mae * 100
  )

print(lhs_vs_ga)
# interpretation: LHS consistently outperforms GA despite the 4 uncovered debates
# GA struggled to optimise in the new config

# plots for GA vs lhs
p_lhs_ga <- lhs_vs_ga %>%
  pivot_longer(cols = c(lhs_best_mae, ga_best_mae),
               names_to  = "stage",
               values_to = "best_mae") %>%
  mutate(
    stage       = recode(stage,
                         "lhs_best_mae" = "LHS",
                         "ga_best_mae"  = "GA"),
    group_label = paste0(model_type,
                         ifelse(use_distinct_agents, " (distinct)", " (homog.)"))
  ) %>%
  ggplot(aes(x = group_label, y = best_mae, fill = stage)) +
  geom_col(position = "dodge") +
  scale_fill_manual(values = c("LHS" = "#3498db", "GA" = "#9b59b6")) +
  labs(
    title = "Best MAE: LHS vs GA Calibration",
    x     = NULL,
    y     = "Best MAE",
    fill  = "Stage"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 25, hjust = 1))

print(p_lhs_ga)

## selection of best parameters
ga_best_params <- df_ga %>%
  filter(model_type != "no_change") %>%
  group_by(model_type, use_distinct_agents) %>%
  slice_min(mae, n = 5, with_ties = FALSE) %>%
  summarise(
    best_mae = min(mae),
    convergence_rate_mean = mean(convergence_rate),
    convergence_rate_sd = sd(convergence_rate),
    confidence_threshold_mean = mean(confidence_threshold),
    confidence_threshold_sd = sd(confidence_threshold),
    repulsion_threshold_mean = mean(repulsion_threshold),
    repulsion_threshold_sd = sd(repulsion_threshold),
    repulsion_strength_mean = mean(repulsion_strength),
    repulsion_strength_sd = sd(repulsion_strength),
    .groups = "drop"
  )


#### Annealing bounds selection ####
# clamp regions to ensure only positive values for GA
# Define the columns that need min/max clamping
min_max_cols <- c(
  "cr_min", "cr_max", "ct_min", "ct_max",
  "rs_min", "rs_max", "rt_min", "rt_max",
  "cr_min_sd", "cr_max_sd", "ct_min_sd", "ct_max_sd",
  "rs_min_sd", "rs_max_sd", "rt_min_sd", "rt_max_sd"
)

# Optional buffer to expand ranges slightly
buffer <- 0.05  # change to 0 if you don't want a buffer

# identify best performing parameter combinations per model
# use this to set bounds for GA experiments in GAMA
annealing_regions <- df_ga %>%
  filter(model_type != "no_change") %>%
  group_by(model_type, use_distinct_agents) %>%
  mutate(mae_threshold = quantile(mae, 0.25)) %>%
  filter(mae <= mae_threshold) %>%
  summarize(
    cr_min = min(convergence_rate),
    cr_max = max(convergence_rate),
    cr_max_sd = max(convergence_rate_sd),
    cr_min_sd = min(convergence_rate_sd),
    ct_min = min(confidence_threshold, na.rm = TRUE),
    ct_max = max(confidence_threshold, na.rm = TRUE),
    ct_min_sd = min(confidence_threshold_sd, na.rm = TRUE),
    ct_max_sd = max(confidence_threshold_sd, na.rm = TRUE),
    rs_min = min(repulsion_strength, na.rm = TRUE),
    rs_max = max(repulsion_strength, na.rm = TRUE),
    rs_min_sd = min(repulsion_strength_sd, na.rm = TRUE),
    rs_max_sd = max(repulsion_strength_sd, na.rm = TRUE),
    rt_min = min(repulsion_threshold, na.rm = TRUE),
    rt_max = max(repulsion_threshold, na.rm = TRUE),
    rt_min_sd = min(repulsion_threshold_sd, na.rm = TRUE),
    rt_max_sd = max(repulsion_threshold_sd, na.rm = TRUE),
    best_mae = min(mae),
    mae_threshold_used = first(mae_threshold), # for reference
    n = n(),
    .groups = "drop"
  ) %>%
  mutate(
    cr_min = pmax(cr_min, 0.05), # floor cap at 0.05
    cr_max = pmin(cr_max, 0.5), # ceiling cap at 0.5
    rs_max = pmin(rs_max, 0.2) # cap repulsion strength at 0.2 from first regions generations
  ) %>%
  mutate(across(all_of(min_max_cols), ~ pmax(0, pmin(1, .)))) # clamp to [0,1]

# diagnostic - to check that n isn't too large and grouping works
annealing_regions %>%
  distinct(model_type, use_distinct_agents, mae_threshold_used) %>%
  print()

# minimum range check - flags parameters that are too narrow for GA search
min_range <- 0.05

range_check <- annealing_regions %>%
  mutate(
    cr_range_ok = (cr_max - cr_min) >= min_range,
    ct_range_ok = (ct_max - ct_min) >= min_range,
    rs_range_ok = (rs_max - rs_min) >= min_range,
    rt_range_ok = (rt_max - rt_min) >= min_range,
    cr_sd_range_ok = (cr_max_sd - cr_min_sd) >= min_range,
    ct_sd_range_ok = (ct_max_sd - ct_min_sd) >= min_range,
    rs_sd_range_ok = (rs_max_sd - rs_min_sd) >= min_range,
    rt_sd_range_ok = (rt_max_sd - rt_min_sd) >= min_range,
  ) %>% select(model_type, use_distinct_agents, ends_with("_range_ok"))

# print warning for narrow ranges
narrow_params <- range_check %>%
  pivot_longer(
    cols = ends_with("_range_ok"),
    names_to = "paramter",
    values_to = "range_ok"
  ) %>%
  filter(!range_ok)

if (nrow(narrow_params) > 0) {
  print("WARNING: the following parameters have ranges too narrow for Annealing search:")
  print(narrow_params)
} else {
  print("All parameter ranges sufficient for Annealing search")
}


# bipolarization constraint check
bipol_check <- annealing_regions %>%
  filter(model_type == "bipolarization") %>%
  mutate(constraint_ok = ct_max < rt_min,
         gap = rt_min - ct_max) %>%
  select(model_type, use_distinct_agents, ct_max, rt_min, gap, constraint_ok)

if (any(!bipol_check$constraint_ok)) {
  print("WARNING: bipolarization GA bounds violate repulsion/confidence constraint")
  print("Adjust ct_max or rt_min manually before running GA")
  print(bipol_check %>% filter(!constraint_ok))
} else {
  print("Bipolarization constraint satisfied in all GA bounds")
  print(bipol_check)
}

# BOUNDS GENERATION run generator and write to file
gaml_annealing_output <- generate_gaml_bounds(annealing_regions)
writeLines(gaml_annealing_output, "gaml_ANNEALING_bounds.txt")
cat(gaml_annealing_output, sep = "\n")  # also print to console



#### validation and comparison ####
df_validation <- df_validation %>% 
  filter(selected_debate_id %in% c("1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"))

df_no_change_valid <- df_validation %>%
  filter(model_type == "no_change") %>%
  group_by(debate_label) %>%
  summarise(no_change_mae = mean(mae), .groups = "drop")

valid_vs_baseline <- df_validation %>%
  filter(model_type != "no_change") %>%
  group_by(model_type, debate_label) %>%
  slice_min(mae, n = 1, with_ties = FALSE) %>%
  left_join(df_no_change_valid, by = "debate_label") %>%
  mutate(delta_mae = mae - no_change_mae,
         abm_wins = delta_mae < 0)

print(valid_vs_baseline)

valid_summary <- valid_vs_baseline %>%
  group_by(model_type) %>%
  summarise(
    mean_delta = mean(delta_mae, na.rm = TRUE),
    pct_abm_wins = mean(abm_wins, na.rm = TRUE) * 100,
    wilcoxon_p = tryCatch(wilcox.test(mae, no_change_mae, paired = TRUE)$p.value, error=function(e) NA_real_),
    .groups = "drop")
#### linear regression comparison - EMPIRICAL vs ABM####
# initial comparison using ag data (compares empirical and ABM: final - from csv, initial - from csv)
# then generalizes to batch_abm_mae so that abm mae gets compared with ols_mae
ols_model <- lm(final_attitude ~ initial_opinion, data = df_ag)
df_ag$ols_error <- abs(df_ag$final_attitude - predict(ols_model, df_ag))

# ols aggregation to debate level
ols_mae_debate <- df_ag %>%
  group_by(selected_debate_id, debate_label) %>%
  summarize(
    ols_mae = mean(ols_error),
    .groups = "drop"
  )

# aggregate ABM mae to debate level from df_batch
abm_mae_debate <- df_batch %>%
  group_by(selected_debate_id, model_type, debate_label,
           speaking_mode, use_distinct_agents) %>%
  summarize(
    abm_mae = mean(mae),
    .groups = "drop")

# join on selected deabte id and debate_label
# compute delta / negative delta implies that ABM improve upon ols
comparison_ols <- abm_mae_debate %>%
  left_join(ols_mae_debate, by = c("selected_debate_id", "debate_label")) %>%
  mutate(delta_mae = abm_mae - ols_mae,
         abm_better = factor(delta_mae < 0, levels = c(FALSE,TRUE),
                             labels = c("OLS BETTER", "ABM BETTER")))

# delta computations, descriptives
mean_delta = mean(comparison_ols$delta_mae)
se_delta = sd(comparison_ols$delta_mae) / sqrt(length(comparison_ols$delta_mae)) # SD / sqrt(n)
ci_lower = mean_delta - 1.96 * se_delta
ci_upper = mean_delta + 1.96 * se_delta


# wilcoxon test for abm and ols
wilcox_abm_ols <- wilcox.test(comparison_ols$abm_mae, comparison_ols$ols_mae, paired = TRUE)
t_test_abm_ols <- t.test(comparison_ols$abm_mae, comparison_ols$ols_mae, paired = TRUE)


# combined summary (t test - for SE, CI and mean comparison (is mean delta mae different from zero))
# Wilcoxon can confirm whether result is robust to skewed MAE distribution, median delta mae differs from zero
delta_summary <- data.frame(
  mean_delta = mean_delta,
  se_delta = se_delta,
  ci_lower = ci_lower,
  ci_upper = ci_upper,
  t_test_p_value = t_test_abm_ols$p.value,
  wilcox_test_p_value = wilcox_abm_ols$p.value
)

print(delta_summary)

# significan of ols_model
summary(ols_model)

# plot of delta mae per debate 
base_mae_debate_plot <- ggplot(comparison_ols, aes(x=debate_label, y=delta_mae, fill=abm_better)) +
  geom_col() +
  geom_hline(yintercept = 0, linetype = "dashed") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  labs(title = "Delta MAE per debate",
       x = "Debate Identifier (Label)",
       y = "Delta MAE (ABM - OLS)")

print(base_mae_debate_plot)

# plot of delta_mae per debate, faceted by model_type
model_mae_debate_plot <- ggplot(comparison_ols, aes(x=debate_label, y=delta_mae, fill=model_type)) +
  geom_col(position = position_dodge()) +
  geom_hline(yintercept = 0, linetype = "dashed") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  labs(title = "Delta MAE per debate by model type",
       x = "Debate Identifier (Label)",
       y = "Delta MAE (ABM - OLS)")

print(model_mae_debate_plot)

# add to slides
ppt <- add_to_ppt(ppt, comparison_ols, "OLS abm and empirical", type = "table")
ppt <- add_to_ppt(ppt, delta_summary, "Wilcox test for abm and empirical", type = "table")
ppt <- add_to_ppt(ppt, base_mae_debate_plot, "Delta MAE per debate", type = "plot")
ppt <- add_to_ppt(ppt, model_mae_debate_plot, "Delta MAE per debate by model_type", type = "plot")

#### parameters ####
# parameter correlations with mae 
#### SD is zero for some models as they don't all use the same parameters
params_cor_full <- df_batch %>%
  group_by(model_type, use_distinct_agents, current_experiment_id) %>%
  summarize(
    cor_convergence = cor(convergence_rate, mae),
    cor_confidence = cor(confidence_threshold, mae),
    cor_repulsion_strength = cor(repulsion_strength, mae, use = "complete.obs"), # complete.obs correlations for complete observations
    cor_repulsion_threshold = cor(repulsion_threshold, mae, use = "complete.obs")
  )

# reshape params for heatmap
params_long <- params_cor_full %>%
  pivot_longer(cols = starts_with("cor_"),
               names_to = "parameter",
               values_to = "correlation")

# parameter heatmap with geomtile
params_heatmap <- ggplot(params_long, mapping = aes(x = parameter, y = model_type, fill = correlation)) +
  geom_tile() +
  scale_fill_gradient2(low = "blue", mid = "grey", high = "red", midpoint = 0) +
  facet_wrap(use_distinct_agents ~ model_type) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# parameter interaction regimes /// modify based on sensitivity analysis
# NEED to define regimes based on top 2 influential parameters per model type (rather than hardcoing convergence rate)
param_regimes <- df_batch %>%
  mutate(regimes = paste0(
    ifelse(convergence_rate > 0.3, "Fast", "Slow"))) %>%
  group_by(regimes, model_type) %>%
  summarize(mae_mean = mean(mae))

# convergence analysis
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

# violin plot for convergence cycle distribution per model type (distribution only)
viol_conv_model_type <- ggplot(df_batch, aes(x=model_type, y=convergence_cycle)) +
  geom_violin(trim=TRUE, scale = "width", fill = "grey85") +
  # add boxplot for robust summary
  geom_boxplot(width=0.12, outlier.shape=NA, fill="white") +
  # median point
  stat_summary(fun = median, geom = "point", color = "red", size = 2) +
  facet_wrap(~ speaking_mode) +
  # labels
  labs(
    title = "Distribution of Convergence Cycle by Model Type",
    x = "Model Type",
    y = "Convergence Cycles (lower = faster convergence)"
  ) +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 30, hjust = 1))

print(viol_conv_model_type)

# aggreagte to show comparison between models
df_conv_debate <- df_batch %>%
  group_by(model_type, selected_debate_id, speaking_mode) %>%
  summarize(mean_conv = mean(convergence_cycle), mean_mae = mean(mae), .groups = "drop")

# violin plot comparisoin
box_conv_compar <- ggplot(df_conv_debate, aes(x=model_type, y=mean_conv, fill = speaking_mode)) +
  geom_boxplot(position = position_dodge(width = 0.8)) +
  labs(title = "Convergence Rate Comparison by model type and speaking mode",
    fill = "speaking mode") +
  theme_bw()

# violin plot comparison with speaking mode facet wrap
box_conv_compar_speak <- ggplot(df_conv_debate, aes(x=model_type, y=mean_conv, fill = speaking_mode)) +
  geom_boxplot(position = position_dodge(width = 0.8)) +
  facet_wrap(~ speaking_mode) +
  labs(title = "Convergence Rate Comparison by model type and speaking mode",
       fill = "speaking mode") +
  theme_bw()

print(box_conv_compar_speak)

# trade off plot of convergence by model type and speaking mode, impact on mae
tradeoff_plot <- ggplot(df_conv_debate,
                        aes(x = mean_conv, y = mean_mae, color = speaking_mode)) +
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

print(tradeoff_plot)

#lm model regression full
# setimating effect of convergence (mean conv), speaking mode / interaction does convergence matter differently depending on speakign mode
# control for model type
conv_model <- lm(mean_mae ~ mean_conv * speaking_mode + model_type, data = df_conv_debate)
summary(conv_model)
# conclusions: there is no speed-accuracy trade-off, conv alone and interaciton with speakign mode is insignificant
# model type significatnly predicts predictive accuracry -> complex models don't necessarily outperform simple baselines
# model dynamics matter more than convergence rate!!!

# debate evolution
# convergence vs divergence, shows which models and under which exp conditions models achieve convergence/bipol
conv_diff <- df_batch %>%
  mutate(outcome = ifelse(opinion_variance < 0.1, "Convergence", "Polarization")) %>%
  group_by(model_type, current_condition, outcome) %>%
  summarize(n = n())

# additions to ppt
ppt <- add_to_ppt(ppt, params_cor_full, "Full Parameter Correlations", type = "table")
ppt <- add_to_ppt(ppt, params_heatmap, "Parameter Heatmap", type = "plot")
ppt <- add_to_ppt(ppt, param_regimes, "Parameter Regimes", type = "table")
ppt <- add_to_ppt(ppt, convergence_anal, "Convergence Analysis", type = "table")
ppt <- add_to_ppt(ppt, conv_diff, "Convergence vs divergence - Models achieving convergence", type = "table")


#### debate composition ####
# based on initial mutation to create h and m groups
h_vs_m <- df_batch %>%
  group_by(debate_composition, model_type, speaking_mode, use_distinct_agents) %>%
  summarize(
    mae_mean = mean(mae),
    mae_sd = sd(mae),
    n = n()
  )

# wilcoxon test over debate_level mae
mae_vs_comp_wilcox <- wilcox.test(mae ~ debate_composition, data = df_batch)
# interpret: W = 23152, p-value < 2.2e-16 ----> sig diference, homogeneous debates systematiclal ylower mae

#### speaking mode comparisons ####
speaking_compar <- df_batch %>%
  group_by(speaking_mode, debate_composition, model_type, use_distinct_agents) %>%
  summarize(
    mae_mean = mean(mae),
    mae_sd = sd(mae),
    mean_norm_convergence = mean(normalised_convergence),
    n = n()
  )
# interp: speaking_mode = true, higher normalised convergence
# speaking true and distinct true, higher normalised convergence (takes longer)

levels(factor(df_batch$speaking_mode))
table(df_batch$speaking_mode)

# wilcox test speaking_mode predicting convergence_cycle
speakingmode_vs_convergence_wilcox <- wilcox.test(convergence_cycle ~ speaking_mode, data = df_batch)
# interpretation: data:  convergence_cycle by speaking_mode
# W = 18970, p-value < 2.2e-16 ---> significant differnece in convergence by speaking_cycle (probably mechanic, slower simulaiton)
# speaking mode takes significantly more cycles to converge

# additions to ppt
ppt <- add_to_ppt(ppt, h_vs_m, "Hetero vs homo mae", type = "table")
ppt <- add_to_ppt(ppt, mae_vs_comp_wilcox, "Wilcoxon rank sum for mae by debate composition", type = "regression")
ppt <- add_to_ppt(ppt, speaking_compar, "Convergence based on speaking", type = "table")
ppt <- add_to_ppt(ppt, speakingmode_vs_convergence_wilcox, "Convergence by speaking mode Wilcox rank sum", type = "regression")

#### no change baseline ####
df_no_change <- df_batch %>%
  filter(model_type == "no_change") %>%
  group_by(selected_debate_id, debate_label, debate_composition, current_experiment_id) %>%
  summarize(baseline_mae = mean(mae))


compar_for_no_change <- inner_join(df_batch %>% filter(model_type != "no_change"),
           df_no_change,
           by = c("selected_debate_id", "debate_label")) %>%
  distinct(selected_debate_id, debate_label)
# shows tha tonly 6 debates cna be compared, need to rerun no_change_exp

ppt <- add_to_ppt(ppt, compar_for_no_change, "GA use of no_change, not always comparable", type = "table")


nrow(df_batch$model_type == "no_change")
print(df_no_change)


# join with df_batch for baseline comparison
baseline_comparison <- df_no_change %>%
  left_join(abm_mae_debate, by = c("selected_debate_id", "debate_label"))

nrow(baseline_comparison)

baseline_comparison <- baseline_comparison %>%
  mutate(delta_mae = abm_mae - baseline_mae)
# interp: no change baselie is very competitive with regards to abm (better for the time being)

ppt <- add_to_ppt(ppt, baseline_comparison, "No change comparison with ABM", type = "table")
write_csv(baseline_comparison, "./results/abm-baseline-compar.csv")


#### failures of models and predictions ####
# best parameters per model
# use slice_min(mae, n=1) and then select by model and params
best_params <- df_batch %>%
  group_by(model_type, use_distinct_agents) %>%
  slice_min(mae, n=1) %>%
  select(model_type, use_distinct_agents, convergence_rate, confidence_threshold, repulsion_strength,
         repulsion_threshold, mae, current_condition, selected_debate_id)

print("Best parameters per model")
print(best_params)

# top 10 best parameter sets for each model / group by moel, distinct, then slice_min(mae, n=10), then select model and params, mae
top10_per_model <- df_batch %>%
  group_by(model_type, use_distinct_agents) %>%
  distinct(convergence_rate, confidence_threshold, repulsion_strength,
           repulsion_threshold, .keep_all = TRUE) %>%
  slice_min(mae, n=10) %>%
  select(model_type, use_distinct_agents, convergence_rate, confidence_threshold, repulsion_strength,
         repulsion_threshold, mae, selected_debate_id)

ppt <- add_to_ppt(ppt, top10_per_model, "top 10 params per model", type = "table")

print("top 10 parameters for each model")
print(top10_per_model)
write_csv(top10_per_model, "./results/10-params-model.csv")

#### cluster formation NEED TO WORK ON IMPROVING ####
# cluster formation changes
clusters <- df_batch %>%
  mutate(cluster_change = num_clusters - initial_num_clusters) %>%
  group_by(model_type, selected_debate_id) %>%
  summarize(mean_cluster_change = mean(cluster_change))

ppt <- add_to_ppt(ppt, clusters, "Cluster formations and changes", type = "table")

#### debate level insights ####
## hardest debate to predict
hardest_debates <- df_batch %>%
  group_by(current_experiment_id, current_condition, use_distinct_agents, debate_label) %>%
  summarize(
    mae_mean = mean(mae),
    mae_min = min(mae),
    best_model = model_type[which.min(mae)],
    .groups = 'drop'
  ) %>%
  arrange(desc(mae_mean)) %>%
  head(10)

print("Hardest debates to predict")
print(hardest_debates)
write_csv(hardest_debates, "./results/hardes-debates.csv")

## easiest debates to predict
easiest_debates <- df_batch %>%
  group_by(current_experiment_id, current_condition, use_distinct_agents, debate_label) %>%
  summarize(
    mae_mean = mean(mae),
    mae_min = min(mae),
    best_model = model_type[which.min(mae)],
    .groups = 'drop'
  ) %>%
  arrange(mae_mean) %>%
  head(10)

print("Easiest debates to predict")
print(easiest_debates)
write_csv(easiest_debates, "./results/easiest-debates.csv")

# failure predictions
failures_comp <- df_batch %>%
  mutate(failures = mae > 0.18) %>%
  group_by(model_type, failures) %>%
  summarize(
    mean_convergence = mean(convergence_rate),
    pct_hetero = mean(use_distinct_agents == "true") * 100,
    n_total = n()
  )
ppt <- add_to_ppt(ppt, failures_comp, "Overpredictions", type = "table")

write_csv(failures_comp, "./results/debate_failures.csv")

# predicting bipolarization does opinion variance chance bipol predictions?
range(df_batch$opinion_variance)

var_compar <- df_batch %>%
  mutate(variance_slice = cut(opinion_variance, 
                         breaks = c(0, 0.05, 0.1, 0.15),
                         labels = c("Low", "Medium", "High"))) %>%
  group_by(model_type, variance_slice) %>%
  summarize(
    n_debates = n(),
    mean_mae = mean(mae),
    mean_convergence = mean(convergence_cycle),
    .groups = 'drop')
write_csv(var_compar, "./results/variance-debates.csv")

# investigating why bipol runs fail?
df_check <- df_batch %>%
  filter(opinion_variance > 0.1) %>%
  select(model_type, repulsion_threshold, confidence_threshold, use_distinct_agents)
### all bipol runs have homophily=1.0, repulsion_thresholhd & confidence < 0.2
### causes network fragmentation and extreme bipolarization
### 5x worse predictions

#### stochasticity impact ####
# stochasticity check -- do different seeds give a different mae?
stochasticity_check <- df_batch %>%
  group_by(model_type, use_distinct_agents, selected_debate_id, convergence_rate,
           confidence_threshold, repulsion_threshold, repulsion_strength, current_experiment_id) %>%
  summarize(
    mae_mean = mean(mae),
    mae_sd = sd(mae),
    mae_min = min(mae),
    mae_max = max(mae),
    n_seeds = n(),
    .groups = 'drop'
  ) %>%
  arrange(mae_mean)

print(stochasticity_check)

## USE THIS OVER PREV STOCH
stochasticity_check_1 <- df_batch %>%
  group_by(model_type, use_distinct_agents, selected_debate_id, seed) %>%
  summarize(mae_sd = sd(mae), n = n())
## COMMENTS
### stochasticity is negligible (>90% of debates show SD=0 across seeds)
### MAX SD = 0.026, high model stability
### seed replication can be reduce din future runs


# min and max stochasticity
max(stochasticity_check_1$mae_sd, na.rm = TRUE)
min(stochasticity_check_1$mae_sd, na.rm = TRUE)

## Heterogeneity impact
## does adding SD > 0 improve mae?
heterogeneity_check <- df_batch %>%
  group_by (model_type, use_distinct_agents) %>%
  summarize (
    mae_mean = mean(mae),
    mae_median = median(mae),
    mae_sd = sd(mae),
    n = n(),
    .groups = 'drop'
  )
write_csv(heterogeneity_check, "./results/hetero-impact.csv")

#### BEST ####
## BOSS summary -- need model+hetero combinations, MAE (mean and best), convergence speed, failure rate
## sample size
boss_table <- df_batch %>%
  group_by(model_type, use_distinct_agents) %>%
  summarize(
    MAE = mean(mae),
    Best_MAE = min(mae),
    Convergence_Speed = mean(convergence_cycle), # speed (cycles)
    Failure_Rate = mean(mae > 0.15) * 100, # failure rate (%)
    n = n()
      ) %>%
  arrange(MAE)

write.csv(boss_table, "boss_summary.csv")
view(boss_table)

# which model performs the best overall
model_comparison <- df_batch %>%
  group_by(model_type, current_experiment_id, speaking_mode, use_distinct_agents) %>%
  summarize(
    mae_mean = mean(mae),
    mae_sd = sd(mae),
    mae_min = min(mae),
    mae_max = max(mae)
  ) %>%
  arrange(mae_mean)

print(model_comparison)

# reformating in wide format
model_wide_full <- model_comparison %>%
  select(model_type, use_distinct_agents, mae_mean) %>%
  pivot_wider(names_from = use_distinct_agents, values_from = mae_mean)

names(model_wide_full)

## which model is best for each condition
model_by_condition <- df_batch %>%
  group_by(model_type, current_condition, use_distinct_agents, current_experiment_id) %>%
  summarize (
    mae_mean = mean(mae),
    mae_min = min(mae),
    n_debates = n_distinct(selected_debate_id),
    .groups = 'drop'
  ) %>%
  arrange(current_condition, use_distinct_agents, mae_mean)
print(model_by_condition)
write_csv(model_by_condition, "./results/model-by-condition.csv")

#### Plots ####
# plot of SD vs MAE for each parameter - started with convergence rate SD
ggplot(data = df_batch, mapping = aes(convergence_rate_sd, mae, color = model_type)) +
  geom_point(alpha = 0.5) +
  geom_smooth(method = "loess") + # could change this later
  labs(title = "SD vs MAE for Convergence Rate", 
       x = "SD of Convergence Rate", 
       y = "MAE") +
  theme_bw()

ggsave("SD-MAE-convergence.png",
       path = "../graphics",
       dpi = 300)
### interpretation
### convergence rate heterogeneity alone doesn't predict MAE
### outlier at SD = 0.05 (homophily=1 case previously) / bipol run (MAE = 0.46)
### models overlap heavily




### interpretation
### false shows stronger correlations (convergence strong pos for consensus / homohily srong posi for bipol)
### // false side: bipol -> negative corr with repulsion dynamics / consensus -> neg with confidence_thresh, repul
### true side: adding agetn variation wipes out correlations // noise is more difficult ot calibrate

# model comparison chart
ggplot(model_comparison, aes(x = model_type, y = mae_mean), reorder(model_type, mae_mean)) +
  coord_flip() +
  geom_col(fill = "steelblue") +
  labs(title = "Model Performance Comparison", x = "Model Type", y = "MAE") +
  theme_minimal()
ggsave("Model Comparison.png",
       path = "../graphics",
       dpi = 300)

# hetero impact plot
ggplot(model_comparison, aes(x=model_type, y = mae_mean, fill=use_distinct_agents)) +
  geom_col(position = "dodge") +
  scale_fill_discrete() +
  labs(title = "Heterogeneity Impact", x = "Model Type", y = "MAE", fill = "Agent Type") +
  theme_minimal()
ggsave("Hetero Impact.png",
       path = "../graphics",
       dpi = 300)

# convergences vs accuracy scatter / geom_point
ggplot(df_batch, aes(x=convergence_cycle, y=mae, color = model_type)) +
  geom_point(alpha=0.3) +
  geom_smooth(method="loess")
ggsave("Convergence vs Accuracy.png",
       path = "../graphics",
       dpi = 300)
### interpretation
### models have similar pattern (slight inverted U for consensus)
### outlier for bipol run / no speed-accuracry trade-off --> speed does not predict accuracy

# parameter regime comparison
ggplot(param_regimes, aes(x=regimes, y=mae_mean, fill=model_type)) +
  coord_flip() +
  geom_col(position = "dodge") +
  labs(title = "Parameter Regimes", x = "Regimes", y = "MAE") +
  theme_minimal()
ggsave("Param-REgimes vs MAE.png",
       path = "../graphics",
       dpi = 300)
### interpretation
### high homophily and fast (worse over all models) / best is low homophily and slow convergence
### use homophily <= 0.5 + convergence rate <= 0.2

#### final recommendations ####
final_recommendations <- df_batch %>%
  group_by(model_type) %>%
  slice_min(mae, n=3) %>%
  select(model_type, mae, convergence_rate, confidence_threshold,
         repulsion_threshold, repulsion_strength,
         use_distinct_agents, current_condition
  ) %>%
  arrange(mae)

print("Final Recommendations")
print(final_recommendations)

# final results table
results_table <- df_batch %>%
  group_by(model_type, use_distinct_agents) %>%
  summarize(
    MAE = mean(mae), .groups = 'drop'
  ) %>%
  arrange(model_type, use_distinct_agents)

write.csv(results_table, "results-presentation.csv")

#### save results to csv ####
write.csv(final_recommendations, "calibration_test_parameters.csv")
write.csv(model_comparison, "model_comparison_summary.csv")
