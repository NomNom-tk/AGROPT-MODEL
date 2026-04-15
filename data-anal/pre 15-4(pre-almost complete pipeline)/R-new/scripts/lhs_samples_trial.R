#lhs samples trial
install.packages("lhs")
library(lhs)

set.seed(123)
n_samples <- 200

lhs_raw <- randomLHS(n_samples, 2)

samples <- data.frame(
  selected_debate_id = round(lhs_raw[,1] * 43 + 1),  # int [1, 100]
  convergence_rate   = lhs_raw[,2] * 0.4 + 0.1       # float [0.1, 0.5]
)

write.table(samples, "lhs_samples.csv", sep = ",", row.names = FALSE, quote = FALSE, 
            col.names = TRUE)

table(samples$selected_debate_id)
