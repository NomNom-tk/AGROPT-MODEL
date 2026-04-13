#plots R:
#depends on: data_processing.R, functions.R

# file source
source("./functions.R")
source("./data_processing.R")
source("./lhs_analysis.R")

# convergence plots from lhs
# violin plot for convergence cycle distribution per model type (distribution only)
viol_conv_model_type <- ggplot(df_lhs, aes(x=model_type, y=convergence_cycle)) +
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

# violin plot comparisoin (df_conv_debate comes from lhs_analysis file)
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
tradeoff_plot <- ggplot(df_conv_debate, aes(x = mean_conv, y = mean_mae, color = speaking_mode)) +
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

# conditional histogram based on threshold
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
