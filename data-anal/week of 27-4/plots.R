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
plot_influence_by_model <- function(df) { # use with df_influence
  ggplot(df, aes(x = model_type, y = influence_score, fill = model_type)) +
    geom_violin() +
    #theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
    labs(x = NULL, y = "Influence Score")
}

## saturation rate by condition
## bar chart of pct_saturated form df suscept, group by model type and current condition
plot_satur_by_condition <- function(df) {
  ggplot(df, aes(x = current_condition, y = pct_saturated, fill = model_type)) +
    geom_bar(stat = "identity", position = "dodge") +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
    labs(x = "Condition", y = "% saturated")
}


## wrong direction rate by pro/anti bar chart
## pct wrong direction from df suscept facet by model type, colored by pro_reduction
### is overestimation asymmetric between pro and anti agents
plot_dir_by_pro <- function(df) {
  ggplot(df, aes(x = model_type, y = pct_wrong_direction, 
                 fill = factor(pro_reduction, labels = c("Anti", "Pro")))) +
    geom_bar(stat = "identity", position = "dodge") +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
    labs(x = "Model Type", y = "% Wrong Direction", fill = "Position")
}