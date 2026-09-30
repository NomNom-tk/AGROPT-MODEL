# SIMBA Summary Document

## 1. What the model does
The GAMA model has been developed in conjunction with Nicolas Darcel and Patrick Taillandier with the aim of recreating real-world behavior in the context of social influence for meat consumption reduction, more specifially in the context of online debates. The founding principle for models comes from a paper entitled `Models of social influence: Towards the next frontiers` by Flache et al. (2017). The models implemented are consensus, clustering and bipolarization. In a consensus model all agents interact simultaneously with each other and average their opinions with those of the other members of the debate to eventually reach a consensus. Clustering implements the confidence threshold below which agents consider themselves similar enough to other members to interact with them and subsequently average their opinions with the neighbors they consider themselves to be similar enough. Above this threshold agents who are dissimilar do not interact with each other. Finally in a bipolarization model, we implement the idea of a repulsion threshold above which agents consider themselves too dissimilar and thus actively distance themselves. In conjunction with the confidence threshold agents thus have the possibility of actively converging with their similar neighbors and distancing themselves from their dissimilar neighbors, resulting in polarized clusters.
 
For future reference or any clarifications please see the OSF protocol registration which contains the Protocol, the ODD as well as further context regarding the project.
- [OSF Protocol](https://osf.io/nfue6/overview)
- ODD: included in the OSF registration files


## 2. Key findings


## 3. How to run the pipeline
- Config setup: The basic principle behind the R analysis code is that the user runs the GAMA experiments and in accordance with the parameters chosen in the `Parameters.gaml` file they subsequently adjust the R config contained in `data_processing.R`. From GAMA the most important items to extract are: `run_type` (LHS, GA, VAL), `composition_scope` (ALL, M, H - denoting the type of debates that have been simulate), `version_scope` (these can be arbitrary names such as "v1", "v1-26/03/2026-fixed cycles", etc), and `analysis_scope` (among: hypotheses, validation, sensitivity which thereafter affects what kinds of output slots are available to view). The analysis scope is particularly important given that one would not run a PCC/PRCC analysis on a GA (this would most likely be run on an LHS model exploration). 
- Once the config has been set up based on the experiments run in GAMA, the user should then fill in the slots at the top of the data processing file, below you will find an example set up:
- Expected run order: LHS -> GA (with train/val split) -> analysis (essentially run LHS, feed into R, compile the LHS section from the notebook, extract param regions, feed into GAMA, run GA, feed back into R, extract params, validation run, finally R analysis for conclusions)
- One final note on the pipeline runs, it is useful to make use of the map_slots function (located in `functions.R`) to double check which slots in the output package located in `framework_analysis.R` have been populated. This will give you a clear idea of what is accessible under which analysis_scope and double check that everything has compiled correctly.
- Bundle construction: when running GA with validation, pass both train and val results in a single bundle (as shown in the `Hypotheses.ipynb` file). The validation block triggers on the presence of sim_val in the bundle, not on analysis_scope.
- Note: GA agent exports set param_set_id = 1 for all agents while batch files retain internal generation indices. The semi_join in framework_analysis.R handles this by joining on design cell only for GA runs.

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
- Network analysis (pending GLPK/RcppParallel)

## Note on stochastic reruns
LHS rerun with keep_seed: false (5 repeats) completed and available 
on the server. Parquet conversion and recompile pending. GA and 
validation reruns with keep_seed: false have not been started.
Current hypothesis results use fixed-seed data.
