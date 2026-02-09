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