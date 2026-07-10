# Research Context and Motivation

Choices regarding what we eat have a profound impact on the world around us, for example on our health (Springmann et al., 2016; Forouzanfar et al., 2015) and the environment (Garnett., 2008; Vermeulen et al., 2012). Notably, the food system accounts for more than a quarter of greenhouse gas emissions (GHG), where 80% of these emissions are attributed to livestock production (Steinfeld et al., 2006). Reducing these emissions to meet national (European Commission., 2024) and international commitments (OECD, 2025) implies reducing red meat consumption and diet change (Rockström et al., 2025; Schebesta & Candel., 2020).

To encourage this behavioral change, investigating how and with whom we eat could provide valuable insights (Cruwys et al., 2015; Higgs., 2015). Existing research in social sciences has increasingly focused on the use of social norms (Pollicino et al., 2025; Çoker et al., 2022) and nudges (Schäufele-Elbers et al., 2025) to shift eating behavior in social settings and encourage engaging in pro-environmental behaviors. These interventions however, often have mixed or little effects (Lin et al., 2025; Pollicini et al., 2025; Brachem et al., 2019), highlighting the possibility of investigating other methods of encouraging behavioral change.

One possibility is to consider deliberation in the context of meat consumption reduction. Drawing on the definition of Bächtiger et al. (2018) deliberation involves people coming together, viewed as equals and with mutual respect, to discuss political and societal issues; such discussions inform collective decisions that will affect their lives. Core functions of such deliberative mechanisms include transparency and accountability, reduction of cognitive burden and enhancement of cognitive abilities (Niemeyer et al., 2024).

An extension of the deliberation definition is "mini-publics" (Niemeyer, 2011) where experts and the public meet to discuss issues and reach a consensus. These mini-publics have been applied to broader contexts involving diverse populations such as the French Citizen's Convention for Climate [CCC] (Convention Citoyenne pour le Climat, 2021). The increasingly broad use of mini-publics coupled with the fact that this kind of deliberation has a transformative effect which facilitates the "view from manywhere" (Niemeyer et al., 2024) highlights the potential for individuals to confront alternative perspectives and reflect on shared values and social expectations.

The reflective process of deliberation in a public setting is particularly relevant to embedded social practices such as meat consumption as it is influenced by individual preferences as well as shared norms. Colin-Jaeger (2025) illustrates this through his investigation of how individuals from diverse backgrounds are invited to critically reflect on shared values, norms and the consequences of their everyday choices. This creates conditions under which the existing behavioral and consumption norms can be questioned and potentially revised.

A study by Dheilly et al. (unpublished) looked into this through a cluster-randomized study using deliberation as a means to better understand the mechanisms by which information is diffused in a social setting relating to meat consumption reduction. This could help encourage a shift to more sustainable eating behavior in line with the recommendations of Eat Lancet (Rockström et al., 2025), improving human wellbeing and contributing to the stability of the earth system.

To analyze attitudes and the predictors for the evolution of these attitudes (what motivates behavioral change), it is conceivable to use regression analyses as they help understand what proportion of variance in the outcome of interest (e.g., attitudes and behavioral change) is explained by which predictors (Peters & Crutzen, 2018). Despite the frequent use of these analyses it is not always justified to use them to establish predictors to target in future behavior change interventions (Crutzen & Peters, 2023) as the regressions assume that the overlap between predictors is removed from the equation. In practice this implies that when performing a regression with two predictors that have some overlap in their definition (e.g., depressive mood and suicidal thoughts), evaluating the impact of the regression for one predictor with ceteris paribus neglects part of the construct, thus invalidating it (Peters & Crutzen, 2018). Thus, this paper uses regression as an initial benchmark from which to improve upon.

In the context of the current group debates, it is conceivable to use Agent Based Modelling [ABM] to study the behavioral mechanisms and underlying societal phenomena as it can analyze how individual actions and interactions generate macro-level patterns, which impact behaviors (Miller & Page, 2009). ABM cannot however be used to test behaviors directly (MacCoun, 2017), instead focussing on predicting patterns that would emerge given certain behaviors were followed (Jung, Miller & Page, 2025). Furthermore, ABM has the ability to generate theories of complex social systems using computational modelling (Guest & Martin, 2021). ABM thus lends itself well to the investigation of social influences and group dynamics in debates targeted toward the reduction of meat consumption.

This study analyzes previously collected survey and debate data including demographic characteristics and attitudes regarding meat consumption reduction. It combines empirical analysis of this data through linear regression with multi-agent simulations implemented in Gama. The simulations are exploratory and systematically vary parameters of the social influence models (Flache et al., 2017). The simulations using social influence models will then be augmented using argumentation models to test the predictive capability of introducing more complex models of interactions between agents (notably through argument graphs and attack and defense relations). This study is innovative as it contributes to existing literature by identifying and investigating mechanisms potentially compatible with observed empirical patterns, and taking advantage of multidisciplinary modelling and analysis techniques.

Building on this literature, the current study formulates hypotheses on the individual agent level, debate level and global level in addition to the predictive performance of agent based models. This protocol was written in accordance with OSF guidelines and guidelines followed in ABM literature. There is thus an ODD protocol that describes all of the mechanistic functions related to the ABM models.

# Objectives

- Analyze how statistical and simulation methods can predict individual, debate level and global attitudes and attitude change with the goal of understanding the underlying mechanisms of social interactions in the context of meat consumption reduction.

# Hypotheses (3 levels)

## Individual-level hypotheses

Deliberation contexts where individuals can reflect on their individual norms, social expectations and values can interact with pre-existing attitudes toward meat consumption reduction (Bächtiger et al., 2018; Niemeyer et al., 2024; Colin-Jaeger, 2025). Individual self-regulatory capacities and social influences can have an influence on attitude stability and variability in food-related domains (Cruwys et al., 2015; Higgs, 2015). This study thus investigates how pre-deliberation attitudes and individual susceptibility to social influence predict post-deliberation attitude changes.

**H1**: Pre-deliberation attitudes toward meat consumption are expected to be positively associated with post-deliberation attitudes, accounting for a meaningful share of variance independent of debate context (i.e. heterogeneous, homogeneous debates). `[Status: not yet analyzed — prospective]`

**H2**: Individuals with higher perceived social norms and lower self-control will exhibit greater absolute attitude change between pre- and post-deliberation measurement points, moderated by their initial opinion strength. `[Status: not yet analyzed — prospective]`

## Debate-level hypotheses

The shift of attitudes within debates illustrates participant interactions and how micro-level social influence processes are aggregated (Miller & Page., 2009; Flache et al., 2017). Deliberation with diverse viewpoints has been argued to foster reflection and reconsideration of prior positions (Bächtiger et al., 2018; Niemeyer et al., 2024). This section looks into the relation of debate composition and its impact on aggregate changes and whether the predictive capability of debate modeling improves upon simple regression approaches.

**H3**: Agent-based simulations initialized with pre-deliberation attitudes alone will generate a lower mean of absolute error [MAE] predictions of post-deliberation attitudes for individual participants compared with linear regression models using observed predictors alone. `[Status: RETROSPECTIVE — LHS/GA analysis substantially conducted prior to registration; see "Analysis Status at Registration" below. Reported as exploratory, not confirmatory.]`

**H4**: Debates with a heterogeneous composition of participants are expected to exhibit a greater mean attitude change between pre- and post-deliberation attitudes compared with homogeneous debates. `[Status: not yet analyzed — prospective]`

**H5**: Agent-based models initialized with pre-deliberation attitudes will generate lower MAE (and potentially lower Variance of Absolute Errors) predictions of post-deliberation attitudes for individual debates compared with linear regression models initialized with pre-deliberation attitudes alone. `[Status: RETROSPECTIVE — see Analysis Status below.]`

**Note on debate-level vs. global-level analysis (resolved)**: "debate level" (H3, H5) = metrics grouped by `model_type` **and** `selected_debate_id`; "global level" (H6, H7) = metrics grouped by `model_type` alone (pooling across all debates), as in the existing `model_comparison_main`/`model_comparison_relative` code. `df_batch` (LHS and GA held as separate files) is inherently structured per debate/model/seed, since debates are run under each of the 3 social-influence models — so a debate-level breakdown for H5 requires no new computation, only adding `selected_debate_id` to the existing grouping.

**Data sources by level of analysis**:
- **Agent level** (H1, H2, individual-participant error): `agent_level` — one row per individual agent per debate per run.
- **Debate level** (H3, H5): `df_batch` grouped by `model_type` + `selected_debate_id`.
- **Global level** (H6, H7): `df_batch` grouped by `model_type` only, as already implemented in `model_comparison_main`/`model_comparison_relative`.
- **Interaction-level detail** (supporting/diagnostic, e.g. network construction, valence dynamics): `interaction_log`, one row per individual agent-agent interaction.

This mapping is adopted as the basis for centralizing the analysis pipeline against H1–H7 going forward.

## Global-level dynamics

Cumulative micro-level interactions can help reveal macro-level patterns and help highlight non-linear dynamics not captured by linear regression (MacCoun, 2017; Guest & Martin., 2021). This section investigates whether agent-based modeling calibrated with pre-deliberation data can illustrate global attitude distributions and whether argumentation based modeling adds predictive value.

**H6**: ABMs calibrated with pre-deliberation attitudes should reproduce a global post-deliberation attitude shift toward meat consumption reduction with a lower MAE than a single global regression model. `[Status: RETROSPECTIVE — see Analysis Status below.]`

**RQ1**: Exploratory analyses will examine how variations in optimized model parameters influence global attitude trajectories and convergence patterns. `[Status: exploratory as originally designated; substantially conducted prior to registration — this designation is unchanged by that fact, since RQ1 was never intended as confirmatory.]`

**H7**: Agent-based models upgraded with argumentation mechanisms alongside models of social influence are expected to yield more accurate and stable predictions of global attitude distributions (using MAE) than models only using social influence (Bächtiger et al., 2018; Niemeyer et al., 2024). `[Status: PROSPECTIVE — CONFIRMATORY. Not yet implemented or tested. This is the confirmatory component this registration is intended to protect.]`

Exploratory analyses are pre-specified but not used for confirmatory inference.

# Analysis Status at Registration

Data were made available on [DATE]. This protocol was originally drafted on [DATE]. Prior to formal registration on this platform (submitted [TODAY'S DATE]), the following analyses had already been conducted as part of iterative model development:

- Latin hypercube sampling (200 samples) and genetic algorithm refinement for the three social influence models (consensus, clustering, bipolarization), evaluated on MAE against linear regression and a no-change baseline (relates to H3, H5, H6). **Neither LHS nor GA outperformed the no-change baseline; GA converged toward near-zero predicted opinion change rather than learning genuine debate dynamics.** This result is what motivates progression to the argumentation model (H7).
- Exploratory analysis of parameter sensitivity via partial and semi-partial correlation coefficients (PCC/PRCC) and of convergence patterns (RQ1), consistent with RQ1's original non-confirmatory designation.
- Exploratory valence/directional-bias analysis (not originally specified in this protocol; developed during RQ1) identifying a systematic anti-reduction bias — models under-predict movement toward reduced meat consumption relative to movement away from it — consistent across all three social influence models. This analysis is reported as emergent exploratory work, distinct from RQ1 as originally scoped.

These are reported as **retrospective/exploratory, not confirmatory**, for H3, H5, H6, and RQ1. The following components of the originally registered calibration pipeline have not been completed:

- **Simulated annealing** (the third calibration stage after LHS and GA) has not been run and will not be conducted. Given LHS and GA results already show no social-influence configuration beats the no-change baseline, with GA converging to a degenerate near-zero-change solution, further local refinement via SA is judged unlikely to alter this conclusion. This is a deviation from the original calibration pipeline, disclosed here rather than silently omitted.
- **Variance of Absolute Errors (VAE)** and **Median MAE**, specified below as dependent variables, have not yet been integrated into the analysis pipeline. Both remain planned prior to final reporting of H3/H5/H6.

One further consolidation pass on the existing LHS/GA output is planned: a final rerun correcting known data-pipeline issues (pro/anti agent count columns, valence/signed-error columns) and one further round of LHS/GA with parameter ranges adjusted in light of the valence findings above (see Parameter Adjustment Note below), followed by a chronological walkthrough of the analysis across dataset versions. This pass does not constitute a new confirmatory test — it re-derives and extends already-observed results on corrected data and adjusted ranges for reporting accuracy and completeness, and is the final action taken on social-influence models before proceeding to H7.

The argumentation model (H7) has not yet been implemented or tested and remains the prospective, confirmatory component of this registration.

# Methods

The study protocol was registered on OSF before the analysis of the data collected by Dheilly et al. (unpublished), with the exception of the retrospective components disclosed in "Analysis Status at Registration" above. Deviations from the registered protocol are described and reported in the appendix section and inline above.

## Design

To contextualize what data are used from Dheilly et al. (unpublished), the structure of the experimental design is described below:

- **T0**: Participants are initially recruited through an advertisement and filled out a questionnaire that collected data on attitudes, intentions, self-declared diet and demographics characteristics. They also received an informational sheet describing the study and were asked to provide informed consent.
- **T1**: Participants were invited to take part in an online consultation (debate) and viewed a video summing up the information document. They were then split into 3 groups (detailed below) and filled out a pre-deliberation questionnaire on attitudes and intentions.
  - heterogeneous: made up of pro and contra participants,
  - homogeneous: only made up of contra or pro participants,
  - private deliberation: the participant is the only member of the debate
- **T2**: Following the online consultation participants filled out a questionnaire that collected attitudes, and responses related to a meat consumption reduction challenge.
- **T3**: Participants complete a questionnaire that collected attitudes toward meat consumption and how they perceived the study.

**Note on private deliberation**: the private deliberation condition is excluded from the H3/H5/H6/H7 analyses reported in this protocol, as it functions as a control condition (no interaction, hence no expected interaction-driven attitude change) rather than a test of the interaction-driven mechanisms these hypotheses target.

### Metrics and Comparison

The chosen metric to compare predictive capability of linear regressions, ABMs with integrated social influence models and argumentation dynamics is the mean of absolute error as it is scale-preserving and is commonly used in the validation of stochastic agent-based models (Windrum et al., 2007; Railsback & Grimm, 2019). The secondary metric to assess robustness and compare regression with ABM and augmented ABM is the variance of absolute error [VAE]. This is used to examine error across repeated simulation runs and can be used as a measure of stability of model predictions in stochastic interaction dynamics (Lorscheid et al., 2012). Each ABM configuration was run multiple times with five different random seeds, and performance metrics (e.g., MAE and variance of absolute errors) were averaged across runs.

- Could reference this for other metrics: https://www.jasss.org/18/4/4.html

In individual-level regression analyses perceived social norms and self-control are included as predictors to investigate susceptibility to attitude change. For agent-based simulations, individual agents are initialized using only pre-deliberation attitudes so that improvements in predictive performance are the result of interaction dynamics rather than stemming from the addition of individual-difference variables. This approach aligns well with ABM literature that compares model outputs with real data using quantitative error measures and focuses on the evaluation of model structure (Windrum et al., 2007; Railsback & Grimm, 2019).

This paper will make use of R libraries to apply linear regression techniques to initially characterize the predictive ability of a set of 5 subfactors (called DBFactorXT1) collected in T1 to predict participant attitude post deliberation at T2. The regression methods used are only intended as a predictive benchmark (with regards to MAE estimation) and not to identify causal predictors.

Using linear regression mean of absolute error [MAE] as a benchmark, 3 models of social influence (inspired by Flache et al., 2017) will be implemented into a multi-agent simulation platform called GAMA (Taillandier et al., 2010). This platform can be tailored to build spatially explicit multi-agent simulations and has been used to model realistic human behavior (Amouroux, Taillandier & Drogoul., 2010; Taillandier et al., 2019; Vu, Gaudou & Oberoi., 2025).

The Gama results will then be analyzed in R to compare the predictive ability of these social influence models compared with linear regression.

Finally, argumentation models (Taillandier et al., 2021) will be implemented in conjunction with the models of social influence in Gama to test the effect of adding argument relations on predictive ability of estimating attitudes at T2. To highlight the differences on a modeling level for social influence models contrasted with argumentation, the latter implies that agents are characterized by a set of attributes (an argument graph) where agents have a list of arguments assigned to them (Dung, 1995). In each agent-agent interaction, one agent randomly selects another agent (uniform distribution) to exchange arguments with. The selection logic of the receiving agent is based on the similarity of the opinions of the two agents (Mäs & Flache., 2013). They select the argument that is most important (according to a measure of strength) to them and "attack" the argument of the other agent. Upon learning a new argument, the oldest argument in the receiving agent's "memory" is forgotten, taking into account the limits of human cognition and memory. Compared to social influence models, agents have an additional characteristic encompassing an argumentation graph that decides how opinions are updated during interactions.

### ABM Implementation

The implementation of the social influence and argumentative models in GAMA is characterized by describing who the agents are, what their state variables include, the interaction dynamics and how the simulation differs between conditions. The virtual agents initialized in GAMA for each debate represent the actual participants who attended the debates. Each individual is embedded in a debate with others according to their experimental condition. This represents a nested format of debates that must be taken into consideration when running batch simulations and subsequently analysing the data. At a minimum, agents are initialized with 5 subfactors that constitute an initial pre-deliberation attitude from previously gathered survey data. Agents interact with their neighbors, defined as agents in their vicinity based on how similar their opinion is to one another. This is moderated in the social influence models of clustering and bipolarization where agents interact if the opinion of their neighbor(s) is above the attraction threshold and below the repulsion threshold. These rules of engagement are defined according to the models of social influence defined in Flache et al. (2017).

#### Parameter Ranges

Full parameter ranges are provided in the ODD protocol (see Appendix X). These ranges were standardized across models to ensure cross-model comparability, except bipolarization models where the confidence threshold range is constrained below the repulsion threshold to ensure model validity.

**Parameter Adjustment Note (finalized, based on 04/06/26 LHS/GA analysis)**: exploratory analysis identified two findings not yet reflected in the confirmatory parameter space: (1) heterogeneous per-agent parameterization (`use_distinct_agents` = TRUE, i.e. agents draw parameter values from a distribution around a base value with an associated SD, rather than sharing one fixed value) consistently outperforms homogeneous parameterization across all three models, and is therefore fixed as TRUE for the final run rather than left as a free/compared factor; (2) `confidence_threshold` and `repulsion_threshold` are currently defined as single, model-wide ranges applied identically regardless of an agent's pro- or anti-reduction stance, despite exploratory valence analysis showing a systematic anti-reduction bias — the models under-predict movement toward reduced meat consumption relative to movement away from it. This asymmetry is not representable under the current single-range parameterization.

The final social-influence run will therefore split `confidence_threshold`, `repulsion_threshold`, and `convergence_rate` into separate pro- and anti-agent ranges (e.g. `confidence_threshold_pro`/`confidence_threshold_anti`), initialized around the existing top-25%-LHS bounds but allowed to diverge, so that any pro/anti asymmetry in influence dynamics can be expressed and tested rather than averaged away. This requires (a) GAML changes to declare and assign the split parameters per agent type at initialization, and (b) R changes to `generate_gaml_bounds` (to emit asymmetric bounds) and `apply_batch_mutations`/`conv_cols` (already carrying `pro_count`/`anti_count`, extended to carry the split parameter columns). This is disclosed prospectively here as a one-time, final adjustment motivated by already-observed exploratory patterns; it is reported as exploratory/RQ1-adjacent regardless of outcome, is run once, and is the last modification made to the social-influence parameter space before proceeding to H7.

## Data

Previously collected survey responses and debate transcriptions will be used, no additional data will be collected. Although data were previously collected, the authors had no access to outcome variables or distributions prior to preregistration, with the exception of the retrospective analyses disclosed above.

The list of participant characteristics and data to be extracted includes:

- Demographics: Age, gender, ID, ID_Group_all, Education
- Attitudes: DBFactor1-5T1, DBFactor1-5T2, DBIndexT1, DBIndexT2, initial_opinion, final_opinion
- Meat consumption reduction: perceived_norms, self_control, environmental_prepotency, perceived_control, Pro_reduction, Attention_failed
- Reduction variables: Red/Processed/Poultry_reduction

## Measures

Independent variables: DBFactor1-5T1, demographic variables, perceived norms, self control

Dependent variables: DBFactor1-5T2, **MAE** (primary reported metric), parameters of simulations (for social influence and argumentation models). Mean signed error and accuracy asymmetry (pro vs. anti directional bias), as already computed in the existing valence analysis pipeline, are retained as descriptive/exploratory measures.

**Deferred to future work** (not integrated into the current pipeline; each is a candidate for a later, separately-scoped analysis rather than a commitment for this registration):
- Variance of Absolute Errors and Median MAE — specified in the original protocol as secondary metrics, not yet integrated.
- Skewness of signed error and MAD of absolute error — considered as additional exploratory sensitivity targets, but not adopted here: with the current per-debate sample sizes, skewness estimates are likely unstable, and neither is yet implemented or validated in the R pipeline. The existing mean-signed-error/accuracy-asymmetry measures already capture directional bias descriptively without this added risk.
- Pro/anti asymmetric parameterization in the social-influence GAML models (see Parameter Adjustment Note above) — deferred given the scope of required GAML and R changes relative to an incompletely documented pipeline.
- Simulated annealing (see Analysis Status above).
- A likelihood-based parameter calibration approach (e.g., treating the existing GA objective as a pseudo-likelihood, or a full Bayesian/ABC approach) — considered but deferred given time constraints and the already-established conclusion that social-influence models do not beat the no-change baseline.

This deferral list is treated as provisional pending review with [advisor] in early [week/date], at which point it may be revisited as a dated amendment rather than a rewrite of this registration.

## Planned Analyses

The planned analyses for this protocol follow a logical structure:

- First, T1 attitudes will be regressed linearly to predict T2 attitudes (establishing a benchmark for simulation).
- Second, models of social influence (Flache et al., 2017) will be implemented into GAMA to analyze how well these models predict T2 attitudes. These will subsequently be analyzed using R and the metrics mentioned above to determine the predictive capacity of each model on the individual, debate, and global level. *(Substantially conducted prior to registration; see Analysis Status.)*
- Third, argumentation models will be implemented into GAMA to further contextualize how argumentation dynamics can be combined with social influence models. This has the goal of understanding to what extent argumentation models predict T2 attitudes relative to linear regression and simple models of social influence. *(Prospective, confirmatory — not yet conducted.)*

### Model Calibration

For each step of the design structure involving regression and Gama, the model will be calibrated using 80% of the available debates then validated on the remaining 20% of debates. The data split will be randomized and stratified by debate type to ensure a broader data split considered by the initial calibration model.

Our calibration process resembles the query-based model exploration [QBME] paradigm described by Stonedahl and Wilensky (2011), whereby the emergent behavior to look for are specified and sampling methods are used to identify parameter sets that reproduce them.

Initial calibration to determine appropriate parameter ranges will be done using latin hypercube sampling [LHS] with 200 samples to allow for an unbiased exploration of the parameter space as well as comparability across the different experiments that use a varying number of parameters (ranging from 2 to 8 parameters). This is further supported by exceeding the sample sizes reported in comparable ABM sensitivity analyses (Thiele et al., 2014). Five simulation repetitions per parameter set will be used, consistent with the idea of selecting sufficient repetitions to stabilise model output rather than applying a fixed default (Thiele et al.; Lorscheid et al., 2012) and to avoid premature convergence on local optima. LHS is implemented using GAMA's internal latin hypercube sampler rather than externally generating samples due to a more simplified analysis pipeline.

Following this, we will use a genetic algorithm [GA] implemented in Gama, to refine the exploration of the parameter space. The bounds used in the GA will be defined through the initial LHS exploration, defined as parameter combinations that fall within the bottom 25th percentile of MAE. The 25th percentile is chosen to allow for a broader promising region to identify the optimum.

Next, we will use simulated annealing within the bounds identified by the GA to refine the solution to a specific optimum. **`[Not conducted — see deviation note in Analysis Status above.]`** This approach was originally intended to complement the previous two approaches: LHS ensures unbiased coverage of the global parameter space, GA explores this refined parameter space to avoid premature convergence on local optima, and simulated annealing specifies it further to a local optimum (Kirkpatrick et al., 1983; Thiele et al., 2014).

# Ethics

According to French law, this study does not require the need for evaluation of an ethical committee. The data used in this study were previously collected by Dheilly et al. (unpublished) and the protocol for data collection was reviewed and approved by the Paris-Saclay University Ethics Committee (file number 608). Further, the data used was anonymized prior to any planning and analysis performed in this study.

# Expected Results

The results of this experiment will analyze the predictive capability of models of social influence and argumentation grounded in academic literature to test whether their implementation using ABM can more accurately predict attitude change in group deliberation for reducing meat consumption. Furthermore, the results will provide insight into the underlying mechanisms potentially driving attitude change in group deliberation.

# Insights and Perspectives

This study will contribute to the literature in the domain of nutrition as well as multi-agent simulations through an interdisciplinary approach; modeling behaviors in debate settings related to the reduction of meat consumption. Further this study aims to categorize and identify emerging behaviors related to social influence by illustrating the predictive capability of common statistical methods (i.e. OLS regressions), simple models of social influence, and an augmentation with argumentation dynamics.
