# Data Dictionary — ABM Opinion Dynamics Pipeline
*Updated: July 13, 2026 (Reflecting unified hypothesis mapping and deduplication architecture)*

## 1. Inputs & Simulation Data Objects (`pipeline_bundle$sim_inputs$`)

| Object | Data Grain | Target Hypothesis | Notes / Analytical Function |
| :--- | :--- | :--- | :--- |
| `df_batch` | Debate × Model × Seed | **H4, H5, H6, H7** | The master simulation data sweep. Carries `debate_composition` and `mae`. Drives the global ranking calculations. |
| `df_ag` | Individual Agent (Pooled) | Core Regression Engine | Micro-level agent tracking. Used to calculate baseline performance metrics and estimate raw individual-level OLS paths. |
| `lhs_versions` | Debate × Version | **H5, H6** | Combined version tracking dataframe used when evaluating multi-version parameter shifts (`version_scope == "both"`). |
| `df_empirical` | Individual (Real World) | **Baseline Alignment** | Real-world participant metrics. Extracted at the top-level of the execution Rmd to bypass previous null assignment bugs. |

---

## 2. Models Package (`pipeline_bundle$results$models$`)

| Object | Data Grain | Target Hypothesis | Status & Notes |
| :--- | :--- | :--- | :--- |
| `conv` | Debate-level | **Pipeline Diagnostic** | Evaluates speed of convergence (`mean_conv * speaking_mode + model_type`) predicting overall error (`mean_mae`). |
| `ols` | Individual Agent (Pooled) | Baseline Error Mapping | The original pooled linear model. Retained strictly to preserve continuity for downstream MAE baseline lines. |
| `ols_h1` | **Individual Agent (Deduplicated)** | **Hypothesis H1** | **Resolved Bug:** Built directly using `distinct(agent_id)` inside Section 3. Provides mathematically unbiased standard errors for pre/post attitude associations. |
| `ols_h2` | **Individual Agent (Deduplicated)** | **Hypothesis H2** | **Newly Implemented:** Evaluates the individual-level predictive power of social norms and self-control (`final_attitude ~ perceived_norms + self_control`). |

---

## 3. Comparisons Package (`pipeline_bundle$results$comparisons$`)

| Object | Data Grain | Target Hypothesis | Status & Notes |
| :--- | :--- | :--- | :--- |
| `ols_debate_mae` | **Debate-level** | **Hypothesis H5** | **Resolved Collision:** Renamed from `comparisons$ols` to prevent namespace overlap. Inner-joined debate-level table comparing ABM vs. OLS error vectors. |
| `summary` | Aggregated Global | **Hypothesis H5** | Captures significance tests (paired Wilcoxon and t-test) showing if social-influence models beat OLS on a debate scale. |
| `ranking` | Grouped Global | **Hypotheses H6, H7** | The primary prospective model ranking framework. Groups outputs by model type, version, and speaking method. |
| `baseline` | Grouped Global | **Hypotheses H3, H5, H6** | Evaluates all social-influence outputs against the trivial `no_change` batch baseline to demonstrate error gaps. |
| `beta_distance` | Model-type Summary | **RQ1 / Calibration** | Z-score metric mapping where real-world empirical beta shifts sit relative to simulated model distributions. |

---

## 4. Behavioral & Diagnostics (`pipeline_bundle$results$behavioral$` / `$dynamics$`)

| Object | Data Grain | Target Hypothesis | Notes / Analytical Function |
| :--- | :--- | :--- | :--- |
| `composition` | Debate-level | **Hypothesis H4** | Segments simulation error distributions across Heterogeneous (H) vs. Homogeneous (M) session types. |
| `conv_diff` | Grouped Condition | **RQ1 (Exploratory)** | Categorical tracker mapping how often distinct parameter conditions lead to full "Convergence" vs. "Polarization" (Variance $< 0.1$). |
| `directional` | Debate-level Aggregation | **RQ1 (Exploratory)** | Tracks directional valence and systematic drift markers to evaluate structural anti-reduction model bias. |

---

### Status of Prior Unresolved Items:
* **H1 Pseudoreplication:** **FIXED.** `ols_h1` uses the deduplicated data grain.
* **Missing H2 Model:** **FIXED.** `ols_h2` is now compiled inside