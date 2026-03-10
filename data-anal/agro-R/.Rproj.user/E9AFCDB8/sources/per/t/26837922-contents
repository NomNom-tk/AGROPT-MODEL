# Agent-level analyses

install.packages("tidyverse")
install.packages("dplyr")
library(tidyverse)
library(dplyr)

# csv load and read //// make sure it is agent file!!!!
df_ag <- read.csv("./data/agent_level_results.csv")

# initial check
print(df_ag$conditions)
nrow(df_ag)
conditions <- unique(df_ag$current_condition)


# do agents with higher convergence rate change more?
## does convergence rate predict opinion change?
agent_behavior <- df_ag %>%
  mutate(
    abs_opinion_change = abs(opinion_change)
  )

## correlation test
cor.test(agent_behavior$convergence_rate,
         agent_behavior$abs_opinion_change)

print(df_ag$individual_error)

# does agent confidence threshold predict error?
confi_error_pred <- df_ag %>%
  group_by(model_type, use_heterogeneous_agents) %>%
  summarize(
    cor_ag_conv = cor(agent_convergence_rate, individual_error),
    cor_ag_repul_thresh = cor(agent_repulsion_threshold, individual_error),
    cor_ag_repul_str = cor(agent_repulsion_strength, individual_error),
    cor_conf_thresh = cor(agent_confidence_threshold, individual_error)
  )

# overshooting / do agents change in the wrong direction?
## count how many overshot and summarize in table


# change in magnitude by debate type
opi_by_debate <- df_ag |>
  group_by(current_condition, model_type, use_heterogeneous_agents) |>
  summarize(
    mean_change = mean(abs(opinion_change)),
    mean_error = mean(individual_error)
  )

pro_compar <- df_ag |>
  filter(pro_reduction == 1) |>
  mutate(empirical_change = final_attitude - initial_opinion) |>
  group_by(model_type) |>
  summarize(
    simulated = abs(mean(opinion_change)),
    empirical = abs(mean(empirical_change))
  ) |>
  pivot_longer(cols = c(simulated, empirical),
               names_to = "source",
               values_to = "change") |>
  ggplot(aes(x = model_type, y = change, fill = source)) +
  geom_col(position = "dodge") +
  labs(title = "Mean Opinion Change by Pro", x = "Model Type", y = "Change")
ggsave("opinion-by-exp-condition_pro.png", path = "../graphics")
# interpretation
# pro agents have little empirical change but HUGE simulated change
# anti agents have little empirical change but greater simulated change (less severe)
# agents dont change much in reality but change a lot more in simulated models

# pro vs anti (anti focus)
anti_compar <- df_ag |>
  filter(pro_reduction == 0) |>
  mutate(empirical_change = final_attitude - initial_opinion) |>
  group_by(model_type) |>
  summarize(
    simulated = abs(mean(opinion_change)),
    empirical = abs(mean(empirical_change))
  ) |>
  pivot_longer(cols = c(simulated, empirical),
               names_to = "source",
               values_to = "change") |>
  ggplot(aes(x = model_type, y = change, fill = source)) +
  geom_col(position = "dodge") +
  labs(title = "Mean Opinion Change by Anti", x = "Model Type", y = "Change")
ggsave("opinion-by-exp-condition_anti.png", path = "../graphics")

# pro vs anti change
pro_vs_anti <- df_ag %>%
group_by(pro_reduction, model_type) %>%
summarize(
  mean_change = mean(abs(opinion_change)),
  mean_error = mean(individual_error)
)
write_csv(pro_vs_anti, "./results/agent-pro-vs-anti.csv")
# interpretation
# pro agents change more and have worse prediction error
# pattern is not consistent across models

# extreme vs moderate initial opinions
# predicting bipolarization does opinion variance chance bipol predictions?
range(df_ag$initial_opinion) # 0.2384259 0.9722222

opin_compar <- df_ag %>%
  mutate(initial_position = cut(initial_opinion, 
                         breaks = c(0, 0.33, 0.67, 1),
                         labels = c("Anti", "Moderate", "Pro"))) %>%
  group_by(initial_position, model_type) %>%
  summarize(mean_error = mean(individual_error))
write.csv(opin_compar, "./results/agent-opinion-comparison.csv")
## interpretation moderately opinionated agents have lower predictions errors

# which agents are leaders? REWORK
agent_leaders <- df_ag %>%
  mutate(abs_opinion_change = abs(opinion_change)) %>%
  group_by(agent_id, model_type) %>%
  summarize(
    mean_change = mean(abs_opinion_change),
    mean_convergence_rate = mean(convergence_rate),
    mean_confidence_threshold = mean(confidence_threshold),
    .groups = 'drop'
  ) %>% 
  arrange(desc(mean_change)) %>%
  head(20)


# do parameter combinations matter?
param_comb_ag <- df_ag %>%
  mutate(
    profile = case_when(
      convergence_rate > 0.3 & confidence_threshold > 0.6 ~ "Malleable",
      convergence_rate < 0.15 & confidence_threshold < 0.3 ~ "Stubborn",
      TRUE ~ "Moderate"
    )
  ) %>%
  group_by(profile, model_type) %>%
  summarize(
    mean_change = mean(abs(opinion_change)),
    mean_error = mean(individual_error), # come back to this and check column name in csv
    n = n(),
    .groups = 'drop'
  ) 
write_csv(param_comb_ag, "./results/agent-params.csv")

# After your table, test which parameter matters more:
conv_opin_cor <- cor.test(df_ag$agent_convergence_rate, abs(df_ag$opinion_change))
confi_opin_cor <- cor.test(df_ag$agent_confidence_threshold, abs(df_ag$opinion_change))

# data frame for correlations
correlation_results <- data.frame(
  parameter = c("agent_convergence_rate", "agent_confidence_threshold"),
  correlation = c(conv_opin_cor$estimate, confi_opin_cor$estimate),
  p_value = c(conv_opin_cor$p.value, confi_opin_cor$p.value),
  conf_low = c(conv_opin_cor$conf.int[1], confi_opin_cor$conf.int[1]),
  conf_high = c(conv_opin_cor$conf.int[2], confi_opin_cor$conf.int[2])
)
write.csv(correlation_results, "./results/agent-param-correlations.csv", row.names=FALSE)
  