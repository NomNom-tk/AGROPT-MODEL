# Agent-Based Model Element Chart
## Purpose: Systematic documentation of all model elements for sensitivity analysis

---

## 1. AGENT CHARACTERISTICS

### 1.1 State Variables (Parametric)

| Element ID | Name | Type | Default Value | Plausible Range | Source | Notes |
|------------|------|------|---------------|-----------------|--------|-------|
| A1 | Initial Attitude (T1) | Continuous | [From data] | [0, 1] normalized | Survey data | Composite of 5 subfactors (A3-A7). Weighted average: Σ(w_i × subfactor_i) / Σ(w_i) |
| A2 | Current Attitude | Continuous | Same as A1 | [0, 1] | Updated during simulation | Opinion state variable that changes during simulation |
| A3 | Subfactor 1: DBFactor1T1 | Continuous | [From data] | [0, 1] normalized | Survey T1 | PRO-reduction subfactor: perceived benefits of a plant-based diet. Original scale [1-7] normalized to [0,1] |
| A4 | Subfactor 2: DBFactor2T1 | Continuous | [From data] | [0, 1] normalized | Survey T1 | PRO-reduction subfactor: downsides of factory farming. Original scale [1-7] normalized to [0,1] |
| A5 | Subfactor 3: DBFactor3T1 | Continuous | [From data] | [0, 1] normalized | Survey T1 | CONTRA-reduction subfactor: health barriers. Original scale [1-7] normalized to [0,1] |
| A6 | Subfactor 4: DBFactor4T1 | Continuous | [From data] | [0, 1] normalized | Survey T1 | CONTRA-reduction subfactor: legitimation barriers. Original scale [1-7] normalized to [0,1] |
| A7 | Subfactor 5: DBFactor5T1 | Continuous | [From data] | [0, 1] normalized | Survey T1 | CONTRA-reduction subfactor: feasibility barriers. Original scale [1-7] normalized to [0,1] |
| A8 | Perceived Social Norms | Continuous | [From data] | [Range TBD] | Survey T1 | For regression only, NOT ABM initialization. Sum of means of items 1-8 in Questionnaire E1 (Theory of Planned Behavior). Greater score = greater propensity to be influenced by social norms |
| A9 | Self-Control | Continuous | [From data] | [Range TBD] | Survey T1 | For regression only, NOT ABM initialization. Sum of item scores in Questionnaire F1 (Theory of temporal self-regulation). Higher score = greater self-control |
| A10 | Susceptibility to Influence | Continuous | [Not used] | 0-1 | Derived or calibrated? | May be implicit in convergence_rate parameter - needs clarification |
| A11 | Argument Memory Size | Integer | [Not implemented] | 3-10 arguments | Literature/calibration | For argumentation model only - to be implemented later |

### 1.2 Agent Behavioral Rules (Non-Parametric)

| Element ID | Name | Default Rule | Alternative Rules to Test | Source |
|------------|------|--------------|---------------------------|--------|
| B1 | Opinion Update Mechanism | **THREE MODELS IMPLEMENTED:**<br><br>**Consensus:** All agents converge toward mean of self + neighbors<br>Formula: `x_i(t+1) = x_i(t) + μ × (mean([x_i, N_i]) - x_i(t))`<br><br>**Clustering:** Only influenced by similar neighbors<br>Formula: `x_i(t+1) = x_i(t) + μ × (mean(N_i^similar) - x_i(t))`<br>where N_i^similar = {j : abs(x_j - x_i) ≤ ε}<br><br>**Bipolarization:** Similar attract, dissimilar repel<br>Three zones: attraction (≤ε), neutral (ε to ρ), repulsion (≥ρ) | **Within models:** Vary parameters (see Section 2)<br><br>**Across models:** Compare predictive accuracy<br><br>**Alternative formulations:**<br>- Weighted by similarity<br>- Asymmetric influence<br>- Bounded updates<br>- Non-linear decay | Flache et al. 2017 |
| B2 | Network Structure & Neighbor Definition | **Three network types:**<br><br>**Complete:** Fully connected within debate<br>Formula: neighbors = all agents in same debate (excluding self, control)<br><br>**Random:** Probabilistic connections<br>Parameter: connection_probability<br><br>**Small-world:** Watts-Strogatz<br>Ring lattice (k neighbors) + rewiring (p probability)<br><br>**All networks are STATIC** (no dynamic rewiring) | **Topologies:**<br>- Scale-free<br>- Spatial<br>- Dynamic rewiring<br><br>**Update rules:**<br>- Sequential<br>- Asynchronous<br><br>**Interaction frequency:**<br>- Probabilistic activation | Implemented in create_network action |
| B3 | Argument Selection (for arg model) | [NOT IMPLEMENTED] | - Random selection<br>- Most different from partner<br>- Strategic (attack weakest) | Taillandier et al. - for future work |
| B4 | Argument Forgetting | [NOT IMPLEMENTED] | - Weakest first<br>- Random<br>- No forgetting | For argumentation model - future work |
| B5 | Attitude Calculation from Subfactors | **Weighted average with normalization:**<br><br>`initial_opinion = Σ(w_i × subfactor_i) / Σ(w_i)`<br><br>Where:<br>- subfactors 1-5 are from T1 survey data<br>- weights w_1 through w_5 are parameters (default: 0.2 each)<br>- Result is normalized [0,1] scale | **Alternative combinations:**<br>- Simple mean (equal weights)<br>- Empirically-derived weights<br>- Different weights by importance<br>- Multiplicative<br>- Min/max operators | Implemented in initialize_agents_for_debate |

---

## 2. SOCIAL INFLUENCE MODEL PARAMETERS (Parametric)

### 2.1 Core Opinion Dynamics Parameters

| Element ID | Name | Default Value | Plausible Range | Applicable Model | Notes |
|------------|------|---------------|-----------------|------------------|-------|
| SI1 | convergence_rate (μ) | 0.2 | [0.05, 0.5] | All three models | Speed of opinion change. Lower = slower convergence |
| SI2 | confidence_threshold (ε) | 0.5 | [0.1, 0.8] | Clustering, Bipolarization | Similarity threshold for attraction. Lower = more selective |
| SI3 | repulsion_threshold (ρ) | 0.6 | [0.5, 1.0] | Bipolarization only | Dissimilarity threshold for repulsion. Must be > ε |
| SI4 | repulsion_strength (α) | 0.1 | [0.05, 0.3] | Bipolarization only | Strength of repulsive force. Lower = weaker repulsion |

**Key constraint:** For bipolarization model, must have ε < ρ (attraction threshold < repulsion threshold)

### 2.2 Model Selection (Categorical)

| Element ID | Name | Options | Default | Notes |
|------------|------|---------|---------|-------|
| MODEL1 | model_type | {consensus, clustering, bipolarization} | consensus | Which social influence model to use |

---

## 3. NETWORK PARAMETERS (Parametric)

| Element ID | Name | Default Value | Plausible Range | Applicable Network | Notes |
|------------|------|---------------|-----------------|-------------------|-------|
| NET1 | network_type | "complete" | {complete, random, small_world} | All (categorical choice) | Which network topology to use |
| NET2 | connection_probability | 0.3 | [0.2, 0.8] | Random only | Probability each potential link forms |
| NET3 | small_world_k | 4 | {2, 4, 6, 8} | Small-world only | Number of nearest neighbors in ring lattice |
| NET4 | small_world_rewire | 0.1 | [0.05, 0.2] | Small-world only | Probability of adding random shortcut |

**Network constraints:**
- All networks are debate-specific (no cross-debate connections)
- Control group agents excluded from networks
- Networks are STATIC after initialization

---

## 4. SUBFACTOR WEIGHT PARAMETERS (Parametric)

| Element ID | Name | Default Value | Plausible Range | Notes |
|------------|------|---------------|-----------------|-------|
| W1 | weight_subfactor_1 | 0.2 | [0.0, 1.0] | Weight for subfactor 1 (PRO-reduction). Normalized automatically |
| W2 | weight_subfactor_2 | 0.2 | [0.0, 1.0] | Weight for subfactor 2 (PRO-reduction). Normalized automatically |
| W3 | weight_subfactor_3 | 0.2 | [0.0, 1.0] | Weight for subfactor 3 (CONTRA-reduction). Normalized automatically |
| W4 | weight_subfactor_4 | 0.2 | [0.0, 1.0] | Weight for subfactor 4 (CONTRA-reduction). Normalized automatically |
| W5 | weight_subfactor_5 | 0.2 | [0.0, 1.0] | Weight for subfactor 5 (CONTRA-reduction). Normalized automatically |

**Note:** Weights are normalized (divided by sum) so they don't need to sum to 1.0

---

## 5. SIMULATION CONTROL PARAMETERS

| Element ID | Name | Default Value | Plausible Range | Notes |
|------------|------|---------------|-----------------|-------|
| SIM1 | max_cycles | 100 | [50, 200] | Maximum simulation length (timesteps) |
| SIM2 | mae_convergence_threshold | 0.001 | [0.0001, 0.01] | Stopping criterion - max opinion change per cycle |
| SIM3 | selected_debate_id | 1 | [1, max_debates] | Which debate to simulate in single-debate mode |
| SIM4 | step | 0.5 | Fixed | Time step duration (not varied in SA) |

---

## 6. ARGUMENTATION MODEL PARAMETERS (NOT IMPLEMENTED)

**Status:** Planned for future work - currently not implemented in code

| Element ID | Name | Default Value | Plausible Range | Source | Notes |
|------------|------|---------------|-----------------|--------|-------|
| ARG1 | Argument Strength Weight | [TBD] | [0, 1] | Dung 1995 | How strength affects selection |
| ARG2 | Attack Success Probability | [TBD] | [0.5, 1.0] | Calibration | Base probability of successful attack |
| ARG3 | Memory Decay Rate | [TBD] | [0, 0.2] per interaction | Calibration | If using decay vs. forgetting |
| ARG4 | Learning Rate | [TBD] | [0, 1] | Calibration | How quickly new arguments adopted |

### 6.1 Argumentation Rules (Non-Parametric) - NOT IMPLEMENTED

| Element ID | Name | Default Rule | Alternatives | Notes |
|------------|------|--------------|--------------|-------|
| ARG5 | Attack Resolution | [NOT SPECIFIED] | - Binary (success/fail)<br>- Probabilistic<br>- Strength-based | How conflicts resolved |
| ARG6 | Argument Graph Structure | [NOT SPECIFIED] | - Fully connected<br>- Hierarchical<br>- Random | How arguments relate |

---

## 7. TEMPORAL DYNAMICS (Non-Parametric)

| Element ID | Name | Current Implementation | Alternatives to Test | Notes |
|------------|------|----------------------|---------------------|-------|
| TIME1 | Interaction Frequency | Every cycle, all agents | - Probabilistic activation<br>- Variable by agent | Currently: all agents update each cycle |
| TIME2 | Simulation Length | Until convergence OR max_cycles | - Fixed duration<br>- Match empirical debate time | Convergence: max opinion change < threshold |
| TIME3 | Update Order | Simultaneous (all agents at once) | - Sequential random<br>- Ordered by extremity | Currently: reflexes execute simultaneously |

---

## 8. INITIALIZATION (Non-Parametric)

| Element ID | Name | Current Procedure | Alternatives to Test | Notes |
|------------|------|------------------|---------------------|-------|
| INIT1 | Opinion Initialization | Weighted average of T1 subfactors | - Add random noise (±ε)<br>- Test different weight combinations | Formula: Σ(w_i × subfactor_i) / Σ(w_i) |
| INIT2 | Debate Assignment | From experimental data | Fixed (cannot vary) | Empirically determined |
| INIT3 | Network Creation | Static at initialization | - Dynamic rewiring<br>- Time-evolving topology | Currently: one-time creation |
| INIT4 | Random Seed | Varies across runs | Test multiple seeds (30-50) | For assessing stochastic variability |

---

## 9. ENVIRONMENTAL PARAMETERS (From Data)

### 9.1 Debate Characteristics (Fixed by Experimental Design)

| Element ID | Name | Source | Range | Notes |
|------------|------|--------|-------|-------|
| ENV1 | Debate Type | Experimental condition | {Heterogeneous, Homogeneous, Control} | From survey data |
| ENV2 | Debate Size | Actual participant count | Varies by debate | From empirical data |
| ENV3 | Initial Attitude Distribution | T1 survey responses | Debate-specific | Pro/anti composition |

---

## 10. OUTPUT VARIABLES

| Variable ID | Name | Description | Level | Computed When |
|-------------|------|-------------|-------|---------------|
| OUT1 | Final Opinion | Agent's opinion at convergence | Individual | End of simulation |
| OUT2 | Attitude Change | Final opinion - initial opinion | Individual | End of simulation |
| OUT3 | Individual MAE | abs(final opinion - empirical T2) | Individual | compute_fit action |
| OUT4 | Debate Mean Change | Mean attitude change in debate | Debate | compute_fit action |
| OUT5 | Debate MAE | Mean MAE for debate | Debate | compute_fit action |
| OUT6 | Global MAE | Mean MAE across all agents | Global | compute_fit action |
| OUT7 | Opinion Variance | Variance of opinions | Global | compute_statistics reflex |
| OUT8 | Number of Clusters | Opinion clusters (histogram bins > 0) | Global | compute_statistics reflex |
| OUT9 | Polarization Index | Variance of pairwise opinion distances | Global | compute_statistics reflex |
| OUT10 | Convergence Cycle | Cycle when convergence achieved | Global | check_convergence reflex |
| OUT11 | Attractive Interactions | Count of attraction zone interactions | Global | Bipolarization only |
| OUT12 | Repulsive Interactions | Count of repulsion zone interactions | Global | Bipolarization only |
| OUT13 | Neutral Interactions | Count of neutral zone interactions | Global | Bipolarization only |

---

## PRIORITY CLASSIFICATION FOR SENSITIVITY ANALYSIS

### 🔴 High Priority (Test First - Essential for all hypotheses)

- [x] **SI1** - convergence_rate (affects all models)
- [x] **SI2** - confidence_threshold (clustering, bipolarization)
- [x] **SI3** - repulsion_threshold (bipolarization)
- [x] **SI4** - repulsion_strength (bipolarization)
- [x] **MODEL1** - model_type (compare three models)
- [ ] **NET1** - network_type (test robustness to topology)
- [ ] **B1** - opinion update mechanism alternatives
- [ ] **INIT3** - random seed variations (30-50 seeds)

### 🟡 Medium Priority (Important for specific hypotheses)

- [ ] **NET2** - connection_probability (if using random network)
- [ ] **NET3** - small_world_k (if using small-world)
- [ ] **NET4** - small_world_rewire (if using small-world)
- [ ] **W1-W5** - subfactor weights (calibration target)
- [ ] **SIM1** - max_cycles (sensitivity to stopping rule)
- [ ] **SIM2** - convergence threshold
- [ ] **TIME3** - update order (simultaneous vs sequential)

### 🟢 Low Priority (Test if time/resources permit)

- [ ] **TIME1** - interaction frequency alternatives
- [ ] **INIT1** - initialization noise
- [ ] **B5** - alternative subfactor combination rules
- [ ] **ARG1-ARG6** - argumentation parameters (future work)

---

## PARAMETER SUMMARY FOR BATCH EXPERIMENTS

### Currently Implemented in Batch Mode:

```
model_type: {consensus, clustering, bipolarization}
convergence_rate: [0.05, 0.1, 0.2, 0.3, 0.5]
confidence_threshold: [0.1, 0.3, 0.5, 0.7]
repulsion_threshold: [0.5, 0.6, 0.8]
repulsion_strength: [0.05, 0.1, 0.2]
selected_debate_id: [1 to max_debates]
```

### Need to Add:

```
network_type: {complete, random, small_world}
connection_probability: [0.3, 0.5, 0.7]  # if random
small_world_k: {2, 4, 6}  # if small-world
small_world_rewire: [0.05, 0.1, 0.2]  # if small-world
```

### For Calibration (will optimize these):

```
weight_subfactor_1: [0.0, 1.0]
weight_subfactor_2: [0.0, 1.0]
weight_subfactor_3: [0.0, 1.0]
weight_subfactor_4: [0.0, 1.0]
weight_subfactor_5: [0.0, 1.0]
```

---

## NOTES FOR COMPLETION

### ✅ Completed (Based on Code Review):

1. ✅ Identified all parametric elements currently in code
2. ✅ Documented three opinion update mechanisms
3. ✅ Documented three network structures
4. ✅ Specified subfactor weighting formula
5. ✅ Listed all output variables computed
6. ✅ Identified parameter ranges for SA

### 🔧 Still Need to Specify:

1. **Subfactor descriptions:** What do DBFactor1-5 actually measure?
2. **Scale details:** Confirm [-6, +6] → [0, 1] normalization formula
3. **Convergence definition:** Verify threshold = 0.001 is appropriate
4. **Debate duration:** How long were empirical debates (to match simulation length)?
5. **Target patterns:** Beyond MAE, what empirical patterns should model reproduce?

### 📋 Questions to Answer:

- **Q1:** Are the 5 subfactors validated scales? What constructs do they measure?
- **Q2:** Should subfactor weights be calibrated or theoretically motivated?
- **Q3:** Is simultaneous update realistic for debate simulation?
- **Q4:** Should network be dynamic (rewire based on opinion changes) or static?
- **Q5:** What's the empirical distribution of debate sizes (for representative sampling)?

### 🎯 Links to Hypotheses:

**H1 (Pre-post correlation):**
- Tests: A1 (initial opinion) prediction of OUT1 (final opinion)
- Parameters: All SI parameters affect strength of relationship

**H2 (Susceptibility to influence):**
- Tests: A8 (social norms), A9 (self-control) → OUT2 (attitude change)
- Note: These are for regression only, not in ABM

**H3 (ABM vs Regression - Individual):**
- Primary metric: OUT3 (individual MAE)
- SA needed: Test robustness across all SI and NET parameters

**H4 (Heterogeneous vs Homogeneous):**
- Tests: ENV1 (debate type) → OUT4 (mean debate change)
- SA needed: Does effect hold across network types and models?

**H5 (ABM vs Regression - Debate level):**
- Primary metric: OUT5 (debate MAE)
- SA needed: Robustness to parameter variations

**H6 (Global attitude shift):**
- Primary metric: OUT6 (global MAE)
- Tests: Can model reproduce aggregate distribution shift?

**H7 (Argumentation vs Social Influence):**
- NOT APPLICABLE YET - argumentation not implemented
- Future work: Add ARG1-ARG6 parameters

---

## COMPUTATIONAL BUDGET ESTIMATE

### Phase 1: Parameter Screening (Grid Search)
- Models: 3 (consensus, clustering, bipolarization)
- SI parameters: ~5 values each × 4 params = ~100 combinations
- Network types: 3
- **Subtotal:** 3 × 100 × 3 = 900 configurations

### Phase 2: Random Seeds (Stochastic Robustness)
- Best configurations from Phase 1: ~10
- Seeds: 30 per configuration
- **Subtotal:** 10 × 30 = 300 runs

### Phase 3: Calibration (Subfactor Weights)
- LHS samples: 200
- Models: 3
- **Subtotal:** 200 × 3 = 600 runs

### Phase 4: Validation
- Calibrated parameters: 3 (one per model)
- Debates: 44 (80% validation set)
- Seeds: 50
- **Subtotal:** 3 × 44 × 50 = 6,600 runs

### **TOTAL ESTIMATED RUNS:** ~8,400

**With parallelization (8 cores):**
- Assuming 6 seconds per run
- Total time: ~14 hours
- Can be split across phases over several days

---

**Last Updated:** [Date]  
**Status:** Living document - update as model develops and SA proceeds
