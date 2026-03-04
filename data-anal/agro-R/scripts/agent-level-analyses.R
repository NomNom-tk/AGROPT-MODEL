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

# pro vs anti change
pro_vs_anti <- df_batch %>%
  group_by(pro_reduction, model_type) %>%
  summarize(
    mean_change = mean(abs(opinion_change)),
    mean_error = mean(individual_error)
  )

## correlation test
cor.test(agent_behavior$convergence_rate,
         agent_behavior$abs_opinion_change)

# which agents are leaders?
agent_leaders <- df_ag %>%
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
df_ag %>%
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
  
  
  