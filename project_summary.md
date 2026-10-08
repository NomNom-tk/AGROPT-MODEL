# SIMBA Summary Document

## 1. What the model does
The GAMA model has been developed in conjunction with Nicolas Darcel and Patrick Taillandier with the aim of recreating real-world behavior in the context of social influence for meat consumption reduction, more specifially in the context of online debates. The founding principle for models comes from a paper entitled `Models of social influence: Towards the next frontiers` by Flache et al. (2017). The models implemented are consensus, clustering and bipolarization. In a consensus model all agents interact simultaneously with each other and average their opinions with those of the other members of the debate to eventually reach a consensus. Clustering implements the confidence threshold below which agents consider themselves similar enough to other members to interact with them and subsequently average their opinions with the neighbors they consider themselves to be similar enough. Above this threshold agents who are dissimilar do not interact with each other. Finally in a bipolarization model, we implement the idea of a repulsion threshold above which agents consider themselves too dissimilar and thus actively distance themselves. In conjunction with the confidence threshold agents thus have the possibility of actively converging with their similar neighbors and distancing themselves from their dissimilar neighbors, resulting in polarized clusters.
 
For future reference or any clarifications please see the OSF protocol registration which contains the Protocol, the ODD as well as further context regarding the project.
- [OSF Protocol](https://osf.io/nfue6/overview)
- ODD: included in the OSF registration files


## 2. Key findings
### Empirical Context
The largest mean change occurred between T0-T1 prior to the possibility of simulating change. SD of mean change from T0-T1 and T1-T2 is up to 2 times larger than the mean change (could be presence of a large amoutn of noise). Analysing beta distance (the standardized regression coefficient of opinion change ~ pro reduction) empirical is near zero and non-significant (-0.03). In the simulated context it ranges from -0.65 to -0.38, implying that the simulated models impose stronger opinion dynamics than supported in the empirical data. Might be consistent with GA convergence toward near-zero attitude change.

### H1a
Homogeneous debates shifted in the negative direction (on the opinion scale) considering the T1-T2 timeframe. Debate composition explains none of the attitude variance once individual differences are accounted for (debate label SD = 0.0). Heterogeneous debates show a small positive shift, homogeneous a small negative shift and both are dwarged by the individual level SD. *SUPPORTED*

### H1b
Across all three models individual differences explain a large proportion of the variance in attitude change (~90%). Residuals in regressions imply that once the individual agents are identified, we know their attitude within +- 0.02.
- Note comparing to H1a: `TimeT2` was 0.022, in simulated regressions `TimeT2` is [-0.0002, -0.0005] -> Calibration algorithms might have found the path of least resistance and produced no movement. This implies that in empirical contexts the composition matters and the simulations fails to reproduce this. *NOT SUPPORTED*

### H2
Initial model had collinearity problems so the means of 3 variable were centered prior to interaction term computation. No predictors reached significance in mean-centered model. Perceived norms, self-control and their interaction with opinion strength do not predict the absolute atttidue change between T1-T2. Confirms H1 finding that group assignment explains no variation in attitude change. *NOT SUPPORTED* 

### H3a
Initial opinion almost perfectly predicts final_attitude after deliberation. Overall, the model is equivalent to the `no_change` baseline with a slight shrinkage towards the mean. Slightly better results for variance in attitude, with 21% being explained by the structure of the data. Individual models are indistinguishable from `no_change`, debate_label (takes into account the structure of the data) explains about the same amount of variance as the benchmark test. No individual model reaches significance. *NOT SUPPORTED*	

### H3b 
For a sign test to be significant in this case the model needs to win 10/12 times to be significant. No model crossed this threshold or came close. 

Comparing the ABM with No Change: majority of models have negative mean difference, so ABM has a lower MAE than the No change condition but not enough to become significant. No support for H3b.

ABM vs MLM: 
Model with the most wins is bipolarization with non-distinct agents and speaking mechanic (8 wins). Does not reach significance. *NOT SUPPORTED*

### H4a
Not supported as the Homogeneous debates have a greater mean change than the homogeneous groups (who were predicted to have a greater mean change). *NOT SUPPORTED*

### H4b
Bipolarization: homogeneous debates showed more mean absolute change / Clustering: heterogeneous debates show more mean absolute change / Consensus: heterogeneous debates show more mean absolute change
Only the bipolarization model follows the empirical pattern (identified in H4a). *NOT CONSISTENTLY SUPPORTED*

### H5
For all models the pooled MLM MAE is within the CI range of the pooled ABM MAE, thus we cannot distinguish the ABM from the MLM. *NOT SUPPORTED*

### RQ1
See the RQ1 seciton of the hypothesis notebook for full plots and tables. 
Top level: convergence_rate and confidence_threshold are the dominant parameters across all models (PCC/PRCC/RF). Convergence cycles cluster near the minimum (11 cycles) for GA for most parameter combinations. Stochastic variance is near-zero under fixed seeds.

## 3. How to run the pipeline
- Config setup: The basic principle behind the R analysis code is that the user runs the GAMA experiments and in accordance with the parameters chosen in the `Parameters.gaml` file they subsequently adjust the R config contained in `data_processing.R`. From GAMA the most important items to extract are: `run_type` (LHS, GA, VAL), `composition_scope` (ALL, M, H - denoting the type of debates that have been simulate), `version_scope` (these can be arbitrary names such as "v1", "v1-26/03/2026-fixed cycles", etc), and `analysis_scope` (among: hypotheses, validation, sensitivity which thereafter affects what kinds of output slots are available to view). The analysis scope is particularly important given that one would not run a PCC/PRCC analysis on a GA (this would most likely be run on an LHS model exploration). 
- Once the config has been set up based on the experiments run in GAMA, the user should then fill in the slots at the top of the data processing file, below you will find an example set up:
- Expected run order: LHS -> GA (with train/val split) -> analysis (essentially run LHS, feed into R, compile the LHS section from the notebook, extract param regions, feed into GAMA, run GA, feed back into R, extract params, validation run, finally R analysis for conclusions)
- One final note on the pipeline runs, it is useful to make use of the map_slots function (located in `functions.R`) to double check which slots in the output package located in `framework_analysis.R` have been populated. This will give you a clear idea of what is accessible under which analysis_scope and double check that everything has compiled correctly.
- Bundle construction: when running GA with validation, pass both train and val results in a single bundle (as shown in the `Hypotheses.ipynb` file). The validation block triggers on the presence of sim_val in the bundle, not on analysis_scope.
- Note: GA agent exports set param_set_id = 1 for all agents while batch files retain internal generation indices. The semi_join in framework_analysis.R handles this by joining on design cell only for GA runs.

### GAMA Side
For the gama experiment launch (taking as an example an LHS run) please refer the experiment entitled `batch_exp_exh-20_3.gaml`. In each init section you will see a series of toggles that reference the `Parameters.gaml` file from which you can set defaults when running and testing in GUI and subsequently before launching the experiments file using [python3 experiment_file.py] double check and or modify the parameters that have been set. I have not made a dedicated manual to launch the GAMA side experiments but the ODD should serve as a baseline for launching. If there are any doubts, this repository has all of the existing code that was used to generate the simulated data (github.com/NomNom-tk/AGROPT-MODEL/tree/main).   





Example:
```r
ga_bundle <- list(
  sim_inputs   = result_ga_train,
  sim_val      = result_ga_val,
  df_empirical = result_ga_train$df_empirical
)
```

```r
run_configs <- list()
lhs <- list()
ga <- list()
val <- list()

# ==========================================
# BUILD THE LHS CONFIGURATION
# ==========================================
lhs$run_type             <- "LHS"
lhs$composition_scope    <- "ALL"
lhs$version_scope        <- "v1"
lhs$analysis_scope       <- "sensitivity"

lhs$batch$v1$path        <- "./data/lhs_batch_summary.csv"
lhs$batch$v1$version     <- "v1_7_5_100c"

lhs$batch$v2$path        <- NULL
lhs$batch$v2$version     <- ""

lhs$agent$v1$path        <- "./data/lhs_agent_level_results.csv"
lhs$agent$v2             <- NULL

lhs$interaction$v1$path  <- "./data/lhs_interaction_log.csv"
lhs$interaction$v2       <- NULL

# ==========================================
# ASSIGN TO MASTER CONTAINER
# ==========================================
run_configs$lhs_main     <- lhs
run_configs$ga_main      <- ga
run_configs$ga_val       <- val
```

### Output package by analysis_scope

| Scope | Key populated slots | Key NULL slots |
|-------|-------------------|---------------|
| sensitivity | PCC, PRCC, RF, PDP, regions/bounds | all hypothesis models, valence, beta_distance |
| hypotheses | H1a/b, H2, H4, wilcox, beta_distance, valence | H3, H5, regions |
| validation (via sim_val) | H3a/b, H5, abm_vs_nc, abm_vs_mlm | regions |

Behavioral and dynamics slots populate under all scopes.



## 4. Known issues
- GAMA GA export: param_set_id mismatch (R-side fix in place)
- upset_prep: blocked by ncol(df_ag) >= 51 guard
- Interaction logs: too slow to compile, network pipeline commented out
- Stochasticity: current runs use fixed seeds (rerun with keep_seed: false planned)
- Valence pipeline: gated by ncol guard, works only with full agent export
- Closure-captured variables: plot closures in the output package 
  capture variables from the enclosing scope at construction time, 
  not from the output package slots. If a variable name changes 
  upstream, the closure silently breaks at call time. 
  Recent examples: empirical_pivot → empirical_stat_pivot, 
  empirical_beta_val → empirical_beta_scalar.
- If a plot closure errors with "object not found", check whether 
  the variable name in the closure matches the variable name where 
  it's computed in framework_analysis.R. The closure captures by 
  name, not by slot path.

## 5. What's next
- Argumentation dynamics (Phase 2, Dung-style)
- keep_seed: false rerun for stochastic analysis (currently being run, if still in this doc when reading, it has not been completed)
- Upset plot pipeline completion
- Network analysis (pending GLPK/RcppParallel) / Code in R files that is not used is specifically for this purpose (e.g., in data_processing.R the section with the title `# Interaction Level` or in functions.R `Interactions` or `Network`)

## Note on stochastic reruns
LHS rerun with keep_seed: false (5 repeats) completed and available 
on the server. Parquet conversion and recompile pending. GA and 
validation reruns with keep_seed: false have not been started.
Current hypothesis results use fixed-seed data.
