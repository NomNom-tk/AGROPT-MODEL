# ODD protocol for Social Influence ABM

# 1. Purpose and Patterns
## 1.1 Purpose - description or social learning or analogy??
-Description
The model addresses the idea that what we eat impacts the world around us, our health (Springmann et al., 2016; Forouzanfar et al., 2015), and the environment (Garnett., 2008; Vermeulen et al., 2012). It focuses on identifying and characterizing the mechanisms by which humans interact in social contexts (i.e. debates) to encourage behavioral change toward more sustainable food choices, such as meat consumption reduction. This model draws inspiration from the definition of deliberation, highlighted by Baechtiger et al. (2018) and takes the example of ¨mini-publics" (Niemeyer, 2011) to characterize a virtual environment where individuals interact and "deliberate" on the reduction of meat consumption. The model in this study uses data and and experimental characteristics (i.e. number of debate participants) from an ongoing study by Dheilly et al (unpublished). 

The purpose of the model is to understand how individual, debate level and global attitudes change in the context of debates that address meat consumption reduction. The ultimate purpose of the model is to characterize the underlying processes and phenomena implicated in this debate process...and further to understand whether the addition of argumentation dynamics improves the predictive efficiency of attitude evolution through the debates. The model social influence model is explicitly based on moels of social influence (Flache et al., 2017). 

The investigation into the impact of deliberation is addressed by looking into 7 hypotheses and one research question (described below). The scope of the model spans across 55 debates (19 homogeneous; 36 heterogeneous) and 187 debates (with only one agent) with a total of 459 participants. Homogeneous debates consist of only pro or only contra meat consumption reduction; heterogeneous debates have an equal split of both. 

The evaluation of the model is based on its ability to accurately predict the magnitude and direction of attitude change from pre- to post-debate compared with the data gathered in Dheilly et al (unpublished). This is quantitatively assessed through the model's ability to more accurately predict attitude change (using the Mean of Absolute Error) and the dynamics of agent interactions compared to Ordinary Least Squares (OLS) regressions.

## 1.2 Patterns
The model aims to reproduce these empirical patterns:
- Individual level -
1) Pre-deliberation attitudes are positively associated with post-deliberation attitudes, independent of debate context.
2) Higher perceived social norms and lower self-control exhibit higher absolute attitude change from pre- to post-deliberation, moderated by initial attitude strength.

- Debate Level -
3) ABM with social influence models initialized with pre-deliberation attitudes generates lower MAE than OLS.
4) Heterogeneous debates exhibit a greater mean attitude change than homogeneous debates.
5) ABM with pre-deliberation attitudes generate a lower MAE and Variance of Absolute Error (VAE) compared to OLS.

- Global Level -
6) ABM with social influence models initialized with pre-deliberation attitudes shows a post-deliberation attitude shift toward meat consumption reduction and generates a lower global MAE than a global OLS regression. 
RQ1) Exploratory analyses examine how variations in model parameters influence global attitude trajectories and convergence patterns.
7) ABM upgraded with argumentation mechanisms yield more accurate and stable predictions of MAE than ABM with social influence models.

Exploratory analyses are pre-specified but not used for confirmatory inference.

# 2. entities, state variables and scales
## 2.1 Entities
The following entities are present in the model: agents representing individuals who engaged in the debates (i.e. experiment participants), experiments (GUI and batch to calibrate and explore model parameters), grid cells (i.e. virtual geographical location in the environment), and the global environment representing the space in which the debates took place (i.e. the virtual meeting room).

## 2.2 State Variables
### Agent State Variables
#### Core Identity
- `agent_id` (integer): Unique identifier matching empirical participant
- `debate_id` (integer): Group membership (1-242)
- `group_type` (string): Debate condition {"Homogeneous", "Heterogeneous", "Control"}
- `pro_reduction` (binary): Initial stance (1=pro, 0=anti meat reduction)

#### Opinion State
- `initial_opinion` (float, [0,1]): Starting attitude computed from T1 subfactors
- `opinion` (float, [0,1]): Current attitude (updated each cycle)
- `previous_opinion` (float, [0,1]): Attitude at t-1 (for convergence detection)
- `final_attitude` (float, [0,1]): Target attitude from empirical T2 data (for validation)

#### Attitude Subfactors (T1 = initial, T2 = empirical target)
Five subfactors measured on [1,7] scale, normalized to [0,1]:
- `subfactor_1_t1` & `subfactor_1_t2`: Health considerations (PRO-reduction)
- `subfactor_2_t1` & `subfactor_2_t2`: Environmental impact (PRO-reduction)
- `subfactor_3_t1` & `subfactor_3_t2`: Taste/enjoyment (CONTRA-reduction)
- `subfactor_4_t1` & `subfactor_4_t2`: Cultural tradition (CONTRA-reduction)
- `subfactor_5_t1` & `subfactor_5_t2`: Economic concerns (CONTRA-reduction)

**Overall attitude formula:**
DB_Index = mean(subfactor_1, subfactor_2) - mean(subfactor_3, subfactor_4, subfactor_5)
Normalized: opinion = (DB_Index + 6) / 12  → [0,1] range

#### Agent-Specific Dynamics Parameters (Heterogeneous Agents Extension)
Each agent has individual susceptibility to influence, sampled from population distributions:
- `agent_convergence_rate` (float, [0.01,0.99]): Personal speed of opinion change
- `agent_confidence_threshold` (float, [0.01,0.99]): Similarity needed for influence
- `agent_repulsion_threshold` (float, [0.01,0.99]): Dissimilarity triggering repulsion
- `agent_repulsion_strength` (float, [0.01,0.99]): Strength of repulsive force

**Sampling:**
agent_param ~ Normal(population_mean, population_sd)
Bounded: max(0.01, min(0.99, sampled_value))
Constraint: agent_repulsion_threshold > agent_confidence_threshold

#### Network Structure
- `neighbors` (list<opinion_agent>): Agents with whom this agent interacts
- Network is static after initialization (no dynamic rewiring)
- Control agents have empty neighbor lists (no interaction)

#### Visualization
- `location` (point): Spatial coordinates for display (randomly assigned, no functional role)
- `color` (rgb): Visual representation of opinion (blue=0/anti, red=1/pro)

### 2.4 Scales
**Spatial:** 100 × 100 continuous 2D space (for visualization only)  
**Temporal:** Discrete time steps, 1 step = 0.5 time units  
**Typical simulation length:** 15-35 cycles until convergence (or max 100 cycles)  
**Opinion scale:** Continuous [0,1] where 0=strongly anti-reduction, 1=strongly pro-reduction  
**Empirical basis:** Real debates lasted ~60 minutes; model time is abstract (not calibrated to real minutes)


### 2.3 Global State Variables
#### Model Selection
- `model_type` (string): Which social influence model to use {"consensus", "clustering", "bipolarization"}
- `mode_batch` (boolean): Batch calibration mode vs GUI visualization

#### Population-Level Dynamics Parameters
Central tendency values from which agent-specific parameters are sampled:
- `convergence_rate` (float, [0,1]): Population mean speed of opinion change (μ)
- `confidence_threshold` (float, [0,1]): Population mean similarity threshold (ε)
- `repulsion_threshold` (float, [0,1]): Population mean dissimilarity threshold (ρ)
- `repulsion_strength` (float, [0,0.5]): Population mean repulsion strength (α)

#### Population Variation Parameters
Control individual differences:
- `convergence_rate_sd` (float, [0,0.2]): Standard deviation of convergence rates
- `confidence_threshold_sd` (float, [0,0.3]): SD of confidence thresholds
- `repulsion_threshold_sd` (float, [0,0.3]): SD of repulsion thresholds
- `repulsion_strength_sd` (float, [0,0.2]): SD of repulsion strengths

**Special case:** When all SD=0, model reverts to homogeneous agents (all share population means)

#### Debate Composition Tracking
- `current_condition` (string): Detected condition for current debate {"homogeneous", "heterogeneous", "control"}
- `num_pro_agents` (integer): Count of pro-reduction agents
- `num_anti_agents` (integer): Count of anti-reduction agents
- `mean_opinion_pro` (float): Mean opinion of pro-reduction agents
- `mean_opinion_anti` (float): Mean opinion of anti-reduction agents

#### Network Parameters
- `homophily_strength` (float, [0,1]): Preference for connecting with similar others
  - 0 = random connections
  - 1 = only connect with very similar agents
  - Determines probability: `P(connect) = homophily_strength × similarity + (1-homophily_strength) × 0.5`

#### Simulation Control
- `selected_debate_id` (integer): Which debate to simulate
- `max_cycles` (integer, default=100): Maximum simulation length
- `step` (float, default=0.5): Time step duration
- `mae_convergence_threshold` (float, default=0.001): Opinion change below this triggers end
- `end_simulation` (boolean): Flag indicating convergence reached
- `convergence_cycle` (integer): Cycle when convergence occurred (-1 if not converged)

#### Output Metrics
- `mae` (float): Global Mean Absolute Error (predicted vs empirical T2)
- `mae_per_debate` (map<int,float>): MAE for each debate separately
- `opinion_variance` (float): Current variance of all opinions
- `num_clusters` (integer): Number of distinct opinion clusters
- `polarization_index` (float): Measure of opinion spread
- `initial_num_clusters` (integer): Clusters at initialization (for comparison)

#### Bipolarization Diagnostics
- `neutral_zone_width` (float): ρ - ε (should be positive)
- `mean_net_repulsion_abs` (float): Average repulsive force magnitude
- `total_attractive_interactions` (integer): Cumulative attraction zone interactions
- `total_repulsive_interactions` (integer): Cumulative repulsion zone interactions
- `total_neutral_interactions` (integer): Cumulative neutral zone interactions


# 3. Process overview and scheduling
## 3.1 Initialization Sequence
1. Load CSV data ("data_complete_anonymised.csv")
↓
2. Validate data loading (check subfactor normalization)
↓
3. Create debate ID mapping (control agents get their unique debate)
↓
4. Initialize_agents_for_debate(selected_debate_id)
- Detect condition for specified debate
- Load subfactors from csv data rows (for T1 and T2)
- Sample agent specific parameters from distributions
- Compute initial_opinion from subfactors using DB_Index formula
- set opinion = initial_opinion
- Assign random spatial location for each agent in environment (for GUI)
↓
5. Create network
- Reset all neighbor connections and lists
- Create network types (complete, random, small_world)
- TO REPLACE NETWORK --> homophily connection
-- Build connections based on homophily_strength
-- Ensure each agent has at least 1 neighbor
↓
6. Report initial diagnostics
- Report number of initial opinion clusters
- Determine neutral_zone_width
- Set final_stats_computed to false 

## 3.2 Simulation Loop
[every cycle]
1. Agents execute reflexes in parallel
└─> consensus_formation OR bounded_confidence OR repulsive_influence
   - Calculate influence from neighbors (given neighbors > 0)
   - Update opinion (bounded [0,1])
   - Store previous_opinion for convergence check
   - Update color

[every 10 cycles]
2. Compute pro/anti stats (heterogeneous debates)
- Count pro and anti agents
- Calculate mean opinion of both groups

3. Compute statistics
- List opinions for all agents
- Calculate mean and variance of opinions
- Count opinion clusters using histogram 
- Compute polarization index using variance of pairwise distances

[every 5 cycles after cycle 10]
4. Convergence check
- Collect |opinion - previous_opinion| for all agents
- If max_change < mae_convergence_threshold
  - Set end_simulation to true
  - Call compute_fit
  - Call compute_final_statistics
- If mode_batch then save_results

[if cycle > max_cycles and not converged]
5. max_cycles_reached
- Force convergence
- Compute fit and save

### Update Order
Within-agent updates are done simultaneously (all agents update their opinion based on their t-1 neighbors).

Rationale: The within-agent updates procedure avoids order effects and maintains symmetry. This implies that network structure matters more than update sequence, consistent with the social influence models of Flache et al., (2017). The initialization sequence was designed to sequentially parse the csv for relevant data, populate the subfactor lists used for T1, then validate the data loading to ensure that the DB_Index variable is correctly calculated according to its equation defined in Dheilly et al. (unpublished). Once all data has been loaded and validated the agents are created according to the debate id and the opinion is set to initial_opinion to give a starting value for each subfactor for each agent. The network creation is initialized at each repetition of the simulation (e.g., in batch experiments to keep debates independent from each other). 

For each simulaiton loop agents execute the reflexes in parallel under one kind of model of social influence as the batch experiments are designed to calibrate parameters according to each model. This ligns up with the purpose of the study being to investigate how each model performs in comparison with the others and OLS. The decision to perform compute pro/anti stats is done every 10 cycles to allow for deliberation processes to occur and to reduce computational load when running the batch experiments. The convergence cycle reflex is activated every 5 cycles and after the 10th cycle to allow for an initial period of deliberation where the debates will most likely not converge and progressively check whether convergence occurs as a result of the deliberative process. The final reflex for max_cycles and no convergence is active after a pre-defined number of max cycles to reduce computational load. This is done as in initial testing, debates usually reached convergence below 100 cycles.

# 4. DESIGN CONCEPTS

### 4.1 Theoretical Background
**Primary theory:** Social influence models (Flache et al., 2017)
- **Consensus model:** Assimilative influence - agents converge toward group mean
- **Clustering model:** Bounded confidence - only similar others influence
- **Bipolarization model:** Similar attract, dissimilar repel

**Extension:** Agent heterogeneity in susceptibility to influence (not in original Flache models)

**Deliberation theory:** Bächtiger et al. (2018), Niemeyer et al. (2024) - mini-publics enable perspective-taking and norm reflection

### 4.2 Emergence
**Emergent phenomena the model can produce:**
- Opinion convergence or polarization (not pre-determined)
- Opinion cluster formation in heterogeneous debates
- Asymmetric attitude change (pro vs anti agents may behave differently)
- Opinion leader effects (agents with high convergence_rate may shift more and influence others)

**Not emergent:**
- Network structure (determined at initialization)
- Agent participation (fixed by debate_id)
- Individual susceptibilities (sampled at init, then constant)

### 4.3 Adaptation
**Agents adapt their opinions** based on neighbors' current opinions.

**No adaptation of:**
- Network connections (static)
- Influence parameters (agent_convergence_rate, etc. are fixed after initialization)
- Interaction rules (model_type doesn't change during simulation)

**Rationale:** Debates are short-term interactions; personality traits and social ties don't change within a 60-minute discussion.

### 4.4 Objectives
**Agents are not goal-directed.** They do not seek to:
- Maximize consensus
- Win arguments
- Change others' minds
- Maintain their own opinion

**Instead:** Agents mechanistically respond to neighbor opinions according to their influence parameters. This represents automatic social influence processes rather than strategic behavior.

**Contrast with argumentation extension (future):** Argument selection may be goal-directed.

### 4.5 Learning
**No learning.** Agent parameters remain constant throughout simulation.

**Rationale:** Short time scale (single debate session). Learning would be relevant for repeated interactions over weeks/months.

### 4.6 Prediction
**Agents do not predict:** They respond to current neighbor opinions, not anticipated future states.

**Model users predict:** The model's purpose is predicting T2 attitudes, but agents themselves have no predictive mechanisms.

### 4.7 Sensing
**Agents perceive:**
- Current opinions of all neighbors (perfect information within network)
- Immediately updated (no delay or memory)

**Agents do NOT perceive:**
- Opinions of non-neighbors
- Past opinion trajectories
- Global statistics (variance, polarization)
- Other agents' influence parameters

**Sensing mechanism:** Direct access to `neighbors` list and each neighbor's `opinion` attribute.

### 4.8 Interaction
**Direct interaction:** Agent i influences agent j if j ∈ neighbors(i)

**Interaction pattern depends on model_type:**

**Consensus model:**
All neighbors influence equally
new_opinion = opinion + agent_convergence_rate × (mean(neighbor_opinions) - opinion)


**Clustering model:**
Only similar neighbors influence
similar_neighbors = {n : |n.opinion - opinion| ≤ agent_confidence_threshold}
new_opinion = opinion + agent_convergence_rate × (mean(similar_opinions) - opinion)

**Bipolarization model:**

Similar attract, dissimilar repel
For each neighbor n:
  diff = |n.opinion - opinion|
  If diff ≤ agent_confidence_threshold:    attraction += (n.opinion - opinion)
  If diff ≥ agent_repulsion_threshold:     repulsion += direction
new_opinion = opinion + convergence_rate × attraction + repulsion_strength × repulsion

**Interaction is symmetric:** If i influences j, then j influences i (undirected network)

**No group-level coordination:** Each agent updates independently based on local neighborhood.

### 4.9 Stochasticity
**Sources of randomness:**

**At initialization:**
- Agent parameter sampling: `agent_param ~ Normal(population_mean, population_sd)`
- Network creation: Probabilistic connections (random, small-world, or homophily-based)
- Spatial location assignment: `location ~ Uniform(0, 100) × Uniform(0, 100)`

**During simulation:**
- None (deterministic dynamics given initial conditions)

**Across runs:**
- Different random seeds produce different parameter samples and networks
- However, empirical findings show: stochasticity has minimal effect on MAE (variance ≈ 0)
- Implication: 1-3 seed replicates sufficient (not 30)

**Control of stochasticity:**
- `keep_seed: true` in batch experiments ensures reproducibility
- Seed value saved in output files for traceability

### 4.10 Collectives
**Debates** are the primary collective entity:
- Agents with same `debate_id` form a collective
- Network connections only within debates (no cross-debate interaction)
- Statistics computed per debate (mae_per_debate)

**No explicit representation:** Debates are implicit groupings, not separate entities with state variables.

**Homogeneous vs Heterogeneous distinction:**
- Homogeneous: All agents start with similar opinions (either pro or anti)
- Heterogeneous: Mix of pro and anti agents
- Detected automatically from data at runtime

### 4.11 Observation
**Data collection occurs at:**
- Every 10 cycles: Variance, polarization, cluster count
- Every 5 cycles (after cycle 10): Convergence check
- At convergence: Final statistics, MAE computation

**Output files:**

**batch_summary.csv** (debate-level):
- model_type, current_condition, selected_debate_id
- pro_count, anti_count
- convergence_rate, confidence_threshold, repulsion_threshold, repulsion_strength (population params)
- convergence_rate_sd, confidence_threshold_sd, etc. (population variation)
- seed, convergence_cycle
- mae, opinion_variance, polarization_index, num_clusters
- Diagnostics: neutral_zone_width, mean_net_repulsion_abs

**agent_level_results.csv** (individual):
- All columns from batch_summary (repeated)
- agent_id, pro_reduction
- subfactor_1_t1 through subfactor_5_t1 (initial)
- initial_opinion (computed from subfactors)
- opinion (final simulated)
- subfactor_1_t2 through subfactor_5_t2 (empirical targets)
- final_attitude (empirical T2 attitude)
- opinion_change, individual_error
- error_sub1 through error_sub5 (prediction error per subfactor)
- agent_convergence_rate, agent_confidence_threshold, agent_repulsion_threshold, agent_repulsion_strength (individual params)

## 5. INITIALIZATION

### 5.1 Initial State

**Environment:** Empty 100×100 continuous space

**Agent creation:** Conditional on `selected_debate_id`
- Only agents with `debate_id_list[idx] == selected_debate_id` are created
- Typical result: 4-7 agents per simulation run (55 debates)
- Control debates: 1 agent (187 control "debates")

### 5.2 Data Loading

**Source:** `data_complete_anonymised.csv` containing empirical study data from Dheilly et al. (unpublished)

**Key columns loaded:**
- Agent identifiers: `agent_id`, `ID_Group_all`
- Debate condition: `Condition` ∈ {"Homogeneous", "Heterogeneous", "Control"}
- Initial stance: `Pro_Anti_Reduction` ∈ {0, 1}
- T1 subfactors: `DBFactor1T1`, `DBFactor2T1`, ..., `DBFactor5T1` (scale [1,7])
- T2 subfactors: `DBFactor1T2`, `DBFactor2T2`, ..., `DBFactor5T2` (scale [1,7])
- Overall attitudes: `DB_IndexT1`, `DB_IndexT2` (scale [-6,+6])

**Data transformations:**

**Subfactors:** From [1,7] to [0,1]

normalized_subfactor = (raw_value - 1.0) / 6.0

**DB_Index:** From [-6,+6] to [0,1]

normalized_index = (raw_value + 6.0) / 12.0


**Validation check:** After loading, verify computed initial_opinion from subfactors matches DB_IndexT1:

computed = (mean(F1,F2) - mean(F3,F4,F5) + 6) / 12
Expected difference: < 10^-10 (floating point precision only)

### 5.3 Debate ID Mapping
Regular debates: multiple agents share the same ID_Group_All so they are assigned a common debate_id.
- 55 multi-agent debates (19 homogeneous and 36 heterogeneous)

Control agents: each gets a unique debate_id (as they have no interaction partners)
- Created as: "Control_" + agent_id
- Prevents the control agents from being grouped together
- 187 single-agent control "debates"

Result: 242 unique debate_ids in the full dataset

### 5.4 Agent Parameter Assignment
For each agent in a selected debate:
Step 1: Load empirical attributes
- agent_id ← agent_id_list[idx]
- debate_id ← selected_debate_id
- group_type ← group_type_list[idx]
- pro_reduction ← pro_reduction_list[idx]
- subfactor_X_t1 ← subfactors_t1[X][idx]  // X ∈ {0,1,2,3,4}
- subfactor_X_t2 ← subfactors_t2[X][idx]
- final_attitude ← final_attitude_list[idx]  // Empirical T2

Step 2: Sample individual dynamics parameters
- agent_convergence_rate ~ max(0.01, min(0.99, 
    Normal(convergence_rate, convergence_rate_sd)))

- agent_confidence_threshold ~ max(0.01, min(0.99,
    Normal(confidence_threshold, confidence_threshold_sd)))

- agent_repulsion_threshold ~ max(0.01, min(0.99,
    Normal(repulsion_threshold, repulsion_threshold_sd)))

- agent_repulsion_strength ~ max(0.01, min(0.99,
    Normal(repulsion_strength, repulsion_strength_sd)))

// Enforce constraint
If agent_repulsion_threshold ≤ agent_confidence_threshold:
    agent_repulsion_threshold ← agent_confidence_threshold + 0.1

Step 3: Compute initial opinion
- pro_mean = (subfactor_1_t1 + subfactor_2_t1) / 2
- contra_mean = (subfactor_3_t1 + subfactor_4_t1 + subfactor_5_t1) / 3

// Denormalize to original [1,7] scale
- pro_denorm = pro_mean × 6.0 + 1.0
- contra_denorm = contra_mean × 6.0 + 1.0

// Compute difference on [-6,+6] scale
- db_index_raw = pro_denorm - contra_denorm

// Normalize to [0,1]
- initial_opinion = (db_index_raw + 6.0) / 12.0

- opinion ← initial_opinion
- previous_opinion ← initial_opinion

Step 4: Initialize other attributes
location ← (random(0,100), random(0,100))
color ← RGB(opinion×255, 0, (1-opinion)×255)
neighbors ← []  // Populated in next step

### 5.5 Network Initialization
**Current implementation: Three network types (to be replaced)**

**Complete network:**
All agents in same debate connect to each other
(Excluding control agents who have no neighbors)

**Random network:**
Each pair of agents connects with probability = connection_probability

**Small-world network:**
Ring lattice with k nearest neighbors + random rewiring with probability p

---

**Planned replacement: Homophily-based network creation**

**Algorithm:**
For each agent i (excluding controls):
    For each potential partner j ≠ i (same debate, not control):
        
        similarity = 1 - |j.initial_opinion - i.initial_opinion|
        
        P(connect) = homophily_strength × similarity + 
                     (1 - homophily_strength) × 0.5
        
        If random() < P(connect):
            Add j to i.neighbors

// Ensure minimum connectivity
For each agent with no neighbors:
    Connect to most similar agent in same debate

**Network properties (both current and planned):**
- Undirected: If i connects to j, j connects to i
- Static: No rewiring during simulation
- Intra-debate only: No cross-debate edges
- Control agents: Empty neighbor lists (isolated)

**Planned parameter:** `homophily_strength` ∈ [0, 1]
- 0: Random network (50% connection probability)
- 0.5: Moderate homophily (similarity weighted 50%)
- 1.0: Strong homophily (only very similar agents connect)

**Rationale for replacement:** Small group debates (4-7 people) likely form connections based on perceived similarity rather than spatial proximity or random matching. Homophily parameter can be calibrated like other model parameters.

### 5.6 Initial Diagnostics
**Computed before simulation starts:**
- `initial_num_clusters`: Number of distinct opinion bins (histogram with 10 bins)
- `neutral_zone_width`: ρ - ε (population-level values; should be positive for bipolarization model)
- `current_condition`: Detected from data {"homogeneous", "heterogeneous", "control"}

**Validation outputs:** Console messages confirming:
- Number of agents created
- Debate condition detected
- Agent parameter distribution statistics (mean, SD, min, max)
- Validation check results (difference between computed and empirical initial opinions)

## 6. INPUT DATA
### 6.1 Data Source
**File:** `data_complete_anonymised.csv`  
**Format:** CSV with header row  
**Rows:** 459 participant records  
**Debates:** 242 unique debate groups
- 55 multi-agent debates (4-7 participants each)
- 187 single-agent control "debates"
**Origin:** Empirical study by Dheilly et al. (unpublished) on deliberative debates about meat consumption reduction

### 6.2 Data Structure
**Required columns:**
- Agent identifiers: `agent_id`, `ID_Group_all`
- Debate condition: `Condition` ∈ {"Homogeneous", "Heterogeneous", "Control"}
- Initial stance: `Pro_Anti_Reduction` ∈ {0, 1}
- T1 subfactors: `DBFactor1T1`, `DBFactor2T1`, ..., `DBFactor5T1` (scale [1,7])
- T2 subfactors: `DBFactor1T2`, `DBFactor2T2`, ..., `DBFactor5T2` (scale [1,7])
- Overall attitudes: `DB_IndexT1`, `DB_IndexT2` (scale [-6,+6])

**Additional columns (not currently used in ABM):**
- Demographics: Age, gender, education
- `perceived_norms`: For regression models
- `self_control`: For regression models
- Reduction variables: Red/Processed/Poultry meat consumption changes

**Data quality checks performed:**
- No missing values in required columns
- Subfactors within [1,7] range
- DB_Index within [-6,+6] range
- Subfactor-based computation matches DB_Index (within floating-point precision)

### 6.3 Environmental Data
**None.** Model does not use:
- Geographic data
- Time series (debates are single time points)
- Weather, resources, or other environmental variables

Spatial location in 100×100 grid is for visualization only and has no functional role in agent interactions.

### 6.4 Model Does NOT Use (from data file)
**Excluded variables:**
- `Perceived Social Norms`: Used in regression models (H2) but not as agent attributes in ABM
- `Self-Control`: Used in regression models (H2) but not as agent attributes in ABM
- Demographic variables: Not needed for social influence prediction task
- Open-ended responses: Not quantifiable for ABM

**Rationale:** Model focuses on attitude dynamics during debates as emergent from social influence processes, not individual personality differences. This design choice enables testing hypothesis H3: whether ABM with only initial attitudes can outperform regression with personality predictors.

## 7. SUBMODELS
### 7.1 Opinion Update Models
Three alternative social influence mechanisms (only one active per run, selected by `model_type` parameter):

#### 7.1.1 Consensus Model (Assimilative Influence)
**Theoretical basis:** DeGroot (1974) social learning model; Friedkin & Johnsen (1990)

**Mechanism:** All agents converge toward mean opinion of their network neighborhood.

**Algorithm:**
For each agent i with neighbors N(i):
    
    all_opinions = [i.opinion] + [n.opinion for n in N(i)]
    new_opinion = mean(all_opinions)
    
    opinion_change = agent_convergence_rate × (new_opinion - i.opinion)
    
    i.opinion = max(0, min(1, i.opinion + opinion_change))
    
    i.color = RGB(i.opinion×255, 0, (1-i.opinion)×255)

**Key parameters:**
- `agent_convergence_rate`: Speed of convergence (higher = faster change)

**Expected behavior:**
- Opinions converge toward group mean
- Final state: Consensus (all agents same opinion) or near-consensus
- Works well for homogeneous debates

**Limitations:**
- Cannot produce polarization
- Ignores opinion dissimilarity effects
- May overpredict convergence in heterogeneous debates

#### 7.1.2 Clustering Model (Bounded Confidence)
**Theoretical basis:** Hegselmann & Krause (2002, 2006); Deffuant et al. (2000)

**Mechanism:** Agents only influenced by similar others (within confidence threshold).

**Algorithm:**
For each agent i with neighbors N(i):
    
    // Filter for similar neighbors
    similar = [n for n in N(i) 
               if |n.opinion - i.opinion| ≤ i.agent_confidence_threshold]
    
    If similar is not empty:
        avg_similar = mean([n.opinion for n in similar])
        opinion_change = i.agent_convergence_rate × (avg_similar - i.opinion)
        i.opinion = max(0, min(1, i.opinion + opinion_change))
    
    i.color = RGB(i.opinion×255, 0, (1-i.opinion)×255)

**Key parameters:**
- `agent_convergence_rate`: Speed of influence
- `agent_confidence_threshold`: Maximum opinion difference for influence (ε)

**Expected behavior:**
- Opinion clusters form (subgroups with internal consensus)
- Number of clusters depends on initial distribution and ε
- Larger ε → fewer, larger clusters
- Smaller ε → more, smaller clusters (possibly no change if everyone too different)

**Limitations:**
- No repulsion mechanism
- Binary cutoff (similar/dissimilar) is abrupt
- Neutral zone has no special properties

#### 7.1.3 Bipolarization Model (Attraction-Repulsion)
**Theoretical basis:** Mäs et al. (2013); Flache & Macy (2011) "negative influence"

**Mechanism:** Similar agents attract, dissimilar agents repel.

**Algorithm:**
For each agent i with neighbors N(i):
    
    attraction_force = 0
    repulsion_force = 0
    attractive_count = 0
    repulsive_count = 0
    
    For each neighbor n in N(i):
        diff = |n.opinion - i.opinion|
        
        If diff ≤ i.agent_confidence_threshold:
            // ATTRACTION ZONE
            attraction_force += (n.opinion - i.opinion)
            attractive_count += 1
        
        Else if diff ≥ i.agent_repulsion_threshold:
            // REPULSION ZONE
            direction = sign(n.opinion - i.opinion)  // +1 if n higher, -1 if lower
            repulsion_force += -direction  // Move away
            repulsive_count += 1
        
        // Else: NEUTRAL ZONE (no influence)
    
    // Apply combined forces
    If attractive_count > 0:
        attraction_effect = i.agent_convergence_rate × (attraction_force / attractive_count)
    Else:
        attraction_effect = 0
    
    If repulsive_count > 0:
        repulsion_effect = i.agent_repulsion_strength × (repulsion_force / repulsive_count)
    Else:
        repulsion_effect = 0
    
    i.opinion = max(0, min(1, i.opinion + attraction_effect + repulsion_effect))
    i.color = RGB(i.opinion×255, 0, (1-i.opinion)×255)

**Key parameters:**
- `agent_convergence_rate`: Strength of attraction (μ)
- `agent_confidence_threshold`: Upper bound of attraction zone (ε)
- `agent_repulsion_threshold`: Lower bound of repulsion zone (ρ)
- `agent_repulsion_strength`: Strength of repulsion (α)

**Constraint:** ε < ρ (attraction threshold must be less than repulsion threshold)

**Three zones:**
|opinion_diff| ≤ ε:       ATTRACTION (move toward neighbor)
ε < |opinion_diff| < ρ:   NEUTRAL (no influence)
|opinion_diff| ≥ ρ:       REPULSION (move away from neighbor)

**Expected behavior:**
- Polarization: Agents cluster at opinion extremes
- Number of poles depends on initial distribution and parameters
- Can maintain opinion diversity even after convergence
- Best for heterogeneous debates with initial opinion spread

**Limitations:**
- More parameters to calibrate
- Requires careful parameter choice (ε < ρ, not too large α)
- Can produce unstable oscillations if parameters poorly chosen

### 7.2 Convergence Detection
**Purpose:** Stop simulation when opinions stabilize (computational efficiency + realism)

**Algorithm (executed every 5 cycles after cycle 10):**
opinion_changes = []

For each agent i:
    change = |i.opinion - i.previous_opinion|
    opinion_changes.append(change)

max_change = max(opinion_changes)

If max_change < mae_convergence_threshold:
    convergence_cycle = current_cycle
    end_simulation = TRUE
    compute_fit()
    compute_final_statistics()
    If batch_mode: save_batch_results()

**Convergence criterion:** Maximum opinion change < 0.001 per cycle

**Rationale:** Opinion change becomes negligible; further cycles add no information

**Fallback:** If max_cycles (100) reached without convergence, force stop

**Typical convergence:** 15-35 cycles for most parameter combinations (observed in initial testing)

### 7.3 Model Fit Computation
**Purpose:** Quantify prediction accuracy

**Metric:** Mean Absolute Error (MAE) between simulated and empirical T2 attitudes

**Algorithm:**
compute_fit():
    all_errors = []
    
    For each agent i:
        predicted = i.opinion  // Final simulated opinion
        empirical = i.final_attitude  // Empirical T2 from data
        error = |predicted - empirical|
        all_errors.append(error)
    
    mae = mean(all_errors)
    
    // Also compute per-debate MAE
    For each unique debate_id d:
        agents_in_d = [agents where debate_id == d]
        errors_d = [|a.opinion - a.final_attitude| for a in agents_in_d]
        mae_per_debate[d] = mean(errors_d)

**Interpretation:**
- MAE = 0: Perfect prediction
- MAE < 0.05: Excellent fit
- MAE < 0.10: Good fit
- MAE > 0.20: Poor fit

**Scale:** MAE on [0,1] normalized opinion scale
- MAE = 0.10 means average prediction error of 1.2 units on original [-6,+6] scale

### 7.4 Statistical Computations
**Executed every 10 cycles (and at convergence):**

**Opinion variance:**
opinions = [agent.opinion for all agents]
mean_opinion = mean(opinions)
variance = mean([(o - mean_opinion)² for o in opinions])

**Opinion clusters (histogram method):**
histogram = [0] * 10  // 10 bins
For each opinion o:
    bin = min(9, floor(o * 10))
    histogram[bin] += 1

num_clusters = count([h for h in histogram if h > 0])

**Polarization index (pairwise distance variance):**
pairwise_distances = []
For each agent i:
    For each agent j ≠ i:
        pairwise_distances.append(|i.opinion - j.opinion|)

mean_distance = mean(pairwise_distances)
variance_distance = 0
For each distance d:
    variance_distance += (d - mean_distance)²

polarization_index = variance_distance / (length(pairwise_distances) × 1.0²)

**Interpretation:** Higher polarization index → more bimodal/polarized distribution

**Pro/Anti group statistics (heterogeneous debates only):**
pro_agents = [agents where pro_reduction == 1]
anti_agents = [agents where pro_reduction == 0]

num_pro_agents = count(pro_agents)
num_anti_agents = count(anti_agents)

If num_pro_agents > 0:
    mean_opinion_pro = mean([a.opinion for a in pro_agents])

If num_anti_agents > 0:
    mean_opinion_anti = mean([a.opinion for a in anti_agents])

### 7.5 Network Creation
**Current implementation (to be documented for completeness):**

**Complete network:**
For each agent i (excluding controls):
    neighbors = all agents j where:
        - j ≠ i
        - j.debate_id == i.debate_id
        - j.group_type ≠ "Control"

**Random network:**
For each agent i (excluding controls):
    For each potential neighbor j (same debate, not control):
        If random() < connection_probability:
            Add j to i.neighbors

**Small-world network:**
agent_list = list of agents (excluding controls, sorted by index)

For each agent i in agent_list:
    // Connect to k nearest neighbors in ring topology
    For j from 1 to small_world_k:
        neighbor_index = (i + j) mod length(agent_list)
        If agent_list[neighbor_index].debate_id == i.debate_id:
            Add to neighbors
    
    // Random rewiring
    If random() < small_world_rewire:
        random_neighbor = random agent (same debate, not control)
        Add to neighbors

**Planned implementation: Homophily-based network**

**Algorithm:**
create_network():
    
    // Reset all neighbor lists
    For each agent: neighbors = []
    
    // Build connections
    For each agent i (excluding control agents):
        For each potential neighbor j ≠ i (same debate, not control):
            
            similarity = 1 - |j.initial_opinion - i.initial_opinion|
            
            connection_prob = homophily_strength × similarity + 
                              (1 - homophily_strength) × 0.5
            
            If random() < connection_prob:
                i.neighbors.add(j)
    
    // Ensure minimum connectivity
    For each agent i with no neighbors:
        closest = agent with min(|j.initial_opinion - i.initial_opinion|)
                  where j ≠ i, same debate, not control
        i.neighbors.add(closest)
        
Parameter: homophily_strength ∈ [0,1]
- 0: Random network (50% connection probability)
- 0.5: Moderate homophily (similarity weighted at 50%)
- 1.0: Strong homophily (only very similar agents connect)

Rationale: In small debates (4-7 people), network dynamic effect might be minimal. Homophily, being a preference for similar others is more theoretically justified for deliberative setting than arbitrary spatial or random structures. This parameter will be calibrated alongside other model parameters.

## 8. MODEL CALIBRATION AND VALIDATION
### 8.1 Calibration Strategy
Objective: Find parameter values minimizing MAE on training set
Method: Genetic Algorithm (GA) implemented in GAMA batch experiments
Parameters calibrated:
Population-level means:
- convergence_rate: [0.1, 0.2, 0.3, 0.4, 0.5]
- confidence_threshold: [0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8] (clustering & bipolarization)
- repulsion_threshold: [0.4, 0.5, 0.6, 0.7, 0.8] (bipolarization only)
- repulsion_strength: [0.1, 0.2, 0.3] (bipolarization only)

Population variation (SD) - if agent heterogeneity extension is used:
- convergence_rate_sd: [0.0, 0.05, 0.1]
- confidence_threshold_sd: [0.0, 0.1, 0.2]
- repulsion_threshold_sd: [0.0, 0.1, 0.2]
- repulsion_strength_sd: [0.0, 0.02, 0.05]

Network (homophily based instead of network dynamics):
- homophily_strength: [0.0, 0.3, 0.5, 0.7, 1.0]

GA settings:
- Population size: 5
- Crossover probability: 0.5
- Mutation probability: 0.1
- Preliminary generations: 5
- Maximum generations: 5
- Replication: 30 seeds per parameter combination initially; reduced to 1-3 after finding stochasticity ≈ 0

Data split procedure:
Stratified random sampling:
- Calibration set: ~11 debates (20% of 55 multi-agent debates)
- Validation set: ~44 debates (80% of multi-agent debates)
- Stratification ensures proportional representation of:
-- Heterogeneous debates
-- Homogeneous debates
-- (Control debates excluded from calibration as they have no interactions)

Implementation in R (yet to be done):
library(dplyr)

# Load and categorize debates
debate_info <- data %>%
  group_by(ID_Group_all) %>%
  summarize(
    Condition = first(Condition),
    n_agents = n()
  ) %>%
  filter(Condition != "Control")  # Exclude controls

# Count by type
n_hetero <- sum(debate_info$Condition == "Heterogeneous")
n_homo <- sum(debate_info$Condition == "Homogeneous")

# Calculate proportional split for 11 debates
n_calib_hetero <- round(11 * n_hetero / 55)
n_calib_homo <- 11 - n_calib_hetero

# Random stratified sample
set.seed(42)  # Reproducibility
hetero_debates <- debate_info %>% filter(Condition == "Heterogeneous")
homo_debates <- debate_info %>% filter(Condition == "Homogeneous")

calib_debates <- c(
  sample(hetero_debates$ID_Group_all, n_calib_hetero),
  sample(homo_debates$ID_Group_all, n_calib_homo)
)

validation_debates <- setdiff(debate_info$ID_Group_all, calib_debates)

# Save split for reproducibility
write.csv(data.frame(debate_id = calib_debates, set = "calibration"),
          "debate_split.csv", row.names = FALSE)
```

**Model selection procedure:**
1. Run GA calibration separately for each model (consensus, clustering, bipolarization)
2. Evaluate on validation set
3. Compare models:
   - Overall (all debates pooled)
   - By condition (heterogeneous vs homogeneous separately)
4. Select best model per condition based on validation MAE

**Computational budget:**
- Phase 1: Grid search exploration (~50-100 parameter combinations per model)
- Phase 2: GA optimization (5 gen × 5 pop = 25 evaluations per parameter set)
- Phase 3: Validation (best params × 44 debates × 3 seeds ≈ 130 runs)
- Total per model: ~200-300 simulation runs
- Total for 3 models: ~600-900 runs
- Estimated time: 4-8 hours with parallelization (depends on hardware)

**Handling of stochasticity:**
- Initial testing revealed stochasticity has minimal effect (variance ≈ 0 across seeds)
- Implication: Only 1-3 seeds needed per parameter combination
- This significantly reduces computational burden

### 8.2 Best Parameters Found

**[FILL IN AFTER CALIBRATION]**

**Consensus model:**
convergence_rate = [VALUE]
convergence_rate_sd = [VALUE] (if heterogeneity tested)
homophily_strength = [VALUE] (if homophily tested)

Best for: [Homogeneous/Heterogeneous/Both]
Calibration MAE: [VALUE]
Validation MAE: [VALUE]
Typical convergence: [X] cycles

**Clustering model:**
convergence_rate = [VALUE]
confidence_threshold = [VALUE]
[+ SD parameters if used]
[+ homophily]

Best for: [Homogeneous/Heterogeneous/Both]
Calibration MAE: [VALUE]
Validation MAE: [VALUE]
Typical convergence: [X] cycles

**Bipolarization model:**
convergence_rate = [VALUE]
confidence_threshold = [VALUE]
repulsion_threshold = [VALUE]
repulsion_strength = [VALUE]
[+ SD parameters if used]
[+ homophily]

Best for: [Homogeneous/Heterogeneous/Both]
Calibration MAE: [VALUE]
Validation MAE: [VALUE]
Typical convergence: [X] cycles

**Key findings:** [INTERPRETATION FROM DATA]
- Which model performs best overall?
- Do different debate types require different models?
- Does agent heterogeneity (SD > 0) improve predictions?
- Does homophily improve predictions over random/complete networks?

### 8.3 Sensitivity Analysis
**Stochasticity analysis:**
- Variance in MAE across different random seeds
- Expected finding: Near-zero variance (deterministic dynamics given initial conditions)
- Implication for seed replication strategy

**Parameter sensitivity:**
- Which parameters have largest effect on MAE?
- Are there parameter interactions?
- Are there non-linear threshold effects?

**Analysis methods:**
- Scatter plots: parameter value vs MAE
- Correlation matrix
- Sobol indices (if comprehensive sensitivity analysis performed)

**[NEED TO FILL IN AFTER ANALYSIS]**

### 8.4 Validation
**Quantitative validation:**
- MAE on held-out validation debates
- Comparison to OLS regression baseline (Hypotheses H3, H5, H6)
- Condition-specific performance (H4)
- Distribution matching: predicted vs empirical T2 distributions

**Qualitative validation:**
- Opinion trajectories show realistic patterns:
  - No oscillations
  - Monotonic convergence or stable equilibrium
  - Maintained diversity (not complete consensus except in special cases)
- Final opinion distributions match empirical patterns
- Convergence times reasonable (15-35 cycles ≈ plausible for 60-minute debates conceptually)

**Pattern matching (from Section 1.2):**
- ✓/✗ Pre-post correlation maintained (H1)
- ✓/✗ Heterogeneous > homogeneous change (H4)
- ✓/✗ ABM < OLS on MAE (H3, H5, H6)
- ? Directional asymmetry (pro vs anti change) - exploratory
- ? Role of perceived norms/self-control (H2) - regression only, not ABM

**Comparison to benchmark (OLS regression):**
Model             | Individual MAE | Debate MAE | Global MAE
------------------+----------------+------------+-----------
OLS (baseline)    | [VALUE]        | [VALUE]    | [VALUE]
Consensus         | [VALUE]        | [VALUE]    | [VALUE]
Clustering        | [VALUE]        | [VALUE]    | [VALUE]
Bipolarization    | [VALUE]        | [VALUE]    | [VALUE]

**[FILL IN AFTER VALIDATION]**

## 9. REFERENCES

**Theoretical foundations:**
- Flache, A., Mäs, M., Feliciani, T., Chattoe-Brown, E., Deffuant, G., Huet, S., & Lorenz, J. (2017). Models of social influence: Towards the next frontiers. *Journal of Artificial Societies and Social Simulation*, 20(4), 2.
- Bächtiger, A., Dryzek, J. S., Mansbridge, J., & Warren, M. E. (2018). Deliberative democracy: An introduction. In *The Oxford handbook of deliberative democracy*. Oxford University Press.
- Niemeyer, S. (2011). The emancipatory effect of deliberation: Empirical lessons from mini-publics. *Politics & Society*, 39(1), 103-140.
- Niemeyer, S., Veri, F., Dryzek, J. S., & Bächtiger, A. (2024). How deliberation happens: enabling deliberative reason. *American Political Science Review*, 118(1), 345-362.

**Bounded confidence models:**
- Hegselmann, R., & Krause, U. (2002). Opinion dynamics and bounded confidence models, analysis, and simulation. *Journal of Artificial Societies and Social Simulation*, 5(3).
- Hegselmann, R., & Krause, U. (2006). Truth and cognitive division of labour: First steps towards a computer aided social epistemology. *Journal of Artificial Societies and Social Simulation*, 9(3), 10.
- Deffuant, G., Neau, D., Amblard, F., & Weisbuch, G. (2000). Mixing beliefs among interacting agents. *Advances in Complex Systems*, 3(01n04), 87-98.

**Attraction-repulsion:**
- Mäs, M., Flache, A., & Helbing, D. (2013). Individualization as driving force of clustering phenomena in humans. *PLoS Computational Biology*, 9(10), e1003225.
- Flache, A., & Macy, M. W. (2011). Small worlds and cultural polarization. *Journal of Mathematical Sociology*, 35(1-3), 146-176.

**Social learning and consensus:**
- DeGroot, M. H. (1974). Reaching a consensus. *Journal of the American Statistical Association*, 69(345), 118-121.
- Friedkin, N. E., & Johnsen, E. C. (1990). Social influence and opinions. *Journal of Mathematical Sociology*, 15(3-4), 193-206.

**ABM methodology:**
- Miller, J. H., & Page, S. E. (2009). *Complex adaptive systems: An introduction to computational models of social life*. Princeton University Press.
- Jung, J., Miller, J. H., & Page, S. E. (2025). Agent-Based Modeling for Psychological Research on Social Phenomena. *American Psychologist*.
- Guest, O., & Martin, A. E. (2021). How computational modeling can force theory building in psychological science. *Perspectives on Psychological Science*, 16(4), 789-802.
- MacCoun, R. J. (2017). Computational models of social influence and collective behavior. In *Computational social psychology* (pp. 258-280). Routledge.

**Model validation:**
- Windrum, P., Fagiolo, G., & Moneta, A. (2007). Empirical validation of agent-based models: Alternatives and prospects. *Journal of Artificial Societies and Social Simulation*, 10(2), 8.
- Railsback, S. F., & Grimm, V. (2019). *Agent-based and individual-based modeling: A practical introduction*. Princeton University Press.
- Lorscheid, I., Heine, B. O., & Meyer, M. (2012). Opening the 'black box' of simulations: increased transparency and effective communication through the systematic design of experiments. *Computational and Mathematical Organization Theory*, 18(1), 22-62.

**ODD protocol:**
- Grimm, V., Railsback, S. F., Vincenot, C. E., Berger, U., Gallagher, C., DeAngelis, D. L., ... & Ayllón, D. (2020). The ODD protocol for describing agent-based and other simulation models: A second update to improve clarity, replication, and structural realism. *Journal of Artificial Societies and Social Simulation*, 23(2), 7.

**Empirical study:**
- Dheilly et al. (unpublished). [Full citation when published]

**Climate & food systems context:**
- Rockström, J., et al. (2025). The EAT–Lancet Commission on healthy, sustainable, and just food systems. *The Lancet*, 406(10512), 1625-1700.
- Steinfeld, H., et al. (2006). *Livestock's long shadow: Environmental issues and options*. FAO.
- Springmann, M., et al. (2016). Analysis and valuation of the health and climate change cobenefits of dietary change. *PNAS*, 113(15), 4146-4151.


## APPENDICES

### A. Parameter Summary Table

[Reference to your model_elements_chart_CLEAN.md or create summary table here]

### B. Data Dictionary

**Subfactor definitions:** // should i include thomas questionnaire?
- DBFactor1: Health considerations (items 1-6, PRO-reduction)
- DBFactor2: Environmental impact (items 7-10, PRO-reduction)
- DBFactor3: Taste/enjoyment (items 11-13, CONTRA-reduction)
- DBFactor4: Cultural tradition (items 14-17, CONTRA-reduction)
- DBFactor5: Economic concerns (items 18-20, CONTRA-reduction)

**DB_Index formula:**
```
DB_Index = mean(DBFactor1, DBFactor2) - mean(DBFactor3, DBFactor4, DBFactor5)
         = [(F1 + F2) / 2] - [(F3 + F4 + F5) / 3]
Range: [-6, +6] on original scale
Normalized: [0, 1] for model


