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


