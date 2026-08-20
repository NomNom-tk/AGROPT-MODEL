# Research Context and Motivation

Choices regarding what we eat have a profound impact on the world around us, for example on our health (Springmann et al., 2016; Forouzanfar et al., 2015) and the environment (Garnett, 2008; Vermeulen et al., 2012). Notably, the food system accounts for more than a quarter of greenhouse gas emissions (GHG), where 80% of these emissions are attributed to livestock production (Steinfeld et al., 2006). Reducing these emissions to meet national (European Commission, 2024) and international commitments (OECD, 2025) implies reducing red meat consumption and diet change (Rockström et al., 2025; Schebesta & Candel, 2020).

To encourage this behavioral change, investigating how and with whom we eat could provide valuable insights (Cruwys et al., 2015; Higgs, 2015). Existing research in social sciences has increasingly focused on the use of social norms (Pollicino et al., 2025; Çoker et al., 2022) and nudges (Schäufele-Elbers et al., 2025) to shift eating behavior in social settings and encourage engaging in pro-environmental behaviors. These interventions however, often have mixed or little effects (Lin et al., 2025; Pollicino et al., 2025; Brachem et al., 2019), highlighting the possibility of investigating other methods of encouraging behavioral change.

One possibility is to consider deliberation in the context of meat consumption reduction. Drawing on the definition of Bächtiger et al. (2018) deliberation involves people coming together, viewed as equals and with mutual respect, to discuss political and societal issues; such discussions inform collective decisions that will affect their lives. Core functions of such deliberative mechanisms include transparency and accountability, reduction of cognitive burden and enhancement of cognitive abilities (Niemeyer et al., 2024).

An extension of the deliberation definition is "mini-publics" (Niemeyer, 2011) where experts and the public meet to discuss issues and reach a consensus. These mini-publics have been applied to broader contexts involving diverse populations such as the French Citizen's Convention for Climate (Convention Citoyenne pour le Climat, 2021). The increasingly broad use of mini-publics coupled with the fact that this kind of deliberation has a transformative effect which facilitates the "view from manywhere" (Niemeyer et al., 2024) highlights the potential for individuals to confront alternative perspectives and reflect on shared values and social expectations.

The reflective process of deliberation in a public setting is particularly relevant to embedded social practices such as meat consumption as meat consumption is influenced by individual preferences as well as shared norms. Colin-Jaeger & Dold (2025) illustrates this through his investigation of how individuals from diverse backgrounds are invited to critically reflect on shared values, norms and the consequences of their everyday choices. This creates conditions under which the existing behavioral and consumption norms can be questioned and potentially revised.

A study by Dheilly et al. (unpublished) looked into this through a cluster-randomized study using deliberation as a means to better understand the mechanisms by which information is diffused in a social setting relating to meat consumption reduction. This could help encourage a shift to more sustainable eating behavior in line with the recommendations of Eat Lancet (Rockström et al., 2025), improving human wellbeing and contributing to the stability of the earth system.

To analyze attitudes and the predictors for the evolution of these attitudes (what motivates behavioral change), it is conceivable to use regression analyses as they help understand what proportion of variance in the outcome of interest (e.g., attitudes and behavioral change) is explained by which predictors (Peters & Crutzen, 2018). Despite the frequent use of these analyses it is not always justified to use them to establish predictors to target in future behavior change interventions (Crutzen & Peters, 2023) as the regressions assume that the overlap between predictors is removed from the equation. In practice this implies that when performing a regression with two predictors that have some overlap in their definition (e.g., depressive mood and suicidal thoughts), evaluating the impact of the regression for one predictor with ceteris paribus neglects part of the construct, thus invalidating it (Peters & Crutzen, 2018). Thus, this paper uses regression as an initial benchmark from which to improve upon.

In the context of the current group debates, it is conceivable to use Agent Based Modelling [ABM] to study the behavioral mechanisms and underlying societal phenomena as it can analyze how individual actions and interactions generate macro-level patterns, which impact behaviors (Miller & Page, 2009). ABM cannot however be used to test behaviors directly (MacCoun, 2017), instead focussing on predicting patterns that would emerge given certain behaviors were followed (Jung, Miller & Page, 2025). Furthermore, ABM has the ability to generate theories of complex social systems using computational modelling (Guest & Martin, 2021). ABM thus lends itself well to the investigation of social influences and group dynamics in debates targeted toward the reduction of meat consumption.

This study analyzes previously collected survey and debate data including demographic characteristics and attitudes regarding meat consumption reduction. It combines empirical analysis of this data through linear regression with multi-agent simulations implemented in Gama. The simulations are exploratory and systematically vary parameters of the social influence models (Flache et al., 2017). The simulations using social influence models will then be augmented using argumentation models to test the predictive capability of introducing more complex models of interactions between agents (notably through argument graphs and attack and defense relations). This study is innovative as it contributes to existing literature by identifying and investigating mechanisms potentially compatible with observed empirical patterns, and taking advantage of multidisciplinary modelling and analysis techniques.

Building on this literature, the current study formulates hypotheses on the individual agent level, debate level and global level in addition to the predictive performance of agent based models. This protocol was written in accordance with OSF guidelines and guidelines followed in ABM literature. There is thus an ODD protocol that describes all of the mechanistic functions related to the ABM models.

# Objectives

- Analyze how statistical and simulation methods can predict individual, debate level and global attitudes and attitude change with the goal of understanding the underlying mechanisms of social interactions in the context of meat consumption reduction.

# Hypotheses (3 levels: Individual level, debate level, global level)

## Behavioral Hypotheses

Deliberation contexts where individuals can reflect on their individual norms, social expectations and values can interact with pre-existing attitudes toward meat consumption reduction (Bächtiger et al., 2018; Niemeyer et al., 2024; Colin-Jaeger, 2025). Individual self-regulatory capacities and social influences can have an influence on attitude stability and variability in food-related domains (Cruwys et al., 2015; Higgs, 2015). This study thus investigates how pre-deliberation attitudes and individual susceptibility to social influence predict post-deliberation attitude changes.

**H1a** (Empirical - Individual Level): Empirical pre-deliberation attitudes toward meat consumption are expected to be positively associated with empirical post-deliberation attitudes, accounting for a meaningful share of variance when controlling for the nested nature of agents within distinct debate groups. `[Status: not yet analyzed — prospective]`
**H1b** (Simulated - Individual Level): Simulated pre-deliberation attitudes toward meat consumption are expected to be positively associated with simulated post-deliberation attitudes, accounting for a meaningful share of variance when controlling for the nested nature of agents within distinct debate groups. `[Status: not yet analyzed — prospective]`

**H2** (Empirical - Individual Level): Individuals with higher perceived social norms and lower self-control will exhibit greater absolute attitude change between pre- and post-deliberation measurement points, moderated by their initial opinion strength. `[Status: not yet analyzed — prospective]`

**H4a** (Empirical - Debate Level): Debates with a heterogeneous composition of participants are expected to exhibit a greater mean attitude change between empirical pre- and post-deliberation attitudes compared with homogeneous debates. `[Status: not yet analyzed — prospective]`
**H4b** (Simulated - Debate Level): Debates with a heterogeneous composition of participants are expected to exhibit a greater mean attitude change between simulated pre- and post-deliberation attitudes compared with homogeneous debates. `[Status: not yet analyzed — prospective]`

## Model Performance Hypotheses

The shift of attitudes within debates illustrates participant interactions and how micro-level social influence processes are aggregated (Miller & Page, 2009; Flache et al., 2017). Deliberation with diverse viewpoints has been argued to foster reflection and reconsideration of prior positions (Bächtiger et al., 2018; Niemeyer et al., 2024). This section looks into the relation of debate composition and its impact on aggregate changes and whether the predictive capability of debate modeling improves upon simple regression approaches.

**H3a** (Simulated - Individual Level): Agent-based simulations initialized with pre-deliberation attitudes alone will lower the mean of absolute error [MAE] - the mean absolute difference between simulated and empirical post-deliberation attitudes - for individual participants compared with a naive "no_change" baseline and a multilevel linear model fitted on the calibration debates and evaluated on held-out debates. `[Status: RETROSPECTIVE — LHS/GA analysis substantially conducted prior to registration; see "Analysis Status at Registration" below. Reported as exploratory, not confirmatory.]`
**H3b** (Simulated - Debate Level): Agent-based simulations initialized with pre-deliberation attitudes alone will lower the mean of absolute error [MAE] - the mean absolute difference between simulated and empirical post-deliberation attitudes - aggregated at the debate group level, compared with a naive "no_change" baseline and a predictive multilevel linear model fitted on the calibration debates and evaluated on held-out debates. `[Status: RETROSPECTIVE — LHS/GA analysis substantially conducted prior to registration; see "Analysis Status at Registration" below. Reported as exploratory, not confirmatory.]`

The design in this study crosses three model types with two binary implementation switches (giving 12 design cells). For H3a and H3b we designate one primary cell per model type: `use_distinct_agents = TRUE, speaking_mode = TRUE` which is structural rather than performance based as it is the only cell where both modelled mechanisms are active. This represents the closest correspondence to the empirical debate setting. The remaining nine cells are reported descriptively as secondary.

**H5** (Simulated - Global Level): When pooled at a global level, ABMs calibrated with pre-deliberation attitudes should reproduce a global post-deliberation attitude shift toward meat consumption reduction with a lower MAE than a single global multilevel regression model. `[Status: RETROSPECTIVE — see Analysis Status below.]`

**H6**: Agent-based models built with an argumentation mechanism (following Taillandier et al., 2021) are expected to yield more accurate and stable predictions of global attitude distributions (using MAE) than agent-based models using only social influence mechanisms. `[Status: PROSPECTIVE — CONFIRMATORY. Not yet implemented or tested. This is the confirmatory component this registration is intended to protect.]`

Where H6 is evaluated across multiple design cells, a primary cell will be designated on structural grounds prior to analysis, following the approach used in H3. As H3a and H3b are retrospective and exploratory, this designation determines which result is reported as primary rather than serving as a statistical correction for multiple comparisons.

Decision rules:
The confirmatory tests use a two-sided alpha of 0.05.

H1a, H1b, H2, H4a and H4b are supported if their relevant coefficients are in the predicted direction and are significant. This concerns the pre-deliberation attitude for H1, the norms x self-control x opinion-strength interaction for H2 and the debate composition for H4.

H3a and H3b are supported if the calibrated ABM produces a lower MAE than the no-change baseline and the multilevel benchmark on held-out debates in the primary design cell. This benchmark is specified as lmer(final_attitude ~ initial_opinion + (1 | debate_label)) which is fitted on the 43 calibration debates and used to predict the held-out debates. This lines up with the information the ABM has access to, as it is only initialized with pre-deliberation attitudes. Any difference in the predictive performance is thus attributable to the interaction dynamics. H3b compares the average MAE per debate. It is tested with a two-sided sign test across the twelve held-out debates. Ten wins would be needed to reach significance, so the test is underpowered and we report the MAE difference regardless. H3a compares the absolute error per participant, which is not independent within a debate and is modelled with a debate-level random intercept.

H5 is supported if the pooled ABM MAE is lower than that of the global multilevel model. The global model follows the same specification as the H3 benchmark lmer(final_attitude ~ initial_opinion + (1 | debate_label)), fitted on the calibration debates. H5 is different from H3 in aggregation rather than in model as MAE is pooled across the held-out participants rather than averaged per debate.

H6 is supported if the argumentation models produce a lower MAE than the social influence models alone, in the primary cell.

**Note on debate-level vs. global-level analysis (resolved)**: "debate level" (H3) = metrics grouped by `model_type` **and** `selected_debate_id`; "global level" (H6) = metrics grouped by `model_type` alone (pooling across all debates), as in the existing `model_comparison_main`/`model_comparison_relative` code. `df_batch` (LHS and GA held as separate files) is inherently structured per debate/model/seed, since debates are run under each of the 3 social-influence models.

## Exploratory Macro-Dynamics Hypotheses

Cumulative micro-level interactions can help reveal macro-level patterns and help highlight non-linear dynamics not captured by linear regression (MacCoun, 2017; Guest & Martin., 2021). This section investigates whether agent-based modeling calibrated with pre-deliberation data can illustrate global attitude distributions and whether argumentation based modeling adds predictive value.

**RQ1**: Exploratory analyses will examine how variations in optimized model parameters influence global attitude trajectories and convergence patterns. `[Status: exploratory as originally designated; substantially conducted prior to registration — this designation is unchanged by that fact, since RQ1 was never intended as confirmatory.]`

Exploratory analyses are pre-specified but not used for confirmatory inference.

# Analysis Status at Registration

Data were made available in December of 2025. This protocol was originally drafted in January of 2026. Prior to formal registration on this platform (submitted 7/8/26), the following analyses had already been conducted as part of iterative model development:

- Latin hypercube sampling (200 samples) and genetic algorithm refinement for the three social influence models (consensus, clustering, bipolarization), evaluated on MAE against a multilevel regression and a no-change baseline (relates to H3, H5, H6). Calibrated models only marginally outperformed the no-change baseline in-sample but did not do so on held-out debates. On held-out debates, four of the twelve design cells performed worse than baseline. Between-debate variation in MAE exceeds between-parameter variation, limiting what the calibration can achieve. This result is what motivates progression to the argumentation model (H6).
- Exploratory analysis of parameter sensitivity via partial and semi-partial correlation coefficients (PCC/PRCC), Random Forest (RF) and of convergence patterns (RQ1), consistent with RQ1's original non-confirmatory designation.
- Exploratory valence/directional-bias analysis (not originally specified in this protocol; developed during RQ1) identifying a systematic anti-reduction bias — models under-predict movement toward reduced meat consumption relative to movement away from it — this analysis was affected by a type-coercion fault and requires re-derivation before it can be relied upon.

These are reported as **retrospective/exploratory, not confirmatory**, for H3, H5, H6, and RQ1. The following components of the originally registered calibration pipeline have not been completed:

- **Simulated annealing** (the third calibration stage after LHS and GA) has not been run and will not be conducted. Given calibrated models do not outperform the baseline out-of-sample, and parameter identifiability is limited, further local refinement is unlikely to alter this conclusion. This is a deviation from the original calibration pipeline, disclosed here rather than silently omitted.
- **Variance of Absolute Errors (VAE)** and **Median MAE**, specified below as dependent variables, will not be integrated into the analysis pipeline. 

The consolidation pass has since been completed: the LHS sweep and the GA calibration were re-run on corrected code. The GA search bounds were re-derived per design cell from the sweep, and the calibrated parameter sets were evaluated on the 12 held out debates, having been calibrated on the remaining 43. No further action on the social influence models is planned. GA search bounds were derived differently from the registered plan; see Model Calibration.

The argumentation model (H6) has not yet been implemented or tested and remains the prospective, confirmatory component of this registration.

The code and data will be deposited upon completion of the analysis.

H5's registered comparison (ABM vs a global multilevel model) is not yet implemented; its specification is given in the decision rules above. The existing comparison ranks ABM variants against one another and is planned as a next step before H6.

# Methods

The study protocol was registered on OSF before the analysis of the data collected by Dheilly et al. (unpublished), with the exception of the retrospective components disclosed in "Analysis Status at Registration" above. Deviations from the registered protocol are described and reported inline above.

## Design

To contextualize what data are used from Dheilly et al. (unpublished), the structure of the experimental design is described below:

- **T0**: Participants are initially recruited through an advertisement and filled out a questionnaire that collected data on attitudes, intentions, self-declared diet and demographics characteristics. They also received an informational sheet describing the study and were asked to provide informed consent.
- **T1**: Participants were invited to take part in an online consultation (debate) and viewed a video summing up the information document. They were then split into 3 groups (detailed below) and filled out a pre-deliberation questionnaire on attitudes and intentions.
  - heterogeneous: made up of pro and contra participants,
  - homogeneous: only made up of contra or pro participants,
  - private deliberation: the participant is the only member of the debate
- **T2**: Following the online consultation participants filled out a questionnaire that collected attitudes, and responses related to a meat consumption reduction challenge.
- **T3**: Participants complete a questionnaire that collected attitudes toward meat consumption and how they perceived the study.

**Note on private deliberation**: the private deliberation condition is excluded from the H3/H5/H6 analyses reported in this protocol, as it functions as a control condition (no interaction, hence no expected interaction-driven attitude change) rather than a test of the interaction-driven mechanisms these hypotheses target.

### Metrics and Comparison

This section describes the metrics as originally specified. Where a metric was not implemented or was implemented differently, this is noted inline.

The chosen metric to compare predictive capability of regressions, ABMs with integrated social influence models and argumentation dynamics is the mean of absolute error as it is scale-preserving and is commonly used in the validation of stochastic agent-based models (Windrum et al., 2007; Railsback & Grimm, 2019). The secondary metric to assess robustness and compare regression with ABM and augmented ABM is the variance of absolute error [VAE] and was defined in the original protocol as a measure of prediction stability under stochastic interaction dynamics (Lorscheid et al., 2012). It has not been integrated into the current pipeline and is deferred (see Measures). Each ABM configuration was planned to run multiple times with five different random seeds, and performance metrics (e.g., MAE) were averaged across runs. In practice, these were executed with a fixed random seed, so repetitions produced identical output and effective replication is one per parameter-set-by-debate combination. A follow up robustness check with varying seeds is planned (see Model Calibration).

In individual-level regression analyses perceived social norms and self-control are included as predictors to investigate susceptibility to attitude change. For agent-based simulations, individual agents are initialized using only pre-deliberation attitudes so that improvements in predictive performance are the result of interaction dynamics rather than stemming from the addition of individual-difference variables. This approach aligns well with ABM literature that compares model outputs with real data using quantitative error measures and focuses on the evaluation of model structure (Windrum et al., 2007; Railsback & Grimm, 2019).

This paper will make use of R libraries to apply regression techniques to initially characterize the predictive ability of a set of 5 subfactors (called DBFactorXT1) collected in T1 to predict participant attitude post deliberation at T2. The regression methods used are only intended as a predictive benchmark (with regards to MAE estimation) and not to identify causal predictors. The benchmark for H3 and H5 is the multilevel specification given in the decision rules, not a pooled linear regression. 

Using linear regression mean of absolute error [MAE] as a benchmark, 3 models of social influence (inspired by Flache et al., 2017) will be implemented into a multi-agent simulation platform called GAMA (Taillandier et al., 2010). This platform can be tailored to build spatially explicit multi-agent simulations and has been used to model realistic human behavior (Amouroux, Taillandier & Drogoul., 2010; Taillandier et al., 2019; Vu, Gaudou & Oberoi, 2025).

The Gama results will then be analyzed in R to compare the predictive ability of these social influence models compared with linear regression.

Finally, argumentation models (Taillandier et al., 2021) will be implemented in conjunction with the models of social influence in Gama to test the effect of adding argument relations on predictive ability of estimating attitudes at T2. To highlight the differences on a modeling level for social influence models contrasted with argumentation, the latter implies that agents are characterized by a set of attributes (an argument graph) where agents have a list of arguments assigned to them (Dung, 1995). In each agent-agent interaction, one agent randomly selects another agent (uniform distribution) to exchange arguments with. The selection logic of the receiving agent is based on the similarity of the opinions of the two agents (Mäs & Flache, 2013). They select the argument that is most important (according to a measure of strength) to them and "attack" the argument of the other agent. Upon learning a new argument, the oldest argument in the receiving agent's "memory" is forgotten, taking into account the limits of human cognition and memory. Compared to social influence models, agents have an additional characteristic encompassing an argumentation graph that decides how opinions are updated during interactions.

### ABM Implementation

The implementation of the social influence and argumentative models in GAMA is characterized by describing who the agents are, what their state variables include, the interaction dynamics and how the simulation differs between conditions. The virtual agents initialized in GAMA for each debate represent the actual participants who attended the debates. Each individual is embedded in a debate with others according to their experimental condition. This represents a nested format of debates that must be taken into consideration when running batch simulations and subsequently analysing the data. At a minimum, agents are initialized with 5 subfactors that constitute an initial pre-deliberation attitude from previously gathered survey data. Agents interact with all other agents in a specific debate; a fully connected network. Opinion similarity moderates whether an interaction results in influence in clustering and bipolarization models, where an agent is influenced only if the neighbor's opinion falls within the confidence threshold, and repelled if it exceeds the repulsion threshold. These rules of engagement are defined according to the models of social influence defined in Flache et al. (2017).

Speaking mode switches three model properties simultaneously, the turn-based versus parallel scheduling, cognitive fatigue on versus off (retention discount applies only in the speaker path), and influence dose (one influence per listener per cycle versus N-1). These are not separated in the present design so any outcome difference is attributable to their combination. The speaking and non-speaking mechanisms are therefore reported as separate model variants rather than levels of a factor; no main effect of speaking mode is interpreted.

#### Parameter Ranges

Full parameter ranges are provided in the ODD protocol.

**Parameter Adjustment Note (finalized, based on 04/08/26 LHS/GA analysis)**: exploratory analysis identified two findings not yet reflected in the confirmatory parameter space: 
(1) heterogeneous per-agent parameterization (`use_distinct_agents` = TRUE, i.e. agents draw parameter values from a distribution around a base value with an associated SD, rather than sharing one fixed value) suggested that it could outperform homogeneous parameterization across the three models. This rested on a diagnostic which compared sweeps over parameter spaces of differing dimensionality and is not a sound basis for fixing the factor. Both arms were thus retained as design cells in the final run. Sensitivity analysis on the final sweep indicates that the magnitude of agent heterogeneity has a negligible effect on MAE. The presence of heterogeneity is however associated with a small improvement - the two are reported separately.

(2) `confidence_threshold` and `repulsion_threshold` are currently defined as single, model-wide ranges applied identically regardless of an agent's pro- or anti-reduction stance. Exploratory valence analysis showed a systematic anti-reduction bias, where the models under-predict movement toward reduced meat consumption relative to movement away from it. This analysis was affected by a type-coercion fault which filtered the relevant rows to zero and has been corrected. It still requires re-derivation before it can be relied upon. If it holds, the asymmetry is not representable under the current single-range parameterization.

(3) The ranges were initially specified as standardized across models, however in the final run this no longer holds. The GA search bounds were derived per design cell from the LHS sweep. `confidence_threshold` bounds were searched over [0.1, 0.35] for non-speaking clustering, [0.1, 0.6] for speaking clustering and [0.1, 0.3] for bipolarization. Cross-model comparison is thus partly confounded with search range and is reported with that caveat.

## Data

Previously collected survey responses and debate transcriptions will be used, no additional data will be collected. Although data were previously collected, no confirmatory hypothesis test has been conducted on them. Outcome variables were accessed during the retrospective calibration and exploratory work disclosed in "Analysis Status at Registration". The argumentation model (H6) has not been implemented and no outcome data have been examined in relation to it.

The list of participant characteristics and data to be extracted includes:

- Demographics: Age, gender, ID, ID_Group_all, Education
- Attitudes: DBFactor1-5T0, DBFactor1-5T1, DBFactor1-5T2, DBIndexT0, DBIndexT1, DBIndexT2 
- Meat consumption reduction: perceived_norms, self_control, environmental_prepotency, perceived_control, Pro_reduction, Attention_failed
- Reduction variables: Red/Processed/Poultry_reduction

The names of these variables are treated in R with the `janitor` package to snake_case.

**Data sources by level of analysis**:
- **Agent level** (H1a, H1b, H2, H3a, individual-participant error): `agent_level` — one row per individual agent per debate per run.
- **Debate level** (H3b, H4a, H4b): `df_batch` grouped by `model_type` + `selected_debate_id`.
- **Global level** (H5, H6, RQ1): `df_batch` grouped by `model_type` only, as already implemented in `model_comparison_main`/`model_comparison_relative`.
- **Interaction-level detail** (supporting/diagnostic, e.g. network construction, valence dynamics): `interaction_log`, one row per individual agent-agent interaction.

## Measures

Independent variables: DBFactor1-5T1, DBIndexT1, demographic variables, perceived norms, self control

Dependent variables: DBFactor1-5T2, **MAE** (primary reported metric), parameters of simulations (for social influence and argumentation models). Mean signed error and accuracy asymmetry (pro vs. anti directional bias), as already computed in the existing valence analysis pipeline, are retained as descriptive/exploratory measures.

Empirical change scores divide the empirical DB_Index difference by 12 rather than 6 as the index spans 12 units. Initial attitude extremity (`opinion_strength`) measures distance from the raw empirical scale's neutral point of 0 rather than from 0.5. All empirical change magnitudes are half of those previously reported and H2's moderation term is not comparable across the two specifications.

**Deferred to future work** (not integrated into the current pipeline; each is a candidate for a later, separately-scoped analysis rather than a commitment for this registration):
- Variance of Absolute Errors and Median MAE — specified in the original protocol as secondary metrics, not yet integrated.
- Skewness of signed error and MAD of absolute error — considered as additional exploratory sensitivity targets, but not adopted here: with the current per-debate sample sizes, skewness estimates are likely unstable, and neither is yet implemented or validated in the R pipeline. The existing mean-signed-error/accuracy-asymmetry measures already capture directional bias descriptively without this added risk.
- Pro/anti asymmetric parameterization in the social-influence GAML models (see Parameter Adjustment Note above) — deferred given the scope of required GAML and R changes relative to an incompletely documented pipeline.
- Simulated annealing (see Analysis Status above).
- A likelihood-based parameter calibration approach (e.g., treating the existing GA objective as a pseudo-likelihood, or a full Bayesian/ABC approach) — considered but deferred given time constraints and the already-established conclusion that social-influence models do not beat the no-change baseline.

## Planned Analyses

The planned analyses for this protocol follow a logical structure:

- First, T1 attitudes will be regressed linearly to predict T2 attitudes (establishing a benchmark for simulation).
- Second, models of social influence (Flache et al., 2017) will be implemented into GAMA to analyze how well these models predict T2 attitudes. These will subsequently be analyzed using R and the metrics mentioned above to determine the predictive capacity of each model on the individual, debate, and global level. *(Substantially conducted prior to registration; see Analysis Status.)*
- Third, argumentation models will be implemented into GAMA to further contextualize how argumentation dynamics can be combined with social influence models. This has the goal of understanding to what extent argumentation models predict T2 attitudes relative to linear regression and simple models of social influence. *(Prospective, confirmatory — not yet conducted.)*

### Model Calibration

For each step of the design structure involving regression and Gama, the model will be calibrated on 43 of the 55 available debates then validated on the remaining 12. The data split was made prior to any calibration and stratified by debate type to ensure a broader data split considered by the initial calibration model.

Initial calibration to determine appropriate parameter ranges will be done using latin hypercube sampling [LHS] with 200 samples to allow for an unbiased exploration of the parameter space as well as comparability across the different experiments that use a varying number of parameters (ranging from 1 to 8 parameters). This is further supported by exceeding the sample sizes reported in comparable ABM sensitivity analyses (Thiele et al., 2014). Five simulation repetitions per parameter set will be used, consistent with the idea of selecting sufficient repetitions to stabilise model output rather than applying a fixed default (Thiele et al.; Lorscheid et al., 2012) and to avoid premature convergence on local optima. LHS is implemented using GAMA's internal latin hypercube sampler rather than externally generating samples due to a more simplified analysis pipeline.

As an addendum to the above paragraph, in practice the batch experiments ran with `keep_seed: true` for exact reproducibility. This holds the RNG state constant across repetitions, so effective replication is one per parameter-set-by-debate combination. Seed replication is flagged as a planned robustness check.

Following this, a genetic algorithm [GA] is implemented in Gama, to refine the exploration of the parameter space. The bounds used in the GA were to be defined through the initial LHS exploration, defined as parameter combinations that fall within the bottom 25th percentile of MAE. The 25th percentile was chosen to allow for a broader promising region to identify the optimum. The algorithm minimises the unweighted mean of per-debate MAE across calibration debates, matching H3b's debate-level framing. An earlier implementation minimised a variable that resets each debate which has since been corrected.

These were computed as planned but returned the full searched range for every parameter in every design cell. This can be explained because between-debate variation in MAE exceeds the between-parameter variation. The envelope alone did thus not give a basis for narrowing the ranges. The bounds were therefore taken as the union of the random-forest partial dependence surface within tolerance of its minimum and the envelope, which was computed per design cell on debate-centered MAE. When a parameter's partial dependence amplitude was negligible relative to debate-level MAE standard deviation, it was treated as unidentified and retained its unchanged LHS range.

As a result, only two parameters were narrowed: `repulsion_threshold` in bipolarization from [0.4, 0.7] to [0.55, 0.7], and `confidence_threshold` in non-speaking clustering, from [0.1, 0.6] to [0.1, 0.35]. Step values differ by parameter since GAMA's genetic algorithm searches an enumerated space and a `min` and `max` alone would only evaluate the interval endpoints. Steps were fixed as a fraction of each range, resulting in 11-26 admissible values per dimension so that the granularity is comparable across parameters of differing scale: `convergence_rate` 0.005, `confidence_threshold` 0.01-0.02, `repulsion_threshold` 0.01, `repulsion_strength` 0.01. The standard deviation parameters had a step of 0.002-0.005. 

Next, we will use simulated annealing within the bounds identified by the GA to refine the solution to a specific optimum. **`[Not conducted — see deviation note in Analysis Status above.]`** This approach was originally intended to complement the previous two approaches: LHS ensures unbiased coverage of the global parameter space, GA explores this refined parameter space to avoid premature convergence on local optima, and simulated annealing specifies it further to a local optimum (Kirkpatrick et al., 1983; Thiele et al., 2014).

# Ethics

According to French law, this study does not require the need for evaluation of an ethical committee. The data used in this study were previously collected by Dheilly et al. (unpublished) and the protocol for data collection was reviewed and approved by the Paris-Saclay University Ethics Committee (file number 608). Further, the data used was anonymized prior to any planning and analysis performed in this study.

# Expected Results

The results of this experiment will analyze the predictive capability of models of social influence and argumentation grounded in academic literature to test whether their implementation using ABM can more accurately predict attitude change in group deliberation for reducing meat consumption. Furthermore, the results will provide insight into the underlying mechanisms potentially driving attitude change in group deliberation.

# Insights and Perspectives

This study will contribute to the literature in the domain of nutrition as well as multi-agent simulations through an interdisciplinary approach; modeling behaviors in debate settings related to the reduction of meat consumption. Further this study aims to categorize and identify emerging behaviors related to social influence by illustrating the predictive capability of common statistical methods (i.e. OLS regressions), simple models of social influence, and an augmentation with argumentation dynamics.

# References

- Amouroux, E., Taillandier, P., & Drogoul, A. (2010). Complex environment representation in epidemiology ABM: application on H5N1 propagation. *ICTACS*.
- Bächtiger, A., Dryzek, J. S., Mansbridge, J., & Warren, M. E. (2018). Deliberative democracy: An introduction. In A. Bächtiger, J. S. Dryzek, M. E. Warren, & J. Mansbridge (Eds.), *The Oxford handbook of deliberative democracy* (pp. 1–34). Oxford University Press.
- Brachem, J., Krüdewagen, H., & Hagmayer, Y. (2019). *The limits of nudging: Can descriptive social norms be used to reduce meat consumption? It's probably not that easy.*
- Çoker, E. N., Pechey, R., Frie, K., Jebb, S. A., Stewart, C., Higgs, S., & Cook, B. (2022). A dynamic social norm messaging intervention to reduce meat consumption: A randomized cross-over trial in retail store restaurants. *Appetite*, 169, 105824.
- Colin-Jaeger, N., & Dold, M. (2025). Individual autonomy and public deliberation in behavioral public policy. *Humanities and Social Sciences Communications*, 12, 430. https://doi.org/10.1057/s41599-025-04708-z
- Convention Citoyenne pour le Climat. (2021, 14 juin). *Site officiel de la Convention Citoyenne pour le Climat.* https://www.conventioncitoyennepourleclimat.fr/
- Crutzen, R., & Peters, G.-J. Y. (2023). The regression trap: why regression analyses are not suitable for selecting determinants to target in behavior change interventions. *Health Psychology and Behavioral Medicine*, 11(1), 2268684. https://doi.org/10.1080/21642850.2023.2268684
- Cruwys, T., Bevelander, K. E., & Hermans, R. C. (2015). Social modeling of eating: a review of when and why social influence affects food intake and choice. *Appetite*, 86, 3–18.
- Dung, P. M. (1995). On the acceptability of arguments and its fundamental role in nonmonotonic reasoning, logic programming and n-person games. *Artificial Intelligence*, 77, 321–357.
- European Commission. (2024). *France – Final updated NECP 2021–2030.* France.
- Flache, A., Mäs, M., Feliciani, T., Chattoe-Brown, E., Deffuant, G., Huet, S., & Lorenz, J. (2017). Models of social influence: Towards the next frontiers. *Journal of Artificial Societies and Social Simulation*, 20(4), 2.
- Forouzanfar, M. H., Alexander, L., Anderson, H. R., Bachman, V. F., Biryukov, S., Brauer, M., … Cohen, A. (2015). Global, regional, and national comparative risk assessment of 79 behavioural, environmental and occupational, and metabolic risks or clusters of risks in 188 countries, 1990–2013: a systematic analysis for the Global Burden of Disease Study 2013. *The Lancet*, 386(10010), 2287–2323.
- Garnett, T. (2008). *Cooking up a storm: Food, greenhouse gas emissions and our changing climate.* Food Climate Research Network, Centre for Environmental Strategy, University of Surrey.
- Guest, O., & Martin, A. E. (2021). How computational modeling can force theory building in psychological science. *Perspectives on Psychological Science*, 16(4), 789–802.
- Higgs, S. (2015). Social norms and their influence on eating behaviours. *Appetite*, 86, 38–44.
- Jung, J., Miller, J. H., & Page, S. E. (2025). Agent-based modeling for psychological research on social phenomena. *American Psychologist*.
- Kirkpatrick, S., Gelatt, C. D., & Vecchi, M. P. (1983). Optimization by simulated annealing. *Science*, 220(4598), 671–680.
- Lin, H., de Barcellos, M. D., & De Steur, H. (2025). The role of nudges in food choices: An umbrella review. *Food Quality and Preference*, 105679.
- Lorscheid, I., Heine, B. O., & Meyer, M. (2012). Opening the 'black box' of simulations: increased transparency and effective communication through the systematic design of experiments. *Computational and Mathematical Organization Theory*, 18(1), 22–62.
- MacCoun, R. J. (2017). Computational models of social influence and collective behavior. In *Computational social psychology* (pp. 258–280). Routledge.
- Mäs, M., & Flache, A. (2013). Differentiation without distancing: explaining bi-polarization of opinions without negative influence. *PLoS ONE*, 8(11), e74516. https://doi.org/10.1371/journal.pone.0074516
- Miller, J. H., & Page, S. E. (2009). *Complex adaptive systems: An introduction to computational models of social life.* Princeton University Press.
- Niemeyer, S. (2011). The emancipatory effect of deliberation: Empirical lessons from mini-publics. *Politics & Society*, 39(1), 103–140.
- Niemeyer, S., Veri, F., Dryzek, J. S., & Bächtiger, A. (2024). How deliberation happens: enabling deliberative reason. *American Political Science Review*, 118(1), 345–362.
- OECD. (2025). *The Paris Agreement at ten years: Expert views on progress and challenges for climate change mitigation.* OECD Publishing, Paris. https://doi.org/10.1787/c5f214dc-en
- Peters, G.-J. Y., & Crutzen, R. (2018). Establishing determinant importance using CIBER: an introduction and tutorial. *The European Health Psychologist*, 20(3), 484–494.
- Pollicino, D., Zamzow, H., Shreedhar, G., Galizzi, M. M., Naci, H., & Freitag, P. (2025). Can social norms promote sustainable food consumption? A systematic review. *Social Influence*, 20(1). https://doi.org/10.1080/15534510.2025.2497341
- Railsback, S. F., & Grimm, V. (2019). *Agent-based and individual-based modeling: A practical introduction.* Princeton University Press.
- Rockström, J., Thilsted, S. H., Willett, W. C., Gordon, L. J., Herrero, M., Hicks, C. C., … DeClerck, F. (2025). The EAT–Lancet Commission on healthy, sustainable, and just food systems. *The Lancet*, 406(10512), 1625–1700.
- Schäufele-Elbers, I., Bosnjak, M., Gastaldello, G., & Schamel, G. (2025). Nudging meat off the plate in foodservice? A systematic review and meta-analysis identifying moderators in field-based intervention studies. *Journal of Environmental Psychology*, 108, 102830.
- Schebesta, H., & Candel, J. J. (2020). Game-changing potential of the EU's Farm to Fork Strategy. *Nature Food*, 1(10), 586–588.
- Springmann, M., Godfray, H. C. J., Rayner, M., & Scarborough, P. (2016). Analysis and valuation of the health and climate change cobenefits of dietary change. *Proceedings of the National Academy of Sciences*, 113(15), 4146–4151. https://doi.org/10.1073/pnas.1523119113
- Steinfeld, H., Gerber, P., Wassenaar, T. D., Castel, V., & de Haan, C. (2006). *Livestock's long shadow: Environmental issues and options.* Food and Agriculture Organization of the United Nations.
- Taillandier, P., Vo, D. A., Amouroux, E., & Drogoul, A. (2010). GAMA: a simulation platform that integrates geographical information data, agent-based modeling and multi-scale control. In *International Conference on Principles and Practice of Multi-Agent Systems* (pp. 242–258). Springer.
- Taillandier, P., Grignard, A., Marilleau, N., Philippon, D., Huynh, Q. N., Gaudou, B., & Drogoul, A. (2019). Participatory modeling and simulation with the GAMA platform. *Journal of Artificial Societies and Social Simulation*, 22(2).
- Taillandier, P., Salliou, N., & Thomopoulos, R. (2021). Introducing the argumentation framework within agent-based models to better simulate agents' cognition in opinion dynamics: Application to vegetarian diet diffusion.
- Thiele, J. C., Kurth, W., & Grimm, V. (2014). Facilitating parameter estimation and sensitivity analysis of agent-based models: A cookbook using NetLogo and R. *Journal of Artificial Societies and Social Simulation*, 17(3), 11.
- Vermeulen, S. J., Campbell, B. M., & Ingram, J. S. I. (2012). Climate change and food systems. *Annual Review of Environment and Resources*, 37, 195–222.
- Vu, T. D., Gaudou, B., & Oberoi, K. S. (2025). Modeling realistic human behavior using generative agents in a multimodal transport system: Software architecture and application to Toulouse. *arXiv preprint* arXiv:2510.19497.
- Windrum, P., Fagiolo, G., & Moneta, A. (2007). Empirical validation of agent-based models: Alternatives and prospects. *Journal of Artificial Societies and Social Simulation*, 10(2), 8.
