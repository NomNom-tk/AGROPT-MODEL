u# meant to organize what i do each day to stay accountable

## 29/1/26
- meeting with Nicolas, Thomas, and Julien
- spoke about Thomas article and updating GAMA and protocol hypotheses
- spent 20 minutes debugging gama
- post lunch continue GAMA debug (parsing problems, distinction between text_file and csv_file?) and switch to protocol
- continue on protocol hypotheses (most of them declared)
- went to a master thesis defence on social computation for eating behaviors
- continued to debug and write hypotheses

## 30/1/26
- start with code restructuring
- found a way to restructure and use 9 files (excluding data file)
structure (in gama there is no compartmentalization of global variables, loads individual globals and collates them into 1)
/models
-main.gaml // for coordination
--/config
---parameters.gaml // all mutable parameters live here
--/species
---opinion_agent.gaml // all opinion agent lives here
---data_manager.gaml // handles all data loading and pre-processing
--/actions
---network_builder.gaml // creates the network (complete, random, small world)
---statistic.gaml // for MAE, variance, clusters
---file_io.gaml // csv storing and saving for debate and agents
--/experiments
---gui_exp.gaml // gui experiment for debug and testing
---batch_experiments.gaml // batch experiments and parameter searching

- had to restructure code because of GAMA limitations
- arrived at a more simple structure and need to modify the data_loader file, create a wrapper to make it a species then introduce into the main model
- will work on the weekend to resolve this bug

## 2/2/26
- TODO
    - work on GAMA debug wrapper
    - continue to develop hypotheses for protocol (see if you can finish writing a first draft)
- started by debugging and testing wrapper for data loader
- managed to get the file somewhat working (issue with data headers not being acessible)
- switch to protocol work
- finished hypotheses and expected results
- switched back to debugging -> got the file to work besides the ID_Group_all column
- tested multiple different methods of parsing (manual and forced conversion / built in parser) DID NOT WORK
    - update: changed value in file text_data to false (from true) -> detected and correctly loaded headers and agents
    - index out of bounds issue
    - managed to correct the parsing and data_loader

## 4/2/26
- started with GAMA debugging for index problems
- fixed it by initializing weights (section hierarchy) before initializing agents for the debate in the init section
- continued to work on protocol after lunch
- met with Nicolas and Patrick – talked about future project and current protocol idea
- continued to restructure introduction and reformat hypotheses

## 5/2/26
- started with GAMA debug post meeting with Nicolas, Thomas and Julien
- proceeded to work on protocol, specification of hypotheses and continued work on the introduction regarding deliberation and justification for its use in the meat redution context
- spent a good 2 hours on setting up Julien's imac with ubuntu and repairing broadcom wifi drivers and kernel (6.17....)
- ended by thinking about structure for hypotheses and rationale leading into it

## 9/2/26
- started work with hypotheses elaboration and answering emails for the first 15 minutes
- continued working on the protocol / finished hypothesis desription and continued justification
- referenced most of the protocol → thought about doxyge like plugin for documentation of GAMA
- final need to write ABM implementation for protocol

## 10/2/26
- meeting with Nicolas regarding protocol advances
- continued working on the ABM implementation and refining of hypotheses
- started a structure of the model (i.e. identifying which parts interact with what and how)
- defined questions to ask the researchers in meeting on the 11th of feb

# 11/2/26
- meeting with researchers (Arthur, Kevin) and Patrick and Nicolas
- discussed model calibration and how to achieve this (need to think about more in depth questions regarding model assumptions)
- assumption that all agents are homogeneous and only interact based on model dynamics is NOT REALISTIC
- look into how agents can be heterogeneous (i.e. different agent profiles, for example a superspreader in the context of covid / a pioneer that draws people in and polarizes opinions)
- before running batch in a headless environment, test with a gui experiment and run robustness checks
- think about the fixed time increment (is it fixed where agents interact in each step or not)
- could all parameters except 1 (and vary it among agents)
- send protocol and github issue reporting link
- look into how to allow GAMA to use more ram (possibly fresh install) // separate workspace from git uploads (already done)
- Do we really have time to reach a consensus in the context of the debate (i.e., given they are all about an hour long)?

# 12/2/26
- started work by filling out the elements of model checklist
- did not finish but steadily working on it
- fresh install gama to check workspace issue
- not resolved
- meeting with Nicolas, Thomas and Julien after team meeting
    - discussed the need for argumentation classification logic

# 13/2/26
- started by filling in model elements
- clarified inputs for agents: DBFactor 1-5 @ T1
- DB Index @ T1 = mean(Factor 1 & 2) - mean (Factor 3,4,5)
- met with Patrick in the afternoon to clarify calibration strategy and how to set up experiments correctly

# 16/2/26
- started by organising git repo
    - main: actual and correct working code
    - dev: exploring and developed code but not ready yet
    - research: all research and documentation files for protocol and future research
- 

# 17/2/26
- worked on GAMA model and deconstructing the code
- ran GA for consensus and quick analysis

# 18/2/26
- travel itinerary for Melanie and Nicolas
- started with GAMA GA for clustering and bipolarization
- analyzed using claude and then using R
- thinking about how to implement agent profiles using agent-specific parameters for each social influence model
-- started a bug and leanring journal for GAMA
--- implemented agent level parameter sampling from global parameter distributions (changes in opinion_agent, batch_exp and main)

# 19/2/26
- initial test with agent-level parameter sampling
- confirmed it properly works
- re-checked protocol and what we can achieve with hypotheses
- started working on ODD protocol for the basic model (social influence)
- started working on homophily network implementation

# 20/2/26
- ran GA with homophily network implemented for all 3 models
- finished first draft of ODD
- bullet notes for Toulouse
- need to write R script for analysis

# 23/2/26
- drafted notes and ideas with Patrick for the week
- I would like:
-- to refactor code
-- come to terms with the headless mode and the internal GAMA parser
-- come into contact with more researchers (thesis, internship students) that use GAMA, Discord suggestion
-- spoke about DSL for gama and doxygen
- set up schedule to talk about future project // thesis idea is good and should be pursued
- set up parameters and constants file to isolate them from the model (easier access for calling)

# 24/2/26
- finished parameters and constants file
- got help to implement modular opinion_agent creation (for each model, i.e. parent and subspecies)
- learned about how to implement modular species and computations // can now add in the argumentation model
- then got help on setting up creation of agents in main file using 'ask' instead of 'loop' when repeating across agents
- started writing R file for analysis

# 25/2/26
- read through bipolarization without negative influence paper
- wrote down notes on how to implement the model
- received exercises for GAMA
- started the exercises

# 26/2/26
- tried to code the model into GAMA with little success
- help from Patrick to understand how to better define maps
- translation of model with help and extra steps
- almost finished it and continued to work on exercises
- testing with server and headless but no success

# 27/2/26
- finished implementing simple argumentation model
- started cleaning debug code in files
- further updated git repo
- helped test Unity and Gama integration

# 2/3/26
- continued work on exercises and debug refactoring (not a complete success)
- continued work on R script
- testing of server with headless but no cigar
- started planning on argumentation model (abstract for JASS) implementation

# 3/3/26
- finished R script
- first run on server with success!
- amelioration of model due to convergence issues

# 4/3/26
- repolished R script
- modified GAMA code to work with convergence issues and modified network creation (allows for both argumentation and social influence)
--> convergence problem in network creation dynamics (created dynamic rewiring -- too complicated for now, too far from original models)
--> point being that all models have static homophilic network creation, each model can then change interaction dynamics and partner selection
- run on server (and further debug with convergence)
- first pull of reasonable results from server!
- first run of r script with new data (need to modify for better presentation of initial results)
- need to write script for sectioning debates - not all!
- archive of models pre-convergence fix (denoted in "archive" by 4-3-26) 


# 23/3/26
- started editing the ODD protocol (update speaking_mode dynamics and calibration strategy with LHS)
- left to do for ODD -> add in parameters table and full elements model cleaned & save_batch and agent results list
- updated protocol (almost ready) with necessary elements
- revised slides with Nicolas and planned future analyses

# 13/4/26
- started by updating meetings file and cleaning dev-test repo
- thought about how to change convergence_threshold (increase to 0.1)
- re-run all exps and in the meantime finish refactoring

# 14/4/26
- almost finished refactoring, minor issues in RMD orchestration and plot viz
- continued to draft ideas for convergence dynamic
- meeting with Patrick and Nicolas on 15/4 to discuss

# 15/4/26
- meeting with Patrick and Nicolas regarding convergence cycle and JASSS
- critical comments on empirical debate change compared with current ABM analyses (fair and improvements)
- started updating the RMD for viz and orchestration, still need to generalize to ga pipeline

# 16/4/26
- continued to process data and orchestrate the rmd file
- bugs and problems in the pcc/prcc and model-performance section

# 20/4/26
- finally started fixing dynamic debate label generation, almost done
- continued working on RMD pipeline, might be doable by 21/4
- managed to almost fix the static debate id generaiton, need to refactor to standardize from csv only, could ignore controls for now (given that input is a sectioned csv file)
- implemented recency of influence and speaking turn logic (need to re-run gui to test and then batch)
- continue debug using claude for static debate ids
- updated local R files on work and home comp
- meeting with Adam for RatRec

# 21/4/26 - 11/5/26
- continued to work on pipeline for analysis and determined that the sd in the empirical data was bigger than the effect size we are estimating
- reduces to the question of whether it is worth adding complexity to the model given that we might be estimating noise
- standardized R pipeline to integrate the empirical data and the network plots
- first version of homogeneous plots generated (chose to add retention_discount as agents get more tired over the debate and are more resistant to change)
- ran an initial test with 100 fixed cycles to check (conclusion: too many cycles given that debates converge dynamically at around 30 cycles)
- improvement of cleaning functions in pipeline (read_clean and standardization of encoding of csvs and parsing the decimals vs commas for numeric columns)
- attempted to continue with network plots
- added max cycles to save logic of interaction, agent and batch results for sensitivity
-- TODO
- improve pipeline version awareness for sensitivity

# 15/7/26
- documented bugs in rnd leaks for GAMA model
- started cleaning up pipeline documentation and links to protocol hypotheses --> hopefully protocol submission by end of week
- process_run is documented, meeting with Nicolas (finish analyses and create middle layer document that details the assumptions for analyses)
- need to finish plots and functions file
- started on phd prep, to follow tomorrow

# 20/7/26
- continued working on ODD (almost done, need to finish section 8 and then comprehensive review with GAML code)
- next step is finishing protocol and ODD to be submitted by EOW
- NEXT: finish documenting plots and functions and update data-dictionary
- NEXT: implement upgraded LM functions and RF sensitivity analysis

# 20/8/26
- finished README translation layer for hypotheses, organized git repo and almost finished the R analyses
- created a changelog to integrate into the `bug-dev-journal` file
- ready for final H3 and H5 implementation, then transition to one final document to start coding the argumentation

# 21/8/26
- working on H3 and H5 pseudo code before touching R
