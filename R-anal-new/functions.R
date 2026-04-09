# Functions
# TO INCLUDE: prepare_sensitivity_data / generate_gaml_bounds / add_to_ppt / pivot_params

# CLEARED BUT TEST AGAIN pivot_parameters ####
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

# TODO prepare sensitivity data (need to change or remove // sensitivity analyses no longe ruse this)
prepare_sensitivity_data <- function(df, param_cols, output_cols) {
  df %>%
    mutate(across(all_of(param_cols), ~(. - mean(., na.rm = TRUE)) / sd(., na.rm = TRUE)),
           across(all_of(output_cols), ~ (. - mean(., na.rm = TRUE)) / sd(., na.rm = TRUE)))
}

# TODO-test saving logic ####
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

# CLEARED apply batch mutations ####
apply_batch_mutations <- function(df) {
  
  # guard for required columns
  required_cols <- c("speaking_mode", "use_distinct_agents", 
                     "debate_label", "convergence_cycle")
  missing <- setdiff(required_cols, colnames(df))
  if (length(missing) > 0) {
    stop(paste("apply_batch_mutations: missing required columns:", 
               paste(missing, collapse = ", ")))
  }
  
  # columsn to mutate to numeric
  conv_cols <- c("convergence_rate", "confidence_threshold", "repulsion_strength", "repulsion_threshold",
                 "convergence_rate_sd", "confidence_threshold_sd", "repulsion_strength_sd", "repulsion_threshold_sd",
                 "mae", "initial_variance", "opinion_variance", "seed", "polarization_index", "neutral_zone_width", "mean_net_repulsion_abs"
  )
  
  # guard to convert only columns that exist in the df
  existing_conv_cols <- intersect(conv_cols, colnames(df))
  
  df %>%
    mutate(across(all_of(existing_conv_cols), ~ as.numeric(gsub(",", ".", trimws(.))))) %>%
    mutate(
      speaking_mode = factor(speaking_mode, levels = c("true", "false")), # changed to factor for wilcox tests
      use_distinct_agents = use_distinct_agents == "true",
      debate_composition = substr(debate_label, 1, 1),
      normalised_convergence = convergence_cycle / 300, # divided by 300 to normalize (max_cycles is constant)
    )
}

# pcc and prcc function ####
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


# fit_lm for regression and can be integrated into pcc and prcc, defaults are lists declared in data_processing ####
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
# TODO generate gaml bounds ####
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