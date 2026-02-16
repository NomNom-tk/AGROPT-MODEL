# Sensitivity Analysis Framework for ABM Study
## Based on Borgonovo et al. (2022) Protocol


## OVERVIEW: Four SA Goals and Their Application

| SA Goal | Definition | Application in Your Study | Method |
|---------|------------|---------------------------|--------|
| **1. Robustness** | Are results stable across reasonable parameter variations? | Do H3-H7 conclusions hold across plausible parameter ranges? | Morris screening, factorial design |
| **2. Factor Prioritization** | Which elements matter most? | Which model elements (social influence params, rules, etc.) most affect MAE? | Sobol indices, random forests |
| **3. Interaction Effects** | How do elements combine? | Do attraction/repulsion thresholds interact? Does debate type moderate parameter effects? | ANOVA, interaction plots |
| **4. Direction of Change** | How do outputs change with inputs? | How does increasing attraction threshold affect attitude convergence? | Modified ICE plots, partial dependence |


## STEP-BY-STEP SA PLAN

### PHASE 1: PRELIMINARY ANALYSIS (Before Main Hypotheses)

**Goal:** Understand model behavior and identify critical elements

#### Step 1.1: One-at-a-Time (OAT) Screening
**Purpose:** Quick initial exploration of parameter space

**Procedure:**
1. Select baseline parameter set (e.g., midpoint of all ranges)
2. For each parametric element in your chart:
   - Vary it from min to max (e.g., 5 values)
   - Hold all other elements constant
   - Run 30 replications per configuration
   - Record MAE, VAE, convergence patterns

**Elements to screen:**
- SI1-SI7 (social influence parameters)
- ARG1-ARG4 (argumentation parameters)
- A11 (memory size)

**Output:** 
- Identify which parameters cause largest MAE changes
- Identify which parameters cause most variance across runs
- Create tornado plots showing parameter sensitivity

**Code snippet:**
```r
# Pseudo-code for OAT analysis
baseline_params <- list(
  attraction_threshold = 1.0,
  repulsion_threshold = 2.0,
  influence_weight = 0.5,
  # ... etc
)

for(param in param_list) {
  param_values <- seq(param$min, param$max, length.out = 5)
  for(value in param_values) {
    current_params <- baseline_params
    current_params[[param$name]] <- value
    
    mae_results <- replicate(30, run_gama_simulation(current_params))
    record_results(param, value, mean(mae_results), var(mae_results))
  }
}
```

#### Step 1.2: Rule Comparison (Non-Parametric Screening)
**Purpose:** Test sensitivity to behavioral rule choices

**Procedure:**
1. For each behavioral rule (B1-B5):
   - Implement 2-3 alternative versions
   - Run with baseline parameters
   - 30 replications each
   - Compare MAE distributions

**Key rules to test:**
- B1: Opinion update mechanism (3 alternatives)
- B2: Partner selection (3 alternatives)
- B3: Argument selection (2 alternatives for arg model)

**Statistical test:** Kruskal-Wallis test (since MAE distributions may not be normal)


### PHASE 2: HYPOTHESIS-SPECIFIC SA

#### For H3, H5, H6 (ABM vs. Regression Comparison)

**SA Goal:** Robustness - Are MAE improvements robust to parameter uncertainty?

**Method:** Morris screening + Bootstrap confidence intervals

**Procedure:**

**Step 2.1: Define Uncertainty Ranges**
Based on Phase 1, define plausible ranges for top 5-7 most influential parameters

Example:
```
attraction_threshold: [0.5, 1.5]
repulsion_threshold: [1.0, 2.5]
influence_weight: [0.2, 0.8]
memory_size: [3, 10]
convergence_rate: [0.05, 0.3]
```

**Step 2.2: Morris Screening**
Generate 100 trajectories through parameter space using Morris method

```r
library(sensitivity)

# Define parameter space
morris_design <- morris(
  model = NULL,
  factors = c("attr_thresh", "rep_thresh", "infl_weight", "mem_size", "conv_rate"),
  r = 100,  # number of trajectories
  design = list(type = "oat", levels = 10, grid.jump = 5),
  binf = c(0.5, 1.0, 0.2, 3, 0.05),  # lower bounds
  bsup = c(1.5, 2.5, 0.8, 10, 0.3)   # upper bounds
)

# Run simulations for each parameter combination
morris_results <- apply(morris_design$X, 1, function(params) {
  # Run GAMA simulation with these parameters
  # Return: difference in MAE between ABM and regression
  mae_abm <- run_abm(params, n_reps = 30)
  mae_regression <- baseline_regression_mae  # Pre-computed
  return(mae_regression - mae_abm)  # Positive = ABM is better
})

# Analyze sensitivity
plot(morris_results)
# Elementary effects show which parameters most affect MAE difference
```

**Step 2.3: Bootstrap Confidence Intervals**
For the "best" parameter configuration found:

```r
# Best parameters from calibration
best_params <- list(...)

# Bootstrap replicates
n_bootstrap <- 1000
bootstrap_results <- replicate(n_bootstrap, {
  mae_abm <- run_abm(best_params, n_reps = 30)
  return(baseline_regression_mae - mae_abm)
})

# 95% CI for MAE improvement
ci_lower <- quantile(bootstrap_results, 0.025)
ci_upper <- quantile(bootstrap_results, 0.975)

# Hypothesis test: Is ABM significantly better?
p_value <- mean(bootstrap_results <= 0)  # Proportion where regression is better
```

**Decision rule:** 
- Accept H3/H5/H6 only if 95% CI excludes zero AND p < 0.05
- Report both point estimate and CI in results

---

#### For H4 (Heterogeneous vs. Homogeneous Debates)

**SA Goal:** Robustness - Does debate type effect hold across parameter variations?

**Method:** Factorial Design with debate type as factor

**Procedure:**

**Step 2.4: 2^k Factorial Design**

```r
# Select k most important parameters from Phase 1 (e.g., k=3)
factors <- list(
  attraction_threshold = c(0.5, 1.5),    # Low, High
  repulsion_threshold = c(1.0, 2.5),     # Low, High
  influence_weight = c(0.2, 0.8)         # Low, High
)

# Generate all combinations (2^3 = 8 configurations)
factorial_design <- expand.grid(factors)

# For each configuration, run both debate types
results <- list()
for(i in 1:nrow(factorial_design)) {
  params <- factorial_design[i, ]
  
  # Run heterogeneous debates
  mae_hetero <- run_abm(params, debate_type = "heterogeneous", n_reps = 50)
  
  # Run homogeneous debates  
  mae_homo <- run_abm(params, debate_type = "homogeneous", n_reps = 50)
  
  results[[i]] <- data.frame(
    config = i,
    params,
    mean_change_hetero = mean(mae_hetero$attitude_change),
    mean_change_homo = mean(mae_homo$attitude_change),
    difference = mean(mae_hetero$attitude_change) - mean(mae_homo$attitude_change)
  )
}

# Analyze: Does heterogeneous > homogeneous across all configs?
results_df <- do.call(rbind, results)
all_positive <- all(results_df$difference > 0)
mean_difference <- mean(results_df$difference)
```

**Visualization:**
- Interaction plot: debate type × parameter values
- Forest plot: effect size of debate type across configurations

---

#### For RQ1 (Exploratory Parameter Effects)

**SA Goal:** Direction of Change - How do parameter variations affect trajectories?

**Method:** Modified ICE plots for stochastic models

**Procedure:**

**Step 2.5: Individual Conditional Expectation (ICE) Plots**

For each key parameter, show how attitude trajectories change:

```r
library(ggplot2)

# Select 20 representative agents across debates
sample_agents <- sample(all_agents, 20)

# For one parameter (e.g., attraction_threshold)
param_values <- seq(0.5, 1.5, by = 0.1)

ice_data <- list()
for(agent in sample_agents) {
  for(param_val in param_values) {
    # Run simulation 10 times with this parameter value
    trajectories <- replicate(10, {
      run_abm_for_agent(agent, attraction_threshold = param_val)
    })
    
    ice_data <- rbind(ice_data, data.frame(
      agent_id = agent,
      param_value = param_val,
      final_attitude = trajectories,
      attitude_change = trajectories - agent$initial_attitude
    ))
  }
}

# Plot: individual trajectories + mean trend
ggplot(ice_data, aes(x = param_value, y = attitude_change)) +
  geom_line(aes(group = interaction(agent_id, replication)), alpha = 0.1) +
  geom_smooth(method = "loess", color = "red", size = 2) +
  labs(title = "Effect of Attraction Threshold on Attitude Change",
       x = "Attraction Threshold",
       y = "Attitude Change (T2 - T1)")
```

**Create ICE plots for:**
- All SI parameters (SI1-SI7)
- Memory size (A11)
- Key ARG parameters (ARG1, ARG2)

---

#### For H7 (Argumentation vs. Social Influence Only)

**SA Goal:** Factor Prioritization - Does argumentation mechanism matter?

**Method:** Variance decomposition (Sobol indices)

**Procedure:**

**Step 2.6: Sobol Sensitivity Analysis**

Compare two model versions:
1. Social influence only
2. Social influence + argumentation

```r
library(sensitivity)

# Define parameter space for BOTH models
params_si_only <- c("attr_thresh", "rep_thresh", "infl_weight", "conv_rate")
params_si_arg <- c("attr_thresh", "rep_thresh", "infl_weight", "conv_rate", 
                   "arg_strength", "memory_size", "attack_prob")

# Sobol design (requires many runs)
n_samples <- 1000
sobol_design_si <- soboljansen(
  model = NULL,
  X1 = data.frame(
    attr_thresh = runif(n_samples, 0.5, 1.5),
    rep_thresh = runif(n_samples, 1.0, 2.5),
    infl_weight = runif(n_samples, 0.2, 0.8),
    conv_rate = runif(n_samples, 0.05, 0.3)
  ),
  X2 = data.frame(
    attr_thresh = runif(n_samples, 0.5, 1.5),
    rep_thresh = runif(n_samples, 1.0, 2.5),
    infl_weight = runif(n_samples, 0.2, 0.8),
    conv_rate = runif(n_samples, 0.05, 0.3)
  ),
  nboot = 100
)

# Run simulations for all parameter combinations
# This will be computationally expensive!
results_si <- apply(sobol_design_si$X, 1, function(params) {
  run_abm_si_only(params, n_reps = 20)
  # Return MAE
})

# Repeat for SI + Argumentation model
sobol_design_arg <- # ... similar but with more parameters

results_arg <- apply(sobol_design_arg$X, 1, function(params) {
  run_abm_with_arg(params, n_reps = 20)
  # Return MAE
})

# Calculate Sobol indices
tell(sobol_design_si, results_si)
tell(sobol_design_arg, results_arg)

# Compare:
# - Which parameters matter most in each model?
# - Does argumentation reduce sensitivity to other parameters?
# - Overall: mean(MAE_si) vs mean(MAE_arg)
```

**Decision rule for H7:**
- Accept if mean(MAE_arg) < mean(MAE_si) across parameter space
- AND if difference is robust (tested via bootstrap)
- Report which argumentation parameters have highest Sobol indices

---

### PHASE 3: COMPREHENSIVE ROBUSTNESS CHECK

**Goal:** Test all hypotheses simultaneously across uncertainty

**Method:** Latin Hypercube Sampling

**Step 3.1: LHS Design**

```r
library(lhs)

# Include ALL important parameters identified in Phase 1
n_params <- 10  # Adjust based on Phase 1 results
n_samples <- 500  # Computational budget permitting

# Generate LHS design
lhs_design <- randomLHS(n_samples, n_params)

# Transform to actual parameter ranges
param_ranges <- list(
  attr_thresh = c(0.5, 1.5),
  rep_thresh = c(1.0, 2.5),
  # ... etc for all 10 parameters
)

lhs_params <- matrix(NA, n_samples, n_params)
for(i in 1:n_params) {
  lhs_params[, i] <- qunif(lhs_design[, i], 
                           param_ranges[[i]][1], 
                           param_ranges[[i]][2])
}

# Run simulations for all samples
lhs_results <- apply(lhs_params, 1, function(params) {
  # Run ABM with these parameters (30 reps each)
  # Return: MAE, variance, convergence time, etc.
  run_full_abm(params, n_reps = 30)
})

# Analyze:
# - Distribution of MAE across parameter space
# - Regions where ABM beats regression
# - Failure modes (if any)
```

**Step 3.2: Global Sensitivity Analysis**

```r
# Fit random forest to predict MAE from parameters
library(randomForest)

rf_model <- randomForest(
  x = lhs_params,
  y = lhs_results$mae,
  importance = TRUE
)

# Variable importance
importance(rf_model)
varImpPlot(rf_model)

# Partial dependence plots for top parameters
for(param in top_5_params) {
  partialPlot(rf_model, lhs_params, param)
}
```

---

## COMPUTATIONAL REQUIREMENTS

### Estimated Number of Simulations

| Analysis Phase | Configurations | Reps per Config | Total Runs |
|----------------|----------------|-----------------|------------|
| Phase 1.1 (OAT) | ~50 | 30 | 1,500 |
| Phase 1.2 (Rules) | ~10 | 30 | 300 |
| Phase 2.1-2.3 (Morris) | 100 | 30 | 3,000 |
| Phase 2.4 (Factorial) | 16 | 50 | 800 |
| Phase 2.5 (ICE) | 200 | 10 | 2,000 |
| Phase 2.6 (Sobol) | 2,000 | 20 | 40,000 |
| Phase 3.1-3.2 (LHS) | 500 | 30 | 15,000 |
| **TOTAL** | | | **~62,600** |

**Optimization strategies:**
1. Use parallel computing in GAMA
2. Implement efficient caching of results
3. Use surrogate models (e.g., Gaussian process) for expensive Sobol analysis
4. Prioritize: Do Phases 1-2 fully, Phase 3 if time/resources permit

---

## REPORTING REQUIREMENTS

For each hypothesis, report:

1. **Point Estimate**: Mean MAE (or other metric)
2. **Uncertainty**: 95% CI from bootstrap or variance across parameters
3. **Robustness**: How many parameter configurations support the hypothesis?
4. **Sensitivity**: Which parameters most affect the conclusion?
5. **Visualization**: 
   - Tornado plots (Phase 1)
   - Interaction plots (Phase 2.4)
   - ICE plots (Phase 2.5)
   - Sobol indices (Phase 2.6)

**Example results statement:**

"H3 is supported: ABM predictions showed lower MAE than regression (ΔMAE = 0.15, 95% CI [0.08, 0.22], p < 0.001). This result was robust across 87% of tested parameter configurations. Morris screening identified attraction threshold (μ* = 0.45) and influence weight (μ* = 0.38) as most influential on the MAE difference, while repulsion threshold had minimal effect (μ* = 0.05)."

---

## INTEGRATION WITH PROTOCOL

### Add to Methods Section:

**New subsection: "Sensitivity Analysis Protocol"**

"Following Borgonovo et al. (2022), we implement a comprehensive sensitivity analysis to ensure robust conclusions. Our SA protocol addresses four goals:

1. **Robustness**: We test whether model predictions are stable across plausible parameter ranges using Morris screening and factorial designs.

2. **Factor Prioritization**: We identify which model elements most influence predictions using Sobol variance decomposition and random forest variable importance.

3. **Interaction Effects**: We examine how model elements combine using factorial ANOVA and interaction plots.

4. **Direction of Change**: We characterize how outputs respond to input variations using modified Individual Conditional Expectation (ICE) plots adapted for stochastic ABMs.

Our SA proceeds in three phases: (1) preliminary screening to identify critical elements, (2) hypothesis-specific robustness checks, and (3) comprehensive global analysis. All parametric elements are varied across plausible ranges informed by literature and preliminary exploration. Non-parametric elements (behavioral rules, network structures) are tested through systematic comparison of alternative specifications."

### Add to Results Section:

Create subsections for SA results:
- "Preliminary Sensitivity Screening" (Phase 1 results)
- "Hypothesis Robustness Analysis" (Phase 2 results)  
- "Global Sensitivity Analysis" (Phase 3 results)

### Add to Appendix:

- Full parameter ranges table
- Complete Sobol indices for all parameters
- All ICE plots
- Supplementary interaction plots

---

## NEXT STEPS FOR YOU

1. **Complete the Model Elements Chart** (previous file)
   - Fill in all [SPECIFY] values
   - Define precise equations for all parametric elements
   - Write pseudo-code for all behavioral rules

2. **Pilot Test** (before full SA)
   - Run 5-10 simulations with different parameter values
   - Verify GAMA output format is compatible with R analysis
   - Check computational time per simulation
   - Adjust n_reps based on variance observed

3. **Set Up Computational Infrastructure**
   - Parallel computing in GAMA
   - Automated pipeline: GAMA → CSV → R analysis
   - Version control for parameter configurations

4. **Prioritize Based on Resources**
   - If limited time: Focus on Phases 1 and 2
   - If limited computation: Reduce n_samples in Phase 3
   - If specific concerns: Expand analysis for particular hypotheses

Would you like me to elaborate on any specific phase or create code templates for the R/GAMA integration?
