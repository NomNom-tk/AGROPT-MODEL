Repository designed to store multi-agent simulations in the context of food decision making through mechanisms of social influence...

# Description of Model files

## DOG_RAT
- personal project intending to reuse GAML tutorials (modification on pred-prey and luneray's flue)
- test with GIS integration and scraping (needs work)

## thomas_dat_2
- composed of 3 models based on Flache et al 2017 (10.18564/jasss.3521)
-- consensus (assimilative social influence)
+ individuals connected to each other (influence relationship) will always exert influence on each other towards reducing opinion differences // can be cancelled out given influence from an actor is superseded by other parties
+ agents have continuous opinions
+ network links remain unchanged over time but are weighed (scale strength of social influence) // in classical models this influence weight is fixed
+ agents have a (mu) rate of opinion convergence (0< mu <1) describing how fast they update their opinion
+ agent opinion updates happen simultaneously in discrete steps // updated opinion moves to weighted avg of previous opinion and neighbors in network opinion

-- clustering (similarity bias)
+ whether social influence occurs between connected individuals (and strength) depends on their  similarity
+ at each time point agents meet (either in pairs or meet all agents simultaneously) and can influence each other // given interaction, opinion moves toward other agent(s) only if their opinions were similar enough before
+ confidence (level) threshold (opinion convergence var is engaged if agent disagreement does not exceed |o(i) - o(j)|) otherwise zero
+  given small confidence threshold --> many small clusters form (smaller threshold = more clusters)
+ the more similarity is needed to make social influence possible, the smaller and more numerous clusters there will be // by extension the more features you include for agents the more likely they are to agree on some feature by chance (e.g., too many statistical tests may give you random statistical significance)
+ noise can help sustain diversity if noise rate is in an intermediate range (opinion clusters cannot merge faster with neighboring regions than spontaneous changes creating new diversity within clusters)

-- bi-polarization (repulsive influence)
+ similar to clustering with the addition of repulsion given (extreme) opinion differences
+ social influence can create assimilation between agents (but assuming a cross in the disagreement threshold, it creates distance between the agents)
+ implication: social influence relations are influence by homophily (similarity between individuals, implies they are more open to influence from others) but also by xenophobia (larger dissimilarity between individuals, more they evaluate each other negatively -> triggers differentiation)
+ in a modelling situation -> random opinion distribution across population, leads to two opposing extremes
++ initial extremists push moderate agents to differentiate from their extreme views and to shift towards opposite pole
+ if there is enough room for both assimilation and differentiation, bipolarization is likely to occur // consensus is likely to occur if interpersonal interactions result primarily in assimilation and not differentiation
++ greater variance in initial agent opinions, increases chance of bipolarization
++ multi-dimensional opinion spaces (dissimilarity is considered aggregate across all dimensions) -> more dimensions can decrease likelihood that from random start agents who happen to interact will strongly disagree on most dimensions
+++ further, models can differentiate between primary and secondary opinion dimensions (primary dimension may determine whether influence is assim or repuls on both dimensions)
+++ another point, distribution of demographic attributes in population (agents central to social identity can affect direciton of influence depending on group membership)

## thomas_dat_2_arg (future file, to be ****coded****) / based on publicaiton (10.18564/jasss.4531)
+ go back and re-read // essentially you could compile a list of arguments from thomas data and categorize them by pro-con, criterion they address (nutritional, ethical, etc) 
+ basic model establishes
++ argumentation graph (based on Dung 1995) where each node is an argument and each edge is an attack on another argument / weight of the edge is the strength of the attack for the agent (read Yun et al 2018 for definition of attacks: https://doi.org/10.1609/aaai.v34i03.5697)
++ criterion importance (given that each argument is associated with at least one criterion); numerical value (0-1) represents importance of criterion for agent x
++ opinion numerical value for each agent x (>0 the agent is in favour of the option; <0 agent is against the option; =0 agent is neutral)
++ behavior as a nominal value for the corresponding agentic behavior resulting from his opinion (e.g., omnivorous, vegetarian, vegan)

+ dynamics and logistics of the model
++ simulation step is the exchange of an argument between two agents / when agent learns a new argument the oldes one is removed from the argumentation graph (value 1 (most recent) - 10 (oldest))
++ given argument is considered the most recent
++ receiving an argument the agent already has does not add it to the argument graph / shifts to most recent argument
++ partner selection -> in each step an agent randomly selects another agent, probability that second agent is chosen as partner depends on similarity between two agents in terms of opinion (confidence threshold)
++ selecting argument to present; randomly chooses argument in preferred extension maximizing the absolute value of opinion

+ deliberation
++ s1: simplifying argument graph according to weights of the edges
++ s2: computing the set of preferred extensions from simplified graph
++ s3: compute opinion from preferred extensions: each extension, agent computes value using opinion equation (3) and return the extension with max absolute value / if several have same value the agent randomly selects on fo these extensions

+ convergence
++ convergence towards steady state achieved if non of the agents can chage their opinion no matter the exchange of arguments / definition of this state depends on strength of homophily
+++ if h = 0 -> all agents can exchange arguments with all other agents even given very different opinions
+++ if h > 0 -> all agents can exchange arguments with all other agents unless they have a completely different opinion (e.g., +1 with -1)
+++ if h > 1 -> all agents must have arguments of homogeneous type (all pro or all con) but opinion can be either -1 or 1






