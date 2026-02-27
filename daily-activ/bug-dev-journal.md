# meant to document the bugs i resolved and what i learned from each programming session

## references
- GAMA documentation
- Railsback ad Grimm: Agent based and individual based modeling
- 

## questions to ask
- why this feature theoretically?
- how do i code this? minimal code implementation
- how to test this? what can i run to check that this matters?

## feature addition process
- what is the minimum code change?
- where does initialization happen?
- where does the update happen?
- what breaks if i add this?
- how do i validate it works?
- what new parameters need calibration?
- what outputs do i need to track?


## 18/2/26 problem: all agents are identical (not realistic)
- solution:
-- add agent level attributes sampled from distribution during simulation
-- need to use agent parameters in current reflexes instead of global parameters
-- further, calibrate mean and variance

- when to use: when theory suggests individual differences matter
- watch out: constraint violations and computational cost

- feature addition
-- need to add 4 agent level parameters
-- initialization happens in main file after agent creation (opinion agent)
-- update happens in reflex opinion update
-- breaks: update mechanism, saving logic, fit computation
-- validation by comparison to mae with global parameters
-- 4 agent specific parameters need calibration (add to GA experiment in batch, can test with GUI)
-- need to track changes in mean and variance // validate with test data

implementation:
- add global agent-parameters in opinion_agent
- add distribution parameters (SD of 4 main parameters) in main_file
- sample in agent_initialization for debate // agent parameters sample from the SD of the global params (i.e. agent_convergence comes from convergence_rate_sd)
- use agent parameters in reflexes (change all globals to agent-specific)
- validate in init section after creating agents (e.g., list<float> agent_rates <- opinion_agent collect each.agent_convergence_rate;
write "Mean: " + mean(agent_rates) + ", SD: " + standard_deviation(agent_rates); )
- update parameters in batch experiment
- update saving to csv for agent file

## 24/2/26
### learned about using modular agent creation for different models
- creation of a virtual general species (virtual does not exist, cannot create agents from it but serves as a forced reminder to declare functions, attributes) // abstract concept
- any action designated as virtual: true implies that the compute_opinion needs to be defined (allows for an individual compute opinion for each subspecies of the general class)
-- forces you to create subspecies 
- implementation
-- e.g. global {
	list<opinion_agent> opinion_agents -> {agents of_generic_species opinion_agent};
}

species opinion_agent virtual: true  {
    // ========================================================================
    // CORE ATTRIBUTES
    // ========================================================================
    float previous_opinion <- 0.0;          // Opinion at previous timestep
    float opinion min: 0.0 max: 1.0;        // Current opinion [0,1]
    list<opinion_agent> neighbors <- [];    // Connected agents in network
    rgb color <- #blue;        
    
    ...
    
    action compute_opinion virtual: true;
    
    reflex repeat_compute_opinion {
    	do compute_opinion;
    	
    }
    
    // now for a subspecies example
    
    species consensus_agent parent: opinion_agent {
    action compute_opinion {
        if length(neighbors) > 0 {
            previous_opinion <- opinion;
            
            // Average opinion including self
            list<float> all_opinions <- [opinion] + (neighbors collect each.opinion);
            float new_opinion <- mean(all_opinions);
            opinion <- max([0.0, min([1.0, opinion + agent_convergence_rate * (new_opinion - opinion)])]); // bounds creation
            
        }
    }
}
    
### when implementing this in the main file to create agents (per model, etc)
- create a species and cast it to <opinion_agent>(model_type + "_agent"_ {
	agent logic....
	}
-- essentially you create a species at tell it what kind of species it is (casting), then assign it the model type + string of characters


- use ask instead of loops when repeating across agents/species (use loops when repeating across numbers, columns)
-- e.g. // part of saving batch results
       ask opinion_agents {
            float individual_error <- abs(opinion - final_attitude);
            float opinion_change <- opinion - initial_opinion;
            
            // Calculate mean of T2 subfactors for comparison
            float mean_t2_subfactors <- (subfactor_1_t2 + subfactor_2_t2 +
                                         subfactor_3_t2 + subfactor_4_t2 + 
                                         subfactor_5_t2) / 5.0; 
-- this allows you to remove the individual context of each agent (no need to write ag.subfactor...)


### main file importing
- only main file should import all other relevant files (NOT EXPERIMENTS)
- experiments should only import the main file

# 26/2/26
- learned how to integrate a new model into the existing models of social influence (Mas and flache 2013, bipolarization without negative influence)
- struggled and had help from patrick
-- gained a better understanding of maps and how to manipulate them (add, remove, modify)
-- implementation in the code: 

- modify gui experiment to slow down steps (use minimum_cycle_duration as a parameter)
- GAMA program (use of searching in built-in model library for terms, e.g., maps, calibration and sensitivity analysis)
- interactive console in GAMA (e.g., '?loop' brings up the documentation)





