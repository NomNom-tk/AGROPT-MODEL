# plots
# depends on nothing

# TODO feedback on which plot is better for PCC and PRCC
plot_pcc_all_heatmap <- function(df) {
  ggplot(df, aes(x=parameter, y=output, fill=PCC)) +
    geom_tile(width = 0.9, height = 0.9) +
    #facet_grid(model_type ~ version) +
    facet_wrap(~ version) +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 8),
          axis.text.y = element_text(size = 8))
}

plot_prcc_all_heatmap <- function(df) {
  ggplot(df, aes(x=parameter, y=output, fill=PRCC)) +
    geom_tile(width = 0.9, height = 0.9) +
    facet_grid(~ version) +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 8),
          axis.text.y = element_text(size = 8))
}

plot_pcc_heatmap <- function(df) {
  ggplot(df, aes(x = parameter, y = output, fill = PCC)) +
    geom_tile() +
    scale_fill_gradient2(low = "blue", mid = "grey", high = "red", midpoint = 0) +
    facet_wrap(~ key, scales = "free_x", ncol = 3) +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))
}

plot_prcc_heatmap <- function(df){
  ggplot(df, aes(x = parameter, y = output, fill = PRCC)) +
    geom_tile() +
    scale_fill_gradient2(low = "blue", mid = "grey", high = "red", midpoint = 0) +
    facet_wrap(~ key, scales = "free_x", ncol = 3) +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))
}

# Interaction plots
## influence distribution by model type -- density of influence score faceted by model type
plot_influence_by_model <- function(df) { # use with df_lhs_influence
  ggplot(df, aes(x = model_type, y = influence_score, fill = model_type)) +
    geom_violin() +
    #theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
    labs(x = NULL, y = "Influence Score")
}

## saturation rate by condition
## bar chart of pct_saturated form df suscept, group by model type and current condition
plot_satur_by_condition <- function(df) { # use with df_lhs_susceptibility
  ggplot(df, aes(x = current_condition, y = pct_saturated, fill = model_type)) +
    geom_bar(stat = "identity", position = "dodge") +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
    labs(x = "Condition", y = "% saturated")
}

## plot direcitonal accuracry
### top right and bottom left are correct direction / top let and bottom right are wrong
plot_directional_accuracy <- function(df) { # use with df_lhs_directional
  ggplot(df, aes(x = current_condition, y = pct_correct_dir, fill = model_type)) +
    geom_bar(stat = "identity", position = "dodge") +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
    labs(x = "Condition", y = "% accurate agents")
}

## delta scatter to understand in which direction gaents go
plot_delta_direction_scatter <- function(df) { # use with df_lhs_directional
  df <- df %>%
    mutate(
      simulated_delta = opinion - initial_opinion,
      empirical_delta = final_attitude - initial_opinion
    )
  
  ggplot(df, aes(x = simulated_delta, y = empirical_delta)) +
    geom_point(alpha = 0.3) +
    geom_abline(slope = 1, int = 0) + # perfect prediction line
    geom_hline(intercept = 0, linetype = "dashed") + # no empirical change
    geom_vline(intercept = 0, linetype = "dashed") + # no simulated change
    facet_wrap(~ model_type) +
    theme_minimal() +
    labs(x = "Simulated Change", y = "Empirical Change")
}

## wrong direction rate by pro/anti bar chart
## pct wrong direction from df suscept facet by model type, colored by pro_reduction
### is overestimation asymmetric between pro and anti agents
plot_dir_by_pro <- function(df) { # use with df_lhs_susceptibility
  ggplot(df, aes(x = model_type, y = pct_wrong_direction, 
                 fill = factor(pro_reduction, labels = c("Anti", "Pro")))) +
    geom_bar(stat = "identity", position = "dodge") +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
    labs(x = "Model Type", y = "% Wrong Direction", fill = "Position")
}