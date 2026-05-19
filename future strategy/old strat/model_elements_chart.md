# Agent-Based Model Element Chart
## Purpose: Systematic documentation of all model elements for sensitivity analysis

---

## 1. AGENT CHARACTERISTICS

### 1.1 State Variables (Parametric)

| Element ID | Name | Type | Default Value | Plausible Range | Source |                                                                                                        Notes | ---------- | --------------------------- | ---------- | ------------- | --------------- | ------------------------- | :-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------: |
| A1 | Initial Attitude (T1) | Discrete | [From data] | 1-7 scale? | Survey data | Composite of 5 subfactors A3-A7. Mean of con factors (Factor3,4,5) subtracted from mean of pro factors (Factor1,2) |
| A2         | Current Attitude | Continuous | Same as A1    | 1-7 scale?      | Updated during simulation |                                                                    |
| A3         | Subfactor 1: DBFactor1T1    | Continuous | [From data]   | [Range]         | Survey T1                 |                                                                                               descriptions of each db                                                                                               |
| A4         | Subfactor 2: DBFactor2T1    | Continuous | [From data]   | [Range]         | Survey T1                 |                                                                                                       FILL IN                                                                                                       |
| A5         | Subfactor 3: DBFactor3T1    | Continuous | [From data]   | [Range]         | Survey T1                 |                                                                                                       FILL IN                                                                                                       |
| A6         | Subfactor 4: DBFactor4T1    | Continuous | [From data]   | [Range]         | Survey T1                 |                                                                                                       FILL IN                                                                                                       |
| A7         | Subfactor 5: DBFactor5T1    | Continuous | [From data]   | [Range]         | Survey T1                 |                                                                                                       FILL IN                                                                                                       |
| A8         | Perceived Social Norms      | Discrete   | [From data]   | [Range]         | Survey T1                 | For regression only, not ABM initialization. Sum of means of items 1-8 in Questionnaire E1 (request). A greater score indicates greater propensity to be influenced by social norms for meat consumption reduction. |
| A9         | Self-Control                | Discrete   | [From data]   | [Range]         | Survey T1                 |                                    For regression only, not ABM initialization. Sum of item scores in Questionnaire F1 (request). Higher the score the greater the self-control.                                    |
| A10        | Susceptibility to Influence | Continuous | ?             | 0-1             | Derived or calibrated?    |                                                                                                DEFINE HOW CALCULATED                                                                                                |
| A11        | Argument Memory Size        | Integer    | ?             | 3-10 arguments? | Literature/calibration    |                                                                     For argumentation model only // need to reclarify with Patrick and Nicolas                                                                      |

### 1.2 Agent Behavioral Rules (Non-Parametric)

| Element ID | Name                                 | Default Rule                                                                                                                                                                                                                                                                                                                                                                           | Alternative Rules to Test                                                           | Source               |
| ---------- | ------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------- | -------------------- |
| B1         | Opinion Update Mechanism             | - For Consensus: new opinion is the mean opinion of own plus all neighbor opinions. Final opinion: own opinion + convergence rate * (new opinion - own opinion)                         - For Clustering (bounded confidence): filter agents within confidence threshold and average them. Final opinion: own opinion + convergence rate * (average of similar opinions - own opinion) | - Simple averaging- Weighted by similarity- Bayesian updating- Assimilate-contrast  | Flache et al. 2017   |
| B2         | Interaction Partner Selection        | Similarity-based (uniform within threshold)                                                                                                                                                                                                                                                                                                                                            | - Purely random- Proportional to similarity- Nearest neighbor- Small-world network  | SPECIFY CURRENT RULE |
| B3         | Argument Selection (for arg model)   | Most important/strongest                                                                                                                                                                                                                                                                                                                                                               | - Random selection<br>- Most different from partner<br>- Strategic (attack weakest) | Taillandier et al.   |
| B4         | Argument Forgetting                  | Oldest first (FIFO)                                                                                                                                                                                                                                                                                                                                                                    | - Weakest first<br>- Random<br>- No forgetting (unlimited memory)                   | SPECIFY              |
| B5         | Attitude Calculation from Subfactors | [SPECIFY: mean? weighted sum?]                                                                                                                                                                                                                                                                                                                                                         | - Arithmetic mean<br>- Weighted average<br>- Min/max<br>- Multiplicative            | SPECIFY              |

---

## 2. SOCIAL INFLUENCE MODEL PARAMETERS (Parametric)

### 2.1 Bounded Confidence Parameters

| Element ID | Name                     | Default Value | Plausible Range | Notes                                     |
| ---------- | ------------------------ | ------------- | --------------- | ----------------------------------------- |
| SI1        | Attraction Threshold (ε) | ?             | 0.1 - 2.0       | Below this difference, agents attract     |
| SI2        | Repulsion Threshold (ρ)  | ?             | 0.5 - 3.0       | Above this difference, agents repel       |
| SI3        | Influence Weight (μ)     | ?             | 0.0 - 1.0       | How much agents adjust toward each other  |
| SI4        | Repulsion Strength       | ?             | 0.0 - 0.5       | How much agents move apart when repelling |

### 2.2 Model-Specific Parameters

| Element ID | Name               | Applicable Model           | Default | Range    | Notes                         |
| ---------- | ------------------ | -------------------------- | ------- | -------- | ----------------------------- |
| SI5        | Homophily Strength | Clustering, Bipolarization | ?       | 0-1      | Preference for similar others |
| SI6        | Negative Influence | Bipolarization             | ?       | -1 to 0  | Strength of repulsion         |
| SI7        | Convergence Rate   | All                        | ?       | 0.01-0.5 | Speed of opinion change       |

## 3. ARGUMENTATION MODEL PARAMETERS (Parametric)

| Element ID | Name                       | Default Value | Plausible Range       | Source      | Notes                                 |
| ---------- | -------------------------- | ------------- | --------------------- | ----------- | ------------------------------------- |
| ARG1       | Argument Strength Weight   | ?             | 0-1                   | Dung 1995   | How strength affects selection        |
| ARG2       | Attack Success Probability | ?             | 0.5-1.0               | Calibration | Base probability of successful attack |
| ARG3       | Memory Decay Rate          | ?             | 0-0.2 per interaction | Calibration | If using decay vs. forgetting         |
| ARG4       | Learning Rate              | ?             | 0-1                   | Calibration | How quickly new arguments are adopted |

### 3.1 Argumentation Rules (Non-Parametric)

| Element ID | Name                     | Default Rule | Alternatives                                                   | Notes                      |
| ---------- | ------------------------ | ------------ | -------------------------------------------------------------- | -------------------------- |
| ARG5       | Attack Resolution        | [SPECIFY]    | - Binary (success/fail)<br>- Probabilistic<br>- Strength-based | How conflicts are resolved |
| ARG6       | Argument Graph Structure | [SPECIFY]    | - Fully connected<br>- Hierarchical<br>- Random                | How arguments relate       |

---

## 4. INTERACTION STRUCTURE (Non-Parametric)

### 4.1 Network Topology

| Element ID | Name                     | Default Structure             | Alternatives                                                     | Notes                                   |
| ---------- | ------------------------ | ----------------------------- | ---------------------------------------------------------------- | --------------------------------------- |
| NET1       | Debate Network           | Fully connected within debate | - Small-world<br>- Scale-free<br>- Random<br>- Spatial proximity | How agents are connected within debates |
| NET2       | Cross-Debate Interaction | None (debates isolated)       | - Some cross-debate links<br>- Hierarchical structure            | Currently isolated?                     |

### 4.2 Temporal Dynamics

| Element ID | Name                  | Default                        | Alternatives                                                  | Notes                  |
| ---------- | --------------------- | ------------------------------ | ------------------------------------------------------------- | ---------------------- |
| TIME1      | Interaction Frequency | One interaction per time step? | - Multiple per step<br>- Variable frequency<br>- Event-driven | SPECIFY                |
| TIME2      | Simulation Length     | ? time steps                   | Match debate duration?                                        | How many steps to run? |
| TIME3      | Interaction Order     | Random/simultaneous            | - Sequential<br>- Round-robin<br>- Priority-based             | SPECIFY                |

## 5. INITIALIZATION (Non-Parametric)

| Element ID | Name                            | Default Procedure           | Alternatives                                                           | Notes                               |
| ---------- | ------------------------------- | --------------------------- | ---------------------------------------------------------------------- | ----------------------------------- |
| INIT1      | Attitude Initialization         | From T1 survey data         | - Add random noise<br>- Normalize<br>- As-is                           | How exactly are attitudes assigned? |
| INIT2      | Debate Assignment               | From experimental condition | Fixed by data                                                          | No alternatives (empirical)         |
| INIT3      | Random Seed                     | Varies                      | Test multiple seeds                                                    | How many seeds to test?             |
| INIT4      | Argument Assignment (arg model) | [SPECIFY]                   | - Random from pool<br>- Based on attitude<br>- From debate transcripts | How are initial arguments assigned? |

---

## 6. ENVIRONMENTAL PARAMETERS

### 6.1 Debate Characteristics

| Element ID | Name                          | Default                           | Notes                     |
| ---------- | ----------------------------- | --------------------------------- | ------------------------- |
| ENV1       | Debate Type                   | Heterogeneous/Homogeneous/Private | From experimental design  |
| ENV2       | Debate Size                   | Varies by data                    | Actual participant counts |
| ENV3       | Initial Attitude Distribution | From data                         | Per debate                |
- [ ] 

## 7. OUTPUT VARIABLES

| Variable | Description                    | Level             |
| -------- | ------------------------------ | ----------------- |
| OUT1     | Final Attitude (T2 prediction) | Individual        |
| OUT2     | Attitude Change (T2 - T1)      | Individual        |
| OUT3     | Mean Debate Attitude Change    | Debate            |
| OUT4     | Debate Attitude Variance       | Debate            |
| OUT5     | Global Attitude Distribution   | Global            |
| OUT6     | Convergence Time               | Individual/Debate |
| OUT7     | Number of Interactions         | Individual        |

---

## PRIORITY CLASSIFICATION FOR SENSITIVITY ANALYSIS

### High Priority (Test First)
- [ ] Opinion update mechanism (B1)
- [ ] Attraction threshold (SI1)
- [ ] Repulsion threshold (SI2)
- [ ] Influence weight (SI3)
- [ ] Interaction partner selection (B2)

### Medium Priority
- [ ] Argument selection rule (B3)
- [ ] Memory size (A11)
- [ ] Convergence rate (SI7)
- [ ] Network topology (NET1)
- [ ] Simulation length (TIME2)

### Low Priority (Test if time permits)
- [ ] Argument forgetting rule (B4)
- [ ] Random seed variations (INIT3)
- [ ] Temporal dynamics (TIME1, TIME3)

---

## NOTES FOR COMPLETION

**ACTION ITEMS:**
1. Fill in all [SPECIFY] and ? values
2. Add precise mathematical formulations for all parametric elements
3. Write out pseudo-code for all behavioral rules
4. Define what the 5 subfactors actually are
5. Specify attitude scale and range
6. Determine which elements are calibrated vs. fixed vs. varied in SA
7. Link each element to specific hypotheses being tested

**QUESTIONS TO ANSWER:**
- How exactly do agents calculate their overall attitude from subfactors?
- What is the precise opinion update equation for each social influence model?
- How is "similarity" mathematically defined?
- How many time steps should simulations run?
- What constitutes "convergence" in your model?
