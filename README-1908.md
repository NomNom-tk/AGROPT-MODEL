# README for the SIMBA project (Simulating Online DeBAtes)
This repository is complementary to the OSF project registration concerning the simulation of online debates for meat consumption reduction.

# Context
Studying food decision making is particularly interesting in the context of meat consumption reduction as it creates GHG emissions that are linked to livestock production (Steinfeld et al., 2006). Reducing these emissions to meet national (European Commission., 2024) and international commitments (OECD, 2025) implies reducing red meat consumption and diet change (Rockström et al., 2025; Schebesta & Candel., 2020). 

Understanding how to encourage and promote this behavioral change has led previous research to investigate the use of nudges (Schäufele-Elbers et al., 2025) and social norms (Pollicino et al., 2025; Çoker et al., 2022). This study focuses on deliberation or more specifically on "mini-publics" (Niemeyer, 2011) as these methods have been applied to promote the discussion between experts and the public on a national stage (Convention Citoyenne pour le Climat, 2021) and are particularly relevant in the current use case whereby meat consumption can be seen as a social behavior that is influenced by individual preferences and shared norms.

This study has the goal of investigating how to encourage behavioral change and uncovering the mechanisms underlying this change by using data collected by Dheilly et al (unpublished) who developed a cluster-randomized study using group deliberation to better understand how information is diffused in a social setting related to meat consumption reduction.

# Model Development
The models developed in this study consist of two parts: models of social influence (inspired by Flache et al., 2017) and argumentation (inspired by the VITAMIN Project by Taillandier et al., 2020). 

The social influence models are categorized into 3 types: consensus, clustering and bipolarization, where bipolarization is a special case of clustering. 

In a consensus model all agents interact simultaneously with each other and average their opinion in conjunction with that of others to eventually reach a consensus (one single opinion group). Each agent has a convergence rate, i.e. the speed at which the individual opinion approaches the average opinion of the other agents with whom they interacted (the other agents in the debate).

The clustering model highlights the idea that agents have a confidence threshold below which they consider themselves to be similar enough to another agent and are willing to interact and exchange opinions. Above this threshold agents simply do not interact with each other (as if ignoring the other agents). The end result being two or more groups of opinions that are distributed across the opinion space (bounded between 0,1).

The bipolarization model extends the clustering model where agents have a repulsion mechanism that activates above a repulsion threshold. If the opinion of an agent with respect to another in the same debate is above this threshold, both agent consider each other dissimilar and actively repulse (they push each other's opinions further apart using a repulsion strength, the same as convergence rate but for repulsion). This in turn leads to two "polarized" groups of opinions (normally at opposite ends of the opinion space) at the end of a debate.

The argumentation framework is based on similar logic to the models of social influence with the addition that agents now have a list of arguments with a valence (for or against the subject at hand) that they can use to attack/defend themselves from the arguments of other agents in the debate. This establishes a graph of arguments whereby each agent can add or remove arguments from their personal list based on the interactions they have with other agents in the debate. 

The added benefit of creating graphs of arguments is that one can now track how the opinion of an agent in a debate evolves based on the interactions they have had and the strength with which they defended or attacked with their personal list of arguments. This more closely mirrors the evolution of a debate compared with the simplified exchange of opinions in social influence models and can help understand and explain what actually happened in the empirical debates of Dheilly et al. (unpublished).

# Hypothesis Testing
To evaluate how well the two classes of models explain the empirical behavior of agents, a set of hypotheses were set up and are hereafter described in layman's terms to ease the reader into the subject matter and to contextualize how well a model explains real life behavior. The hypotheses described below are directly linked to the OSF protocol using the same numbering nomenclature and are segmented into two categories: behavioral and model performance hypotheses. Each hypothesis will be restated from the OSF protocol, followed by a sentence describing what it tests.

## Behavioral Hypotheses
**H1a** (Empirical - Individual Level): Empirical pre-deliberation attitudes toward meat consumption are expected to be positively associated with empirical post-deliberation attitudes, accounting for a meaningful share of variance when controlling for the nested nature of agents within distinct debate groups.

This hypothesis tests whether the attitudes of agents prior to deliberation (T1) are positively correlated to their attitudes after deliberation (T2) as a measure of the variance explained in the T2 opinion, accounting for the fact that an individual agent pertains to and only interacts with other agents in a specific debate group.

**H1b** (Simulated - Individual Level): Simulated pre-deliberation attitudes toward meat consumption are expected to be positively associated with simulated post-deliberation attitudes, accounting for a meaningful share of variance when controlling for the nested nature of agents within distinct debate groups. 

This hypothesis tests whether the empirical attitude with which agents are initialized in the agent-based models is positively correlated with the simulated attitude at the end of the debate, explaining a significant share of the variance. It follows the same nested structure whereby agents can only interact with other agents in a specific debate group.

**H2** (Empirical - Individual Level): Individuals with higher perceived social norms and lower self-control will exhibit greater absolute attitude change between pre- and post-deliberation measurement points, moderated by their initial opinion strength.

Individuals who are more likely to be receptive and influenced by social norms observed around them as well as those that are less likely to be able to exert control over their own actions are likely to change their attitude more in absolute terms before and after the debate, controlling for the strength of their attitude before the debate.

**H4a** (Empirical - Debate Level): Debates with a heterogeneous composition of participants are expected to exhibit a greater mean attitude change between empirical pre- and post-deliberation attitudes compared with homogeneous debates. 

Debates composed of agents who are pro and anti meat consumption reduction (compared with only anti reduction) are more likely to change their attitude on average with respect to their pre and post debate attitudes in empirical debates. 

**H4b** (Simulated - Debate Level): Debates with a heterogeneous composition of participants are expected to exhibit a greater mean attitude change between simulated pre- and post-deliberation attitudes compared with homogeneous debates. 

This hypothesis tests whether the simulated models that consider heterogeneous debates change more on average when compared to homogeneous debate composition, i.e. producing the composition effect when initialized on empirical T1 attitudes. 

## Model Performance Hypotheses
**H3a** (Simulated - Individual Level): Agent-based simulations initialized with pre-deliberation attitudes alone will generate a lower mean of absolute error [MAE] predictions of post-deliberation attitudes for individual participants compared with a naive "no_change" baseline and a multilevel linear model fitted on the calibration debates and evaluated on held-out debates, at the individual participant level.

This hypothesis tests whether the agent-based simulations of social influence models better explain the real world behavior exhibited by agents compared with a model that assumes no change (or static agents) as well as a multilevel linear model that assumes the pre-deliberation attitudes are positively associated with post-deliberation attitudes for individual agents. The multilevel model is fitted on the calibration debates and evaluated on a held-out set.

**H3b** (Simulated - Debate Level): Agent-based simulations initialized with pre-deliberation attitudes alone will generate a lower mean of absolute error [MAE] predictions of post-deliberation attitudes, aggregated at the debate group level, compared with a naive "no_change" baseline and a predictive multilevel linear model fitted on the calibration debates and evaluated on held-out debates.

H3b follows the same structure as H3a with the caveat that we now investigate how well the agent-based simulations explain behavior considering debate level MAE. The multilevel model is again fitted on calibration debates and evaluated on a held-out set.

**H5** (Simulated - Global Level): When pooled at a global level, ABMs calibrated with pre-deliberation attitudes should reproduce a global post-deliberation attitude shift toward meat consumption reduction with a lower MAE than a single global multilevel regression model.

This hypothesis tests whether pooling the predictions of agent-based simulations across all debates, initialized with the empirical pre-deliberation attitudes better explains the post-deliberation shift toward consumption reduction compared with a single regression model fitted across all debates.

**H6**: Agent-based models upgraded with argumentation mechanisms alongside models of social influence are expected to yield more accurate and stable predictions of global attitude distributions (using MAE) than models only using social influence mechanisms (Bächtiger et al., 2018; Niemeyer et al., 2024).

The final hypothesis is that the implementation of the argumentation framework (described above) better explains the empirical behavior compared with the agent-based simulations of social influence models. More specifically, does adding in the exchange of actual arguments instead of only information, better explain how agents react and change their attitude toward meat consumption reduction post-deliberation.