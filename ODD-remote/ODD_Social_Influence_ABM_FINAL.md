# ODD protocol for Social Influence ABM

# 1. Purpose and Patterns
## 1.1 Purpose
-Description
The model addresses the idea that what we eat impacts the world around us, our health (Springmann et al., 2016; Forouzanfar et al., 2015), and the environment (Garnett, 2008; Vermeulen et al., 2012). It focuses on identifying and characterizing the mechanisms by which humans interact in social contexts (i.e. debates) to encourage behavioral change toward more sustainable food choices, such as meat consumption reduction. This model draws inspiration from the definition of deliberation, highlighted by Baechtiger et al. (2018) and takes the example of ¨mini-publics" (Niemeyer, 2011) to characterize a virtual environment where individuals interact and "deliberate" on the reduction of meat consumption. The model in this study uses data and experimental characteristics (i.e. number of debate participants) from an ongoing study by Dheilly et al (unpublished). 

The purpose of the model is to understand how individual, debate level and global attitudes change in the context of debates that address meat consumption reduction. The ultimate purpose of the model is to characterize the underlying processes and phenomena implicated in this debate process...and further to understand whether the addition of argumentation dynamics improves the predictive efficiency of attitude evolution through the debates. The model social influence model is explicitly based on moels of social influence (Flache et al., 2017). 

The investigation into the impact of deliberation is addressed by looking into 7 hypotheses and one research question (described below). The scope of the model spans across 55 debates (19 homogeneous; 36 heterogeneous) and 187 debates (with only one agent) with a total of 459 participants. Homogeneous debates consist of only pro or only contra meat consumption reduction; heterogeneous debates have an equal split of both. 

The evaluation of the model is based on its ability to accurately predict the magnitude and direction of attitude change from pre- to post-debate compared with the data gathered in Dheilly et al (unpublished). This is quantitatively assessed through the model's ability to more accurately predict attitude change (using the Mean of Absolute Error) and the dynamics of agent interactions compared to multi-level linear regressions.

This protocol specifies the social influence dynamic models (including Consensus, Clustering and Bipolarization mechanisms for H1-H6). This architecture is designed to serve as the basis for the next planned step being the implementation of an argumentation extension (evaluating Dung-style argument dynamics for H7). The argumentation module represents the secondary research extensiuon of this project and will be registered under a Phase 2 protocol update prior to H7 testing.

## 1.2 Patterns
The model aims to reproduce these empirical patterns:
- Behavioral Patterns -
1) Pre-deliberation attitudes toward meat consumption are expected to be positively associated with post-deliberation attitudes, accounting for a meaningful share of variance when controlling for the nested nature of agents within distinct debate groups.
2) Individuals with higher perceived social norms and lower self-control will exhibit greater absolute attitude change between pre- and post-deliberation measurement points, moderated by their initial opinion strength.

- Model Performance Patterns -
3) Debates with a heterogeneous composition of participants are expected to exhibit a greater mean attitude change between pre- and post-deliberation attitudes compared with homogeneous debates.
4) Agent-based simulations initialized with pre-deliberation attitudes alone will generate a lower mean of absolute error [MAE] predictions of post-deliberation attitudes for individual participants compared with a naive "no_change" baseline and a predictive multilevel linear model, at the individual participant and debate level.
5) When pooled at a global level, ABMs calibrated with pre-deliberation attitudes should reproduce a global post-deliberation attitude shift toward meat consumption reduction with a lower MAE than a single global multilevel regression model.
6) Agent-based models upgraded with argumentation mechanisms alongside models of social influence are expected to yield more accurate and stable predictions of global attitude distributions (using MAE) than models only using social influence mechanisms (Bächtiger et al., 2018; Niemeyer et al., 2024).

Exploratory analyses are pre-specified but not used for confirmatory inference.

# 2. entities, state variables and scales
## 2.1 Entities
The following entities are present in the model: agents representing individuals who engaged in the debates (i.e. experiment participants), experiments (GUI and batch to calibrate and explore model parameters), grid cells (i.e. virtual geographical location in the environment for GUI testing), and the global environment representing the space in which the debates took place (i.e. the virtual meeting room).

## 2.2 State Variables
### 2.2.1 Agent State Variables

| Variable Name | Data Type | Domain Bounds | Description |
| :--- | :--- | :--- | :--- |
| **Core Identity** | | | |
| `agent_id` | `integer` | $\mathbb{Z}^+$ | Unique participant identifier matching empirical record[cite: 1]. |
| `debate_id` | `integer` | $[1, 242]$ | Unique group/session identifier mapping to `m_debate_list`[cite: 1]. |
| `group_type` | `string` | `{"Homogeneous", "Heterogeneous", "Control"}` | Experimental debate composition condition[cite: 1]. |
| `pro_reduction` | `binary` | `{0, 1}` | Empirical pre-debate stance bias ($0 = \text{anti}$, $1 = \text{pro}$ meat reduction)[cite: 1]. |
| `debate_label` | `string` | Text | Active empirical session descriptor string[cite: 1]. |
| `current_experiment_id` | `string` | Text | Unique identifier for active simulation batch/scenario run[cite: 1]. |
| **Opinion State** | | | |
| `initial_opinion` | `float` | $[0.0, 1.0]$ | Starting pre-deliberation attitude computed from normalized T1 subfactors[cite: 1]. |
| `opinion` | `float` | $[0.0, 1.0]$ | Active opinion updated dynamically each simulation cycle[cite: 1]. |
| `previous_opinion` | `float` | $[0.0, 1.0]$ | Agent opinion at cycle $t-1$ (used for local convergence tracking)[cite: 1]. |
| `final_attitude` | `float` | $[0.0, 1.0]$ | Target post-deliberation attitude from empirical T2 survey data[cite: 1]. |
| `initial_opinion_snapshot` | `float` | $[0.0, 1.0]$ | Immutable step-0 baseline copy used to calculate structural drift[cite: 1]. |
| `agent_net_change` | `float` | $[-1.0, 1.0]$ | Structural shift magnitude: $\text{opinion} - \text{initial\_opinion\_snapshot}$[cite: 1]. |
| `agent_wrong_direction` | `boolean` | `true/false` | Validation flag tracking if simulated shift opposes baseline empirical stance[cite: 1]. |
| **Attitude Subfactors** | | | |
| `subfactor_1_t1` / `subfactor_1_t2` | `float` | $[0.0, 1.0]$ | Health considerations (PRO-reduction) at T1 (initial) and T2 (empirical target)[cite: 1]. |
| `subfactor_2_t1` / `subfactor_2_t2` | `float` | $[0.0, 1.0]$ | Environmental impact (PRO-reduction) at T1 (initial) and T2 (empirical target)[cite: 1]. |
| `subfactor_3_t1` / `subfactor_3_t2` | `float` | $[0.0, 1.0]$ | Taste/enjoyment (CONTRA-reduction) at T1 (initial) and T2 (empirical target)[cite: 1]. |
| `subfactor_4_t1` / `subfactor_4_t2` | `float` | $[0.0, 1.0]$ | Cultural tradition (CONTRA-reduction) at T1 (initial) and T2 (empirical target)[cite: 1]. |
| `subfactor_5_t1` / `subfactor_5_t2` | `float` | $[0.0, 1.0]$ | Economic concerns (CONTRA-reduction) at T1 (initial) and T2 (empirical target)[cite: 1]. |
| **Individual Dynamics** | | | |
| `agent_convergence_rate` | `float` | $[0.001, 0.99]$ | Personal speed of opinion adjustment ($\mu_i$), sampled from population distribution[cite: 1]. |
| `agent_confidence_threshold` | `float` | $[0.001, 0.99]$ | Similarity boundary required for attraction ($\epsilon_i$), sampled from population distribution[cite: 1]. |
| `agent_repulsion_threshold` | `float` | $[0.001, 0.99]$ | Dissimilarity boundary triggering repulsion ($\rho_i$), sampled from population distribution[cite: 1]. |
| `agent_repulsion_strength` | `float` | $[0.001, 0.99]$ | Relative force multiplier for negative influence ($\alpha_i$), sampled from population distribution[cite: 1]. |
| **Fatigue & Interaction** | | | |
| `recent_speech` | `list<int>` | Binary vector | Rolling speech history window across cycles ($1 = \text{spoke}$, $0 = \text{listened}$)[cite: 1]. |
| `speak_weight` | `float` | $(0.0, 1.0]$ | Speaker selection probability weight: $1.0 / (\sum(\text{recent\_speech}) + 1.0)$[cite: 1]. |
| `total_influences_received` | `integer` | $\mathbb{Z}_{\ge 0}$ | Cumulative counter of incoming communication events received by agent[cite: 1]. |
| `retention_discount` | `float` | $(0.0, 1.0]$ | Dynamic cognitive fatigue scaling modifier: $1.0 / (1.0 + \text{total\_influences\_received} \times 0.1)$[cite: 1]. |
| `agent_is_saturated` | `boolean` | `true/false` | Dynamic fatigue inhibition flag (triggered `true` when `retention_discount` $< 0.2$)[cite: 1]. |
| `cumulative_opinion_change` | `float` | $\ge 0.0$ | Running cumulative total of all absolute local shifts across steps[cite: 1]. |
| **Network & Display** | | | |
| `neighbors` | `list<agent>` | List | Direct topological neighbor list (static after initialization; empty for control)[cite: 1]. |
| `location` | `point` | $[0, 100] \times [0, 100]$ | Continuous 2D coordinates assigned for GUI visual display[cite: 1]. |
| `color` | `rgb` | RGB Color | Visual stance spectrum mapping: `rgb(opinion * 255, 0, (1.0 - opinion) * 255)`[cite: 1]. |

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
- `recent_speech` (list): Binary timeline vector recording whether the agent spoke during interaction cycles.
- `speak_weight` (float): Dynamic selection priority weight computed as: $$\text{speak\_weight} = \frac{1.0}{\sum(\text{recent\_speech}) + 1.0}$$
- `total_influences_received` (integer): Cumulative counter tracking individual received incoming communication events.
- `retention_discount` (float [0,1]): Dynamic cognitive fatigue modifier scaling down opinion adjustment steps, computed as: $$\text{retention\_discount} = \frac{1.0}{1.0 + \text{total\_influences\_received} \times 0.1}$$
- `agent_is_saturated` (boolean): Flag trigerred true when an agent becomes fatigue-inhibited (retention_discount < 0.2)
- `cumulative_opinion_change` (float): Running total of all absolute local shifts across steps.

#### Network Structure
- `neighbors` (list<opinion_agent>): Agents with whom this agent interacts
- Network is static after initialization (no dynamic rewiring)
- Control agents have empty neighbor lists (no interaction)

#### Visualization
- `location` (point): Spatial coordinates for display (randomly assigned, no functional role)
- `color` (rgb): Visual representation of opinion (blue=0/anti, red=1/pro)

## 2.3 Scales
**Spatial:** 100 × 100 continuous 2D space (for visualization only)  
**Temporal:** Discrete time steps (abstract, not calibrated to real time)
**Typical simulation length:** 11–100 cycles; no run in the sweep reached `max_cycles`
(max 100 cycles — applies equally to speaking and non-speaking mode)
**Update opportunities per debate:** Cycle counting begins at 0 and the timeout condition is `(cycle - debate_start_cycle) >= max_cycles`, so a debate that runs to the ceiling receives 101 update opportunities rather than 100.
**Convergence threshold:** max |opinion - previous_opinion| < 0.01 (see Submodel 7.2 for the full convergence-checking algorithm and its consequences)
**Opinion scale:** Continuous [0,1] where 0=strongly anti-reduction, 1=strongly pro-reduction  
**Empirical basis:** Real debates lasted ~60 minutes; model time is abstract (not calibrated to real minutes)


## 2.4 Global State Variables

| Variable Name | Data Type | Domain Bounds | Description |
| :--- | :--- | :--- | :--- |
| **Model Selection** | | | |
| `model_type` | `string` | `{"consensus", "clustering", "bipolarization", "no_change"}` | Active social influence update rule active for the simulation batch. |
| `mode_batch` | `boolean` | `true/false` | Toggle between batch execution mode (`true`) and GUI visualization mode (`false`). |
| `speaking_mode` | `boolean` | `true/false` | Switch between turn-based speaker mechanics (`true`) and parallel network updates (`false`). |
| `use_distinct_agents` | `boolean` | `true/false` | Toggle between heterogeneous agent parameter sampling (`true`) and homogeneous parameters (`false`). |
| `selection_mode` | `string` | `{"filter", "explicit"}` | Determines debate selection method (context filtering vs. explicit list). |
| `composition_scope` | `string` | `{"H", "M", "ALL"}` | Condition filtering scope for debate experiment instantiation. |
| **Population Means ($\mu$)** | | | |
| `convergence_rate` | `float` | $[0.005, 1.0]$ | Central tendency mean for individual speed of opinion change. |
| `confidence_threshold` | `float` | $[0.0, 1.0]$ | Central tendency mean for bounded confidence attraction boundary ($\epsilon$). |
| `repulsion_threshold` | `float` | $[0.0, 1.0]$ | Central tendency mean for repulsion boundary ($\rho$). |
| `repulsion_strength` | `float` | $[0.0, 0.5]$ | Central tendency mean for repulsive force scaling weight ($\alpha$). |
| **Population SD ($\sigma$)** | | | |
| `convergence_rate_sd` | `float` | $[0.0, 0.2]$ | Standard deviation of individual convergence rates around global mean. |
| `confidence_threshold_sd` | `float` | $[0.0, 0.3]$ | Standard deviation of confidence thresholds around global mean. |
| `repulsion_threshold_sd` | `float` | $[0.0, 0.3]$ | Standard deviation of repulsion thresholds around global mean. |
| `repulsion_strength_sd` | `float` | $[0.0, 0.2]$ | Standard deviation of repulsion strengths around global mean. |
| **Composition Tracking** | | | |
| `current_condition` | `string` | `{"homogeneous", "heterogeneous", "control"}` | Runtime detected condition string for current active debate. |
| `num_pro_agents` | `integer` | $\mathbb{Z}_{\ge 0}$ | Active count of agents with empirical `pro_reduction = 1`. |
| `num_anti_agents` | `integer` | $\mathbb{Z}_{\ge 0}$ | Active count of agents with empirical `pro_reduction = 0`. |
| `mean_opinion_pro` | `float` | $[0.0, 1.0]$ | Real-time mean opinion trajectory of pro-reduction participants. |
| `mean_opinion_anti` | `float` | $[0.0, 1.0]$ | Real-time mean opinion trajectory of anti-reduction participants. |
| **Simulation Control** | | | |
| `selected_debate_id` | `integer` | $[1, 242]$ | Active debate identifier index being simulated. |
| `max_cycles` | `integer` | Default $100$ | Hard boundary cycle limit before triggering timeout fallback. |
| `step` | `float` | Default $0.5$ | Time step duration per execution cycle. |
| `mae_convergence_threshold` | `float` | Default $0.01$ | Single convergence criterion threshold for max absolute opinion delta. |
| `end_simulation_at_convergence` | `boolean` | `true/false` | Toggle early stopping upon meeting convergence criteria vs. forced run to `max_cycles`. |
| `convergence_cycle` | `integer` | $[11, max\_cycles]$ | Cycle count since debate start when convergence was met (records `max_cycles` if timed out). |
| `debate_start_cycle` | `integer` | $\mathbb{Z}_{\ge 0}$ | Simulation baseline cycle when active debate session was instantiated. |
| `converged` | `boolean` | `true/false` | `TRUE` if the debate met the convergence criterion before `max_cycles` was reached, `FALSE` if it terminated at `max_cycles`. Reset to `FALSE` at the start of each debate. |
| **Output Metrics** | | | |
| `mae` | `float` | $[0.0, 1.0]$ | Global Mean Absolute Error between final simulated attitudes and T2 data. |
| `mae_per_debate` | `map<int, float>` | Map | Session-level MAE aggregated separately per unique debate ID. |
| `opinion_variance` | `float` | $\ge 0.0$ | Current statistical variance of agent opinions across active population. |
| `num_clusters` | `integer` | $[0, 10]$ | Number of non-empty 10-bin histogram opinion clusters. |
| `polarization_index` | `float` | $\ge 0.0$ | Standardized variance of all unique pairwise opinion distance coordinates. |
| `initial_num_clusters` | `integer` | $[0, 10]$ | Baseline count of opinion clusters evaluated at step 0. |
| `interaction_log` | `list<string>` | List | Dynamic runtime container array holding step-by-step transaction logs. |
| **Diagnostics** | | | |
| `neutral_zone_width` | `float` | $[-1.0, 1.0]$ | Bipolarization zone gap calculated as $\rho - \epsilon$. |
| `mean_net_repulsion_abs` | `float` | $\ge 0.0$ | Population average magnitude of active repulsive forces. |
| `total_attractive_interactions` | `integer` | $\mathbb{Z}_{\ge 0}$ | Cumulative count of interactions occurring in attraction zones. |
| `total_repulsive_interactions` | `integer` | $\mathbb{Z}_{\ge 0}$ | Cumulative count of interactions occurring in repulsion zones. |
| `total_neutral_interactions` | `integer` | $\mathbb{Z}_{\ge 0}$ | Cumulative count of interactions occurring in neutral buffer zones. |

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
- `end_simulation_at_convergence` (boolean): Global toggle that determines early halt or forces continuous run until max_cycles.
- `convergence_cycle` (integer): Cycles elapsed since debate start when convergence was met; records `max_cycles` on timeout. Initialised to -1 at debate reset, but this sentinel is always overwritten before saving.
- `debate_start_cycle` (integer): Records the absolute simulation baseline cycle when active debate group loop instantiated.
- `converged` (boolean). Gets set to true if the debate reaches convergence before `max_cycles`; `false` if it terminated at the ceiling. It is reset to `false` at the start of each subsequent debate.

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

For a comprehensive elementing mapping chart, parameter sensitivity screening bounds and output variable links to hypotheses (H1-H7), see Supplementary File `model_elements_chart_CLEAN.md`.

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


[every cycle after cycle 10 from debate start, if end_simulation_at_convergence is true]
5. Convergence check (`check_convergence`) — see Submodel 7.2 for the full algorithm, threshold value, and finalization/debate-progression logic triggered on convergence.

[every cycle]
6. Maximum Cycles Reached (`max_cycles_reached`) — see Submodel 7.2 for the fallback algorithm triggered when `max_cycles` is reached without convergence.

### Update Order & Rationale
Within-agent updates are done simultaneously (all agents update their opinion based on their t-1 neighbors).

Rationale: The within-agent updates procedure avoids order effects and maintains symmetry. This implies that network structure matters more than update sequence, consistent with the social influence models of Flache et al., (2017). The initialization sequence was designed to sequentially parse the csv (`train_data.csv`) for relevant data, populate the subfactor lists used for T1, then validate the data loading to ensure that the DB_Index variable is correctly calculated according to its equation defined in Dheilly et al. (unpublished). Once all data has been loaded and validated, the agents are created according to the debate id, and the opinion is set to initial_opinion to give a starting value for each subfactor for each agent. The network creation is initialized at each repetition of the simulation (e.g., in batch experiments to keep debates independent from each other). 

For each simulation loop, agents execute reflexes under one kind of model of social influence as the batch experiments are designed to calibrate parameters according to each model. This aligns with the purpose of the study to investigate how each model performs in comparison with the others and OLS. The decision to perform compute pro/anti stats and global metrics is done every 10 cycles to allow for deliberation processes to occur and to reduce computational load when running the batch experiments. 

The convergence cycle reflex (`check_convergence`) is evaluated every cycle after the 10th cycle from debate start. This allows for an initial period of deliberation where the debates will most likely not converge, while progressively checking whether group stabilization has occurred against an exact absolute tolerance floor (`mae_convergence_threshold <- 0.01;`). The final reflex for max_cycles and no convergence evaluates the timeout boundary continuously every cycle after a pre-defined maximum length (`max_cycles <- 100;`). This design cap minimizes computational load across vast batch combinations, as empirical testing demonstrates that stable debate runs successfully settle within 100 cycles.

Empirical testing demonstrates that stable debate runs successfully settle within 100 cycles.

# 4. DESIGN CONCEPTS

## 4.1 Theoretical Background
**Primary theory:** Social influence models (Flache et al., 2017)
- **Consensus model:** Assimilative influence - agents converge toward group mean
- **Clustering model:** Bounded confidence - only similar others influence
- **Bipolarization model:** Similar attract, dissimilar repel

**Extension:** Agent heterogeneity in susceptibility to influence (not in original Flache models)

**Deliberation theory:** Bächtiger et al. (2018), Niemeyer et al. (2024) - mini-publics enable perspective-taking and norm reflection

## 4.2 Emergence
**Emergent phenomena the model can produce:**
- Opinion convergence or polarization (not pre-determined)
- Opinion cluster formation in heterogeneous debates
- Asymmetric attitude change (pro vs anti agents may behave differently): Empirical benchmarking reveals a systematic **anti-reduction bias** where symmetric parameter distributions consistently under-predict real-world shifts toward plant-based diets. The model captures this through asymmetric population parameter distributions
- Opinion leader effects (agents with high convergence_rate may shift more and influence others)

**Not emergent:**
- Network structure (determined at initialization; fully connected for interactive mode, empty for control agents)
- Agent participation (fixed by debate_id)
- Individual susceptibilities (sampled at init, then constant)

## 4.3 Adaptation
**Agents adapt their opinions** based on neighbors' current opinions.

**No adaptation of:**
- Network connections (static)
- Influence parameters (agent_convergence_rate, etc. are fixed after initialization)
- Interaction rules (model_type doesn't change during simulation)

**Rationale:** Debates are short-term interactions; personality traits and social ties don't change within a 60-minute discussion.

## 4.4 Objectives
**Agents are not goal-directed.** They do not seek to:
- Maximize consensus
- Win arguments
- Change others' minds
- Maintain their own opinion

**Instead:** Agents mechanistically respond to neighbor opinions according to their influence parameters. This represents automatic social influence processes rather than strategic behavior.

**Contrast with argumentation extension (future):** Argument selection may be goal-directed.

## 4.5 Learning
**No learning.** Agent parameters remain constant throughout simulation.

**Rationale:** Short time scale (single debate session). Learning would be relevant for repeated interactions over weeks/months.

## 4.6 Prediction
**Agents do not predict:** They respond to current neighbor opinions, not anticipated future states.

**Model users predict:** The model's purpose is predicting T2 attitudes, but agents themselves have no predictive mechanisms.

## 4.7 Sensing
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

## 4.8 Interaction
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

## 4.9 Stochasticity
**Sources of randomness:**

**At initialization:**
- Agent parameter sampling: a Gaussian draw of each parameter when `use_distinct_agents = TRUE`

**During simulation:**
- Deterministic when `speaking_mode = FALSE` and `use_distinct_agents = FALSE`
- When speaking_mode = true: stochasticity is introduced at every interaction cycle via the random choice operator (rnd_choice) selecting the active speaker.

**Across runs:**
- Different random seeds produce different parameter samples and networks
- Implication: repeat: 1 for the 4 deterministic experiments and repeat: 5 for the remaining 9.

**Control of stochasticity:**
- `keep_seed: true` in batch experiments ensures reproducibility
- Seed value saved in output files for traceability

As stated above stochasticity enters the model through two channels: the Gaussian draw of agent parameter values and the `rnd_choice` when `speaking_mode = TRUE`. Four of the thirteen experiment cells (`cons_ndist_nospeak`, `clst_ndist_nospeak`, `bipol_ndist_nospeak`, `no_change_exp`) with both `use_distinct_agents` and `speaking_mode` switches off are deterministic and repeated runs under these identical parameter set ups produce identical output.

By design, the nine remaining experiment cells are stochastic, however during the run reported here the flag `keep_seed: true` fixed the RNG state across repeats. Because the per-debate seed reset only took effect from the second debate onwards, the repeats varied for the first debate but were identical for all subsequent debates. The number of effective independent replicates per parameter-set by debate combination is thus one, not the nominal `repeat` value and `logged_batch_seed` records an identical value across all runs. This follows from prioritising reproducibility. A planned robustness check will require a re-run using `keep_seed: false`. 

An earlier version of this document stated that stochasticity had a negligible effect on MAE. This claim is withdrawn as the diagnostic tool supporting it folded the random seed into a grouping variable, implying that variation across parameter sets was measured at a fixed seed rather than the variation resulting from different seeds. Furthermore, in a prior experimental set up before the final run, all debates within an experiment began from the same RNG state, resulting in speaker selection being replayed in the same sequence for each debate.

**Non-sources of randomness**
**At initialization:**
- Network creation: fully deterministic (fully connected network)
- Spatial location assignment: `location ~ Uniform(0, 100) × Uniform(0, 100)`
The spatial location assignment comes from a uniform draw, is used purely for visualization and never enters an update rule.

Regarding the lhs sweep, no run reached `max_cycles` - all 1,565,243 rows have `converged = TRUE`. Convergence detection is gated by a minimum of 10 cycles and subsequently evaluated at every cycle. The removal of a previous restriction to multiples of 5 results in the convergence cycle saved in the output files reflecting the exact cycle where the debate converged. 

## 4.10 Collectives
**Debates** are the primary collective entity:
- Agents with same `debate_id` form a collective
- Network connections only within debates (no cross-debate interaction)
- Statistics computed per debate (mae_per_debate)

**No explicit representation:** Debates are implicit groupings, not separate entities with state variables.

**Homogeneous vs Heterogeneous distinction:**
- Homogeneous: All agents start with similar opinions (either pro or anti)
- Heterogeneous: Mix of pro and anti agents
- Detected automatically from data at runtime

## 4.11 Observation
**Data collection occurs at:**
- Every cycle: Convergence check (`check_convergence`) and timeout evaluation (`max_cycles_reached`).
- Every 10 cycles: Group composition (`compute_pro_anti_stats`) and polarization variance metrics (`compute_statistics`).
- At convergence: Final statistics, error metrics, file writing loops.

**Output files:**

**batch_summary.csv** (debate-level, 29 columns) — one row per debate × parameter set × repetition:
- **Run identification:** `model_type`, `current_condition`, `selected_debate_id`, `debate_label`, `current_experiment_id`, `max_cycles`, `converged`, `use_distinct_agents`, `speaking_mode`, `logged_batch_seed`
- **Debate composition:** `pro_count`, `anti_count`
- **Population parameters:** `convergence_rate`, `confidence_threshold`, `repulsion_threshold`, `repulsion_strength`
- **Population variation:** `convergence_rate_sd`, `confidence_threshold_sd`, `repulsion_threshold_sd`, `repulsion_strength_sd`
- **Outcomes:** `convergence_cycle`, `initial_variance`, `mae`, `opinion_variance`, `polarization_index`, `num_clusters`, `initial_num_clusters`
- **Bipolarization diagnostics:** `neutral_zone_width`, `mean_net_repulsion_abs`

**agent_level_results.csv** (individual, 51 columns):
Shares the run-identification and population-parameter columns of `batch_summary.csv` (`model_type`, `current_condition`, `selected_debate_id`, `debate_label`, `current_experiment_id`, `max_cycles`, `use_distinct_agents`, `speaking_mode`, `logged_batch_seed`, `pro_count`, `anti_count`, the four population parameters, `convergence_cycle`, `converged`). It does **not** carry the debate-level outcome columns (`mae`, `opinion_variance`, `polarization_index`, `num_clusters`, `initial_num_clusters`, `neutral_zone_width`, `mean_net_repulsion_abs`), which exist only at debate grain. Agent-specific columns are:
- `agent_id`, `pro_reduction`
- `subfactor_1_t1` through `subfactor_5_t1` (initial)
- `initial_opinion` (computed from subfactors), `initial_variance`
- `opinion` (final simulated attitude)
- `subfactor_1_t2` through `subfactor_5_t2` (empirical targets), `mean_t2_subfactors`
- `final_attitude` (empirical T2 attitude — the prediction target, not a model output)
- `opinion_change`, `individual_error`, `error_sub1` through `error_sub5`
- `agent_convergence_rate`, `agent_confidence_threshold`, `agent_repulsion_threshold`, `agent_repulsion_strength` (realised individual draws)
- `total_influences_received`, `retention_discount`, `cumulative_opinion_change`
- `agent_net_change`, `agent_wrong_direction`, `agent_is_saturated`

This file does **not** carry the debate-level outcome columns (`mae`, `opinion_variance`, `polarization_index`, `num_clusters`, `initial_num_clusters`, `neutral_zone_width`, `mean_net_repulsion_abs`), nor the population variation parameters (`*_sd`), all of which exist only at debate grain.

**interaction_log.csv** (18 columns) — one row per dyadic influence event; written only when `speaking_mode = true`:
- **Run identification:** `speaking_mode`, `model_type`, `current_condition`, `selected_debate_id`, `debate_label`, `current_experiment_id`, `use_distinct_agents`, `logged_batch_seed`, `max_cycles`
- **Event:** `cycle`, `sender_id`, `receiver_id`, `sender_opinion`, `opinion_before`, `opinion_after`, `delta`
- **Flags at event time:** `agent_is_saturated`, `agent_wrong_direction`

# 5. INITIALIZATION

## 5.1 Initial State

**Environment:** Empty 100×100 continuous space (for GUI visualization)

**Agent creation:** Conditional on `selected_debate_id` coordinated sequentially by global controller `initialize_agents_for_debate`.
- Only agents with matching debate records from data loader and instantiated.
- Typical size of debates is between 4-7 agents.
- Control debates: 1 agent per simulation session.

## 5.2 Data Loading
**Source:** `../data-dictionary/exp-dat/train_data.csv`, loaded via `load_csv_data` in the model's `init` block. This is the calibration split only — see Section 6.1/6.2 for data structure, column mapping, and integrity checks, and Appendix C for how this file is produced from the full dataset.

**Note on validation runs:** the file path above is hardcoded in `main_4-3.gaml`'s `init` block, with no runtime switch to `test_data.csv`. Validation-set runs (Section 8.1.2, Hypotheses H3/H5/H6) require a manual path edit to simulate based on the test data (already implemented in model code for out-of-sample validation).

## 5.3 Debate ID Mapping
Multi-agent debates are parsed using an explicit string-to-integer translation map (`stable_group_map`). 
- **Interactive Groups:** Agents sharing a common string configuration are mapped to a shared integer ID index.
- **Control Groups:** Isolated control agents are dynamically assigned an exclusive string ID key defined as `"Control_" + agent_id` to prevent group allocation errors and guarantee topological isolation.
- **Resulting Space:** The orchestration pipeline manages up to 242 unique debate ID sessions sequentially via `m_debate_list`.

## 5.4 Agent Parameter Assignment
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
If heterogeneous distributions are enabled (`use_distinct_agents = true`), individual dynamic attributes are drawn from Gaussian distributions centered on global population means with assigned standard deviations ($\sigma$). To enforce strict multi-run determinism, the RNG is seeded once per agent as (`seed` $\leftarrow \text{logged_batch_seed} + \text{idx}$) before sampling; the four parameters are then drawn in sequence from that single stream. Draws are clamped to $[0.001, 0.99]$ to avoid boundary calculation errors:

The mean domains below are the Latin hypercube sampling ranges used in the exploratory sweep. The Genetic Algorithm search bounds are derived per design cell from that sweep and are narrower for some parameters, see 6.5.1.

| Dynamic Parameter | Symbol | Global Sampling Mean ($\mu$) Domain | Standard Deviation ($\sigma$) Bounds | Individual Truncated Domain |
| :--- | :--- | :--- | :--- | :--- |
| **Convergence Rate** | $\mu_i$ | $[0.005, 0.100]$ | $[0.000, 0.020]$ | $[0.001, 0.990]$ |
| **Confidence Threshold** | $\epsilon_i$ | $[0.100, 0.300]$ | $[0.000, 0.020]$ | $[0.001, 0.990]$ |
| **Repulsion Strength** | $\alpha_i$ | $[0.050, 0.200]$ | $[0.000, 0.020]$ | $[0.001, 0.990]$ |
| **Repulsion Threshold** | $\rho_i$ | $[0.400, 0.700]$ | $[0.000, 0.030]$ | $[0.001, 0.990]$ |

*Algorithmic sampling and deterministic seeding logic:*
- `agent_convergence_rate` $\leftarrow \max(0.001, \min(0.99, \text{gauss}(\{\text{convergence\_rate}, \text{convergence\_rate\_sd}\})))$
- `agent_confidence_threshold` $\leftarrow \max(0.001, \min(0.99, \text{gauss}(\{\text{confidence\_threshold}, \text{confidence\_threshold\_sd}\})))$
- `agent_repulsion_strength` $\leftarrow \max(0.001, \min(0.99, \text{gauss}(\{\text{repulsion\_strength}, \text{repulsion\_strength\_sd}\})))$
- `agent_repulsion_threshold` $\leftarrow \max(0.001, \min(0.99, \text{gauss}(\{\text{repulsion\_threshold}, \text{repulsion\_threshold\_sd}\})))$
- `agent_repulsion_threshold` $\leftarrow \max(`agent_confidence_threshold` + 0.05, `agent_repulsion_threshold`)

*Structural Neutral Zone Enforcer:*
To guarantee physical validity and prevent invalid overlap between attraction and repulsion zones ($\rho_i \le \epsilon_i$), the model enforces a minimum neutral buffer of $0.05$:
$$\text{agent\_repulsion\_threshold} \leftarrow \max(\text{agent\_confidence\_threshold} + 0.05, \text{agent\_repulsion\_threshold})$$

The realized distribution of $\rho_i$ is truncated from below at $\epsilon_i + 0.05$ and is not the declared Gaussian. This implies that the marginal distributions of `confidence_threshold` and `repulsion_threshold` differ between heterogeneous and homogenous arms.

If heterogeneous mode is disabled (`use_distinct_agents = false`), agents inherit global population baseline values directly ($\mu_i = \mu, \epsilon_i = \epsilon, \alpha_i = \alpha, \rho_i = \rho$). The clamp and enforcer thus do not fire in this arm; the constraint $\epsilon < \rho$ is instead guaranteed by the population level ranges and the initialization guard described in section 7.1.3.

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

## 5.5 Network Initialization
**Topology Creation:**
The system runs `create_network` to clear old connections and maps undirected edges across active agents.
- **Interactive Modes:** Instantiates a fully connected, complete undirected network graph among all individuals assigned to the active `selected_debate_id`.
- **Control Mode:** The network assignment is skipped entirely; control agent populations retain an empty `neighbors` list.

**Network structural constraints:**
- **Undirected Validity:** Multi-agent connections are explicitly verified across both ends of the edge: if agent $i$ lists $j$ as a structural neighbor, $j$ is structurally directed to add $i$ to its own `neighbors` array.
- **Static Invariance:** Node links are structurally locked at $t = 0$; no edge updates, re-linking events, or network rewiring occur during simulation execution loops.
- **Absolute Boundary Isolation:** Links are built exclusively inside the current active debate circle. Cross-debate edges across different session IDs are completely impossible.

## 5.6 Initial Diagnostics
The global controller computes starting state tracking values at $t = 0$ before initiating the simulation cycle loop:
- `initial_variance` ← Calculates the statistical variance of the initial opinions across the instantiated population.
- `initial_num_clusters` / `num_clusters` ← Computed via a 10-bin logical histogram layout to classify baseline group distributions.
- `neutral_zone_width` ← Calculated as $\text{repulsion\_threshold} - \text{confidence\_threshold}$.
- `current_condition` ← Automatically mapped to `"homogeneous"`, `"heterogeneous"`, or `"control"` depending on empirical participant properties parsed at runtime.

# 6. INPUT DATA
## 6.1 Data Source & Empirical Origin
**Primary Input File:** `../data-dictionary/exp-dat/train_data.csv` (structured calibration split of the empirical dataset; see Section 5.2 for initialization details and Appendix C for dataset construction).  
**Format:** Character CSV file with an initial header row.  
**Origin:** Empirical study dataset from Dheilly et al. investigating deliberative debates on plant-based dietary shifts and meat consumption reduction.
**Dataset Structure:** Contains individual participant records mapped into unique debate sessions:
- **Multi-Agent Debates:** 55 multi-agent interactive groups ($4\text{--}7$ participants per group).
- **Control Debates:** 187 single-agent isolated sessions where no social interaction occurs.
- **Total Mapped Sessions:** 242 unique debate session identifiers (`m_debate_list`).

*Note on Validation Split:* Out-of-sample model evaluations (Section 8.1.2, Hypotheses H3, H5, H6) utilize a path switch to `test_data.csv` to ensure strict separation between calibration and testing datasets.

## 6.2 Data Structure & Runtime Mapping
The global data loader parses CSV columns dynamically at step 0 (`load_csv_data`) and fills the following system data arrays:

| CSV Target Dimension | Internal Mapped GAML Variable Array | Data Type / Domain Bounds | Description / Role |
| :--- | :--- | :--- | :--- |
| Participant Identifiers | `agent_id_list` | `list<int>` | Unique participant keys matching empirical records. |
| Empirical Group Labels | `id_group_raw` | `list<string>` | Raw session identifiers mapped via `stable_group_map`. |
| Experimental Condition | `group_type_list` | `list<string>` $\in$ `{"Homogeneous", "Heterogeneous", "Control"}` | Experimental group composition classification. |
| Pre-Debate Stance Bias | `pro_reduction_list` | `list<int>` $\in$ `{0, 1}` | Binary stance bias ($0 = \text{anti}$, $1 = \text{pro}$ meat reduction). |
| Initial Attitude Point | `initial_attitude_list` | `list<float>` $\in [0.0, 1.0]$ | Pre-deliberation T1 attitude assigned to `opinion`. |
| Empirical Final Outcome | `final_attitude_list` | `list<float>` $\in [0.0, 1.0]$ | Target T2 attitude evaluated solely for MAE metrics. |
| Timepoint 1 Subfactors | `subfactors_t1` | `list<list<float>>` $\in [0.0, 1.0]$ | $5 \times N$ matrix of T1 baseline subfactor scores. |
| Timepoint 2 Subfactors | `subfactors_t2` | `list<list<float>>` $\in [0.0, 1.0]$ | $5 \times N$ matrix of T2 target subfactor scores. |

**Data Transformations:** Raw empirical metrics are normalized prior to simulation ingestion using the composite subfactor mapping defined in Section 2.2.

**Data Quality and Integrity Checks:**
When `debug_mode` is enabled, the global initialization block executes defensive verification routines:
- Verifies that all position variables and stance scores fall strictly within $[0.0, 1.0]$.
- Executes `do debug_init` to confirm algebraically that initial attitudes match the composite balance of input subfactors within floating-point tolerances ($10^{-10}$).
- Enforces deterministic agent-level seed binding (`local\_agent\_seed` $\leftarrow \text{logged_batch_seed} + \text{idx}$) to guarantee identical data ingestion and parameter assignments across execution runs.

## 6.3 Environmental Data
**None.** The simulation world contains:
- No GIS data, geographic vector layers, or spatial boundaries.
- No continuous external time series or exogenous environmental drivers.
- No dynamic resource grids.

*Spatial Rendering Note:* Continuous $100 \times 100$ coordinates are assigned to agents purely for 2D visualization within the GAMA Graphical User Interface (GUI). They exert no functional role, topological filtering influence, or communication constraint.

## 6.4 Model Exclusions & Theoretical Rationale
**Variables Omitted from ABM Processing:**
- Participant demographic attributes (age, gender identity, education level).
- Perceived social norms matrices and internal self-control indexes (retained in baseline OLS/multilevel models, but excluded from agent dynamic state logic).
- Open-ended qualitative debate transcripts.

**Design Rationale:** To evaluate social influence as an abstract, rule-based process, individual differences are compressed into starting opinion stances and susceptibility parameters. This minimal input baseline enables rigorous testing of hypothesis **H3**: evaluating whether an agent-based model driven strictly by localized interaction rules can match or outperform traditional statistical models that rely on full demographic attributes.

## 6.5 Calibration Search Space & Sensitivity Pipeline
### 6.5.1 Active Parameter Bounds

Population means ($\mu$) and, where heterogeneous sampling is active (`use_distinct_agents = true`), standard deviations ($\sigma$) are optimised by the Genetic Algorithm within the search bounds below. Bounds are derived per design cell from the LHS sweep (see §8.2); the ranges shown are the widest applied to any cell.

GAMA's genetic method searches over an enumerated parameter space. A `step` must therefore be declared for each parameter: with `min` and `max` alone the method evaluates only the interval endpoints and no interior values are sampled.

| Parameter Name | GAML Variable | Mean Search Bound ($\mu$) | Step | SD Bound ($\sigma$) | SD Step |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Convergence Rate** | `convergence_rate` | $[0.005, 0.100]$ | $0.005$ | $[0.000, 0.020]$ | $0.002$ |
| **Confidence Threshold** | `confidence_threshold` | $[0.100, 0.350]$ clustering (non-speaking); $[0.100, 0.600]$ clustering (speaking); $[0.100, 0.300]$ bipolarization | $0.01$–$0.02$ | $[0.050, 0.100]$ clustering; $[0.000, 0.020]$ bipolarization | $0.005$ / $0.002$ |
| **Repulsion Strength** | `repulsion_strength` | $[0.050, 0.200]$ | $0.01$ | $[0.000, 0.020]$ | $0.002$ |
| **Repulsion Threshold** | `repulsion_threshold` | $[0.550, 0.700]$ | $0.01$ | $[0.000, 0.030]$ | $0.003$ |

*Genetic Algorithm Calibration Configuration:*
- **Optimization Criterion:** `minimize: mae_mean_all`, the unweighted mean of per-debate MAE across all calibration debates. The global `mae` variable is reset at the start of each debate, so minimising `mae` directly would optimise only the final debate of each run.
- **Population Size:** `pop_dim: 5`
- **Crossover Probability:** `crossover_prob: 0.5`
- **Mutation Probability:** `mutation_prob: 0.1`
- **Generation Limits:** 5 preliminary generations, 10 maximum generations (`max_gen: 10`)
- **Repetitions:** `repeat: 1` (see §4.9 — `keep_seed: true` fixes the RNG state across repeats, so additional repetitions produce identical output)
- **Scope:** All twelve design cells are calibrated independently (3 model types × heterogeneity × speaking mode), plus the `no_change` baseline, which has no free parameters and is evaluated in a single pass.

### 6.5.2 Sensitivity Analysis Workflow
Parameter importance is assessed on the LHS sweep, independently within each design cell (`model_type` × `use_distinct_agents` × `speaking_mode`), rather than pooled across cells. Pooling would combine response surfaces that differ in both dimensionality and shape.

Because between-debate variation in MAE substantially exceeds between-parameter variation, sensitivity is computed on debate-centred MAE: within each design cell, the mean MAE of each debate is subtracted, so the remaining variation is attributable to parameters rather than to debate difficulty. Analyses are run on a random subsample of 50,000 rows per cell for tractability.

1. **Partial Correlation Coefficients (PCC/PRCC):** monotonic dependencies between input parameters ($\mu_i, \epsilon_i, \alpha_i, \rho_i$ and their standard deviations) and outputs (MAE, opinion variance, convergence cycle).
2. **Random Forest permutation importance and partial dependence:** non-parametric check for non-linear effects and interactions. Out-of-bag $R^2$ on MAE is reported per cell as an identifiability diagnostic — a low value indicates that MAE in that cell is not well predicted by the swept parameters, and that calibrated values there should not be interpreted as estimates.
3. **Bound derivation:** GA search bounds are taken as the union of (a) the empirical envelope of parameter values attaining top-quartile MAE within the cell and (b) the region of the partial dependence surface within tolerance of its minimum. Where a parameter's partial dependence amplitude is negligible relative to the debate-level MAE standard deviation, the parameter is treated as unidentified and its LHS range retained unchanged.

Completing this calibration and sensitivity analysis defines the formal stopping condition for model parameterization before statistical hypothesis testing and argumentation modeling.

# 7. SUBMODELS
## 7.1 Opinion Update Models
Three alternative social influence mechanisms (only one active per run, selected by `model_type` parameter):

### 7.1.1 Consensus Model (Assimilative Influence)
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

### 7.1.2 Clustering Model (Bounded Confidence)
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

### 7.1.3 Bipolarization Model (Attraction-Repulsion)
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
- $\epsilon < \rho$ (The population-level attraction threshold must be strictly less than the repulsion threshold). If this global rule is broken, initialization is flagged via `infeasible_params` flag, the simulation is terminated `end_simulation <- true`, and a fitness penalty is  applied in `compute_fit`. For heterogeneous agents, if individual sampling causes an overlap ($\epsilon_i \ge \rho_i$), it violates the structural premise of a neutral zone buffer which is corrected in Section 5.4.

**Expected behavior:**
- Opinions drive outward toward opposite extremes ($0.0$ and $1.0$), forcing distinct ideological polarization.
- Because forces are explicitly normalized by the counts of active attractive and repulsive neighbors (`n_attraction` and `n_repulsion`), individual trajectories update via balanced vector steps, reducing arbitrary step oscillations.

**Limitations:**
- **Dimensionality Overhead:** Introduces a significantly larger parameter space (up to 8 dimensions when optimizing standard deviations), drastically increasing the computational complexity and risk of overfitting during calibration phases (GA/LHS).
- **Edge Accumulation Artifacts:** Because repulsion pushes agents away from the group center, opinions naturally pile up exactly at the extreme boundaries ($0.0$ and $1.0$), which can overpredict absolute fanaticism compared to more nuanced empirical data distributions.

### 7.1.4 Turn-Based Broadcast & Cognitive Fatigue Mechanics (`speaking_mode = true`)
When dyadic turn-based interactions are activated, parallel neighbor loops are replaced by sequential broadcast dynamics via `compute_opinion_speaker(speaker_opinion, sender)`. In each cycle, a speaker agent $S$ broadcasts position $o_S$ to listening peers $i \in N(S)$.

Across all three submodels, stance updates in speaker mode incorporate an explicit pairwise averaging construct and are scaled by the individual cognitive fatigue factor (`retention_discount`).

**Differences from the parallel regime**
Within the `speaking_mode` mechanic, three model properties change together:
- Scheduling: There is one speaker per cycle who is selected by a weighted probabilistic draw (`rnd_choice` over `speak_weight`) who broadcasts to all other agents in the debate. Under `speaking_mode = false`, every agent simulatenously update from their full neighborhood.
- Influence dose: In speaking_mode a listener received one influence per cycle compared with `N - 1` under parallel updating. The effective adjustment per cycle therefore differs by approximately an order of magnitude for typical debate sizes, independent of parameter values.
- Cognitive fatigue: `retention_discount` only applies in the `speaking_mode` path. Under parallel updating the fatigue term does not enter the update rules and `total_influences_received` does not accumulate.

Because these three properties change together, comparing outcomes from both regimes is not feasible as their differences are attributable to the change in properties. The two regimes are therefore reported as separate model variants, rather than two levels of an experimental factor.

#### 1. Consensus Speaker
All listening neighbors evaluate the midpoint $\bar{o}_{\text{sim}} = \frac{o_i + o_S}{2}$ and adjust their stance:
$$\Delta o_i = \text{agent\_convergence\_rate}_i \times \text{retention\_discount}_i \times (\bar{o}_{\text{sim}} - o_i) = \text{agent\_convergence\_rate}_i \times \text{retention\_discount}_i \times \left( \frac{o_S - o_i}{2} \right)$$

#### 2. Clustering Speaker (Bounded Confidence)
Listening agents check if the speaker falls within their confidence boundary ($|o_S - o_i| \le \epsilon_i$).
- **If $|o_S - o_i| \le \epsilon_i$:** Calculate midpoint $\bar{o}_{\text{sim}} = \frac{o_i + o_S}{2}$ and update stance:
  $$\Delta o_i = \text{agent\_convergence\_rate}_i \times \text{retention\_discount}_i \times \left( \frac{o_S - o_i}{2} \right)$$
- **If $|o_S - o_i| > \epsilon_i$:** No stance modification occurs ($\Delta o_i = 0$), and cognitive fatigue counters remain unchanged.

#### 3. Bipolarization Speaker (Attraction-Repulsion)
Evaluates distance $d_{iS} = |o_S - o_i|$ against individual thresholds:
- **Attraction Zone ($d_{iS} \le \epsilon_i$):**
  $$\text{Eff}_{\text{attract}} = \text{agent\_convergence\_rate}_i \times \text{retention\_discount}_i \times (o_S - o_i)$$
- **Repulsion Zone ($d_{iS} \ge \rho_i$):**
  $$\text{direction} = \begin{cases} -1.0 & \text{if } o_S > o_i \\ 1.0 & \text{if } o_S \le o_i \end{cases}$$
  $$\text{Eff}_{\text{repel}} = \text{agent\_repulsion\_strength}_i \times \text{retention\_discount}_i \times \text{direction}$$
- **Neutral Zone ($\epsilon_i < d_{iS} < \rho_i$):** Zero influence.

$$\Delta o_i = \text{Eff}_{\text{attract}} + \text{Eff}_{\text{repel}}$$

---

#### Post-Update State & Inline Diagnostic Tracking
Whenever an interaction occurs within an active influence zone, the listening agent updates state variables, recalculates fatigue, and logs the event within the same routine:

1. **State Transition & Visual Mapping:**
   $$o_i(t+1) = \max\left(0.0, \, \min\left(1.0, \, o_i(t) + \Delta o_i\right)\right)$$
   $$\text{color} \leftarrow \text{rgb}(o_i \times 255, \, 0, \, (1.0 - o_i) \times 255)$$

2. **Cumulative Influence & Fatigue Decay:**
   $$\text{cumulative\_opinion\_change}_i \leftarrow \text{cumulative\_opinion\_change}_i + (o_i(t+1) - o_i(t))$$
   $$\text{total\_influences\_received}_i \leftarrow \text{total\_influences\_received}_i + 1$$
   $$\text{retention\_discount}_i \leftarrow \frac{1.0}{1.0 + \text{total\_influences\_received}_i \times 0.1}$$

3. **Inline Diagnostic Flags & Logging:**
   - **Cognitive Saturation Flag:** $\text{is\_sat} \leftarrow \text{retention\_discount}_i < 0.2$
   - **Directional Accuracy Flag (`wrong_dir`):**
     $$\text{wrong\_dir} = (o_{\text{final}} > o_{\text{init}} \text{ and } \Delta o_{\text{net}} < 0) \lor (o_{\text{final}} < o_{\text{init}} \text{ and } \Delta o_{\text{net}} > 0)$$
   - **Interaction Log Append:** Records `[speaking_mode, model_type, current_condition, debate_id, debate_label, current_experiment_id, use_distinct_agents, seed, cycle, sender_id, agent_id, speaker_opinion, opinion_before, opinion, delta, is_sat, wrong_dir, max_cycles]` directly to `interaction_log`.


## 7.2 Convergence Detection
**Purpose:** Stop simulation when opinions stabilize (computational efficiency + realism)

**Mechanism:** The global orchestration loop executes a structural tracking check every cycle (beginning on step 10, relative to `debate_start_cycle`) via the `check_convergence` reflex, to determine if state stabilization has been reached. A separate `max_cycles_reached` reflex provides a fallback timeout, evaluated every cycle.

**Algorithm (`check_convergence`):**
1. Collect each agent's opinion displacement since the previous cycle:
   $$\text{max\_delta} = \max \left( |o_i(t) - o_i(t-1)| \right) \quad \forall i$$
   (`previous_opinion` is refreshed every cycle by a separate reflex, so this is always a one-cycle comparison.)
2. If $\text{max\_delta} < \text{mae\_convergence\_threshold}$ (hardcoded to $0.01$):
- Set `convergence_cycle` $\leftarrow$ current cycle $-$ `debate_start_cycle`.
- Set `converged` $\leftarrow$ `true`.
- Trigger `end_simulation <- true`.
- Call `do compute_fit` and `do compute_final_statistics`.
- If `mode_batch` is true, execute `do save_batch_results`.
- Sequential loop control: if `debate_counter < length(m_debate_list) - 1`, increment the counter, update `selected_debate_id` to the next debate, remove all current agent instances, and call `do init_debate`; otherwise set `end_simulation <- true`.

**Algorithm (`max_cycles_reached`, fallback):**
1. If `(cycle - debate_start_cycle) >= max_cycles` (default 100) and `end_simulation` is still false:
- Set `convergence_cycle` $\leftarrow$ current cycle $-$ `debate_start_cycle`, which under this trigger condition equals `max_cycles`. The sentinel value $-1$ assigned at debate reset is therefore never written to output.
- Set `converged` $\leftarrow$ `false`.
- Trigger `end_simulation <- true`.
- Call `do compute_fit` and `do compute_final_statistics`, then (if `mode_batch`) `do save_batch_results`.
- Same sequential debate-progression logic as above.

Both `convergence_cycle` and `converged` are reset at the start of each debate by `reset_debate_globals`, to $-1$ and `false` respectively.

**Convergence criterion:** Maximum opinion change < 0.01, checked every cycle starting at cycle 10 relative to debate start.

**Rationale:** Opinion change becomes negligible; further cycles add no information. The 10-cycle initial grace period allows deliberation to begin before checking is meaningful.

**Fallback:** If `max_cycles` (100) is reached without convergence, the simulation is force-stopped by `max_cycles_reached` and finalized identically to a converged run, with `convergence_cycle` still recorded for diagnostic purposes.

## 7.3 Model Fit Computation
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

## 7.4 Statistical Computations
Calculated systematically every 10 cycles and captured as an immutable final snapshot upon termination:

*   **Population Variance:** Measures the dispersion of opinions across the active sub-population.
*   **Opinion Clusters:** Evaluates distribution layouts by parsing agent opinions into a 10-bin mathematical histogram over the range $[0.0, 1.0]$. Bins containing an agent count $> 0$ register as active clusters.
*   **Polarization Index:** Computed using the standardized variance of all unique pairwise distance matrix coordinates:
    $$\text{PI} = \frac{1}{K} \sum_{i \in Agents} \sum_{j \neq i} \left(|o_i - o_j| - \overline{\text{dist}}\right)^2$$
*   **Stance-Stratified Metrics:** Sub-groups are filtered using the empirical baseline binary flag `pro_reduction`. The system splits records into independent tracking matrices to generate separate real-time group trajectories for `mean_opinion_pro` and `mean_opinion_anti`.

## 7.5 Network Creation
The simulation utilizes a static, complete network framework configured at step 0 to isolate opinion transformations from topological confounding variables.

**Execution Routine (`create_network`):**
1. Purge all historical node arrays and flush active agent tracking lists (`neighbors <- []`).
2. Map complete multi-directional boundaries within identical groups:
   $$\forall (i, j), \text{ if } \text{debate\_id}_i == \text{debate\_id}_j \text{ and } i \neq j \Rightarrow j \in N(i)$$
3. **Control Isolation Guard:** If an agent's experimental descriptor matches `"Control"`, network allocation functions bypass the agent entirely, ensuring their neighbor register remains strictly empty.

# 8. EXPERIMENTAL SETUP & PARAMETER BOUND PROTOCOL (ODD+D)
**Registration status note:** Sections 8.1-8.4 are pre-specified analysis plans registered prior to completion of full batch simulation and validation analyses. 
Results and interpretations will be added upon completion and will be document as post-registration additions in the appending to distinguish them from pre-specified analyses.


## 8.1 Exploratory Sampling Design & Sensitivity Analysis
### 8.1.1 Latin Hypercube Sampling (LHS)
To evaluate parameter sensitivity, interaction effects, and model robustness across the multi-dimensional search space (RQ1), Latin Hypercube Sampling (LHS) is applied within derived parameter bounds. LHS ensures uniform space-filling coverage across multi-dimensional search spaces and represents standard practice for agent-based model calibration and global sensitivity analysis (Lee et al., 2015).

To maintain consistency with the pre-registered OSF protocol and preserve cross-model comparability across varying dimensionalities (2 to 12 active parameters depending on `model_type` and `use_distinct_agents`), $N = 200$ hypercube samples are generated per model variant. This sample size provides a computationally feasible yet statistically robust foundation for downstream Random Forest sensitivity analysis and response surface modeling.

---

### 8.1.2 Global Sensitivity Analysis Protocol (PCC / PRCC & Random Forest)
The global parameter sensitivity is evaluated in a two-step framework applied to the $N = 200$ LHS simulation output matrix:
1. **Linear & Monotonic Sensitivity (PCC/PRCC):**
   * **Partial Correlation Coefficient (PCC):** Quantifies linear relationships between individual input parameters ($\mu_i, \epsilon_i, \alpha_i, \rho_i$) and emergent opinion dynamics while controlling for the confounding effects of other parameters.
   * **Partial Rank Correlation Coefficients (PRCC):** Evaluate non-linear but monotonic relationships by applying rank-transformation to the input-output pairs prior to partial correlation calculation.
2. **Non-Parametric Interaction Importance (Random Forest):**
To capture non-linear and non-monotonic interactions across the parameter space, a Random Forest regression model is fitted on the pooled parameter-output dataset. Parameter importance is quantified using Permutation Importance ($\%IncMSE$) and Node Purity ($IncNodePurity$).

## 8.2 Two-Stage Boundary Selection & Derivation Protocol (`generate_gaml_bounds`)
Parameter search boundaries for Latin Hypercube Sampling (LHS) and Genetic Algorithm (GA) sweeps are established through a two-stage hybrid process combining empirical pilot constraint with automated pipeline processing:

### Stage 1: Preliminary Pilot Exploration & Search Space Tailoring
Prior to finalizing the pre-registered protocol, preliminary exploratory runs across legacy datasets were evaluated. To avoid wasting computational bandwidth on degenerate or trivial dynamics (e.g., parameter combinations causing instantaneous collapse or complete deadlock), the global search space was manually tailored to plausible behavioral regions.

### Stage 2: Programmatic Range Extraction & Guard Enforcment
Following preliminary tailoring, operational parameter boundaries ($[\mathbf{p}_{\text{min}}, \mathbf{p}_{\text{max}}]$) are formalized programmatically using the R analysis routine (`generate_gaml_bounds`). This function extracts identical bounding boxes for both LHS space-filling sweeps and GA optimizations:

1. **Elite Quantile Selection:** Upstream execution results are filtered to retain configurations within the top 25% lowest MAE quantile (`best_mae` per `model_type` and `use_distinct_agents` combination).
2. **Empirical Range Extraction:** Raw minimum ($p_{\text{raw, min}}$) and maximum ($p_{\text{raw, max}}$) bounds are extracted across the elite set.
3. **Degenerate Range Expansion:** If an elite parameter range collapses to a single point ($p_{\text{raw, min}} == p_{\text{raw, max}}$), the internal helper `expand_range()` expands the bounds symmetrically around the point estimate using a fixed buffer ($\text{buffer} = 0.05$):
   $$p_{\text{min}} = p_{\text{raw, min}} - 0.05, \quad p_{\text{max}} = p_{\text{raw, max}} + 0.05$$
4. **Structural Inclusion Guards:** Parameters are conditionally included in the generated GAML declarations based on model topology and numerical relevance:
   * **Convergence Rate ($\mu$):** Included unconditionally across all model variants.
   * **Confidence Threshold ($\epsilon$):** Guarded by `ct_max > 0.01`. Included for Clustering and Bipolarization variants; suppressed for Consensus where spatial confidence does not structurally apply.
   * **Repulsion Parameters ($\alpha, \rho$):** Guarded by `rs_max > 0.01`. Active exclusively for Bipolarization variants.
   * **Population Heterogeneity ($\sigma$):** Standard deviation variants ($\sigma_{\mu}, \sigma_{\epsilon}, \sigma_{\alpha}, \sigma_{\rho}$) pass through their respective structural guards only when `use_distinct_agents = TRUE`.

---

## 8.3 Genetic Algorithm (GA) Optimization Protocol
To identify parameter combinations that minimize the difference compared with empirical deliberation attitudes, a GA optimization is executed in GAMA (`method: genetic`).

Early pilot exploration across legacy datasets used heuristic parameter tuning to establish search boundaries, the formal model calibration (i.e. last run before argumentation implementation) adheres to a standardized GAMA genetic experiment configuration:

```
method genetic 
  minimize: mae_mean_all 
  pop_dim: 5 
  crossover_prob: 0.5 
  mutation_prob: 0.1 
  nb_prelim_gen: 5 
  max_gen: 10;
```

Mae is reset per debate, so minimising it would have optimized only the final debate of each run.

* **Search Space Constraints:** The GA space is constrainted by the operational parameter ranges created by `generate_gaml_bounds`.
* **Objective Function:** The GA has the goal of optimizing parameters to obtain the minimal Mean Absolute Error ($MAE$) between final simulated stance ($o_{i, \text{final}}$) and post-debate empirical stances ($T2$).
* **Operators & Hyperparameters:** 
   * **Population Dimension (pop_dim):** 5 individuals per generation.
   * **Preliminary Generations (nb_prelim_gen):** 5 initial randomized generations to seed population diversity.
   * **Maximum Generations (max_gen):** 10 generations.
   * **Crossover Probability (crossover_prob):** 0.5 (50% chance of single-point crossover).
   * **Mutation Probability (mutation_prob):** 0.1 (10% uniform mutation rate across active parameter bounds). 
* **Protocol Deviation Note:** Simulated annealing which was originally planned as the third local calibration stage following GA was formally omitted. Prior legacy LHS and GA sweeps demonstrated that the social-influence variants do not beat the static `no_change` baseline, with GA converging to a near zero change state. Further local search refinement was via SA was thus judged as not capable of altering the macro-level conclusions.

---

## 8.4 Model Validation Protocol
The validity of the model is evaluated with a multi-tiered empirical cross-validation framework:
### 8.4.1 Quantitative Validation & Benchmarks
1. **Individual-Level Fit (Primary Metric):** Model performance is evaluated using Mean Absolute Error (MAE) comparing simulated individual post-debate stances ($o_{i, \text{final}}$) against empirical post-deliberation survey stances ($y_i \in T_2$): $$\text{MAE} = \frac{1}{N} \sum_{i=1}^{N} \vert{}o_{i, \text{final}} - y_i\vert{}$$
2. **Out-of-Sample Cross-Validation:** To evaluate the generalizability of the model and prevent overfitting, the parameter combinations identified in the GA calibration phase are validated across held-out debates not used in initial parameter fitting. Overall baseline population error across the pooled dataset evaluated in Sections 8.2 and 8.4 illustrates performance at $\text{MAE} \approx 0.0644$.
3. **Benchmark Comparison:** Model variants are evaluated against a trivial `no_change` baseline ($T_1 \rightarrow T_1$) and an empirical regression baseline across grlobal, debate and individual groupings.

| Model Variant | Execution / Sampling Mode | Global MAE | Status / Analytical Role |
|---|---|---|---|
| **`no_change` Baseline** | Static Persistence ($T_1 \rightarrow T_1$) | **0.0399** | Empirical Lower Bound Benchmark |
| **OLS Regression** | Empirical Stance Predictor | *Pending* | Statistical Control Benchmark |
| **Consensus Variant** | LHS Sweep (`speaking_mode = true`) | **0.0616** | Unimodal Convergence Model |
| **Clustering Variant** | LHS Sweep (`speaking_mode = true`) | **0.0528** | Bounded Confidence Model |
| **Bipolarization Variant** | LHS Sweep (`speaking_mode = true`) | **0.0873** | Repulsive Dynamics Model |
| **GA-Optimized Composite** | Pooled Optimizations | **0.0644** | Calibrated Multi-Model Fit |

## 8.5 Operational Guard Specifications

| Parameter Symbol | Variable Name | Theoretical Domain | Operational Guard Condition | Active Model Variants |
|---|---|---|---|---|
| $\mu_i$ | `convergence_rate` | $[0.0, 1.0]$ | Unconditional | All models |
| $\sigma_{\mu}$ | `convergence_rate_sd` | $[0.0, 0.5]$ | `use_distinct_agents == TRUE` | All models |
| $\epsilon_i$ | `confidence_threshold` | $[0.0, 1.0]$ | `ct_max > 0.01` | Clustering, Bipolarization |
| $\sigma_{\epsilon}$ | `confidence_threshold_sd` | $[0.0, 0.5]$ | `use_distinct_agents == TRUE` & `ct_max_sd > 0.01` | Clustering, Bipolarization |
| $\alpha_i$ | `repulsion_strength` | $[0.0, 1.0]$ | `rs_max > 0.01` | Bipolarization |
| $\sigma_{\alpha}$ | `repulsion_strength_sd` | $[0.0, 0.5]$ | `use_distinct_agents == TRUE` & `rs_max_sd > 0.01` | Bipolarization |
| $\rho_i$ | `repulsion_threshold` | $[\epsilon_i + 0.05, 1.0]$ | `rs_max > 0.01` | Bipolarization |
| $\sigma_{\rho}$ | `repulsion_threshold_sd` | $[0.0, 0.5]$ | `use_distinct_agents == TRUE` & `rs_max_sd > 0.01` | Bipolarization |

> **Note on MAE Evaluation Metrics:** The `best_mae` values documented in generated parameter declaration headers (ranging from $0.0081$ to $0.0112$) represent top-quantile single-fit cutoff thresholds used to bound the elite filter. These are conceptually distinct from the global baseline population MAE averaged across all participants, sessions, and runs ($\approx 0.0644$). Generated GAML parameter lines are exported dynamically to `/outputs/gaml_parameter_bounds.gaml` for computational audit.

# 9. REFERENCES

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


# APPENDICES

## A. Parameter Summary Table

[Reference to your model_elements_chart_CLEAN.md or create summary table here]

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
