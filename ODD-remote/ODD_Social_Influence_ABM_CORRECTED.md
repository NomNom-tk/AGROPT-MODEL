# ODD protocol for Social Influence ABM

# 1. Purpose and Patterns
## 1.1 Purpose
-Description
The model addresses the idea that what we eat impacts the world around us, our health (Springmann et al., 2016; Forouzanfar et al., 2015), and the environment (Garnett, 2008; Vermeulen et al., 2012). It focuses on identifying and characterizing the mechanisms by which humans interact in social contexts (i.e. debates) to encourage behavioral change toward more sustainable food choices, such as meat consumption reduction. This model draws inspiration from the definition of deliberation, highlighted by Baechtiger et al. (2018) and takes the example of ¨mini-publics" (Niemeyer, 2011) to characterize a virtual environment where individuals interact and "deliberate" on the reduction of meat consumption. The model in this study uses data and experimental characteristics (i.e. number of debate participants) from an ongoing study by Dheilly et al (unpublished). 

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
The following entities are present in the model: agents representing individuals who engaged in the debates (i.e. experiment participants), experiments (GUI and batch to calibrate and explore model parameters), grid cells (i.e. virtual geographical location in the environment for GUI testing), and the global environment representing the space in which the debates took place (i.e. the virtual meeting room).

## 2.2 State Variables
### Agent State Variables
#### Core Identity
- `agent_id` (integer): Unique identifier matching empirical participant.
- `debate_id` (integer): Group membership matching the experimental session (1-242).
- `group_type` (string): Debate condition {"Homogeneous", "Heterogeneous", "Control"}
- `pro_reduction` (binary): Initial stance based on empirical designation (1=pro, 0=anti meat consumption reduction).
- `debate_label` (string): Text string naming the active empirical group.
- `current_experiment_id` (string): Tracker identifying the active simulation batch scenario.

#### Opinion State
- `initial_opinion` (float, [0,1]): Starting attitude computed from T1 subfactors from normalized T1 subfactors.
- `opinion` (float, [0,1]): Current attitude (updated dynamically each cycle).
- `previous_opinion` (float, [0,1]): Attitude at t-1 (for convergence detection).
- `final_attitude` (float, [0,1]): Target attitude from empirical T2 data (for validation).
- `initial_opinion_snapshot` (float, [0,1]): Immutable copy of the agent's initial opinion, set at setup to track deviations.
- `agent_net_change` (float): Structural shift magnitude from starting baseline, calculated dynamically as opinion - initial_opinion_snapshot.
- `agent_wrong_direction` (boolean): Validation flag to cehck if the simulated trajectory lines up with empirical data: $$\text{agent\_wrong\_direction} = (\text{pro\_reduction} = 1 \land \text{agent\_net\_change} < 0) \lor (\text{pro\_reduction} = 0 \land \text{agent\_net\_change} > 0)$$ 

#### Attitude Subfactors (T1 = initial, T2 = empirical target)
Five subfactors measured on [1,7] scale, normalized to [0,1]:
- `subfactor_1_t1` & `subfactor_1_t2`: Health considerations (PRO-reduction)
- `subfactor_2_t1` & `subfactor_2_t2`: Environmental impact (PRO-reduction)
- `subfactor_3_t1` & `subfactor_3_t2`: Taste/enjoyment (CONTRA-reduction)
- `subfactor_4_t1` & `subfactor_4_t2`: Cultural tradition (CONTRA-reduction)
- `subfactor_5_t1` & `subfactor_5_t2`: Economic concerns (CONTRA-reduction)

**Overall attitude formula (canonical statement — referenced, not repeated, in Sections 5.2 and 6.2):**
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

#### Turn-Based & Cognitive Fatigue
- `recent_speed` (list): Binary timeline vector recording whether the agent spoke during interaction cycles.
- `speak_weight` (float): Dynamic selection priority weight computed as: $$\text{speak\_weight} = \frac{1.0}{\sum(\text{recent\_speech}) + 1.0}$$
- `total_influences_received` (integer): Cumulative counter tracking individual received incoming communication events.
- `retention_discount` (float [0,1]): Dynamic cognitive fatigue modifier scaling down opinion adjustment steps, computed as: $$\text{retention\_discount} = \frac{1.0}{1.0 + \text{total\_influences\_received} \times 0.1}$$
- `agent_is_saturated` (boolean): Flag trigerred true when an agent becomes fatigue-inhibited (retention_discount > 0.2)
- `cumulative_opinion_change` (float): Running total of all absolute local shifts across steps.

#### Network Structure
- `neighbors` (list<opinion_agent>): Agents with whom this agent interacts
- Network is static after initialization (no dynamic rewiring)
- Control agents have empty neighbor lists (no interaction)

#### Visualization
- `location` (point): Spatial coordinates for display (randomly assigned, no functional role)
- `color` (rgb): Visual representation of opinion (blue=0/anti, red=1/pro)

### 2.4 Scales
**Spatial:** 100 × 100 continuous 2D space (for visualization only)  
**Temporal:** Discrete time steps (abstract, not calibrated to real time)
**Typical simulation length:** 15-110 cycles until convergence 
(max 100 cycles — applies equally to speaking and non-speaking mode)
**Convergence threshold:** max |opinion - previous_opinion| < 0.01 (see Submodel 7.2 for the full convergence-checking algorithm and its consequences)
**Opinion scale:** Continuous [0,1] where 0=strongly anti-reduction, 1=strongly pro-reduction  
**Empirical basis:** Real debates lasted ~60 minutes; model time is abstract (not calibrated to real minutes)


### 2.3 Global State Variables
#### Model Selection
- `model_type` (string): Which social influence model to use {"consensus", "clustering", "bipolarization", "no_change"}
- `mode_batch` (boolean): Batch calibration mode vs GUI visualization
- `speaking_mode` (boolean): Switches the environment between turn-based interaction blocks (true) or static network calculations (false).
- `use_distinct_agents` (boolean): Determines whether individual agent parameters are heterogeneous (true) or homogeneous (false).
- `selection_mode` (string): Dictates whether debates run based on a filter or an xml file {"filter", "explicit"} (linked with composition_scope)
- `composition_scope` (string): Context-based experiment target filtering {"H", "M", "ALL"}

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

#### Simulation Control
- `selected_debate_id` (integer): Which debate to simulate
- `max_cycles` (integer, default=100): Maximum simulation length for local debate. This is the sole cycle-limit parameter in the model — there is no separate 300-cycle timeout; see Submodel 7.2.
- `step` (float, default=0.5): Time step duration
- `mae_convergence_threshold` (float, default=0.01): Opinion change below this triggers end. This is the model's only convergence-threshold variable; earlier drafts of this document referred to a separate `opinion_delta_threshold`, which does not exist in the implementation and has been removed.
- `end_simulation_at_convergence` (boolean): Global toggle that determines early halt or forcs continuous run until max_cycles.
- `convergence_cycle` (integer): Cycle when convergence occurred (-1 if not converged)
- `debate_start_cycle` (integer): Records the absolute simulation baseline cycle when active debate group loop instantiated.

#### Output Metrics
- `mae` (float): Global Mean Absolute Error (predicted vs empirical T2)
- `mae_per_debate` (map<int,float>): MAE for each debate separately
- `opinion_variance` (float): Current variance of all opinions
- `num_clusters` (integer): Number of distinct opinion clusters
- `polarization_index` (float): Measure of opinion spread
- `initial_num_clusters` (integer): Clusters at initialization (for comparison)
- `interaction_log` (list): Dynamic runtime container array holding micro-interaction rows before direct saving.

#### Bipolarization Diagnostics
- `neutral_zone_width` (float): ρ - ε (should be positive)
- `mean_net_repulsion_abs` (float): Average repulsive force magnitude
- `total_attractive_interactions` (integer): Cumulative attraction zone interactions
- `total_repulsive_interactions` (integer): Cumulative repulsion zone interactions
- `total_neutral_interactions` (integer): Cumulative neutral zone interactions


# 3. Process overview and scheduling
## 3.1 Initialization Sequence
1. Load CSV data ("train_data.csv" — see Section 6.1)
↓
2. Validate data loading (check subfactor normalization — see Section 6.2)
↓
3. Create debate ID mapping (control agents get their unique debate)
- Generate integer mapping values via stable_group_map and export mapping records to "debate_id_mapping.csv"
↓
4. Initialize_agents_for_debate(selected_debate_id)
- Detect condition for specified debate
- Load subfactors from csv data rows (for T1 and T2)
- Sample agent specific parameters from distributions
- Compute initial_opinion from subfactors using DB_Index formula (Section 2.2)
- Set opinion = initial_opinion
- Set initial_opinion_snapshot <- initial_opinion / previous_opinion <- initial_opinion
- Initialize total_influences_received <- 0, retention_discount <- 1.0, cumulative_opinion_change <- 0.0, recent_speech <- []
- Assign random spatial location for each agent in environment (for GUI)
↓
5. Create network
- Reset all neighbor connections and lists
- Create network (fully connected)
↓
6. Report initial diagnostics
- Report number of initial opinion clusters
- Determine neutral_zone_width
- Set final_stats_computed to false 

## 3.2 Simulation Loop
In each batch simulation, one of the two interaciton models is active, determined by the speaking_mode parameter.
[every cycle]
1. Opinion update (MUTUALLY EXCLUSIVE):

   IF speaking_mode = FALSE:
   └─> Each agent runs repeat_compute_opinion which executes compute_opinion
       - Update attitude from neighbors at t-1 (bounded [0,1])
       - Update color
       - Each agent triggers update_tracking reflex to refresh agent_net_change, agent_is_saturated, and agent_wrong_direction.

   IF speaking_mode = TRUE:
   └─> Speaking turn mechanic (see step 2)

2. Speaking turn (only if speaking_mode = TRUE)
   - Invoke speaking_turn reflex
   - Compute speak_weight per agent: 1 / (sum(recent_speech) + 1)
   - Select speaker via weighted probabilistic selection (rnd_choice)
   - Speaker calls talk_to_all: all other agents update via compute_opinion_speaker, incrementing total_influences_received counter and applies retention_discount.
   - Update recent_speech rolling window (window size = N agents)
     - Speaker appends 1, non-speakers append 0.
     - Appends compiled entry to interaction_log string array.
     - All agents trigger update_tracking reflex to refresh agent_net_change, agent_is_saturated, and agent_wrong_direction.

3. Update previous_opinion for all agents (previous_opinion <- opinion).

[every 10 cycles]
4. Execute compute_pro_anti_stats (heterogeneous debates)
- Execute compute_statistics to list opinions for all agents, calculate mean and variance, count clusters using logical histogram, compute polarization index.
- Calculate mean opinion of both groups


[every 5 cycles after cycle 10 from debate start, if end_simulation_at_convergence is true]
5. Convergence check (`check_convergence`) — see Submodel 7.2 for the full algorithm, threshold value, and finalization/debate-progression logic triggered on convergence.

[every cycle]
6. Maximum Cycles Reached (`max_cycles_reached`) — see Submodel 7.2 for the fallback algorithm triggered when `max_cycles` is reached without convergence.

### Update Order
Within-agent updates are done simultaneously (all agents update their opinion based on their t-1 neighbors).

### Update Order & Rationale
Within-agent updates are done simultaneously (all agents update their opinion based on their t-1 neighbors).

Rationale: The within-agent updates procedure avoids order effects and maintains symmetry. This implies that network structure matters more than update sequence, consistent with the social influence models of Flache et al., (2017). The initialization sequence was designed to sequentially parse the csv (`train_data.csv`) for relevant data, populate the subfactor lists used for T1, then validate the data loading to ensure that the DB_Index variable is correctly calculated according to its equation defined in Dheilly et al. (unpublished). Once all data has been loaded and validated, the agents are created according to the debate id, and the opinion is set to initial_opinion to give a starting value for each subfactor for each agent. The network creation is initialized at each repetition of the simulation (e.g., in batch experiments to keep debates independent from each other). 

For each simulation loop, agents execute reflexes under one kind of model of social influence as the batch experiments are designed to calibrate parameters according to each model. This aligns with the purpose of the study to investigate how each model performs in comparison with the others and OLS. The decision to perform compute pro/anti stats and global metrics is done every 10 cycles to allow for deliberation processes to occur and to reduce computational load when running the batch experiments. 

The convergence cycle reflex (`check_convergence`) is evaluated every 5 cycles after the 10th cycle from debate start. This allows for an initial period of deliberation where the debates will most likely not converge, while progressively checking whether group stabilization has occurred against an exact absolute tolerance floor (`mae_convergence_threshold <- 0.01;`). The final reflex for max_cycles and no convergence evaluates the timeout boundary continuously every cycle after a pre-defined maximum length (`max_cycles <- 100;`). This design cap minimizes computational load across vast batch combinations, as empirical testing demonstrates that stable debate runs successfully settle within 100 cycles.

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
- Asymmetric attitude change (pro vs anti agents may behave differently): Empirical benchmarking reveals a systematic **anti-reduction bias** where symmetric parameter distributions consistently under-predict real-world shifts toward plant-based diets. The model captures this through asymmetric population parameter distributions
- Opinion leader effects (agents with high convergence_rate may shift more and influence others)

**Not emergent:**
- Network structure (determined at initialization; fully connected for interactive mode, empty for control agents)
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

**Sensing mechanism:**:
- In parallel network mode when speaking_mode = false
  - agents have direct access to their local neighbors list and read their neighbor's opinion attribute.
- In turn-based mode when speaking_mode = true
  - agents listen directly via a global broadcast mechanism triggered by selected speaker's talk_to_all action.

### 4.8 Interaction
**Direct interaction:** In parallel network mode (`speaking_mode = false`), agent $i$ influences agent $j$ if $j \in \text{neighbors}(i)$. In turn-based mode (`speaking_mode = true`), interaction occurs via an asymmetric one-to-all global broadcast from a probablistically selected speaker.

**Interaction pattern depends on model_type:**

**Consensus model:**
All neighbors influence the agent. The target opinion shifts towards the group mean, scaled by both the individual convergence speed and the cognitive fatigue modifier:
$$\text{new\_opinion} = \text{opinion} + (\text{agent\_convergence\_rate} \times (\text{mean}(\text{neighbor\_opinions}) - \text{opinion})) \times \text{retention\_discount}$$

**Clustering model:**
Only neighbors whose opinions fall within the agent's confidence boundary exert influence:
$$\text{similar\_neighbors} = \{n \in \text{neighbors} : |n.\text{opinion} - \text{opinion}| \le \text{agent\_confidence\_threshold}\}$$
$$\text{new\_opinion} = \text{opinion} + (\text{agent\_convergence\_rate} \times (\text{mean}(\text{similar\_opinions}) - \text{opinion})) \times \text{retention\_discount}$$

**Bipolarization model:**
Similar agents attract, while dissimilar agents push the opinion away. For each interacting agent $n$:
*   $\text{diff} = n.\text{opinion} - \text{opinion}$
*   **IF** $| \text{diff} | \le \text{agent\_confidence\_threshold}$: $\text{attraction} \mathrel{+}= \text{diff}$
*   **IF** $| \text{diff} | \ge \text{agent\_repulsion\_threshold}$: $\text{repulsion} \mathrel{+}= \text{sign}(\text{diff})$

The combined forces are adjusted by the agent's individual parameter scaling weights, modulated by the cognitive fatigue coefficient, and strictly bounded to the $[0,1]$ space:
$$\text{raw\_opinion} = \text{opinion} + (\text{agent\_convergence\_rate} \times \text{attraction} + \text{agent\_repulsion\_strength} \times \text{repulsion}) \times \text{retention\_discount}$$
$$\text{new\_opinion} = \max(0.0, \min(1.0, \text{raw\_opinion}))$$

**Interaction Symmetry:** Interaction is structurally symmetric (undirected network) only when `speaking_mode = false`. When `speaking_mode = true`, the interaction pattern is dynamically asymmetric per simulation step.

### 4.9 Stochasticity
**Sources of randomness:**

**At initialization:**
- Agent parameter sampling: `agent_param ~ Normal(population_mean, population_sd)`
- Network creation: fully connected network
- Spatial location assignment: `location ~ Uniform(0, 100) × Uniform(0, 100)`

**During simulation:**
- Deterministic when speaking_mode = false
- When speaking_mode = true: stochasticity is introduced at every interaction cycle via the random choice operator (rnd_choice) selecting the active speaker.

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
- Every cycle: Convergence check (`check_convergence`) and timeout evaluation (`max_cycles_reached`).
- Every 10 cycles: Group composition (`compute_pro_anti_stats`) and polarization variance metrics (`compute_statistics`).
- At convergence: Final statistics, error metrics, file writing loops.

**Output files:**

**batch_summary.csv** (debate-level):
- model_type, current_condition, selected_debate_id
- pro_count, anti_count, seed, max_cycles, speaking_mode
- debate_label, current_experiment_id, use_distinct_agents
- convergence_rate, confidence_threshold, repulsion_threshold, repulsion_strength (population params)
- convergence_rate_sd, confidence_threshold_sd, repulsion_threshold_sd, repulsion_strength_sd (population variation)
- convergence_cycle, initial_variance,
- mae, opinion_variance, polarization_index, num_clusters, initial_num_clusters,
- Diagnostics: neutral_zone_width, mean_net_repulsion_abs

**agent_level_results.csv** (individual):
- All columns from batch_summary (repeated)
- agent_id
- subfactor_1_t1 through subfactor_5_t1 (initial)
- initial_opinion (computed from subfactors), initial_variance
- opinion (final simulated)
- subfactor_1_t2 through subfactor_5_t2 (empirical targets), mean_t2_subfactors
- final_attitude (empirical T2 attitude)
- speaking_mode
- opinion_change, individual_error
- error_sub1 through error_sub5 (prediction error per subfactor)
- agent_convergence_rate, agent_confidence_threshold, agent_repulsion_threshold, agent_repulsion_strength (individual params),
- total_influences_received, retention_discount, cumulative_opinion_change,
- agent_net_change, agent_wrong_direction, agent_is_saturated,
- convergence_rate, confidence_threshold, repulsion_threshold, repulsion_strength (population params)

**interaction_log.csv** (asynchronous turn-based interaction logs)
Contains step by step transaction (agent interaction data) generate when `speaking_mode` is true, includes:
- speaking_mode, model_type,current_condition,selected_debate_id,debate_label,current_experiment_id,use_distinct_agents,seed,cycle,sender_id,receiver_id,
sender_opinion,opinion_before,opinion_after,delta,agent_is_saturated,agent_wrong_direction, max_cycles.

## 5. INITIALIZATION

### 5.1 Initial State

**Environment:** Empty 100×100 continuous space (for GUI visualization)

**Agent creation:** Conditional on `selected_debate_id` coordinated sequentially by global controller `initialize_agents_for_debate`.
- Only agents with matching debate records from data loader and instantiated.
- Typical size of debates is between 4-7 agents.
- Control debates: 1 agent per simulation session.

### 5.2 Data Loading
**Source:** `../data-dictionary/exp-dat/train_data.csv`, loaded via `load_csv_data` in the model's `init` block. This is the calibration split only — see Section 6.1/6.2 for data structure, column mapping, and integrity checks, and Appendix C for how this file is produced from the full dataset.

**Note on validation runs:** the file path above is currently hardcoded in `main_4-3.gaml`'s `init` block, with no runtime switch to `test_data.csv`. Validation-set runs (Section 8.1.2, Hypotheses H3/H5/H6) therefore currently require either a manual path edit or a separate model/experiment configuration not yet documented here. **[TODO: document how validation runs are actually invoked before H3/H5/H6 validation-set results are reported in Section 8.4.]**

### 5.3 Debate ID Mapping
Multi-agent debates are parsed using an explicit string-to-integer translation map (`stable_group_map`). 
- **Interactive Groups:** Agents sharing a common string configuration are mapped to a shared integer ID index.
- **Control Groups:** Isolated control agents are dynamically assigned an exclusive string ID key defined as `"Control_" + agent_id` to prevent group allocation errors and guarantee topological isolation.
- **Resulting Space:** The orchestration pipeline manages up to 242 unique debate ID sessions sequentially via `m_debate_list`.

### 5.4 Agent Parameter Assignment
For each agent in a selected debate:
#### Step 1: Load empirical attributes
- agent_id ← agent_id_list[idx]
- debate_id ← selected_debate_id
- group_type ← group_type_list[idx]
- pro_reduction ← pro_reduction_list[idx]
- `subfactor_1_t1` through `subfactor_5_t1` ← `subfactors_t1[0..4][idx]`
- `subfactor_1_t2` through `subfactor_5_t2` ← `subfactors_t2[0..4][idx]`
- final_attitude ← final_attitude_list[idx]  // Empirical T2

#### Step 2: Sample individual dynamics parameters
If heterogeneous distributions are enabled (`use_distinct_agents = true`), individual attributes are drawn from a normal distribution around the global population means and clamped tightly to the $[0.01, 0.99]$ space to avoid boundary calculation errors:
- `agent_convergence_rate` $\sim \max(0.01, \min(0.99, \text{Normal}(\text{convergence\_rate}, \text{convergence\_rate\_sd})))$
- `agent_confidence_threshold` $\sim \max(0.01, \min(0.99, \text{Normal}(\text{confidence\_threshold}, \text{confidence\_threshold\_sd})))$
- `agent_repulsion_threshold` $\sim \max(0.01, \min(0.99, \text{Normal}(\text{repulsion\_threshold}, \text{repulsion\_threshold\_sd})))$
- `agent_repulsion_strength` $\sim \max(0.01, \min(0.99, \text{Normal}(\text{repulsion\_strength}, \text{repulsion\_strength\_sd})))$

*Structural Safety Guard:* Parameter validation happens globally at the experiment layer before the agents run. If the optimization logic pairs an invalid overlap rule ($\text{repulsion\_threshold} \le \text{confidence\_threshold}$), the system writes a warning string and triggers an early halt (`end_simulation <- true`).

#### Step 3: Mapping initial opinions and tracking baselines
- `initial_opinion` ← Derived from the pre-normalized empirical initial attitude data column.
- `opinion` ← `initial_opinion`
- `previous_opinion` ← `initial_opinion`
- `initial_opinion_snapshot` ← `initial_opinion` (locked at step 0 as an immutable baseline value to calculate overall structural displacement drifts).

#### Step 4: Initialize structural transaction arrays
- `location` $\sim (\text{rnd}(0.0, 100.0), \text{rnd}(0.0, 100.0))$
- `color` ← $\text{rgb}(\text{opinion} \times 255, 0, (1.0 - \text{opinion}) \times 255)$
- `neighbors` ← `[]` (left blank; populated systematically during topological network creation)
- `recent_speech` ← `[]` (empty integer list tracking speech histories)
- `total_influences_received` ← 0
- `retention_discount` ← 1.0
- `cumulative_opinion_change` ← 0.0
- `agent_is_saturated` ← `false`

### 5.5 Network Initialization
**Topology Creation:**
The system runs `create_network` to clear old connections and maps undirected edges across active agents.
- **Interactive Modes:** Instantiates a fully connected, complete undirected network graph among all individuals assigned to the active `selected_debate_id`.
- **Control Mode:** The network assignment is skipped entirely; control agent populations retain an empty `neighbors` list.

**Network structural constraints:**
- **Undirected Validity:** Multi-agent connections are explicitly verified across both ends of the edge: if agent $i$ lists $j$ as a structural neighbor, $j$ is structurally directed to add $i$ to its own `neighbors` array.
- **Static Invariance:** Node links are structurally locked at $t = 0$; no edge updates, re-linking events, or network rewiring occur during simulation execution loops.
- **Absolute Boundary Isolation:** Links are built exclusively inside the current active debate circle. Cross-debate edges across different session IDs are completely impossible.

### 5.6 Initial Diagnostics
The global controller computes starting state tracking values at $t = 0$ before initiating the simulation cycle loop:
- `initial_variance` ← Calculates the statistical variance of the initial opinions across the instantiated population.
- `initial_num_clusters` / `num_clusters` ← Computed via a 10-bin logical histogram layout to classify baseline group distributions.
- `neutral_zone_width` ← Calculated as $\text{repulsion\_threshold} - \text{confidence\_threshold}$.
- `current_condition` ← Automatically mapped to `"homogeneous"`, `"heterogeneous"`, or `"control"` depending on empirical participant properties parsed at runtime.

## 6. INPUT DATA
### 6.1 Data Source
**Primary Input File:** `../data-dictionary/exp-dat/train_data.csv` (structured training split of the empirical data set used for model calibration; see Section 5.2 for how and when this file is loaded, and Appendix C for how it is produced from the full dataset). 
**Format:** CSV with an initial header row.  
**Structure:** Contains individual participant records mapped into unique debate sessions.
- **Multi-Agent Debates:** 55 multi-agent interactive groups (4–7 participants per group).
- **Control Debates:** 187 single-agent isolated sessions where no interaction occurs.
- **Total Mapped Debates:** 242 unique debate identifiers.
**Origin:** Empirical laboratory study dataset from Dheilly et al. (unpublished) investigating deliberative debates on plant-based dietary shifts and meat consumption reduction.

### 6.2 Data Structure & Runtime Mapping
The global data loader parses the CSV columns dynamically at initialization and fills the following internal system arrays:

| CSV Target Dimension | Internal Mapped GAML Variable Array | Data Type / Domain Bounds |
| :--- | :--- | :--- |
| Participant Identifiers | `agent_id_list` | `list<int>` (Unique participant keys) |
| Empirical Group Labels | `id_group_raw` | `list<string>` (Raw session identifiers) |
| Experimental Condition | `group_type_list` | `list<string>` $\in$ `{"Homogeneous", "Heterogeneous", "Control"}` |
| Pre-Debate Stance Bias | `pro_reduction_list` | `list<int>` $\in$ `{0, 1}` (0 = anti, 1 = pro meat reduction) |
| Initial Attitude Point | `initial_attitude_list` | `list<float>` (Normalized initial opinion $[0, 1]$) |
| Empirical Final Outcome | `final_attitude_list` | `list<float>` (Normalized target attitude $[0, 1]$) |
| Timepoint 1 Subfactors | `subfactors_t1` | `list<list<float>>` (Matrix of 5 subfactors, each bounded $[0, 1]$) |
| Timepoint 2 Subfactors | `subfactors_t2` | `list<list<float>>` (Matrix of 5 subfactors, each bounded $[0, 1]$) |

**Data transformations:** Raw empirical metrics are normalized prior to runtime input processing within the base data framework, using the DB_Index → opinion formula defined in Section 2.2.

**Data Quality and Integrity Checks:**
The data initialization block performs defensive consistency checks when `debug_mode` is enabled:
- Verifies that all required position variables and attitude columns fall strictly within normalized $[0.0, 1.0]$ bounds.
- Runs an algebraic check via `do debug_init` to confirm that the empirical initial attitude matches the calculated composite balance of the 5 input subfactors (formula in Section 2.2), within floating-point tolerances ($10^{-10}$).

### 6.3 Environmental Data
**None.** The simulation world does not include:
- GIS, geographic coordinates, or spatial boundaries.
- Continuous external time series or exogenous environmental drivers.
- Dynamic localized resource maps.

*Note on Space:* The continuous $100 \times 100$ 2D coordinates assigned to agents are randomized at initialization purely for 2D visual layout separation within the GAMA Graphical User Interface (GUI). They exert no functional role, filtering influence, or topological constraint on agent communication rules.

### 6.4 Model Does NOT Use (from data file)
**Variables Omitted from ABM Processing:**
- Participant demographic characteristics (age, gender identity, education level).
- Perceived social norms matrices and internal self-control indexes (retained in auxiliary statistical datasets for baseline OLS validation models, but excluded from ABM logic).
- Long-form qualitative text transcripts or open-ended deliberation responses.

**Design Rationale:** To isolate social influence dynamics as an abstract mathematical process, individual differences are compressed into initial behavioral profiles and susceptibility parameters. This minimal input baseline enables clean testing of hypothesis **H3**: determining whether an agent-based model driven strictly by localized interaction rules can match or outperform traditional linear regression models that rely on comprehensive personal data attributes.

## 7. SUBMODELS
### 7.1 Opinion Update Models
Three alternative social influence mechanisms (only one active per run, selected by `model_type` parameter):

#### 7.1.1 Consensus Model (Assimilative Influence)
**Theoretical basis:** DeGroot (1974) social learning model; Friedkin & Johnsen (1990)

**Mechanism:** All agents converge toward the average position of their network neighbors, scaled by their individual convergence rate.

**Algorithm:**
For each agent $i$ with a non-empty neighbor list $N(i)$:
1. Calculate the mean opinion of all neighbors:
   $$\bar{o}_{N(i)} = \frac{1}{|N(i)|} \sum_{j \in N(i)} o_j$$
2. Compute the directional opinion change:
   $$\Delta o_i = \text{agent\_convergence\_rate}_i \times \left(\bar{o}_{N(i)} - o_i\right)$$
3. Update and clamp the opinion value to the state space:
   $$o_i(t+1) = \max\left(0.0, \min\left(1.0, o_i(t) + \Delta o_i\right)\right)$$
4. Dynamically update agent visual state:
   $$\text{color} \leftarrow \text{rgb}(o_i \times 255, \, 0, \, (1.0 - o_i) \times 255)$$
   
**Key parameters:**
- `agent_convergence_rate` ($\mu_i$): Individual speed of assimilation. If `use_distinct_agents` is true, this is sampled stochastically per agent around the global population mean parameter.

**Expected behavior:**
- Opinions contract toward the initial local group mean.
- The model inevitably yields consensus (or near-consensus structural states) across all interactive agents within a debate session.
- It cannot generate polarization or fragmentation from a unified network graph.

**Limitations:**
- **Structural Inability to Polarize:** Mathematically incapable of generating divergence or maintaining disagreement; it cannot replicate the polarization observed in highly contentious empirical debates.
- **Uniform Weighting:** Ignores the relative distance between opinions, assuming that individuals are equally open to highly radical opposing viewpoints as they are to moderate ones, which contradicts social judgment theory.

#### 7.1.2 Clustering Model (Bounded Confidence)
**Theoretical basis:** Hegselmann & Krause (2002, 2006); Deffuant et al. (2000)

**Mechanism:** Agents filter their interaction network, only influenced by similar others (within confidence threshold ($\epsilon$)).

**Algorithm:**
For each agent $i$ with network neighbors $N(i)$:
1. Construct the subset of valid influencing neighbors:
   $$I(i) = \{j \in N(i) \mid |o_j - o_i| \le \text{agent\_confidence\_threshold}_i\}$$
2. If $I(i)$ is not empty, execute the pull update:
   $$\bar{o}_{I(i)} = \frac{1}{|I(i)|} \sum_{j \in I(i)} o_j$$
   $$\Delta o_i = \text{agent\_convergence\_rate}_i \times \left(\bar{o}_{I(i)} - o_i\right)$$
   $$o_i(t+1) = \max\left(0.0, \min\left(1.0, o_i(t) + \Delta o_i\right)\right)$$

**Key parameters:**
- `agent_convergence_rate` ($\mu_i$): Individual speed of opinion adjustment.
- `agent_confidence_threshold` ($\epsilon_i$): The maximum opinion distance an agent tolerates before disregarding a neighbor's viewpoint.

**Expected behavior:**
- Opinions split into distinct local coordinate clusters (sub-groups with internal consensus).
- When agent heterogeneity is active, the confidence threshold ($\epsilon_i$) varies per individual. This can create asymmetric influence relationships where Agent A is influenced by Agent B, but Agent B filters out Agent A, leading to more fluid cluster boundaries than classic symmetric variants.

**Limitations:**
- **Lack of Active Repulsion:** Can only explain fragmentation via a passive "drop-off" in communication (lack of influence). It cannot model active ideological backlash or backfire effects where listening to an opponent pushes an agent further away.
- **Discontinuous Cutoffs:** The binary transition at the confidence boundary ($\epsilon$) creates an abrupt step function where an opinion difference of $0.19$ causes full assimilation, but $0.21$ causes absolute indifference.

#### 7.1.3 Bipolarization Model (Attraction-Repulsion)
**Theoretical basis:** Mäs et al. (2013); Flache & Macy (2011) "negative influence"

**Mechanism:** Similar agents attract, dissimilar agents repel.

**Algorithm:**
For each agent $i$:
1. Initialize force accumulation registers: `attraction_sum = 0.0`, `repulsion_sum = 0.0`, `n_attraction = 0`, `n_repulsion = 0`.
2. Iterate through each neighbor $j \in N(i)$:
   - Let $\text{distance} = o_j - o_i$
   - **Attraction Zone:** If $|\text{distance}| \le \text{agent\_confidence\_threshold}_i$:
     $$\text{attraction\_sum} \leftarrow \text{attraction\_sum} + \text{distance}$$
     $$\text{n\_attraction} \leftarrow \text{n\_attraction} + 1$$
   - **Repulsion Zone:** If $|\text{distance}| \ge \text{agent\_repulsion\_threshold}_i$:
     $$\text{direction} = \text{sign}(o_i - o_j) \quad (\text{push away from } o_j)$$
     $$\text{repulsion\_sum} \leftarrow \text{repulsion\_sum} + \text{direction}$$
     $$\text{n\_repulsion} \leftarrow \text{n\_repulsion} + 1$$
3. Combine active normalized forces:
   $$\text{Eff}_{\text{attract}} = \begin{cases} \text{agent\_convergence\_rate}_i \times \frac{\text{attraction\_sum}}{\text{n\_attraction}} & \text{if } \text{n\_attraction} > 0 \\ 0.0 & \text{otherwise} \end{cases}$$
   $$\text{Eff}_{\text{repel}} = \begin{cases} \text{agent\_repulsion\_strength}_i \times \frac{\text{repulsion\_sum}}{\text{n\_repulsion}} & \text{if } \text{n\_repulsion} > 0 \\ 0.0 & \text{otherwise} \end{cases}$$
4. Finalize state transition:
   $$o_i(t+1) = \max\left(0.0, \min\left(1.0, o_i(t) + \text{Eff}_{\text{attract}} + \text{Eff}_{\text{repel}}\right)\right)$$

**Key parameters:**
- `agent_convergence_rate` ($\mu_i$): Individual strength of the attractive force.
- `agent_confidence_threshold` ($\epsilon_i$): Upper boundary limit of the attraction zone.
- `agent_repulsion_threshold` ($\rho_i$): Lower boundary limit of the repulsion zone.
- `agent_repulsion_strength` ($\alpha_i$): Individual strength of the negative/repulsive force.

**Three zones:**
|opinion_diff| ≤ ε:       ATTRACTION (move toward neighbor)
ε < |opinion_diff| < ρ:   NEUTRAL (no influence)
|opinion_diff| ≥ ρ:       REPULSION (move away from neighbor)

**Constraint:** 
- $\epsilon < \rho$ (The population-level attraction threshold must be strictly less than the repulsion threshold). If this global rule is broken, initialization is terminated early via a hard constraint guard (`end_simulation <- true`). For heterogeneous agents, if individual sampling causes an overlap ($\epsilon_i \ge \rho_i$), it violates the structural premise of a neutral zone buffer.

**Expected behavior:**
- Opinions drive outward toward opposite extremes ($0.0$ and $1.0$), forcing distinct ideological polarization.
- Because forces are explicitly normalized by the counts of active attractive and repulsive neighbors (`n_attraction` and `n_repulsion`), individual trajectories update via balanced vector steps, reducing arbitrary step oscillations.

**Limitations:**
- **Dimensionality Overhead:** Introduces a significantly larger parameter space (up to 8 dimensions when optimizing standard deviations), drastically increasing the computational complexity and risk of overfitting during calibration phases (GA/LHS).
- **Edge Accumulation Artifacts:** Because repulsion pushes agents away from the group center, opinions naturally pile up exactly at the extreme boundaries ($0.0$ and $1.0$), which can overpredict absolute fanaticism compared to more nuanced empirical data distributions.

#### 7.1.4 Speaking Mode Variants (`speaking_mode = true`)
When dyadic speaking variants are activated, the complete neighbor loop step is structurally replaced by a sequential turn-taking broadcast layout:
1. The system isolates the active debate and randomly selects one agent $S$ to act as the sole active speaker for the cycle.
2. All other agents $j \in N(S)$ act as passive listeners and update their internal values directly against the speaker's scalar value ($o_S$):
   - **Consensus Speaker:** $\Delta o_j = \text{agent\_convergence\_rate}_j \times (o_S - o_j)$
   - **Clustering Speaker:** If $|o_S - o_j| \le \text{agent\_confidence\_threshold}_j$, execute consensus update; else $\Delta o_j = 0.0$.
   - **Bipolarization Speaker:** Run the attraction/repulsion checks from 7.1.3 treated with $n=1$ against $o_S$.

### 7.2 Convergence Detection
**Purpose:** Stop simulation when opinions stabilize (computational efficiency + realism)

**Mechanism:** The global orchestration loop executes a structural tracking check every 5 execution cycles (beginning on step 10, relative to `debate_start_cycle`) via the `check_convergence` reflex, to determine if state stabilization has been reached. A separate `max_cycles_reached` reflex provides a fallback timeout, evaluated every cycle.

**Algorithm (`check_convergence`):**
1. Collect each agent's opinion displacement since the previous cycle:
   $$\text{max\_delta} = \max \left( |o_i(t) - o_i(t-1)| \right) \quad \forall i$$
   (`previous_opinion` is refreshed every cycle by a separate reflex, so this is always a one-cycle comparison, evaluated on the 5-cycle check schedule.)
2. If $\text{max\_delta} < \text{mae\_convergence\_threshold}$ (hardcoded to $0.01$):
   - Set `convergence_cycle` $\leftarrow$ current cycle $-$ `debate_start_cycle`.
   - Trigger `end_simulation <- true`.
   - Call `do compute_fit` and `do compute_final_statistics`.
   - If `mode_batch` is true, execute `do save_batch_results`.
   - Sequential loop control: if `debate_counter < length(m_debate_list) - 1`, increment the counter, update `selected_debate_id` to the next debate, remove all current agent instances, and call `do init_debate`; otherwise set `end_simulation <- true`.

**Algorithm (`max_cycles_reached`, fallback):**
1. If `(cycle - debate_start_cycle) >= max_cycles` (default 100) and `end_simulation` is still false:
   - Set `convergence_cycle` to the current elapsed cycle count (recorded regardless of non-convergence).
   - Trigger `end_simulation <- true`.
   - Call `do compute_fit` and `do compute_final_statistics`, then (if `mode_batch`) `do save_batch_results`.
   - Same sequential debate-progression logic as above.

**Convergence criterion:** Maximum opinion change < 0.01, checked every 5 cycles starting at cycle 10 relative to debate start.

**Rationale:** Opinion change becomes negligible; further cycles add no information. The 10-cycle initial grace period allows deliberation to begin before checking is meaningful; checking every 5 cycles (rather than every cycle) reduces computational load across large batch runs.

**Fallback:** If `max_cycles` (100) is reached without convergence, the simulation is force-stopped by `max_cycles_reached` and finalized identically to a converged run, with `convergence_cycle` still recorded for diagnostic purposes.

### 7.3 Model Fit Computation
**Mechanism:** Quantifies structural error performance against empirical data profiles by running a post-simulation calculation loop.

**Equations:**
The absolute error for an individual agent is defined as:
$$e_i = |o_i(t_{\text{final}}) - \text{final\_attitude}_i|$$
The simulation-wide target optimization score is evaluated as the Mean Absolute Error (MAE):
$$\text{MAE} = \frac{1}{M} \sum_{i=1}^{M} e_i$$
*Per-Debate Metric Logging:* To parse contextual variances, the system aggregates errors per unique `debate_id` segment and exports them into separate tracking columns inside the file generation module.

**Interpretation:**
- MAE = 0: Perfect prediction
- MAE < 0.05: Excellent fit
- MAE < 0.10: Good fit
- MAE > 0.20: Poor fit

**Scale:** MAE on [0,1] normalized opinion scale
- MAE = 0.10 means average prediction error of 1.2 units on original [-6,+6] scale

### 7.4 Statistical Computations
Calculated systematically every 10 cycles and captured as an immutable final snapshot upon termination:

*   **Population Variance:** Measures the dispersion of opinions across the active sub-population.
*   **Opinion Clusters:** Evaluates distribution layouts by parsing agent opinions into a 10-bin mathematical histogram over the range $[0.0, 1.0]$. Bins containing an agent count $> 0$ register as active clusters.
*   **Polarization Index:** Computed using the standardized variance of all unique pairwise distance matrix coordinates:
    $$\text{PI} = \frac{1}{K} \sum_{i \in Agents} \sum_{j \neq i} \left(|o_i - o_j| - \overline{\text{dist}}\right)^2$$
*   **Stance-Stratified Metrics:** Sub-groups are filtered using the empirical baseline binary flag `pro_reduction`. The system splits records into independent tracking matrices to generate separate real-time group trajectories for `mean_opinion_pro` and `mean_opinion_anti`.

### 7.5 Network Creation
The simulation utilizes a static, complete network framework configured at step 0 to isolate opinion transformations from topological confounding variables.

**Execution Routine (`create_network`):**
1. Purge all historical node arrays and flush active agent tracking lists (`neighbors <- []`).
2. Map complete multi-directional boundaries within identical groups:
   $$\forall (i, j), \text{ if } \text{debate\_id}_i == \text{debate\_id}_j \text{ and } i \neq j \Rightarrow j \in N(i)$$
3. **Control Isolation Guard:** If an agent's experimental descriptor matches `"Control"`, network allocation functions bypass the agent entirely, ensuring their neighbor register remains strictly empty.

## 8. MODEL CALIBRATION AND VALIDATION
**Registration status note:** Sections 8.1-8.4 are pre-specified analysis plans registered prior to completion of full batch simulation and validation analyses. 
Results and interpretations will be added upon completion and will be document as post-registration additions in the appending to distinguish them from pre-specified analyses.

### 8.1 Calibration Strategy
#### 8.1.1 Genetic Algorithm Description
Objective: Find parameter values minimizing MAE on training set.
Method: Genetic Algorithm (GA) implemented in GAMA batch experiments
Parameters calibrated:
Population-level means:
- convergence_rate: [0.1, 0.2, 0.3, 0.4, 0.5]
- confidence_threshold: [0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8] (clustering & bipolarization)
- repulsion_threshold: [0.4, 0.5, 0.6, 0.7, 0.8] (bipolarization only)
- repulsion_strength: [0.1, 0.2, 0.3] (bipolarization only)

Population variation (SD) - for use_distinct_agents = TRUE:
- convergence_rate_sd: [0.0, 0.05, 0.1]
- confidence_threshold_sd: [0.0, 0.1, 0.2]
- repulsion_threshold_sd: [0.0, 0.1, 0.2]
- repulsion_strength_sd: [0.0, 0.02, 0.05]

GA settings:
- Population size: 5
- Crossover probability: 0.5
- Mutation probability: 0.1
- Preliminary generations: 5
- Maximum generations: 5
- Replication: 30 seeds per parameter combination initially; reduced to 1-3 after finding negligible stochastic variance.

#### 8.1.2 Data Splitting Procedure
Data split procedure:
Stratified random sampling:
- Calibration set: ~43 debates (80% of multi-agent debates)
- Validation set: ~12 debates (20% of 55 multi-agent debates)
- Seed: set a 123
- Stratification ensures proportional representation of:
-- Heterogeneous debates
-- Homogeneous debates
-- (Control debates excluded from calibration as they have no interactions)

Implementation details (R code) are provided in Appendix X. **[Cross-reference note: Section 5.2 flags that the main GAML model currently loads `train_data.csv` unconditionally, with no confirmed automated path for running against `test_data.csv`. Resolve before validation-set MAE (Section 8.4) is reported.]**

**Model selection procedure:**
1. Run GA calibration separately for each model (consensus, clustering, bipolarization)
2. Evaluate on validation set
3. Compare models:
   - Overall (all debates pooled)
   - By condition (heterogeneous vs homogeneous separately)
4. Select best model per condition based on validation MAE

#### 8.1.3 Feasible Parameter Regions
**Decisions criterion for LHS**
The genetic algorithm was used to identify parameter combinations that minimize MAE on the calibration dataset. Due to the potential for equifinality - where different parameter combinations can yield similar model outcomes - the GA alone is not sufficient to characterize the parameter space (Thiele et al., 2014).

To address this issue we define a feasible parameter range by keeping all of the paramter sets whose MAE falls within a tolerated best-performing solution (within 10% of the minimum MAE). This ensures that the multiple different parameter combinations resulting in a similar solution are considered rather than relying on a single optimum.

From this retained data set, the parameter bounds are constructed using percentile ranges (5th-95th percentile) to reduce the impact of extreme values. This approach complies with the concept of a "good-enough" parameter region, consistent with the idea of considering multiple plausible parameterizations rather than a single optimal point (Williams et al., 2020).

#### 8.1.4 Latin Hypercube Sampling (LHS)
To further explore the feasible parameter region, Latin Hypercube Sampling (LHS) is then applied in these bounds.

The use of LHS in this context is justified as this sampling method ensure more uniform coverage of the multidimensional parameter spaces considered in this study compared with simple random samplig. This smapling method is widely used in the ABM field and is recommended for calibration and sensitivity analysis (Lee et al., 2015). 

**[NOTE — reconcile with registered OSF protocol:** this section states an LHS sample size of "20–50× the number of calibrated parameters, ≈300 samples per model." The registered OSF protocol states 200 samples per model. These describe the same design decision and currently disagree; pick one figure and update both documents before further reporting.]

The number of LHS sample is determined as a function of model dimensionality. This was chosen to ensure consistent cross-model comparison, regardless of the number of calibrated parameters varying between the models (consensus, clustering, bipolarization), as well as ensuring computational feasibility.

The second stage exploration enables a more comprehensive assessment of parameter sensitivity, interaction effects and robustness of model outcomes. This supports the study's exploratory objective (RQ1) of understanding how parameter variation influences the emergent opinion dynamics. 

#### 8.1.5 Parameter Bounds for LHS
The parameter bounds used for LHS are derived from the retained set of high-performing GA solutions (top-25%-MAE GA runs, per Section 8.1.3), summarized below by `model_type` and `use_distinct_agents`:

| model_type | use_distinct_agents | best_mae | cr_min | cr_max | ct_min | ct_max | rs_min | rs_max | rt_min | rt_max |
|---|---|---|---|---|---|---|---|---|---|---|
| bipolarization | FALSE | 0.0112 | — | — | — | — | — | — | — | — |
| bipolarization | TRUE | 0.0099 | — | — | — | — | — | — | — | — |
| clustering | FALSE | 0.0112 | — | — | — | — | — | — | — | — |
| clustering | TRUE | 0.0081 | — | — | — | — | — | — | — | — |
| consensus | FALSE | 0.0112 | — | — | — | — | — | — | — | — |
| consensus | TRUE | 0.0081 | — | — | — | — | — | — | — | — |

Population-variation (SD) bounds (`use_distinct_agents = TRUE`) are similarly derived: `cr_min_sd`/`cr_max_sd`, `ct_min_sd`/`ct_max_sd`, `rs_min_sd`/`rs_max_sd`, `rt_min_sd`/`rt_max_sd`, per model_type.

**[TODO — before finalizing this table: (1) fill in the numeric `cr_min`–`rt_max` cell values from the R output (`generate_gaml_bounds`); (2) verify whether the `best_mae` values above (0.0081–0.0112) are computed on the same pooled calibration set as the overall GA MAE reported in Section 8.2/8.4 (~0.0644), or a narrower subset (e.g. top-25% filter only) — these are not directly comparable as currently labeled and should not be presented side-by-side without that clarification.]**

#### 8.1.6 Computational Budget
**Computational budget:**
- Phase 1: Grid search exploration (~50-100 parameter combinations per model)
- Phase 2: GA optimization (5 gen × 5 pop = 25 evaluations per parameter set)
- Phase 3: LHS exploration (~300 samples per model — see reconciliation note in 8.1.4)
- Phase 4: Validation (best params × 44 debates × 3 seeds ≈ 130 runs)
- Total per model: ~200-300 simulation runs
- Total for 3 models: ~600-900 runs
- Estimated time: 4-8 hours with parallelization (depends on hardware)

#### 8.1.7 Handling of Stochasticity
- Initial testing revealed stochasticity has minimal effect (variance ≈ 0 across seeds)
- Implication: Only 1-3 seeds needed per parameter combination
- This significantly reduces computational burden

### 8.2 Best Parameters Found

**Consensus model:**
convergence_rate = [VALUE]
convergence_rate_sd = [VALUE] (if heterogeneity tested)

Best for: [Homogeneous/Heterogeneous/Both]
Calibration MAE: [VALUE]
Validation MAE: [VALUE]
Typical convergence: [X] cycles

**Clustering model:**
convergence_rate = [VALUE]
confidence_threshold = [VALUE]
[+ SD parameters if used]

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

**Key findings (confirmed from existing LHS/GA output; see caveats in 8.1.5):**
- **Which model performs best overall (unoptimized/LHS, pooled global ranking)?** With `speaking_mode = true`: `no_change` (0.0399) < clustering (0.0528) < consensus (0.0616) < bipolarization (0.0873). With `speaking_mode = false`: clustering (0.0920) < consensus (0.1058) < bipolarization (0.1112). No social-influence model beats `no_change` under either speaking mode.
- **Does GA optimization improve on this?** Yes, but not enough: GA reduces MAE from an LHS baseline of μ=0.0875 to μ=0.0644 (~26% reduction, Welch's t-test t(63394)=−48.96, p<2.2×10⁻¹⁶), still above the 0.0399 `no_change` baseline.
- **Do different debate types require different models?** Composition/behavioral diagnostics data (by `debate_composition`, `model_type`, `speaking_mode`, `use_distinct_agents`) exists to answer this but has not yet been summarized into an explicit conclusion — **[TODO]**.
- **Does agent heterogeneity (SD > 0) improve predictions?** Yes, consistently: `use_distinct_agents = TRUE` outperforms `FALSE` across all three models in the composition/behavioral diagnostics comparison.
- **Does homophily improve predictions over random/complete networks?** Not applicable as tested — the current network is always fully connected (Section 5.5); no random/homophilous network variant has been implemented or compared. **[TODO if this comparison is intended — currently out of scope of the implemented model.]**

### 8.3 Sensitivity Analysis
**[DEFERRED — to be completed following the final consolidated LHS/GA rerun described in the registered OSF protocol's Analysis Status section.]**

**Stochasticity analysis:**
- Variance in MAE across different random seeds
- Confirmed finding (Section 4.9/8.1.7): near-zero variance across seeds (deterministic dynamics given initial conditions when `speaking_mode = false`; minor stochasticity from speaker selection when `speaking_mode = true`)
- Implication for seed replication strategy: 1–3 seed replicates sufficient, consistent with implementation.

**Parameter sensitivity:**
- Which parameters have the largest effect on MAE? — not yet formally assessed beyond preliminary PCC/PRCC exploration (inconclusive).
- Are there parameter interactions? — not yet assessed.
- Are there non-linear threshold effects? — not yet assessed.

**Planned method:** random forest–based permutation importance (Antoniadis, Lambert-Lacroix & Poggi, 2021), applied post-hoc to pooled LHS+GA parameter/output pairs. Selected over formal Sobol' index estimation because the existing and planned sampling design (LHS + GA refinement, not a Saltelli-type factorial design) does not support valid Sobol' estimation, while RF-based permutation importance can be computed directly on irregular samples without a specific sampling structure.

**Targets:** MAE (primary), skewness of signed error and variance of absolute error (secondary, probing directional bias and stability respectively, motivated by the anti-reduction bias noted in Section 4.2). Cross-checked against a moment-independent measure (δ or β^Ku; Baucells & Borgonovo, 2013) per the multi-measure logic in Borgonovo et al. (2022).

### 8.4 Validation
**Quantitative validation:**
- MAE on held-out validation debates — **not yet computed**; see the validation-path gap flagged in Section 5.2/8.1.2.
- Comparison to OLS regression baseline (Hypotheses H3, H5, H6) — OLS baseline not yet computed within this pipeline.
- Condition-specific performance (H4) — data available (Section 8.2 composition table) but not yet summarized against H4 specifically.
- Distribution matching: predicted vs empirical T2 distributions — not yet assessed.

**Qualitative validation:**
- Opinion trajectories show realistic patterns:
  - No oscillations
  - Monotonic convergence or stable equilibrium
  - Maintained diversity (not complete consensus except in special cases)
- Final opinion distributions match empirical patterns
- Convergence times reasonable (15-35 cycles ≈ plausible for 60-minute debates conceptually)

**[NEED TO FILL IN AFTER ANALYSIS — none of the qualitative validation checks above have been formally run yet.]**

**Pattern matching (from Section 1.2):**
- ✓/✗ Pre-post correlation maintained (H1) — not yet tested (individual-level regression not yet run against this pipeline's output).
- ✓/✗ Heterogeneous > homogeneous change (H4) — data available, not yet summarized against this specific claim.
- ✓/✗ ABM < OLS on MAE (H3, H5, H6) — **partially answerable now**: ABM (social-influence, all variants tested) does not beat the trivial `no_change` baseline (Section 8.2), which is a stronger requirement than beating OLS; OLS comparison itself not yet run.
- ? Directional asymmetry (pro vs anti change) - exploratory — **confirmed present** (Section 4.2, anti-reduction bias), not yet formally decomposed by model/condition.
- ? Role of perceived norms/self-control (H2) - regression only, not ABM — not applicable to this ABM by design (Section 6.4).

**Comparison to benchmark (OLS regression):**

Model level of comparison is defined as follows (see also cross-referenced discussion in accompanying analysis materials): **Global** = metrics pooled across all debates by `model_type` alone; **Debate** = metrics grouped by `model_type` + `selected_debate_id`; **Individual** = per-agent `individual_error` from `agent_level_results.csv`.

| Model | Individual MAE | Debate MAE | Global MAE |
|---|---|---|---|
| no_change (baseline, not OLS) | [VALUE] | [VALUE] | 0.0399 |
| OLS (baseline) | [VALUE] | [VALUE] | [VALUE — not yet run] |
| Consensus (LHS, speaking_mode=true) | [VALUE] | [VALUE — requires debate-level groupby, not yet run] | 0.0616 |
| Clustering (LHS, speaking_mode=true) | [VALUE] | [VALUE — not yet run] | 0.0528 |
| Bipolarization (LHS, speaking_mode=true) | [VALUE] | [VALUE — not yet run] | 0.0873 |
| GA-optimized (all models pooled) | [VALUE] | [VALUE — not yet run] | 0.0644 |

**[FILL IN AFTER VALIDATION — Global column is partially populated from confirmed LHS output above; Individual and Debate columns, and the OLS row entirely, remain to be computed.]**

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

**Sensitivity analysis:**
- Thiele, J. C., Kurth, W., & Grimm, V. (2014). Facilitating parameter estimation and sensitivity analysis of agent-based models: A cookbook using NetLogo and R. *Journal of Artificial Societies and Social Simulation*, 17(3), 11.
- Lee, J. S., Filatova, T., Ligmann-Zielinska, A., Hassani-Mahmooei, B., Stonedahl, F., Lorscheid, I., ... & Parker, D. C. (2015). The complexities of agent-based modeling output analysis. *Journal of Artificial Societies and Social Simulation*, 18(4).
- Williams, T. G., Guikema, S. D., Brown, D. G., & Agrawal, A. (2020). Assessing model equifinality for robust policy analysis in complex socio-environmental systems. *Environmental Modelling & Software*, 134, 104831.
- Borgonovo, E., Pangallo, M., Rivkin, J., Rizzo, L., & Siggelkow, N. (2022). Sensitivity analysis of agent-based models: a new protocol. *Computational and Mathematical Organization Theory*, 28(1), 52-94.
- Antoniadis, A., Lambert-Lacroix, S., & Poggi, J. M. (2021). Random forests for global sensitivity analysis: A selective review. *Reliability Engineering & System Safety*, 206, 107312.

**Model validation:**
- Windrum, P., Fagiolo, G., & Moneta, A. (2007). Empirical validation of agent-based models: Alternatives and prospects. *Journal of Artificial Societies and Social Simulation*, 10(2), 8.
- Railsback, S. F., & Grimm, V. (2019). *Agent-based and individual-based modeling: A practical introduction*. Princeton University Press.
- Lorscheid, I., Heine, B. O., & Meyer, M. (2012). Opening the 'black box' of simulations: increased transparency and effective communication through the systematic design of experiments. *Computational and Mathematical Organization Theory*, 18(1), 22-62.

**ODD protocol:**
- Grimm, V., Railsback, S. F., Vincenot, C. E., Berger, U., Gallagher, C., DeAngelis, D. L., ... & Ayllón, D. (2020). The ODD protocol for describing agent-based and other simulation models: A second update to improve clarity, replication, and structural realism. *Journal of Artificial Societies and Social Simulation*, 23(2), 7.

**Empirical study:**
- Dheilly et al. (unpublished).

**Climate & food systems context:**
- Rockström, J., et al. (2025). The EAT–Lancet Commission on healthy, sustainable, and just food systems. *The Lancet*, 406(10512), 1625-1700.
- Steinfeld, H., et al. (2006). *Livestock's long shadow: Environmental issues and options*. FAO.
- Springmann, M., et al. (2016). Analysis and valuation of the health and climate change cobenefits of dietary change. *PNAS*, 113(15), 4146-4151.
- Forouzanfar, M. H., et al. (2015). Global, regional, and national comparative risk assessment of 79 behavioural, environmental and occupational, and metabolic risks or clusters of risks in 188 countries, 1990-2013. *The Lancet*, 386(10010), 2287-2323.
- Garnett, T. (2008). Cooking up a storm: Food, greenhouse gas emissions and our changing climate. Food Climate Research Network.
- Vermeulen, S. J., Campbell, B. M., & Ingram, J. S. I. (2012). Climate change and food systems. *Annual Review of Environment and Resources*, 37, 195-222.


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

**DB_Index formula:** (see also Section 2.2, the canonical statement of this formula)
```
DB_Index = mean(DBFactor1, DBFactor2) - mean(DBFactor3, DBFactor4, DBFactor5)
         = [(F1 + F2) / 2] - [(F3 + F4 + F5) / 3]
Range: [-6, +6] on original scale
Normalized: [0, 1] for model
```

### C. Data Splitting R Implementation
Implementation in R:
```r
library(dplyr)

# debate data seleciton
debate_data <- df_base %>%
  filter(Condition %in% c("Heterogeneous", "Homogeneous"))

control_data <- df_base %>%
  filter(Condition %in% c("Control"))

# select unique debates
unique_debates <- debate_data %>%
  distinct(ID_Group_all, Condition)

# set seed for reproducibility
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
```
