# data sectioning
# pacakge imports
install.packages("dplyr")
install.packages("tidyverse")

# package load
library(dplyr)
library(tidyverse)

# data import
df_base <- read.csv("./data/data_complete_anonymised.csv")

# deabte data seleciton
debate_data <- df_base %>%
  filter(Condition %in% c("Heterogeneous", "Homogeneous"))

control_data <- df_base %>%
  filter(Condition %in% c("Control"))

# select unique debates
unique_debates <- debate_data %>%
  distinct(ID_Group_all, Condition)

# set seed for reproduc
set.seed(123)

test_hetero <- unique_debates %>%
  filter(Condition == "Heterogeneous") %>%
  slice_sample(n = 6)

test_homo <- unique_debates %>%
  filter(Condition == "Homogeneous") %>%
  slice_sample(n = 6)

# bind rows
test_debates <- bind_rows(test_hetero, test_homo)

# extract debate ids
test_ids <- test_debates$ID_Group_all 

print(test_ids)

# split into two different files
test_data <- debate_data %>% filter(ID_Group_all %in% test_ids)
train_data <- debate_data %>% filter(!ID_Group_all %in% test_ids)

# write csvs
write.csv(train_data, "./data/train_data.csv", row.names = FALSE)
write.csv(test_data, "./data/test_data.csv", row.names = FALSE)
write.csv(control_data, "./data/control_data.csv", row.names = FALSE)

# check split
cat("Train Debates:", nrow(distinct(train_data, ID_Group_all)), "\n") # 43 debates
cat("Test Debates:", nrow(distinct(test_data, ID_Group_all)), "\n") # 12 debates
