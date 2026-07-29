# Functions
# TO INCLUDE: prepare_sensitivity_data / add_to_ppt / pivot_params


# CLEAR read_clean to clean colnames before all else 7/5/26 (update 27/7/26 strip stray chars from headers)
#' update 28/7/26 adjusted parquet syntax----
read_clean <- function(path) {

  # if input is parquet then read parquet
  if (grepl("\\.parquet$", path, ignore.case  = TRUE)) {
    return(read_parquet_duckdb(path, prudence = "lavish") |> clean_stray_headers())
  }
    
  # otherwise assume csv and check for clean parquet cached version
  parquet_path <- sub("\\.csv$", ".parquet", path, ignore.case = TRUE)

  # check if parquet path exists and if not slow path read clean
  if (file.exists(parquet_path)) {
    return(read_parquet_duckdb(parquet_path, prudence = "lavish") |> clean_stray_headers())
  }
    
  # memory safe fallback for csv read using arrow to avoid duckdb c++ crashes
  cat(sprintf("Generating Parquet Cache: %s\n", basename(parquet_path)))
  arrow_stream <- read_csv_arrow(path, as_data_frame = FALSE)
  write_parquet(arrow_stream, parquet_path)
  rm(arrow_stream)
  gc()

  # duckdb csv read post parquet file generation
  df <- read_parquet_duckdb(parquet_path, prudence = "lavish")
    
  # strip stray quotes, parentehses, and spaces from column headers  
  names(df) <- gsub("['() ]", "", names(df)) 
    
  df <- df %>% 
    clean_names() %>%
    clean_stray_headers()
    
  return(df)
}

# TODO and CHECK clean_stray_headers 29/7/26
clean_stray_headers <- function(df) {
  if (!inherits(df, "duckplyr_df") && !is.data.frame(df)) return(df)

  # identify anchor/first column if its null or na return base df
  first_column <- names(df)[1]
  if (is.null(first_column) | is.na(first_column)) return(df)

  # clean the names for the first col in file
  clean_col_name <- gsub("[^a-zA-Z0-9_]", "", first_column)

  # ensure lazy duckdb evaluation without copying rows into R RAM
  df <- df |>
    dplyr::filter(
        is.na(.data[[first_column]]) |
        gsub("[^a-zA-Z0-9_]", "", as.character(.data[[first_column]])) != clean_col_name
    )

  return(df)
}

# TODO and CHECK append_metadata 28/5/26 ----
## purpose: provenance travels with dfs, provides objects to call in analysis files and in rmd
append_metadata <- function(df, config, version = NA) {
  df %>% 
    mutate(
      run_type = config$run_type,
      composition_scope = config$composition_scope,
      version = version
    )
}
# TODO and CHECK composition_filter 27/5/26 ----
## purpose: centralizes filtering logic, removes duplicate code
## update 2/6/26, dynamic column detection and stop condition
apply_composition_filter <- function(df, config) {
  if (is.null(df) || nrow(df) == 0 || is.null(config$composition_scope) || tolower(trimws(config$composition_scope)) == "all") {
    return(df)
  }
  
  # dynamic column detection strategy
  target_col <- case_when(
    "debate_composition" %in% colnames(df) ~ "debate_composition",
    "selected_debate_id" %in% colnames(df) ~ "selected_debate_id",
    "debate_label" %in% colnames(df) ~ "debate_label",
    TRUE ~ NA_character_ # 2/6/26 updated guard to NA_char (case_when will populate NA character as other columsn to check are chars)
  )
  
  if (is.null(target_col)) {
    stop("Composition filter failed: df contains no recognizable debate identifiers")
  }
  
  df <- df %>%
    filter(str_starts(tolower(trimws(.data[[target_col]])), tolower(trimws(config$composition_scope))))
  
  return(df)
}
# TODO empirical_prep 27/7/26 (checked var names to match read_clean formatting) ----
empirical_prep <- function(path) {
  read_clean(path) %>%
    mutate(index_t0_check = ((db_factor1t0 + db_factor2t0) / 2) - ((db_factor3t0 + db_factor4t0 + db_factor5t0) / 3),
          composition = substr(id_group_all, 1, 1),
          change_t0_t1 = (db_index_t1 - db_index_t0) / 6,
          change_t1_t2 = (db_index_t2 - db_index_t1) / 6,
          change_t0_t2 = (db_index_t2 - db_index_t0) / 6,
          abs_change_t1_t2 = abs(change_t1_t2),
          opinion_strength = abs(db_index_t1 - 0.5), # strength is initial opinion - neutrality point (0.5)
          opinion_strength_cent = opinion_strength - mean(opinion_strength, na.rm = TRUE), # added for colinearity problem in h2
          perceived_norm_cent = perceived_norms - mean(perceived_norms, na.rm = TRUE), # centered perceived norms for h2
          self_control_cent = self_control - mean(self_control, na.rm = TRUE)) # centered self control for h2
}

# load and prepare 27/5/26 ----/
## prepare data handling using read_clean, batch mutations, bipol_contraints
## append meta data attaches, run type, composition scope and verison columns
## aply composition filter to M/H?all filter\
# returns single clean df
load_and_prepare <- function(path, config, version = NA) {
  
  # guard: return NULL if path is NULL or file does not exist
  if (is.null(path) || !file.exists(path)) {
    warning(paste("File read aborted: Path is NULL or doesnt exist at:", path))
    return(NULL)
  }
  
  df <- path %>%
    read_clean() %>%
    apply_batch_mutations() %>%
    bipol_constraint_filter() %>%
    append_metadata(config, version = version) %>%
    apply_composition_filter(config)
  
  return(df)
}

# TODO empirical_stats ----
empirical_stats <- function(df) {
  df <- df %>%
    group_by(Condition) %>%
    summarize(
      mean_change_t0_t1 = mean(change_t0_t1, na.rm = TRUE),
      sd_change_t0_t1 = sd(change_t0_t1, na.rm = TRUE),
      mean_change_t1_t2 = mean(change_t1_t2, na.rm = TRUE),
      sd_change_t1_t2 = sd(change_t1_t2, na.rm = TRUE),
      mean_change_t0_t2 = mean(change_t0_t2, na.rm = TRUE),
      sd_change_t0_t2 = sd(change_t0_t2, na.rm = TRUE),
      n = n()
    )
}
# CLEAR BUT TEST AGAIN pivot_params ####
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
  
  return(df)
}

# TODO prepare sensitivity data (need to change or remove // sensitivity analyses no longe ruse this)
prepare_sensitivity_data <- function(df, param_cols, output_cols) {
  df %>%
    mutate(across(all_of(param_cols), ~(. - mean(., na.rm = TRUE)) / sd(., na.rm = TRUE)),
           across(all_of(output_cols), ~ (. - mean(., na.rm = TRUE)) / sd(., na.rm = TRUE)))
}

# # CLEAR data loading prepare_data ----
# prepare_data <- function(path, version) {
#   read_clean(path) %>%
#     apply_batch_mutations() %>%
#     bipol_constraint_filter() %>%
#     mutate(version = version)
# }

# TODO-test saving logic add_to_ppt ####
add_to_ppt <- function(ppt, content, title, type = "table") {
  ppt <- add_slide(ppt, lyaout = "Title and Content", master = "Office Theme")
  ppt <- ph_with(ppt, value = tile, location = ph_location_type(type = "title"))
  
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

## use
## ppt <- read_pptx()
## add table example: 
## ppt <- add_to_ppt(ppt, model_comparison, "Model Comparison), type = "table)
## ppt <- add_to_ppt(ppt, boss_table, "Summary Results", type = "table)
## save once
# print(ppt, target = "relative path")

# # TODO 12/6/26 no_change_anchor duplicates no_change across TRUE/FALSE for speaking_mode ----
# anchor_baseline_facets <- function(df, condition_col = "speaking_mode", baseline_val = "no_change") {

#   # check if baseline model_type exists in df
#   baseline_rows <- df %>%
#     filter(model_type == baseline_val)

#   if (nrow(baseline_rows) > 0) {
#     # dynamically create explicit TRUE and FALSE data structures
#     nc_true <- baseline_rows %>% mutate(!!sym(condition_col) := TRUE)
#     nc_false <- baseline_rows %>% mutate(!!sym(condition_col) := FALSE)

#     # Strip original unassigned baseline and bind explicit mirrored copies
#     df_clean <- df %>% filter(model_type != baseline_val)
#     df <- bind_rows(df_clean, nc_true, nc_false) %>% distinct()
#     }
#   return(df)
# }

# # CLEAR prepare_interactions for df_interactions ----
# prepare_interactions <- function(path) {
#   read_csv(path, skip = 1) %>% # temp fix using skip lines and no read_clean 7/5/26
#     mutate(
#       selected_debate_id = as.character(selected_debate_id),
#       seed = as.character(seed),
#       use_distinct_agents = case_when(
#         use_distinct_agents == "true" ~ TRUE,
#         use_distinct_agents == "false" ~ FALSE,
#       ),
#       agent_is_saturated = as.logical(agent_is_saturated),
#       agent_wrong_direction = as.logical(agent_wrong_direction)
#     ) %>%
#     filter(speaking_mode == TRUE)
# }

#' Prepare and Clean Interaction Logs updated on 23/7/26
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

  df <- read_clean(path) # removed path due to deletion of first commented header 24/7/26

  # nrow guard fix for lazy count 29/7/26
  n_rows <- df %>% summarise(n = n()) %>% pull(n)
  
  # Guard: Return early if file is empty (e.g., non-speaking model run)
  if (n_rows == 0) {
    message("Notice: Interaction log at '", path, "' contains 0 rows. Skipping.")
    return(df)
  }
  
  df <- df %>%
    mutate(
      selected_debate_id    = as.character(selected_debate_id),
      seed                  = as.character(logged_batch_seed),

      # ensure delta and opinion are numeric cols
      across(any_of(c("delta", "initial_opinion", "opinion", "final_attitude")), as.numeric),

      # convert logical flags  
      across(any_of(c("speaking_mode", "use_distinct_agents", "agent_is_saturated", "agent_wrong_direction")), as.logical)
    ) %>%
    filter(speaking_mode %in% TRUE)
  
  return(df)
}

# TODO compute_influence_scores 27/4/26 (update 27/7/26 empty df and row guard) ----
compute_influence_scores <- function(df) { # use with df_interactions, establish broadcasts and influence
  # guard for empyt data set and warning

  if (is.null(df)) {
    message("Notice: Passed NULL to compute_influence_scores(). Returning NULL.")
    return(NULL)
  }
    
  # nrows extra lazy guard before eval 29/7/26
  n_rows <- df %>% summarise(n = n()) %>% pull(n)
    
  if (n_rows == 0) {
    message("Notice: Dataset passed to compute_influence_scores is empty. Returning NULL.")
    return(NULL)
  }
    
  df %>%
    group_by(model_type, current_condition, selected_debate_id, sender_id) %>%
    summarize(
      influence_score = mean(abs(delta)),
      n_broadcasts = n(),
      .groups = "drop"
    )
}

#' Compute Receiver Susceptibility Scores 27/4/26 (updated 23/7/26 to include guard for the first row)
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
#' 
#' @export
compute_susceptibility_scores <- function(df) { # use with df_interactions
  # guard for empyt data set and warning

  if (is.null(df)) {
    message("Notice: Passed NULL to compute_susceptibility_scores(). Returning NULL.")
    return(NULL)
  }
    
  # nrows extra lazy guard before eval 29/7/26
  n_rows <- df %>% summarise(n = n()) %>% pull(n)
    
  if (n_rows == 0) {
    message("Notice: Dataset passed to compute_susceptibility_scores is empty. Returning NULL.")
    return(NULL)
  }
    
  df %>%
    group_by(model_type, current_condition, selected_debate_id, receiver_id, pro_reduction) %>%
    summarize(
      susceptibility_score = mean(abs(delta)),
      n_exposures = n(),
      pct_saturated = mean(agent_is_saturated),
      pct_wrong_direction = mean(agent_wrong_direction),
      .groups = "drop"
    )
}
# CLEAR combine_df_versions ----
# allows combination of different versions of tests for comparison e.g., convergence_threshold
combine_df_versions <- function(dfs, version_names) {
  
  stopifnot(length(dfs) == length(version_names))
  
  dfs <- lapply(seq_along(dfs), function(i) {
    df <- dfs[[i]]
    df$version <- version_names[i]
    df
  })
  
  dplyr::bind_rows(dfs)
}

# DEADCODE / remove once pipeline finished 22/7/26
# # CLEAR compute_ols_baseline ----
# compute_ols_baseline <- function(df_ag) {
#   model <- lm(final_attitude ~ initial_opinion, data = df_ag)
  
#   # predictions
#   preds <- predict(model, newdata = df_ag)
  
#   # attach error
#   df_ag_ols <- df_ag %>%
#     mutate(
#       ols_pred = preds,
#       ols_error = abs(final_attitude - ols_pred)
#     )
  
#   # global performance metric to compare to abm
#   ols_mae_global <- mean(df_ag_ols$ols_error, na.rm = TRUE)
  
#   list(model = model,
#        data = df_ag_ols,
#        ols_mae = ols_mae_global)
# }
# TODO aggregae_abm_debate ----
aggregate_abm_debate <- function(df, mae_col = "mae") {
  df %>%
    group_by(selected_debate_id, debate_label) %>%
    summarize(
      abm_mae = mean(.data[[mae_col]], na.rm = TRUE),
      r_runs = n(),
      .groups = "drop"
    )
}


#' Apply Batch Mutations and Type Coercion to Simulation Output
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
  
  df <- df %>%
    filter(model_type != "model_type")
  
  # columns to mutate to numeric
  conv_cols <- c("convergence_rate", "confidence_threshold", "repulsion_strength", "repulsion_threshold",
                 "convergence_rate_sd", "confidence_threshold_sd", "repulsion_strength_sd", "repulsion_threshold_sd",
                 "mae", "initial_variance", "opinion_variance", "logged_batch_seed", "polarization_index", "neutral_zone_width", "mean_net_repulsion_abs", "convergence_cycle", "pro_count", "anti_count")
  
  # guard to convert only columns that exist in the df
  existing_conv_cols <- intersect(conv_cols, colnames(df))
  
  # guard for required columns
  required_cols <- c("speaking_mode", "use_distinct_agents", 
                     "debate_label", "convergence_cycle")
  # removed 3/2/26 duplicate conditional addition
  #if ("debate_label" %in% colnames(df)) required_cols <- c(required_cols, "debate_label")
  
  # structural contract check 2/6/26
  missing <- setdiff(required_cols, colnames(df))
  if (length(missing) > 0) {
    stop(paste("apply_batch_mutations: missing required columns:", 
               paste(missing, collapse = ", ")))
  } else {
    message("no missing required columns, proceeding with mutations")
  }
  
  
  # mutation for char and logical columns to numeric for future analysis
  df <- df %>%
    mutate(across(all_of(existing_conv_cols), as.numeric)) %>%
    mutate(
      # for wilcox tests with speaking mode, wrap as logical
      #speaking_mode = case_when(speaking_mode == "true" ~ TRUE,
      #                          speaking_mode == "false" ~ FALSE),
      #use_distinct_agents = case_when(use_distinct_agents == "true" ~ TRUE,
      #                                use_distinct_agents == "false" ~ FALSE),
      normalised_convergence = convergence_cycle / 100, # divided by 100 to normalize, updated to 100 6/5/26
    )
  
  # guards for string tags matching if columns exist 2/6/26
  if ("debate_label" %in% colnames(df)) {
    df <- df %>% mutate(debate_composition = substr(debate_label, 1, 1))
  }
  if ("selected_debate_id" %in% colnames(df)) {
    df <- df %>% mutate(selected_debate_id = as.character(selected_debate_id))
  }
  if ("logged_batch_seed" %in% colnames(df)) {
    df <- df %>% mutate(seed = as.character(logged_batch_seed))
  }
  if ("agent_wrong_direction" %in% colnames(df)) {
    df <- df %>%
      mutate(
        agent_wrong_direction = as.logical(agent_wrong_direction),
        agent_is_saturated = as.logical(agent_is_saturated)
      )
  }

  # collect once to materialize into local RAM before diagnostics
  df <- collect(df)
  message("lazy data frame collected and pulled into R memory, starting NA diagnostics")
  
  # count NAs // recheck logic
  na_check <- colSums(is.na(df))
  problematic <- na_check[na_check > 0]
  print(na_check)
  print(sum(na_check))
  
  # precise location of NAs
  if (length(problematic) > 0) {
    warning(paste("NAs found in columns:", 
                  paste(names(problematic), collapse = ", ")))
    for (col in names(problematic)) {
      na_rows <- which(is.na(df[[col]]))
      warning(paste("Cols:", col, "has NAs at rows:",
                    paste(na_rows, collapse = ", ")))
      }
    } else {
      message(paste("No NA values in rows or columns"))
    }
  
  # return cleaned df
  return(df)
  
}

#' Compute PCC/PRCC/RF Sensitivity Indices per Model/Agent-Type Combination (updated on 24/7/26)
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
#'   variance explained (\eqn{R^2}).
#'
#'   Skips (via \code{next}: keys not found in \code{param_cols_by_model};
#'   param sets that don't intersect with \code{df_piece} columns;
#'   outputs missing from \code{df_piece}; outputs with zero variance (constant value)
#'   since correlation requires variance in both X and Y.
#'
#' @section Side effects:
#'   Prints debug output to console: current key, available
#'   \code{param_cols_by_model} names, selected \code{param_cols}, and
#'   \code{str()}/\code{head()} of the PRCC result object.
#'
#' @seealso \code{plot_pcc_heatmap()}, \code{plot_prcc_heatmap()} for
#'   visualizing the returned dataframes. \code{PCC} column name confirmed
#'   here as \code{"original"} extracted from \code{sensitivity::pcc()}.
run_sensi_analysis <- function(df, param_cols_by_model, output_cols, num_trees = 500) {
  
  sensi_split <- df %>%
    filter(model_type != "no_change") %>%
    group_by(model_type, use_distinct_agents) %>%
    group_split()
  
  # Initialize storage
  pcc_results <- list()  # store results per key-output combination
  prcc_results <- list() # storage for prcc (pcc with rank)
  rf_results <- list() # storage of rf results
  
  # Loop over each piece in the sensi_split
  for (df_piece in sensi_split) {
    
    # Generate key for lookup
    model_type_val <- as.character(unique(df_piece$model_type)) # key value for results list - unique model type -converted into char
    distinct_val   <- ifelse(unique(df_piece$use_distinct_agents), "TRUE", "FALSE") # value pair for results - distinct agents as chars
    key <- paste(model_type_val, distinct_val, sep="_") # key creation [model, val] separated by _
    
    # key debug
    #print(paste("key:", key))
    #print(names(param_cols_by_model))
    
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
    
    #print(key)
    #print(param_cols)
    
    # check if keys are null or not
    if (is.null(param_cols)) {
      print(paste("Skipping key:", key))
      next
    }
    
    # Loop over output columns
    for (output in output_cols) {
      
      if (!output %in% colnames(df_piece)) next   # skip if output missing
      y <- as.numeric(df_piece[[output]])        # define output as numeric, from df_piece associated with output key
      
      # skip outputs with constant values (PCC won't work) - requires variance in both X and Y
      ## zero variance causes division by zero in correlation calc
      if (length(unique(y)) < 2) next

      # RF Combined data frame creation
      rf_data <- cbind(X, target_y = y)
      rf_data <- rf_data[complete.cases(rf_data), , drop = FALSE]
      
      # Handle single-parameter case
      if (ncol(X) == 1) { # if the number of columns in input X is equal to 1
        # PCC reduces to simple correlation
        pcc_values <- cor(X[[1]], y, use = "complete.obs") # linear Pearson
        prcc_values <- cor(X[[1]], y, use = "complete.obs", method = "spearman") # Spearman (rank/monotonic)
        
        pcc_results[[paste(key, output, sep="_")]] <- data.frame( # modified data frame output to match multi param case
          key = key,
          model_type = model_type_val,
          use_distinct_agents = distinct_val,
          output = output,
          parameter = colnames(X),
          PCC = pcc_values
        )
        
        prcc_results[[paste(key, output, sep="_")]] <- data.frame(
          key = key,
          model_type = model_type_val,
          use_distinct_agents = distinct_val,
          output = output,
          parameter = colnames(X),
          PRCC = prcc_values
        )
        
      } else {
      
      # Compute PCC for multiple parameters partial pearson
      pcc_res <- pcc(X, y) # Partial Pearson correlation coefficients using X (param cols input), and y column names converted to numeric
      prcc_res <- pcc(X, y, rank = TRUE) # PRCC
      #print(str(prcc_res))
      #print(head(prcc_res$PCC))
      
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
        parameter = param_names_prcc,
        PRCC = prcc_values
      )
      
      # PCC Store results
      pcc_results[[paste(key, output, sep="_")]] <- data.frame( # results paste, key, output, using "_" as a separator
        # ensure it is a df for analysis, then repeat each value for paste to match all columns (df needs same column length)
        key = rep(key, length(pcc_values)),
        model_type = rep(model_type_val, length(pcc_values)),
        use_distinct_agents = rep(distinct_val, length(pcc_values)),
        output = rep(output, length(pcc_values)),
        parameter = param_names, # distinct because prcc and pcc store cols names based on method
        PCC = pcc_values
      )
      
    }  # end PCC/PRCC if/else

  # RF implementation
  if (nrow(rf_data) >= 10) {

    rf_fit <- ranger::ranger(
      formula = target_y ~ .,
      data = rf_data,
      importance = "permutation",
      num.trees = num_trees,
      seed = 42
    )

    imp_scores <- rf_fit$variable.importance

    rf_results[[paste(key, output, sep = "_")]] <- data.frame(
      key = rep(key, length(imp_scores)),
      model_type = rep(model_type_val, length(imp_scores)),
      use_distinct_agents = rep(distinct_val, length(imp_scores)),
      output = rep(output, length(imp_scores)),
      parameter = names(imp_scores),
      importance = as.numeric(imp_scores),
      r_squared = rep(rf_fit$r.squared, length(imp_scores))
    )  
   }    
  } # end output loop
 } # end df_piece loop
  
  # results bind
  
  prcc_results_df <- bind_rows(prcc_results)
  pcc_results_df <- bind_rows(pcc_results)
  rf_results_df <- bind_rows(rf_results)

  #return list
  return(list(
    pcc = pcc_results_df,
    prcc = prcc_results_df,
    rf = rf_results_df
    ))
}


# CLEAR fit_lm for regression and can be integrated into pcc and prcc, defaults are lists declared in data_processing ####
# example call for bipol_true regressed onto mae and variance: test <- fit_lm(df_batch, param_cols = param_cols_by_model[["bipolarization_TRUE"]], 
# output_cols = c("mae", "opinion_variance"))
fit_lm <- function(df, param_cols, output_cols, standardize = FALSE) {
  
  # ensure param_cols passed are numeric
  df <- df %>%
    mutate(across(all_of(param_cols), ~ as.numeric(.)))
  
  # optional standardization (standardize = TRUE)
  if (standardize) {
    df <- df %>%
      mutate(across(all_of(param_cols), ~(. - mean(., na.rm = TRUE)) / sd(., na.rm = TRUE)),
             across(all_of(output_cols), ~(. - mean(., na.rm = TRUE)) / sd(., na.rm = TRUE))
    )
  }
  # initialize results storage
  lm_results <- list()
  
  # loop over outputs for multiple outputs the curly takes care of storage and lm model fit
  for (var in output_cols) {
    if (!var %in% colnames(df)) next
  
  # build formula
  formula_obj <- as.formula(paste(var, "~", paste(param_cols, collapse = " + ")))
  
  # fit formula
  model <- lm(formula_obj, data = df)
  
  # results store R squared and tidy results
  lm_results[[var]] <- data.frame(
    output = var,
    r_square = summary(model)$r.squared,
    tidy(model)
  )
  }
  
  # r bind results
  lm_results_df <- bind_rows(lm_results, .id = "output")
  
  # return results
  return(lm_results_df)
}
                  
#' Generate GAML Parameter Bound Declarations from Top-Performing Configs 24/7/26 (update to incorporate guards and initialize as characters)
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

  # guard agianst null/empty dataframe
  if (is.null(df) || nrow(df) == 0) {
    warning("Input df to generate_gaml_bounds is empty. Returning empty comment line.")
    return("// WARNING: No valid parameter regions found in upstream LHS evaluation.")
  }
  
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
  
  output_lines <- character(0) # explicit character type initialization
  
  for (i in seq_len(nrow(df))) {
    row <- df[i, ]
    
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
#'
#' @section Known issue:
#'   Lines 26-30 (the standalone \code{df \%>\% filter(...)} block without
#'   reassignment) execute but discard their result — only the subsequent
#'   reassigned \code{df <- df \%>\% filter(...)} actually takes effect. The
#'   earlier block is dead code and can be removed.
bipol_constraint_filter <- function(df, verbose = TRUE) {
  # check and reconvert any naming problems
  if ("debate" %in% names(df)) {
    df <- df %>% rename(selected_debate_id = debate)
  }
  
  # guard rail for df_ag - neutral_zone_width
  if (!"model_type" %in% colnames(df) || !"neutral_zone_width" %in% colnames(df)) {
    if (verbose) {
      message("Skipping neutral zone validation: columns not in dataset")
    }
    return(df)
  }
  
  violations <- df %>%
    filter(model_type == "bipolarization",
           neutral_zone_width < 0)
  
  n_violations <- nrow(violations)
  
  # verbose output if there are violations
  if (verbose && n_violations > 0) {
    message(paste(n_violations,
                  "Removed bipolarization rows where there are neutral zone violations", unique(n_violations)))
  } else if (verbose) {
    message(paste("No violations found, good on ya ;-+"))
  }
  
  # only apply to bipolarization rows
  #df %>%
  #  filter(
  #    model_type != "bipolarization" |
  #      (model_type == "bipolarization" & neutral_zone_width >= 0)
  #  )
  
  # return filtered df
  df <- df %>%
    filter(!(model_type == "bipolarization" & neutral_zone_width < 0))
  
  return(df)
}

# CLEAR param_region_extraction ####
param_region_extraction <- function(df, percentile = 0.25,
                                    cr_max_cap = NULL,
                                    rs_max_cap = NULL,
                                    min_range = 0.05) {
  
  # remove model_type problem row and bipol)constraints
  df <- df %>%
    filter(
      # exclude missing or bad header rows 24/7/26
      !is.na(model_type) & model_type != "model_type" & model_type != "no_change",

      # handle bipolarization constraints safely
      # keeps non bipol models intact and enforces positive width for bipolarization in case it is not the case
      ifelse(model_type == "bipolarization",
             !is.na(neutral_zone_width) & neutral_zone_width >= 0,
             TRUE))
  
  # group specific threhsold and filter
  df <- df %>%
    group_by(model_type, use_distinct_agents) %>%
    mutate(mae_threshold = quantile(mae, percentile)) %>%
    filter(mae <= mae_threshold) %>%
    ungroup()
  
  # summarise per group of vars / added neutral zone width checks 27/7/26
  df <- df %>% 
    group_by(model_type, use_distinct_agents) %>%
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
      nzw_min = min(neutral_zone_width, na.rm = TRUE),
      nzw_max = max(neutral_zone_width, na.rm = TRUE),
      best_mae = min(mae),
      mae_threshold_used = first(mae_threshold), # for reference
      n = n(),
      .groups = "drop"
  )
  
  # apply caps if defined from prev runs
  if (!is.null(cr_max_cap)) {
    df <- df %>%
      mutate(cr_max = pmin(cr_max, cr_max_cap))
  }
  if (!is.null(rs_max_cap)) {
    df <- df %>%
      mutate(rs_max = pmin(rs_max, rs_max_cap))
  }
  
  # zero out useless params (max <= 0.01 means zeroed out in GAMA)
  param_pairs <- list(
    c("ct_min", "ct_max"),
    c("ct_min_sd", "ct_max_sd"),
    c("rs_min", "rs_max"),
    c("rs_min_sd", "rs_max_sd"),
    c("rt_min", "rt_max"),
    c("rt_min_sd", "rt_max_sd"),
    c("nzw_min", "nzw_max") # added neutral zone width 27/7/26
  )
  
  for (pair in param_pairs) {
    min_col <- pair[1]
    max_col <- pair[2]
    df <- df %>%
      mutate(
        !!min_col := ifelse(.data[[max_col]] <= 0.01, NA, .data[[min_col]]),
        !!max_col := ifelse(.data[[max_col]] <= 0.01, NA, .data[[max_col]])
      )
  }
  
  
  # Define the columns that need min/max clamping
  min_max_cols <- c(
    "cr_min", "cr_max", "ct_min", "ct_max",
    "rs_min", "rs_max", "rt_min", "rt_max", "nzw_min", "nzw_max",
    "cr_min_sd", "cr_max_sd", "ct_min_sd", "ct_max_sd",
    "rs_min_sd", "rs_max_sd", "rt_min_sd", "rt_max_sd"
  )
  
  # Optional buffer to expand ranges slightly
  #buffer <- 0.05  # change to 0 if you don't want a buffer
  
  # Apply clamping and buffer
  df <- df %>%
    mutate(across(all_of(min_max_cols), ~ pmax(0, pmin(1, .)))) 
  
  # minimum range check - flags parameters that are too narrow for GA search
  df <- df %>%
    mutate(
      cr_range_ok = (cr_max - cr_min) >= min_range,
      ct_range_ok = is.na(ct_max) | (ct_max - ct_min) >= min_range,
      rs_range_ok = is.na(rs_max) | (rs_max - rs_min) >= min_range,
      rt_range_ok = is.na(rt_max) | (rt_max - rt_min) >= min_range,
      cr_sd_range_ok = is.na(cr_max_sd) | (cr_max_sd - cr_min_sd) >= min_range,
      ct_sd_range_ok = is.na(ct_max_sd) | (ct_max_sd - ct_min_sd) >= min_range,
      rs_sd_range_ok = is.na(rs_max_sd) | (rs_max_sd - rs_min_sd) >= min_range,
      rt_sd_range_ok = is.na(rt_max_sd) | (rt_max_sd - rt_min_sd) >= min_range,
    ) 
  #%>% select(model_type, use_distinct_agents, ends_with("_range_ok"))
  
  # print warning for narrow ranges
  # assign a differnet df to checks
  regions <- df
  range_check <- regions %>%
    pivot_longer(
      cols = ends_with("_range_ok"),
      names_to = "parameter",
      values_to = "range_ok"
    ) %>%
    filter(!range_ok, is.na(range_ok))
  
  if (nrow(range_check) > 0) { # pulls df from warning prints (should equate to zero)
    print("WARNING: the following parameters have ranges too narrow for follow up algorithm search:")
    print(range_check)
  } else {
    print("All parameter ranges sufficient for follow up algorithm search")
  }
  
  
  # bipolarization constraint check
  bipol_check <- regions %>%
    filter(model_type == "bipolarization") %>%
    mutate(constraint_ok = is.na(ct_max) | is.na(rt_max) | (ct_max < rt_min),
           gap = ifelse(!is.na(ct_max) & !is.na(rt_min) | rt_min - ct_max, NA)) %>%
    select(model_type, use_distinct_agents, ct_max, rt_min, gap, constraint_ok)
  
  if (any(!bipol_check$constraint_ok)) {
    print("WARNING: bipolarization bounds violate repulsion/confidence constraint")
    print("Adjust ct_max or rt_min manually before running follow up algorithm")
    print(bipol_check %>% filter(!constraint_ok))
  } else {
    print("Bipolarization constraint satisfied in all algorithm bounds")
    print(bipol_check)
  }
  
  
  # return check
  return(list(
    regions = regions,
    range_check = range_check,
    bipol_check = bipol_check
  ))
  
}

# CLEAR prepare_direcitonal_df 29/4/26 ----
prepare_directional <- function(df) { # use with df_ag
  df_directional <- df %>%
    filter(speaking_mode == TRUE) %>%
    mutate(empirical_dir = sign(final_attitude - initial_opinion), #vector of direction (posi = positive end opin) 
           simulated_dir = sign(opinion - initial_opinion), #vector positive implies simulated opinion is larger
           correct_dir = empirical_dir == simulated_dir, # returns TRUE/FALSE for equal or not
           empirical_moved = empirical_dir != 0
           ) %>%
    filter(empirical_moved) 
}

# CLEAR summarize_directional ----
#' aggregates individual agents to one result per debate
summarize_directional <- function(df) {
  df %>%
    group_by(model_type, current_condition, selected_debate_id) %>%
    summarize(
      pct_correct_dir = mean(correct_dir),
      pct_wrong_dir = mean(agent_wrong_direction),
      mean_mae = mean(abs(opinion - final_attitude)),
      mean_baseline_mae = mean(abs(initial_opinion - final_attitude)),
      n = n(),
      .groups = "drop"
    )
}

#' Summarize Direcitonal Accuracy, Valence split 
#' Summarize Directional Accuracy by Valence Split 1/7/26
#' 
#' Extension of summarize_directional() with a pro_reduction split./ update 23/7 to take into account homogeneous debates where all agents are pro_reduciton == 0
#' removes pro_signed error as it is irrelevant
#' Computes per-debate, per-model, per-condition, and per-valence directional
#' accuracy and signed error metrics across both heterogeneous and homogeneous debates.
#' 
#' @param df Agent-level dataframe (e.g., df_directional_agents) containing:
#'   \code{model_type}, \code{current_condition}, \code{selected_debate_id},
#'   \code{pro_reduction}, \code{correct_dir}, \code{agent_wrong_direction},
#'   \code{opinion}, \code{final_attitude}, and \code{initial_opinion}.
#'
#' @return A summarized data frame in long format with one row per 
#'   \code{model_type} x \code{current_condition} x \code{selected_debate_id} x \code{pro_reduction}.
#'   Columns include \code{pct_correct_dir}, \code{pct_wrong_dir}, 
#'   \code{mean_signed_error}, \code{mean_mae}, \code{mean_baseline_mae}, and \code{n}.
summarize_directional_valence <- function(df) {
  df %>%
    mutate(pro_reduction = as.integer(as.character(pro_reduction))) %>% 
    group_by(model_type, current_condition, selected_debate_id, pro_reduction) %>%
    summarize(
      pct_correct_dir   = mean(correct_dir, na.rm = TRUE), 
      pct_wrong_dir     = mean(agent_wrong_direction, na.rm = TRUE),
      mean_signed_error = mean(opinion - final_attitude, na.rm = TRUE),
      mean_mae          = mean(abs(opinion - final_attitude), na.rm = TRUE),
      mean_baseline_mae = mean(abs(initial_opinion - final_attitude), na.rm = TRUE),
      n                 = n(),
      .groups           = "drop"
    )
}

#' Compute Valence Asymmetry Across Debates 1/7/26 (update 23/7/26 to be comprehensive for homogeneous debates as well)
#' 
#' Takes the output of \code{summarize_directional_valence()} and pivots it wide 
#' to compute accuracy and error asymmetry between pro (1) and anti (0) groups.
#' Accommodates both heterogeneous and homogeneous debates; single-valence 
#' (homogeneous) debates produce \code{NA} for asymmetry metrics.
#' 
#' @param df Aggregated agent-level dataframe from \code{summarize_directional_valence()} 
#'   containing: \code{model_type}, \code{current_condition}, \code{selected_debate_id}, 
#'   \code{pro_reduction}, \code{pct_correct_dir}, \code{pct_wrong_dir}, 
#'   \code{mean_signed_error}, \code{mean_mae}, \code{mean_baseline_mae}, and \code{n}.
#' 
#' @return A dataframe in wide format with one row per debate x model x condition. 
#'   Contains separate columns for pro (\code{_1}) and anti (\code{_0}) metrics, 
#'   alongside derived asymmetry columns (\code{accuracy_asymmetry}, \code{error_asymmetry}).
compute_valence_asymmetry <- function(df) {
  if (is.null(df) || nrow(df) == 0) return(NULL)
    
  df %>%
    mutate(pro_reduction = factor(as.character(pro_reduction), levels = c("0", "1"))) %>%
    select(model_type, current_condition, selected_debate_id, pro_reduction,
           pct_correct_dir, mean_signed_error, mean_mae) %>%
    pivot_wider(
      names_from   = pro_reduction,
      values_from  = c(pct_correct_dir, mean_signed_error, mean_mae),
      names_expand = TRUE
    ) %>%
    mutate(
      accuracy_asymmetry = pct_correct_dir_1 - pct_correct_dir_0, 
      error_asymmetry    = mean_signed_error_1 - mean_signed_error_0
    )
}
        

#' Build Per-Agent Influence Network Metrics (Debate-Level and Aggregate) 6/5/26
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
  if (is.null(df) || nrow(df) == 0) {
    message("INput dataframe df is empty or NULL. Skipping Network build")
    return(NULL)
  }
    
  # prepare edge list
  edges <- df %>%
    mutate(sender_id = as.character(sender_id),
           receiver_id = as.character(receiver_id),
           delta = as.numeric(as.character(delta))) %>%
    filter(!is.na(sender_id), !is.na(receiver_id), !is.na(delta)) %>%
    group_by(sender_id, receiver_id, selected_debate_id, model_type) %>%
    summarize(
      edge_weight = mean(abs(delta)),
      n_interactions = n(),
      .groups = "drop"
    ) %>%
    filter(edge_weight > 0)
  
  # initial list to split edges df by debate_id and model_type
  edge_split <- group_split(edges, selected_debate_id, model_type)
  
  # edge graphs for each debate_id and model_type combination
  # extract debate and model from initial df, then compute on graph object
  node_metrics <- map(edge_split, .progress = TRUE, ~ {
    debate <- unique(.x$selected_debate_id)[1]
    model <- unique(.x$model_type)[1]
    g <- graph_from_data_frame(.x, directed = TRUE)
    
    # metrics computations
    in_str <- strength(g, mode = "in", weights = E(g)$edge_weight) # weighted in-strength per node (total influence received)
    out_str <- strength(g, mode = "out", weights = E(g)$edge_weight) # weight out per node (total influence exerted)
    between <- betweenness(g, directed = TRUE, weights = E(g)$edge_weight) # betweennes centrality/node (bridge agents between clusters)
    graph_density <- edge_density(g) # proportion of possible edges that exist in network
    mean_in_str <- mean(in_str) # mean susceptibility across all agents in debate
    mean_out_str <- mean(out_str) # mean influence exerted across all agents in debate
    isolated_nodes <- sum(degree(g) == 0) # agents with no interactions in this debate
    
    # data frame conversion
    node_metrics_piece <- data.frame(
      agent_id = names(in_str),
      in_strength = in_str,
      out_strength = out_str,
      betweenness = between,
      graph_density = graph_density,
      mean_in_strength = mean_in_str,
      mean_out_strength = mean_out_str,
      isolated_nodes = isolated_nodes,
      selected_debate_id = debate,
      model_type = model
    )
  }) %>%
    bind_rows()
  
  # aggregate networks per condition
  debate_edges <- df %>%
    mutate(sender_id = as.character(sender_id),
           receiver_id = as.character(receiver_id),
           delta = as.numeric(as.character(delta))) %>%
    filter(!is.na(sender_id), !is.na(receiver_id), !is.na(delta)) %>%
    mutate(sender_id = paste(selected_debate_id, sender_id, sep = "_"),
           receiver_id = paste(selected_debate_id, receiver_id, sep = "_")) %>%
    group_by(sender_id, receiver_id, current_condition, model_type, selected_debate_id) %>%
    summarize(
      edge_weight = mean(abs(delta)),
      n_interactions = n(),
      .groups = "drop"
    ) %>%
    filter(edge_weight > 0)
  
  # set up of edge_list
  agg_edge_split <- group_split(debate_edges, current_condition, model_type)
  
  # aggregate edge graphs
  agg_edge_graphs <- map(agg_edge_split, ~ graph_from_data_frame(.x, directed = TRUE), .progress = TRUE)
  
  # addition of naming fix
  names(agg_edge_graphs) <- map_chr(agg_edge_split, ~ paste(unique(.x$current_condition)[1], unique(.x$model_type)[1], sep = "_"))
  
  # aggregated metrics
  aggregate_metrics <- map(agg_edge_split, .progress = TRUE, ~ {
    current_condition <- unique(.x$current_condition)[1]
    model <- unique(.x$model_type)[1]
    g <- graph_from_data_frame(.x, directed = TRUE)
    
    # metrics calculation on aggregate level
    in_str <- strength(g, mode = "in", weights = E(g)$edge_weight) # weighted in-strength per node across all debates
    out_str <- strength(g, mode = "out", weights = E(g)$edge_weight) # weight out per node across all debates
    between <- betweenness(g, directed = TRUE, weights = E(g)$edge_weight) # bridge agents between clusters across all debates
    graph_density <- edge_density(g) # proportion of possible edges that exist in network
    mean_in_str <- mean(in_str) # mean susceptibility across all agents in debate
    mean_out_str <- mean(out_str) # mean influence exerted across all agents in debate
    isolated_nodes <- sum(degree(g) == 0) # agents with no interactions in this debate
    
    # data frame conversion
    data.frame(
      agent_id = names(in_str),
      in_strength = in_str,
      out_strength = out_str,
      betweenness = between,
      graph_density = graph_density,
      mean_in_strength = mean_in_str,
      mean_out_strength = mean_out_str,
      isolated_nodes = isolated_nodes,
      current_condition = current_condition,
      model_type = model
    )
  }) %>%
    bind_rows()
  
  # agent_static_attributes, filter raw attributes / one row per agent, per debate
  ## 5/6/26
  agent_static_attributes <- df_attributes %>%
    select(agent_id, selected_debate_id, current_condition, pro_reduction, agent_is_saturated) %>%
    group_by(agent_id, selected_debate_id) %>%
    summarize(
      current_condition = first(current_condition),
      pro_reduction = first(pro_reduction),
      agent_is_saturated = first(agent_is_saturated),
      .groups = "drop"
    )

  # join with df_ag on agent_id
  combined <- left_join(node_metrics %>% mutate(agent_id = as.character(agent_id)), # test to check coercion
                        agent_static_attributes,
                        by = c("agent_id", "selected_debate_id"))
  print(colnames(combined))
  print(nrow(combined))
  
  # table summary per debate
  per_debate_summary <- combined %>%
    select(agent_id, selected_debate_id, model_type, pro_reduction,
           in_strength, out_strength, betweenness, graph_density, isolated_nodes)
  
  # macro attributes form shielded agent_static_attributes
  macro_attributes <- agent_static_attributes %>%
    select(agent_id, current_condition, pro_reduction, agent_is_saturated) %>%
    distinct(agent_id, current_condition, .keep_all = TRUE)
    
  # table summary for aggregate by condition
  per_condition_summary <- aggregate_metrics %>%
    ungroup() %>%
    mutate(agent_id = str_extract(agent_id, "\\d+$")) %>% # added to extract only numeric part from prefixed ID
    left_join(macro_attributes, by = c("agent_id", "current_condition")) %>%
    group_by(agent_id, current_condition, model_type, pro_reduction) %>%
    reframe( # reframe allows multiple rows per group return
      in_strength = in_strength,
      out_strength = out_strength,
      betweenness = betweenness,
      graph_density = graph_density,
      isolated_nodes = isolated_nodes,
      agent_is_saturated = agent_is_saturated,
      #.by = c(agent_id, current_condition, model_type, pro_reduction) # equivalent to group_by
    )

  # uncomment to check if network data structure matches up and no NAs enter the equation
  # message(paste("per_debate rows:", nrow(per_debate_summary)))
  # message(paste("aggregate rows:", nrow(per_condition_summary)))
  # message(paste("NAs in pro_reduction:", sum(is.na(per_condition_summary$pro_reduction))))
  
  # outputs
  return(list(
    per_debate = per_debate_summary,
    per_debate_full = combined, # node metrics joined with df_ag, per debate
    aggregate_full = aggregate_metrics, # node metrics at condition level
    aggregate = per_condition_summary, # summary of metrics per condition
    graphs = agg_edge_graphs # igraph objects for condition level viz
  ))
  
}

#' Attach Static Agent Attributes to Graph Vertices 7/5/26
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
  vertex_ids <- as.numeric(V(g)$name) # agent_ids as characters converted to numeric
  attributes_reordered <- df %>%
    filter(agent_id %in% vertex_ids) %>% # filter to relevant vertex_id rows
    distinct(agent_id, .keep_all = TRUE) %>%
    mutate(agent_id = as.character(agent_id))

  g_enriched <- as_tbl_graph(g) %>% 
    activate(nodes) %>%
    left_join(attributes_reordered, by = c("name" = "agent_id")) %>%
    distinct(name, .keep_all = TRUE)
  
  return(g_enriched)
}

#' Filter Graph to Top-N Nodes by Out-Strength 13/5/26
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
  g_filtered <- g %>% 
    as_tbl_graph() %>%
    activate(nodes) %>%
    slice_max(order_by = out_strength, n = top_n)
  
  return(g_filtered)
}

#' Filter Graph Edges Below a Weight Threshold 15/5/26
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
  g_filtered_edge <- g %>%
    as_tbl_graph() %>%
    activate(edges) %>%
    filter(edge_weight > threshold) %>%
    activate(nodes) %>%
    filter(!node_is_isolated())
  
  return(g_filtered_edge)
}

# TODO build_network_graph 15/5/26 update, added arrows, node_text and continuous edges ----
build_network_graph <- function(g) {
  ggraph(g, layout = "nicely") + # test with star instead of fr or even stress
    geom_edge_link(aes(width = edge_weight),
                   arrow = arrow(length = unit(3, "mm"), type = "closed"),
                   end_cap = circle(3, "mm")) + # addition of arrows to indicate broadcast direction
    geom_node_text(aes(label = name), repel = TRUE, size = 3) + # repel prevents overlap
    #geom_edge_arc(aes(width = edge_weight, alpha = n_interactions)) +
    geom_node_point(aes(size = out_strength, color = pro_reduction, shape = agent_is_saturated)) +
    scale_edge_width_continuous(range = c(0.5, 3)) +
    theme(legend.position = "bottom") +
    theme_graph()
}
