# meant to organize what i do each day to stay accountable

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

