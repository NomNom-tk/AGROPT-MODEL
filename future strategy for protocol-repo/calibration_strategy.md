# Calibration Strategy for ABM Models
## Filling the Gap in Your Protocol

---

## PROBLEM STATEMENT

Your protocol currently says: "Think about calibration strategy in paragraph below"

This is insufficient because:
1. Calibration determines which parameter values to use for hypothesis testing
2. Poor calibration can invalidate all subsequent analyses
3. The 20/80 train-test split alone doesn't constitute a calibration strategy

## CALIBRATION PHILOSOPHY

### What Are We Calibrating?

**Option A: Free Parameters** (recommended for you)
- Parameters with NO theoretical or empirical guidance
- Examples: attraction threshold, repulsion threshold, convergence rate
- Method: Optimize to match empirical patterns

**Option B: All Parameters** (not recommended)
- Risks overfitting
- Loses theoretical grounding
- Only if you have strong validation set

**Your Approach:** Calibrate social influence parameters (SI1-SI7) and argumentation parameters (ARG1-ARG4) while keeping empirically-grounded values fixed (e.g., initial attitudes from data, debate sizes from data)

### What Are We Calibrating TO?

**Not just MAE!** You need multiple calibration targets that capture different aspects of the empirical data:

1. **Individual-level patterns**
   - Distribution of attitude changes (mean, SD, skewness)
   - Proportion of individuals who changed attitudes substantially (>1 point)
   - Correlation between initial and final attitudes

2. **Debate-level patterns**
   - Mean attitude change per debate
   - Variance in final attitudes within debates
   - Convergence patterns (do attitudes become more similar?)

3. **Global patterns**
   - Overall distribution shift from T1 to T2
   - Preservation of debate-type differences (hetero vs. homo)
   - Clustering patterns in attitude space

**Pattern-Oriented Modeling (POM) Principle:** Match multiple patterns simultaneously to constrain parameter space (Grimm et al., 2005; Railsback & Grimm, 2019)

---

## CALIBRATION STRATEGY: THREE-STAGE PROCESS

### STAGE 1: Define Calibration Targets (Empirical Patterns)

**Step 1.1: Calculate Target Patterns from 20% Calibration Data**

```r
# Load calibration data (20% of debates)
calibration_data <- load_calibration_subset()

# Individual-level targets
individual_targets <- list(
  mean_attitude_change = mean(calibration_data$T2 - calibration_data$T1),
  sd_attitude_change = sd(calibration_data$T2 - calibration_data$T1),
  correlation_T1_T2 = cor(calibration_data$T1, calibration_data$T2),
  prop_large_change = mean(abs(calibration_data$T2 - calibration_data$T1) > 1),
  prop_positive_change = mean(calibration_data$T2 > calibration_data$T1),
  # Distribution shape
  skewness_change = moments::skewness(calibration_data$T2 - calibration_data$T1)
)

# Debate-level targets
debate_targets <- calibration_data %>%
  group_by(debate_id) %>%
  summarize(
    mean_change = mean(T2 - T1),
    final_variance = var(T2),
    convergence = var(T1) - var(T2),  # Negative = divergence
    debate_type = first(debate_type)
  )

debate_summary_targets <- list(
  mean_debate_change = mean(debate_targets$mean_change),
  sd_debate_change = sd(debate_targets$mean_change),
  mean_convergence = mean(debate_targets$convergence),
  # Debate type differences
  hetero_mean_change = mean(debate_targets$mean_change[debate_targets$debate_type == "heterogeneous"]),
  homo_mean_change = mean(debate_targets$mean_change[debate_targets$debate_type == "homogeneous"]),
  debate_type_effect = mean(debate_targets$mean_change[debate_targets$debate_type == "heterogeneous"]) -
                       mean(debate_targets$mean_change[debate_targets$debate_type == "homogeneous"])
)

# Global targets
global_targets <- list(
  global_mean_shift = mean(calibration_data$T2) - mean(calibration_data$T1),
  global_T1_variance = var(calibration_data$T1),
  global_T2_variance = var(calibration_data$T2),
  # Distribution comparison
  ks_statistic = ks.test(calibration_data$T1, calibration_data$T2)$statistic
)

# Save all targets
calibration_targets <- list(
  individual = individual_targets,
  debate = debate_summary_targets,
  global = global_targets
)

saveRDS(calibration_targets, "calibration_targets.rds")
```

**Step 1.2: Visualize Target Patterns**

```r
# Create reference plots
p1 <- ggplot(calibration_data, aes(x = T2 - T1)) +
  geom_histogram(bins = 30) +
  labs(title = "Target: Distribution of Attitude Change")

p2 <- ggplot(calibration_data, aes(x = T1, y = T2)) +
  geom_point(alpha = 0.3) +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed") +
  labs(title = "Target: T1 vs T2 Relationship")

p3 <- ggplot(debate_targets, aes(x = debate_type, y = mean_change)) +
  geom_boxplot() +
  labs(title = "Target: Debate-Level Changes by Type")

# Save these as reference
ggsave("calibration_targets_plots.pdf", gridExtra::grid.arrange(p1, p2, p3))
```

---

### STAGE 2: Parameter Space Exploration

**Goal:** Understand where in parameter space the model can produce realistic outputs

**Step 2.1: Initial Parameter Ranges**

Based on literature and theoretical constraints:

```r
parameter_space <- list(
  # Social influence parameters
  attraction_threshold = c(min = 0.3, max = 2.0),     # Below this: attract
  repulsion_threshold = c(min = 0.5, max = 3.0),      # Above this: repel
  influence_weight = c(min = 0.05, max = 0.95),       # Strength of influence
  convergence_rate = c(min = 0.01, max = 0.5),        # Speed of change
  
  # For bounded confidence model
  homophily_strength = c(min = 0, max = 1),
  
  # For bipolarization model
  negative_influence = c(min = -0.5, max = 0),
  
  # Argumentation parameters (if using)
  memory_size = c(min = 3, max = 10),                 # Integer
  argument_strength_weight = c(min = 0, max = 1),
  attack_success_prob = c(min = 0.5, max = 1)
)
```

**Step 2.2: Latin Hypercube Sampling of Parameter Space**

```r
library(lhs)

# Generate 200 parameter combinations
n_samples <- 200
n_params <- length(parameter_space)

lhs_design <- randomLHS(n_samples, n_params)

# Transform to actual parameter values
param_matrix <- matrix(NA, n_samples, n_params)
colnames(param_matrix) <- names(parameter_space)

for(i in 1:n_params) {
  param_name <- names(parameter_space)[i]
  range <- parameter_space[[param_name]]
  param_matrix[, i] <- qunif(lhs_design[, i], range["min"], range["max"])
}

# Round integer parameters
param_matrix[, "memory_size"] <- round(param_matrix[, "memory_size"])
```

**Step 2.3: Run Simulations for All Parameter Combinations**

```r
# For each parameter combination, run on calibration data
exploration_results <- list()

for(i in 1:n_samples) {
  params <- param_matrix[i, ]
  
  # Run GAMA simulation with these parameters
  # Using calibration debates only
  # Multiple replications to account for stochasticity
  sim_output <- run_gama_simulation(
    params = params,
    debate_data = calibration_data,
    n_replications = 20,
    output = "full"  # Get individual, debate, and global outputs
  )
  
  # Calculate same patterns as empirical targets
  sim_patterns <- calculate_patterns(sim_output)
  
  # Store results
  exploration_results[[i]] <- list(
    params = params,
    patterns = sim_patterns,
    distance = calculate_distance_to_targets(sim_patterns, calibration_targets)
  )
  
  # Progress
  if(i %% 10 == 0) cat("Completed", i, "of", n_samples, "\n")
}

saveRDS(exploration_results, "exploration_results.rds")
```

**Step 2.4: Identify Feasible Region**

```r
# Extract distances
distances <- sapply(exploration_results, function(x) x$distance)

# Find parameter combinations that are "good enough"
threshold <- quantile(distances, 0.2)  # Top 20%
feasible_indices <- which(distances < threshold)

feasible_params <- param_matrix[feasible_indices, ]

# Visualize feasible region
pairs(feasible_params, 
      main = "Feasible Parameter Region (Top 20% Fits)")

# Check if certain regions are systematically excluded
# This informs whether initial ranges were reasonable
```

### STAGE 3: Optimization Within Feasible Region

**Goal:** Find optimal parameter values that best match all calibration targets

**Step 3.1: Define Objective Function**

```r
objective_function <- function(params, calibration_data, calibration_targets, 
                               weights = NULL) {
  # Run simulation
  sim_output <- run_gama_simulation(
    params = params,
    debate_data = calibration_data,
    n_replications = 30,  # More reps for optimization
    output = "full"
  )
  
  # Calculate simulated patterns (averaged across replications)
  sim_patterns <- calculate_patterns(sim_output)
  
  # Calculate distance for each target
  # Individual-level
  ind_dist <- sqrt(
    ((sim_patterns$individual$mean_attitude_change - 
      calibration_targets$individual$mean_attitude_change) / 
     calibration_targets$individual$sd_attitude_change)^2 +
    ((sim_patterns$individual$sd_attitude_change - 
      calibration_targets$individual$sd_attitude_change) / 
     calibration_targets$individual$sd_attitude_change)^2 +
    ((sim_patterns$individual$correlation_T1_T2 - 
      calibration_targets$individual$correlation_T1_T2))^2
    # ... add more individual-level terms
  )
  
  # Debate-level
  deb_dist <- sqrt(
    ((sim_patterns$debate$mean_debate_change - 
      calibration_targets$debate$mean_debate_change) / 
     calibration_targets$debate$sd_debate_change)^2 +
    ((sim_patterns$debate$debate_type_effect - 
      calibration_targets$debate$debate_type_effect))^2
    # ... add more debate-level terms
  )
  
  # Global
  glob_dist <- sqrt(
    ((sim_patterns$global$global_mean_shift - 
      calibration_targets$global$global_mean_shift))^2 +
    ((sim_patterns$global$ks_statistic - 
      calibration_targets$global$ks_statistic))^2
  )
  
  # Weighted sum (default: equal weights)
  if(is.null(weights)) {
    weights <- c(individual = 1/3, debate = 1/3, global = 1/3)
  }
  
  total_distance <- weights["individual"] * ind_dist +
                    weights["debate"] * deb_dist +
                    weights["global"] * glob_dist
  
  return(total_distance)
}
```

**Step 3.2: Optimization Algorithm**

Use multiple optimization approaches to avoid local minima:

**Approach A: Genetic Algorithm** (good for complex landscapes)

```r
library(GA)

# Define parameter bounds
lower_bounds <- sapply(parameter_space, function(x) x["min"])
upper_bounds <- sapply(parameter_space, function(x) x["max"])

# Genetic algorithm
ga_result <- ga(
  type = "real-valued",
  fitness = function(params) -objective_function(params, calibration_data, calibration_targets),
  lower = lower_bounds,
  upper = upper_bounds,
  popSize = 50,
  maxiter = 100,
  run = 20,  # Stop if no improvement for 20 generations
  parallel = TRUE,
  seed = 12345
)

best_params_ga <- ga_result@solution[1, ]
```

**Approach B: Particle Swarm Optimization**

```r
library(pso)

pso_result <- psoptim(
  par = rep(NA, n_params),  # Initial values
  fn = objective_function,
  lower = lower_bounds,
  upper = upper_bounds,
  control = list(
    maxit = 200,
    s = 40,  # Swarm size
    trace = 1,
    REPORT = 10
  ),
  calibration_data = calibration_data,
  calibration_targets = calibration_targets
)

best_params_pso <- pso_result$par
```

**Approach C: Bayesian Optimization** (efficient for expensive simulations)

```r
library(rBayesianOptimization)

# Define bounds as list
bounds_list <- list()
for(param_name in names(parameter_space)) {
  bounds_list[[param_name]] <- parameter_space[[param_name]]
}

bayes_opt_result <- BayesianOptimization(
  FUN = function(...) {
    params <- unlist(list(...))
    -objective_function(params, calibration_data, calibration_targets)
  },
  bounds = bounds_list,
  init_points = 20,   # Initial random exploration
  n_iter = 100,       # Optimization iterations
  acq = "ucb",        # Acquisition function
  kappa = 2.576,
  verbose = TRUE
)

best_params_bayes <- bayes_opt_result$Best_Par
```

**Step 3.3: Compare and Select Best Parameters**

```r
# Run all three "best" parameter sets
candidates <- list(
  GA = best_params_ga,
  PSO = best_params_pso,
  Bayes = best_params_bayes
)

comparison <- lapply(candidates, function(params) {
  distance <- objective_function(params, calibration_data, calibration_targets)
  
  # Also run more replications for stability
  sim_outputs <- replicate(50, {
    run_gama_simulation(params, calibration_data, n_replications = 1)
  }, simplify = FALSE)
  
  # Calculate variance in outputs (stability)
  mae_variance <- var(sapply(sim_outputs, function(x) mean(abs(x$T2_predicted - x$T2_actual))))
  
  list(
    distance = distance,
    mae_variance = mae_variance,
    params = params
  )
})

# Select based on distance AND stability
best_method <- names(which.min(sapply(comparison, function(x) x$distance + 0.1*x$mae_variance)))
final_calibrated_params <- comparison[[best_method]]$params

# Save
saveRDS(final_calibrated_params, "calibrated_parameters.rds")
```

---

## VALIDATION ON HELD-OUT 80%

After calibration, test on the 80% validation set:

```r
validation_data <- load_validation_subset()  # The other 80%

# Run with calibrated parameters
validation_output <- run_gama_simulation(
  params = final_calibrated_params,
  debate_data = validation_data,
  n_replications = 50
)

# Calculate same patterns as calibration
validation_patterns <- calculate_patterns(validation_output)

# Compare to empirical validation patterns
validation_targets <- calculate_patterns(validation_data)

# Report fit on validation set
validation_report <- list(
  individual_MAE = mean(abs(validation_output$T2_predicted - validation_data$T2)),
  debate_MAE = # ... calculate for each debate
  global_KS = ks.test(validation_output$T2_predicted, validation_data$T2)$statistic,
  
  # Pattern matching
  mean_change_error = abs(validation_patterns$individual$mean_attitude_change - 
                          validation_targets$individual$mean_attitude_change),
  correlation_error = abs(validation_patterns$individual$correlation_T1_T2 - 
                          validation_targets$individual$correlation_T1_T2)
  # ... etc
)

# Visualize validation fit
validation_plots <- list(
  predicted_vs_actual = ggplot() + 
    geom_point(aes(x = validation_data$T2, y = validation_output$T2_predicted)) +
    geom_abline(slope = 1, intercept = 0) +
    labs(title = "Validation: Predicted vs Actual T2 Attitudes"),
  
  change_distribution = ggplot() +
    geom_density(aes(x = validation_data$T2 - validation_data$T1), color = "black") +
    geom_density(aes(x = validation_output$T2_predicted - validation_data$T1), color = "red") +
    labs(title = "Validation: Distribution of Attitude Change (black=actual, red=predicted)")
)
```

---

## MODEL-SPECIFIC CALIBRATION NOTES

### For Social Influence Models (Flache et al., 2017)

You're implementing 3 different models - each needs separate calibration:

1. **Simple Averaging Model**
   - Fewer parameters: just influence_weight
   - Faster to calibrate

2. **Bounded Confidence (Deffuant et al.)**
   - Parameters: attraction_threshold, influence_weight
   - May need different thresholds for hetero vs. homo debates

3. **Bipolarization (Mäs & Flache)**
   - Parameters: attraction_threshold, repulsion_threshold, negative_influence
   - Watch for instability (agents flying off to extremes)

**Calibration Strategy:**
- Calibrate each model separately
- Use same objective function and targets
- Compare: which model achieves lowest distance?
- Report all three in sensitivity analysis

### For Argumentation Model

Additional calibration considerations:

**Argument Initialization:**
- How are arguments assigned to agents initially?
  - Option 1: Random from pool based on their T1 attitude
  - Option 2: Extract from debate transcripts (if available)
  - Option 3: Generate synthetic arguments based on position

**Calibration Decision:** If you have debate transcripts, use them to initialize argument pools. Otherwise, synthetic generation is acceptable but document this limitation.

**Memory Size:**
- Test range: 3-10 arguments
- Smaller = more forgetting = potentially more attitude change
- Calibrate via LHS + optimization

---

## HANDLING MULTIPLE RANDOM SEEDS

**Problem:** Your protocol mentions "two different random seeds" - insufficient!

**Solution:**

```r
# For final calibrated parameters, test stability across seeds
n_seeds <- 50
seeds <- sample(1:10000, n_seeds)

seed_results <- lapply(seeds, function(seed) {
  set.seed(seed)
  run_gama_simulation(
    params = final_calibrated_params,
    debate_data = validation_data,
    n_replications = 1,
    seed = seed
  )
})

# Calculate variability
mae_by_seed <- sapply(seed_results, function(x) mean(abs(x$T2_predicted - x$T2_actual)))

# Report
seed_statistics <- list(
  mean_MAE = mean(mae_by_seed),
  sd_MAE = sd(mae_by_seed),
  CI_95 = quantile(mae_by_seed, c(0.025, 0.975)),
  coefficient_of_variation = sd(mae_by_seed) / mean(mae_by_seed)
)

# If CV > 0.1, model is somewhat unstable - report this!
```

---

## REPORTING CALIBRATION IN YOUR PROTOCOL

**Add to Methods Section:**

"**Calibration Procedure:** We calibrated model parameters using a three-stage process following pattern-oriented modeling principles (Grimm et al., 2005). First, we computed calibration targets from 20% of debates, including individual-level patterns (mean and SD of attitude change, T1-T2 correlation), debate-level patterns (mean change per debate, debate-type effects), and global patterns (distribution shifts, variance changes). Second, we explored parameter space using Latin Hypercube Sampling (n=200 combinations) to identify feasible regions. Third, we optimized parameters within the feasible region using genetic algorithms, minimizing weighted distance to all calibration targets simultaneously. The objective function combined individual-level (weight=1/3), debate-level (weight=1/3), and global-level (weight=1/3) pattern distances. We validated calibrated parameters on the remaining 80% of debates, reporting both MAE and pattern reproduction fidelity. Each social influence model (simple averaging, bounded confidence, bipolarization) was calibrated separately. For the argumentation model, we additionally calibrated memory size and argument strength weighting. All calibrations used 30 simulation replications per parameter configuration to account for stochasticity."

**Add to Results Section:**

Create calibration results subsection:
- Table of calibrated parameter values
- Comparison of calibration vs validation fit
- Pattern matching plots (predicted vs actual distributions)
- Stability analysis across random seeds

---

## PRACTICAL TIPS

1. **Start Simple:** Calibrate social influence models first (fewer parameters), then add argumentation

2. **Computational Budget:** 
   - Exploration (Stage 2): ~200 configs × 20 reps = 4,000 runs
   - Optimization (Stage 3): ~2,000 additional runs
   - Validation: 50 reps × multiple seeds = 2,500 runs
   - Total: ~8,500 simulation runs for calibration alone

3. **Parallelize:** Use GAMA's batch mode + R's parallel package

4. **Sanity Checks:**
   - Does the model produce T2 values in plausible range?
   - Are there unrealistic extremes?
   - Do heterogeneous debates behave differently than homogeneous?

5. **Document Failures:** If calibration cannot match certain patterns, report this! It's informative about model limitations.

---

## NEXT STEPS

1. **Complete Model Elements Chart** to know exactly what you're calibrating
2. **Calculate Empirical Targets** from your 20% calibration data
3. **Implement** `run_gama_simulation()` wrapper in R
4. **Run Stage 2 Exploration** to understand parameter space
5. **Run Stage 3 Optimization** for each model variant
6. **Validate** and document results

Would you like me to create R code templates for any of these steps?
