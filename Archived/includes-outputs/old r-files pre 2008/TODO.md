# TODO 
TODO UPDATES
- H2
Variable Derivation:opinion_strength represents baseline belief conviction and is calculated as the distance from the neutral midpoint:
$$\text{opinion\_strength} = \vert{}\text{db\_index\_t1} - 0.5\vert{}$$
Using abs() ensures both strong pro ($0.8 \to 0.3$) and strong anti ($0.2 \to 0.3$) positions reflect equal conviction magnitude.
Model Diagnostics & VIF Resolution:
Collinearity: Multiplicative interaction terms ($\text{norm} \times \text{strength}$) originally caused high structural multicollinearity ($\text{VIF} > 10$).
Fix (Mean-Centering): Mean-centering perceived_norms, self_control, and opinion_strength resolves the VIF issue while fully preserving individual-level variance and interaction $p$-values.
Group Variance ($\tau_{00} = 0$):The random effect (1 | id_group_all) returned zero variance (boundary (singular) fit).
Attitude change variance is driven entirely by individual traits/conviction rather than debate group assignment.
Quick Text to Drop into Your Paper/Protocol: To test $H_2$, baseline opinion strength was derived as the absolute deviation of $T_1$ composite attitudes from neutrality ($\vert{}\text{db\_index\_t1} - 0.5\vert{}$). 
To mitigate structural multicollinearity from interaction terms, all continuous predictors were mean-centered prior to model fitting, effectively reducing variance inflation factors ($\text{VIF}$) while preserving individual-level variance. 
Random intercept variance across debate groups estimated at zero ($\tau_{00} = 0.00$), indicating individual psychological characteristics accounted for observed variations in attitude change.
# conclusions from the centered check_model
# final centered - variance inflation factors - VIF range is (1.03 - 1.11) (fully preserved individual-level variance) 
# alongside tao = 00, implying that variance in absolute attitude change is drive by individual psychological characteristics rather than group level assignment

# updates for the rmd and ols calls / ols_model_..._viz has the check_model combined plots, NEED to call summary(ols_model_h1a) to pull the fit and summarize


📄 Key Documentation & Protocol EntriesBelow are the exact technical specifications and methodological details you need to align in your ODD Protocol and OSF Registration.
1. Global Sensitivity Analysis Method (ODD / Protocol)Sampling Scheme: Latin Hypercube Sampling (LHS) is strictly used for Global Sensitivity Analysis (GSA). Optimization/GA runs are excluded from global sensitivity indices to prevent convergence/sampling bias in parameter importance estimation.
Analytical Engines & Metrics:
Partial Correlation Coefficients (PCC): Evaluates linear parameter-output relationships ($R^2$ / Pearson metrics).
Partial Rank Correlation Coefficients (PRCC): Evaluates monotonic, non-linear parameter-output relationships via Spearman rank transformations.
Random Forest Permutation Importance (ranger): Evaluates non-linear dynamics, parameter interactions, and non-monotonic tipping points.
Metamodel Quality Guard ($R^2$ Thresholding): Random Forest feature importance scores must be interpreted alongside the Out-Of-Bag (OOB) $R^2$ score ($R^2 = 1 - \frac{\text{MSE}}{\text{Var}(Y)}$). Low variance explained (e.g., $R^2 \approx 0.05$) indicates that output dynamics are driven predominantly by stochastic noise rather than parameter variation, rendering relative ranking differences negligible.
Ensemble Stability: Random Forest sensitivity runs use $N_{\text{trees}} = 500$ trees per sub-model combination to ensure convergence and variance reduction in permutation importance rankings across stochastic seeds.
2. Parameter Region Extraction & Bounds Constraints (ODD Section 7 / Protocol)Quantile Thresholding: Parameter search space selection filters the top $25^{\text{th}}$ percentile ($Q_{0.25}$) of runs based on Mean Absolute Error (mae).
Zero-Variance Parameter Inactivation: Parameters with upper bounds $\le 0.01$ are classified as inactive in GAMA and assigned NA to prevent numerical instability or division-by-zero during correlation calculations.
Domain Clamping: All continuous parameters are strictly clamped to $[0.1, 0.9999]$ or $[0, 1]$.
Global Parameters vs. Per-Agent Distribution Metrics:Heterogeneous agent metrics track both mean and standard deviation (_sd) bounds (e.g., confidence_threshold, repulsion_strength, repulsion_threshold, convergence_rate).
Global model properties—specifically neutral_zone_width in the Bipolarization variant—exist strictly as single global parameters and do not possess an _sd component.
Structural Bipolarization Constraint: Valid search regions for Bipolarization models must enforce $CT_{\text{max}} < RT_{\text{min}}$ (Confidence Threshold maximum bound must strictly remain below the Repulsion Threshold minimum bound).
🛠️ Codebase Modifications & FixesBelow is a summary of the bug fixes and pipeline updates made across the scripts:run_sensi_analysis() & Roxygen2 Header:Updated Roxygen2 @return block to explicitly document the 3-element return structure (pcc, prcc, rf).
Added mathematical context for single-parameter fallbacks (cor()) versus multi-parameter $PCC/PRCC$ via sensitivity::pcc().
framework_analysis.R Pipeline Alignment:Corrected list element extraction typo ($rc $\rightarrow$ $rf).Corrected dplyr method name typo (mutation() $\rightarrow$ mutate()).
Added missing explicit initializations (rf_lhs, rf_v1, rf_v2, rf_all) and safe multi-version concatenation (bind_rows(rf_v1, rf_v2)).
param_region_extraction() Logic Repairs:Fixed syntax error in header filter: !is.na(model_type(.Corrected logical operator in narrow range warning check from , (AND) to | (OR) so !range_ok and NA entries are correctly caught.
Removed erroneous neutral_zone_width_sd references while retaining nzw_min and nzw_max.
Added NA guards (is.na()) to range and bipolarization constraint checks to prevent zeroed-out parameters from raising false errors.
prepare_interactions() Parsing Simplification:Replaced verbose manual case_when() blocks with readr::parse_logical() across boolean columns (speaking_mode, use_distinct_agents, agent_is_saturated, agent_wrong_direction).
Streamlined filtering using speaking_mode %in% TRUE, dropping unnecessary redundant if conditionals.

### Changed & Fixed
- **GSA Pipeline (`run_sensi_analysis`)**: Integrated Random Forest permutation importance via `ranger` alongside PCC/PRCC engines; added OOB R² evaluation for metamodel validation.
- **Sensitivity Workflow (`framework_analysis.R`)**: Fixed dataframe reference typos ($rc -> $rf, mutation -> mutate); added explicit binding and initialization for multi-version RF outputs (`rf_all`).
- **Bound Extraction (`param_region_extraction`)**:
  - Repaired syntax error in model type filter.
  - Fixed narrow-range check filter logic (`!range_ok | is.na(range_ok)`).
  - Cleaned parameter definitions: removed non-existent `neutral_zone_width_sd` while retaining global bounds (`nzw_min`, `nzw_max`).
  - Added safety guards for `NA` evaluation in zero-variance parameter pairs and bipolarization constraints.
- **Data Import (`prepare_interactions`)**: Replaced brittle `as.logical()` string conversions with `readr::parse_logical()` across boolean columns; removed redundant conditional check blocks.
- **Documentation**: Updated Roxygen2 headers with explicit `@param num_trees` trade-off descriptions and details on $R^2$ OOB metrics.