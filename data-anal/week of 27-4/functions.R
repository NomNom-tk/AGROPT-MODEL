# Functions
# TO INCLUDE: prepare_sensitivity_data / generate_gaml_bounds / add_to_ppt / pivot_params

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

# data loading prepare_data ----
prepare_data <- function(path, version) {
  read.csv(path) %>%
    apply_batch_mutations() %>%
    bipol_constraint_filter() %>%
    mutate(version = version)
}
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

# TODO prepare_interactions for df_interactions ----
prepare_interactions <- function(path) {
  read.csv(path, sep = ",") %>%
    mutate(across(where(~ all(grepl("^-?[0-9,\\.]+([Ee][+-]?[0-9]+)?$", 
                                    na.omit(as.character(.))))), 
                  ~ as.numeric(gsub(",", ".", trimws(.))))) %>%
    mutate(
      selected_debate_id = as.character(selected_debate_id),
      seed = as.character(seed),
      speaking_mode = factor(speaking_mode, levels = c("true", "false")),
      use_distinct_agents = case_when(
        use_distinct_agents == "true" ~ TRUE,
        use_distinct_agents == "false" ~ FALSE,
      ),
      agent_is_saturated = as.logical(agent_is_saturated),
      agent_wrong_direction = as.logical(agent_wrong_direction)
    ) %>%
    filter(speaking_mode == "true")
}
# TODO compute_influence_scores 27/4/26 ----
compute_influence_scores <- function(df) { # use with df_interactions, establish broadcasts and influence
  df %>%
    group_by(model_type, current_condition, selected_debate_id, sender_id) %>%
    summarize(
      influence_score = mean(abs(delta)),
      n_broadcasts = n(),
      .groups = "drop"
    )
}
# TODO compute_susceptibility_scores 27/4/26 ----
compute_susceptibility_scores <- function(df) { # use with df_interactions
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
# TODO combine_df_versions ----
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
# CLEAR compute_ols_baseline ----
compute_ols_baseline <- function(df_ag) {
  model <- lm(final_attitude ~ initial_opinion, data = df_ag)
  
  # predictions
  preds <- predict(model, newdata = df_ag)
  
  # attach error
  df_ag_ols <- df_ag %>%
    mutate(
      ols_pred = preds,
      ols_error = abs(final_attitude - ols_pred)
    )
  
  # global performance metric to compare to abm
  ols_mae_global <- mean(df_ag_ols$ols_error, na.rm = TRUE)
  
  list(model = model,
       data = df_ag_ols,
       ols_mae = ols_mae_global)
}
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
# SEMI_CLEARED apply_batch_mutations / zero all non-useful params in GAMA exp (consensus has SD values) ####
apply_batch_mutations <- function(df) {
  
  df <- df %>%
    filter(model_type != "model_type")
  
  # columns to mutate to numeric
  conv_cols <- c("convergence_rate", "confidence_threshold", "repulsion_strength", "repulsion_threshold",
                 "convergence_rate_sd", "confidence_threshold_sd", "repulsion_strength_sd", "repulsion_threshold_sd",
                 "mae", "initial_variance", "opinion_variance", "seed", "polarization_index", "neutral_zone_width", "mean_net_repulsion_abs",
                 "convergence_cycle")
  
  # guard to convert only columns that exist in the df
  existing_conv_cols <- intersect(conv_cols, colnames(df))
  
  # guard for required columns
  required_cols <- c("speaking_mode", "use_distinct_agents", 
                     "debate_label", "convergence_cycle")
  missing <- setdiff(required_cols, colnames(df))
  if (length(missing) > 0) {
    stop(paste("apply_batch_mutations: missing required columns:", 
               paste(missing, collapse = ", ")))
  } else {
    message("no missing required columns, proceeding with mutations")
  }
  
  
  # mutation for char and logical columns to numeric for future analysis
  df <- df %>%
    mutate(across(all_of(existing_conv_cols), ~ as.numeric(gsub(",", ".", trimws(.))))) %>%
    mutate(
      speaking_mode = factor(speaking_mode, levels = c("true", "false")), # changed to factor for wilcox tests
      use_distinct_agents = case_when(use_distinct_agents == "true" ~ TRUE,
                                      use_distinct_agents == "false" ~ FALSE),
      debate_composition = substr(debate_label, 1, 1),
      normalised_convergence = convergence_cycle / 300, # divided by 300 to normalize (max_cycles is constant)
    ) %>%
    mutate(selected_debate_id = as.character(selected_debate_id),
           seed = as.character(seed)) %>%
    mutate(across(where(~ all(grepl("^-?[0-9,\\.]+([Ee][+-]?[0-9]+)?$", 
                                    na.omit(as.character(.))))), 
                  ~ as.numeric(gsub(",", ".", trimws(.)))))
  
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

# CLEAR pcc and prcc function run_sensi_analysis ####
run_sensi_analysis <- function(df, param_cols_by_model, output_cols) {
  
  sensi_split <- df %>%
    filter(model_type != "no_change") %>%
    group_by(model_type, use_distinct_agents) %>%
    group_split()
  
  # Initialize storage
  pcc_results <- list()  # store results per key-output combination
  prcc_results <- list() # storage for prcc (pcc with rank)
  
  # Loop over each piece in the sensi_split
  for (df_piece in sensi_split) {
    
    # Generate key for lookup
    model_type_val <- as.character(unique(df_piece$model_type)) # key value for results list - unique model type -converted into char
    distinct_val   <- ifelse(unique(df_piece$use_distinct_agents), "TRUE", "FALSE") # value pair for results - distinct agents as chars
    key <- paste(model_type_val, distinct_val, sep="_") # key creation [model, val] separated by _
    
    # key debug
    print(paste("key:", key))
    print(names(param_cols_by_model))
    
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
    
    print(key)
    print(param_cols)
    
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
      
      # PCC Handle single-parameter case
      if (ncol(X) == 1) { # if the number of columns in input X is equal to 1
        # PCC reduces to simple correlation
        pcc_values <- cor(X[[1]], y)
        prcc_values <- cor(X[[1]], y)
        
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
      
    }  # end output loop
  }
  
  # results bind
  
  prcc_results_df <- bind_rows(prcc_results)
  pcc_results_df <- bind_rows(pcc_results)

  #return list
  return(list(
    pcc = pcc_results_df,
    prcc = prcc_results_df))
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
# CLEAR generate_gaml_bounds ####
generate_gaml_bounds <- function(df, buffer = 0.05) {
  
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
# CLEAR bipol_constraint_filter ####
bipol_constraint_filter <- function(df, verbose = TRUE) {
  # check and reconvert any naming problems
  if ("debate" %in% names(df)) {
    df <- df %>% rename(selected_debate_id = debate)
  }
  
  violations <- df %>%
    filter(model_type == "bipolarization",
           neutral_zone_width < 0)
  
  n_violations <- nrow(violations)
  
  # verbose output if there are violations
  if (verbose && n_violations > 0) {
    message(paste(n_violations,
                  "Removed bipolarization rows where there are neutral zone violations", unique(n_violations)))
  } else {
    message(paste("No violations found, good on ya ;-+"))
  }
  
  # only apply to bipolarization rows
  df %>%
    filter(
      model_type != "bipolarization" |
        (model_type == "bipolarization" & neutral_zone_width >= 0)
    )
  
  # return filtered df
  df %>%
    filter(!(model_type == "bipolarization" & neutral_zone_width < 0))
}

# CLEAR param_region_extraction ####
param_region_extraction <- function(df, percentile = 0.25,
                                    cr_max_cap = NULL,
                                    rs_max_cap = NULL,
                                    min_range = 0.05) {
  
  # remove model_type problem row and bipol)constraints
  df <- df %>%
    filter(model_type != "model_type",
               !(model_type == "bipolarization" & neutral_zone_width < 0),
           model_type != "no_change")
  
  # group specific threhsold and filter
  df <- df %>%
    group_by(model_type, use_distinct_agents) %>%
    mutate(mae_threshold = quantile(mae, percentile)) %>%
    filter(mae <= mae_threshold) %>%
    ungroup()
  
  # summarise per group of vars
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
    c("rt_min_sd", "rt_max_sd")
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
    "rs_min", "rs_max", "rt_min", "rt_max",
    "cr_min_sd", "cr_max_sd", "ct_min_sd", "ct_max_sd",
    "rs_min_sd", "rs_max_sd", "rt_min_sd", "rt_max_sd"
  )
  
  # Optional buffer to expand ranges slightly
  buffer <- 0.05  # change to 0 if you don't want a buffer
  
  # Apply clamping and buffer
  df <- df %>%
    mutate(across(all_of(min_max_cols), ~ pmax(0, pmin(1, .)))) 
  
  # minimum range check - flags parameters that are too narrow for GA search
  df <- df %>%
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
    mutate(constraint_ok = ct_max < rt_min,
           gap = rt_min - ct_max) %>%
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
# TODO build_analysis_outputs ----
## 27/4/26: added source and df for interactions, change source to be generalizable
## also added interactions list
build_analysis_outputs <- function(source, 
                              df,
                              df_versions,
                              df_interactions = NULL,
                              df_influence = NULL,
                              df_susceptibility = NULL,
                              sensi,
                              models,
                              comparisons,
                              behavioral,
                              dynamics,
                              regions,
                              plot_fns) {
  
  # --------
  # OUTPUT CONTRACT
  # --------
  outputs <- list(
    source = source,
    
    # DATA
    data = list(
      raw      = df,
      versions = df_versions
    ),
    
    # SENSITIVITY ANALYSIS
    sensitivity = list(
      pcc  = sensi$pcc,
      prcc = sensi$prcc
    ),
    
    # MODELS
    models = models,
    
    # INTERACTIONS
    interactions = list(
      raw = df_interactions,
      influence = df_influence,
      susceptibility = df_susceptibility
    ),
    
    # STATISTICAL COMPARISONS
    # need to contain: selected_debate_id, ols_mae, abm_mae, delta_mae, abm_better
    comparisons = list(
      ols_abm = comparisons$ols_abm
    ),
    
    # BEHAVIORAL ANALYSIS
    behavioral = behavioral,
    
    # DYNAMICS / SYSTEM OUTPUTS
    dynamics = dynamics,
    
    # PARAMETER SPACE / REGIONS
    regions = regions,
    
    # PLOTS (FUNCTIONS, NOT OBJECTS)
    plots = list(
      pcc         = function() plot_fns$pcc(sensi$pcc),
      prcc        = function() plot_fns$prcc(sensi$prcc),
      convergence = function() plot_fns$convergence(df),
      tradeoff    = function() plot_fns$tradeoff(df),
      delta_mae   = function() plot_fns$delta_mae(comparisons$ols)
    )
  )
  return(outputs)
}
# TODO prepare_direcitonal_df 29/4/26 ----
prepare_directional <- function(df) { # use with df_ag
  df_directional <- df %>%
    filter(speaking_mode == "true") %>%
    mutate(empirical_dir = sign(final_attitude - initial_opinion),
           simulated_dir = sign(opinion - initial_opinion),
           correct_dir = empirical_dir == simulated_dir,
           empirical_moved = empirical_dir != 0
           ) %>%
    filter(empirical_moved) 
}

# TODO summarize_directional ----
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
