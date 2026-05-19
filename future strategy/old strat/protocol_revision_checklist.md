# Protocol Revision Checklist
## Integrating ABM Literature Best Practices (Based on Borgonovo et al., 2022)

---

## CRITICAL ADDITIONS NEEDED

### ✅ = Must have before running simulations
### ⚠️ = Highly recommended
### 💡 = Nice to have

---

## SECTION 1: MODEL SPECIFICATION

### ✅ 1.1 Complete Model Elements Documentation

**Current Status:** Vague description of ABM implementation

**Required Changes:**

- [ ] **Create comprehensive model element chart** (see `model_elements_chart.md`)
  - List ALL parametric elements with ranges
  - List ALL non-parametric elements with alternatives
  - For each element, specify: type, default, range, source
  
- [ ] **Write out precise mathematical formulations**
  - Opinion update equations for each social influence model
  - Similarity calculation formula
  - Argument strength calculation
  - Weight/threshold definitions
  
- [ ] **Provide pseudo-code for behavioral rules**
  - Partner selection algorithm
  - Argument selection logic
  - Memory management
  - Update procedures

**Where to Add:** New subsection in Methods: "3.1 Agent-Based Model Specification"

**Example Template:**
```
3.1 Agent-Based Model Specification

3.1.1 Agent Characteristics
Agents represent individual debate participants, each initialized with:
- State variables: [list from chart]
- Behavioral rules: [describe with pseudo-code]

3.1.2 Social Influence Models
We implement three models from Flache et al. (2017):

Model 1: Simple Averaging
Opinion update: x_i(t+1) = x_i(t) + μ * (x_j(t) - x_i(t))
where μ ∈ [0,1] is the influence weight

Model 2: Bounded Confidence (Deffuant et al., 2000)
Agents interact if |x_i - x_j| < ε (attraction threshold)
Update: [equation]

[Continue for all models...]

3.1.3 Argumentation Extension
[Describe argument structure, attack relations, etc.]
```

---

### ✅ 1.2 Specify the 5 Subfactors

**Current Status:** Mentioned but never named

**Required Changes:**

- [ ] **Explicitly list the 5 subfactors** that constitute T1 attitude
- [ ] **Explain how they combine** to form overall attitude
- [ ] **Provide measurement details** (scale, range, interpretation)

**Example:**
```
The pre-deliberation attitude (T1) is composed of five subfactors measured on 7-point Likert scales:
1. Environmental concern (1=not at all concerned, 7=extremely concerned)
2. Health motivation (1=not important, 7=very important)
3. [subfactor 3 name and scale]
4. [subfactor 4 name and scale]
5. [subfactor 5 name and scale]

Overall attitude is calculated as: Attitude_T1 = mean(subfactor1, ..., subfactor5)
[or specify if it's a weighted average or other combination]
```

---

### ⚠️ 1.3 Network Topology Specification

**Current Status:** "neighbors based on opinion similarity" - too vague

**Required Changes:**

- [ ] **Define "neighbor" precisely**
  - Within debate only? Or across debates?
  - Based on absolute difference or ranked similarity?
  
- [ ] **Specify interaction structure**
  - Fully connected within debate?
  - K-nearest neighbors?
  - Dynamic network that changes with opinions?
  
- [ ] **Document alternative topologies to test** (for sensitivity analysis)

**Example:**
```
Agents interact within their assigned debate only (no cross-debate communication). 
Within each debate, the network is fully connected - all agents can interact with 
all other agents. Partner selection for each interaction is determined by opinion 
similarity: agent i selects agent j with probability proportional to 
1/(1 + |x_i - x_j|), ensuring agents with similar opinions interact more frequently 
while maintaining non-zero probability of interacting with dissimilar others.
```

---

## SECTION 2: CALIBRATION

### ✅ 2.1 Complete Calibration Strategy

**Current Status:** "Think about calibration strategy in paragraph below"

**Required Changes:**

- [ ] **Replace placeholder with full calibration section** (see `calibration_strategy.md`)
- [ ] **Define calibration targets** (patterns to match)
- [ ] **Specify parameter search space**
- [ ] **Describe optimization method**
- [ ] **Explain validation approach**

**Where to Add:** Expand "Model Calibration" subsection in Methods

**Minimum Required Content:**
```
3.X Model Calibration

3.X.1 Calibration Targets
We calibrate parameters to match the following empirical patterns from 20% of debates:
- Individual level: [list patterns]
- Debate level: [list patterns]  
- Global level: [list patterns]

3.X.2 Parameter Search
We explore parameter space using Latin Hypercube Sampling (n=200 configurations):
[Table of parameters and ranges]

3.X.3 Optimization
We optimize parameters using [genetic algorithm/PSO/Bayesian optimization] to 
minimize weighted distance to calibration targets:
[Objective function formula]

3.X.4 Validation
Calibrated parameters are validated on the remaining 80% of debates. We report:
- Mean Absolute Error (MAE)
- Pattern reproduction fidelity
- Stability across random seeds (n=50)
```

---

### ✅ 2.2 Increase Number of Random Seeds

**Current Status:** "two different random seeds"

**Required Changes:**

- [ ] **Change to minimum 30 seeds** for robustness testing
- [ ] **Change to minimum 50 seeds** for final validation
- [ ] **Add analysis of variance across seeds**

**Example Revision:**
```
OLD: "Each ABM configuration was run multiple times with two different random seeds"

NEW: "Each ABM configuration was run with 30 different random seeds to assess 
stochastic variability. For final hypothesis testing, we used 50 seeds and report 
mean MAE with 95% confidence intervals. Models with coefficient of variation 
(CV = SD/mean) > 0.15 across seeds are flagged as unstable."
```

---

## SECTION 3: SENSITIVITY ANALYSIS

### ✅ 3.1 Add Comprehensive SA Framework

**Current Status:** Vague mention of "exploratory analyses" (RQ1)

**Required Changes:**

- [ ] **Add full SA section to Methods** (see `sensitivity_analysis_framework.md`)
- [ ] **Map each hypothesis to specific SA goals**
- [ ] **Specify SA methods for each goal**
- [ ] **Define analysis plan with phases**

**Where to Add:** New section "3.X Sensitivity Analysis Protocol"

**Structure:**
```
3.X Sensitivity Analysis Protocol

Following Borgonovo et al. (2022), we implement systematic sensitivity analysis 
addressing four goals:

3.X.1 Robustness Analysis
To test whether conclusions are stable across parameter uncertainty:
- Method: Morris screening + factorial designs
- Applied to: H3, H4, H5, H6, H7
- Decision rule: Accept hypothesis only if supported in >80% of parameter configs

3.X.2 Factor Prioritization
To identify which model elements most influence outcomes:
- Method: Sobol variance decomposition
- Applied to: All hypotheses, especially H7 (argumentation vs social influence)
- Metric: First-order and total-effect Sobol indices

3.X.3 Interaction Effects
To examine how elements combine:
- Method: Factorial ANOVA
- Applied to: H4 (debate type × parameters)
- Visualization: Interaction plots

3.X.4 Direction of Change
To characterize how outputs respond to inputs:
- Method: Modified ICE plots for stochastic models
- Applied to: RQ1 (parameter effects on trajectories)
- Supplemented by: Partial dependence plots
```

---

### ✅ 3.2 Revise Hypothesis Statements to Include SA

**Current Status:** Hypotheses don't mention robustness

**Required Changes:**

For EACH hypothesis, add robustness criteria:

- [ ] **H3:** Add "...robust across parameter variations tested via Morris screening"
- [ ] **H4:** Add "...with effect size >0.3 maintained across 80% of parameter configurations"
- [ ] **H5:** Add "...demonstrated via factorial design varying [specify 3-4 key parameters]"
- [ ] **H6:** Add "...with 95% CI for MAE difference excluding zero across Latin Hypercube sample"
- [ ] **H7:** Add "...confirmed by Sobol analysis showing argumentation parameters contribute >20% of total variance"

**Example Revision:**

```
OLD H3: Agent-based simulations initialized with pre-deliberation attitudes alone 
will generate lower MAE predictions of post-deliberation attitudes for individual 
participants compared with linear regression models using observed predictors alone.

NEW H3: Agent-based simulations initialized with pre-deliberation attitudes alone 
will generate lower MAE predictions of post-deliberation attitudes for individual 
participants compared with linear regression models (expected ΔMAE > 0.10), with 
this improvement demonstrated to be robust across 80% of parameter configurations 
tested via Morris screening of the five most influential model parameters identified 
in preliminary sensitivity analysis.
```

---

### ⚠️ 3.3 Add Non-Parametric Sensitivity Tests

**Current Status:** Only parametric elements considered

**Required Changes:**

- [ ] **Identify alternative behavioral rules** to test
- [ ] **Create comparison plan** for rule variants
- [ ] **Add to analysis plan**

**Example Addition:**
```
3.X.5 Non-Parametric Sensitivity Analysis

We test sensitivity to key modeling choices by comparing alternative specifications:

Rule B1 (Opinion Update Mechanism):
- Variant A: Simple averaging (default)
- Variant B: Weighted by similarity  
- Variant C: Bayesian updating
Analysis: Run all three on validation data with calibrated parameters, 
compare MAE distributions via Kruskal-Wallis test

Rule B2 (Partner Selection):
- Variant A: Similarity-weighted random (default)
- Variant B: Purely random
- Variant C: K-nearest neighbors (K=3)
Analysis: [similar approach]

[Continue for other critical non-parametric elements...]
```

---

## SECTION 4: COMPUTATIONAL REQUIREMENTS

### ⚠️ 4.1 Add Computational Budget Estimate

**Current Status:** Not mentioned

**Required Changes:**

- [ ] **Calculate total number of simulations needed**
- [ ] **Estimate computation time**
- [ ] **Describe parallelization strategy**
- [ ] **Justify computational feasibility**

**Example Addition:**
```
3.X Computational Requirements

Table: Simulation Budget
| Analysis Phase | Configurations | Reps | Seeds | Total Runs | Est. Time* |
|----------------|----------------|------|-------|------------|------------|
| Calibration    | 200            | 30   | 1     | 6,000      | 10 hours   |
| Validation     | 1              | 50   | 50    | 2,500      | 4 hours    |
| Morris SA      | 100            | 30   | 1     | 3,000      | 5 hours    |
| Factorial      | 16             | 50   | 10    | 8,000      | 13 hours   |
| Sobol          | 500            | 20   | 1     | 10,000     | 17 hours   |
| Total          |                |      |       | 29,500     | ~49 hours  |

*Assuming 6 seconds per simulation run on [specify hardware]

To ensure feasibility, we implement:
- Parallel processing in GAMA (8 cores)
- Batch automation (GAMA headless mode)
- Result caching to avoid redundant runs
- Phased approach: Phases 1-2 mandatory, Phase 3 if time permits

Estimated actual time with parallelization: ~6-8 hours total
```

---

### 💡 4.2 Add Contingency Plan

**Current Status:** No backup if full SA is infeasible

**Required Changes:**

- [ ] **Define minimum viable SA** (if computational limits hit)
- [ ] **Prioritize analyses**
- [ ] **Specify fallback options**

**Example:**
```
If computational constraints prevent full SA protocol:

Priority 1 (Must complete):
- Calibration and validation
- H3-H6 hypothesis tests with baseline parameters
- Morris screening for top 5 parameters
- Robustness check with ±20% parameter variations

Priority 2 (Should complete if possible):
- Full factorial for H4
- ICE plots for RQ1
- Non-parametric rule comparisons

Priority 3 (Nice to have):
- Full Sobol analysis for H7
- LHS global analysis
- Additional interaction effects
```

---

## SECTION 5: RESULTS REPORTING

### ✅ 5.1 Expand Results Structure

**Current Status:** Only mentions comparing MAE

**Required Changes:**

- [ ] **Add SA results subsections**
- [ ] **Specify required visualizations**
- [ ] **Define reporting standards**

**New Results Structure:**
```
4. Results

4.1 Preliminary Sensitivity Analysis
4.1.1 Parameter Screening Results
4.1.2 Behavioral Rule Comparisons
4.1.3 Feasible Parameter Region

4.2 Model Calibration
4.2.1 Calibration Process
4.2.2 Parameter Values
4.2.3 Calibration Fit Quality

4.3 Hypothesis Testing
4.3.1 H1: Pre-Post Attitude Correlation
4.3.2 H2: Social Influence Susceptibility
4.3.3 H3: Individual-Level ABM vs Regression
  - Point estimate and 95% CI for ΔMAE
  - Robustness across parameter variations
  - Sensitivity analysis results
  [Similar structure for H4-H7]

4.4 Exploratory Analyses (RQ1)
4.4.1 Parameter Effects on Trajectories (ICE plots)
4.4.2 Interaction Effects
4.4.3 Convergence Patterns

4.5 Model Comparison
4.5.1 Social Influence Model Comparison
4.5.2 Argumentation Model Added Value
4.5.3 Global Sensitivity Summary
```

---

### ✅ 5.2 Define Reporting Standards for Each Hypothesis

**Current Status:** Unclear what metrics will be reported

**Required Changes:**

For each hypothesis, specify required reporting:

- [ ] **Point estimates** (mean MAE, effect sizes)
- [ ] **Uncertainty quantification** (95% CIs, variance across seeds)
- [ ] **Robustness evidence** (% of parameter configs supporting hypothesis)
- [ ] **Sensitivity metrics** (Sobol indices, Morris μ*, interaction effects)
- [ ] **Visualizations** (required plots for each hypothesis)

**Example Template:**

```
H3 Reporting Requirements:
✓ Mean MAE for ABM and regression (with SDs)
✓ Mean difference ΔMAE with 95% bootstrap CI
✓ P-value from paired t-test
✓ Robustness: % of parameter configs where ABM < regression
✓ Morris screening: μ* values for top 5 parameters
✓ Visualizations:
  - Scatter: predicted vs actual (both methods)
  - Forest plot: MAE difference across parameter configs
  - Tornado plot: parameter sensitivity
```

---

## SECTION 6: DISCUSSION IMPLICATIONS

### ⚠️ 6.1 Add SA Implications to Discussion

**Current Status:** Will likely only discuss whether hypotheses supported

**Required Changes:**

- [ ] **Add subsection on model limitations** identified through SA
- [ ] **Discuss parameter sensitivity** findings
- [ ] **Address non-parametric uncertainties**
- [ ] **Recommend future model refinements**

**Example Structure:**
```
5. Discussion

5.X Sensitivity Analysis Insights

Our systematic sensitivity analysis revealed:

5.X.1 Critical Parameters
The attraction threshold (μ* = 0.45) and influence weight (μ* = 0.38) most 
strongly affected model predictions, while [parameter X] had minimal impact 
(μ* = 0.05). This suggests future empirical work should focus on measuring 
[theoretical construct related to critical parameters].

5.X.2 Model Limitations
The model failed to reproduce [specific pattern] across all parameter 
configurations tested, suggesting the current formulation does not capture 
[theoretical mechanism]. Future models should consider [alternative mechanism].

5.X.3 Robustness and Uncertainty
While H3-H6 were supported across most (>80%) parameter configurations, 
sensitivity was high for [specific conditions]. Conclusions are most robust 
for [conditions], less certain for [conditions].
```

---

## SECTION 7: APPENDIX ADDITIONS

### ⚠️ 7.1 Add Technical Appendices

**Required Changes:**

- [ ] **Appendix A: Complete Model Specification**
  - Full ODD protocol (Overview, Design concepts, Details)
  - Mathematical formulations for all equations
  - Pseudo-code for all algorithms
  
- [ ] **Appendix B: Sensitivity Analysis Details**
  - Complete parameter ranges table
  - All Sobol indices (first-order and total)
  - Morris elementary effects for all parameters
  - Full correlation matrix of parameters vs outputs
  
- [ ] **Appendix C: Calibration Details**
  - Exploration results (LHS)
  - Optimization convergence plots
  - Validation pattern matching (all plots)
  
- [ ] **Appendix D: Supplementary Visualizations**
  - All ICE plots
  - All interaction plots
  - Alternative rule comparison results

---

## PRIORITY ACTION CHECKLIST

### Week 1: Foundation

- [ ] Complete model elements chart (all parameters, all rules)
- [ ] Specify mathematical formulations for opinion updates
- [ ] Name and describe the 5 subfactors
- [ ] Define network topology precisely
- [ ] Implement `run_gama_simulation()` R wrapper

### Week 2: Calibration Prep

- [ ] Calculate empirical calibration targets from 20% data
- [ ] Define parameter search space (ranges for all parameters)
- [ ] Set up LHS exploration (200 configs)
- [ ] Run preliminary simulations to check feasibility

### Week 3: Calibration

- [ ] Run LHS parameter exploration
- [ ] Identify feasible parameter region
- [ ] Run optimization (GA/PSO/Bayes)
- [ ] Validate on 80% holdout
- [ ] Document calibrated parameters

### Week 4: Sensitivity Analysis Setup

- [ ] Write sensitivity analysis section for protocol
- [ ] Generate Morris design
- [ ] Set up factorial design for H4
- [ ] Prepare ICE plot infrastructure
- [ ] Test computational requirements

### Week 5+: Run Analyses

- [ ] Phase 1 SA: Screening
- [ ] Phase 2 SA: Hypothesis-specific robustness
- [ ] Phase 3 SA: Global analysis (if feasible)
- [ ] Generate all required plots
- [ ] Compile results

---

## VERIFICATION CHECKLIST

Before submitting revised protocol, verify:

### Model Specification
- [ ] Every parameter has a defined range and source
- [ ] Every behavioral rule has pseudo-code or mathematical formula
- [ ] Network topology is precisely specified
- [ ] The 5 subfactors are explicitly named
- [ ] Initialization procedures are detailed

### Calibration
- [ ] Calibration targets are listed with formulas
- [ ] Parameter search space is justified
- [ ] Optimization method is specified
- [ ] Validation approach is described
- [ ] Random seed strategy is adequate (>30 seeds)

### Sensitivity Analysis
- [ ] All four SA goals are addressed
- [ ] Methods are matched to goals (see Borgonovo Table 1)
- [ ] Parametric AND non-parametric elements are tested
- [ ] Computational requirements are estimated
- [ ] Reporting standards are defined

### Integration
- [ ] Each hypothesis mentions robustness
- [ ] Methods section has SA subsection
- [ ] Results section has SA subsections
- [ ] Discussion addresses SA findings
- [ ] Appendices contain technical details

### Feasibility
- [ ] Total simulation count is estimated
- [ ] Computation time is estimated
- [ ] Parallelization strategy is described
- [ ] Contingency plan exists if infeasible
- [ ] Pilot testing is planned

---

## REFERENCES TO ADD

Add these to your bibliography:

```
Borgonovo, E., Pangallo, M., Rivkin, J., Becker, W., Zio, E., & Plischke, E. (2022). 
Sensitivity analysis: A discipline coming of age. In E. Borgonovo & E. Plischke (Eds.), 
Sensitivity Analysis in Practice (pp. 1-11). Springer.

Grimm, V., Revilla, E., Berger, U., Jeltsch, F., Mooij, W. M., Railsback, S. F., ... 
& DeAngelis, D. L. (2005). Pattern-oriented modeling of agent-based complex systems: 
lessons from ecology. Science, 310(5750), 987-991.

Ten Broeke, G., Van Voorn, G., & Ligtenberg, A. (2016). Which sensitivity analysis 
method should I use for my agent-based model? Journal of Artificial Societies and 
Social Simulation, 19(1), 5.

Saltelli, A., Ratto, M., Andres, T., Campolongo, F., Cariboni, J., Gatelli, D., ... 
& Tarantola, S. (2008). Global sensitivity analysis: the primer. John Wiley & Sons.
```

---

## ESTIMATED EFFORT

Revising protocol with all critical additions:
- **Minimum (✅ only):** 20-30 hours
- **Recommended (✅ + ⚠️):** 40-50 hours  
- **Complete (all):** 60-80 hours

Running the full SA pipeline:
- **Computation time:** 6-8 hours (with parallelization)
- **Analysis and visualization:** 20-30 hours
- **Writing results:** 15-20 hours

**Total project timeline:** 6-8 weeks for careful implementation

---

Good luck! The criticism you received was valid, but the fixes are totally manageable. 
Your study will be much stronger with these additions. Start with the model 
specification (Week 1 checklist), and everything else will follow naturally.
