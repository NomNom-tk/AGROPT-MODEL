# questions to ask yourself when writing analysis code
Level 1: Data Quality & Exploration
Before analyzing, always ask:

What was actually varied?

Which parameters were in the experiment?
What ranges were explored?
Are all parameter combinations represented?


Is the data complete?

Missing runs? (GA might have skipped some)
Convergence failures? (max_cycles reached)
Invalid combinations? (your constraint check)


What's the stochasticity?

How much variance across seeds?
If variance ≈ 0, reduce seed replicates
If high variance, need more seeds

R thoughts:
- how many seeds/equal runs per model?
- how many debates hit max cycles
- check variance across seeds

Level 2: Model Performance
Core questions for any calibration:

Which model wins overall?

Mean MAE across all conditions
Median MAE (robust to outliers)
Best single run


Which model wins per condition?

Stratify by experimental conditions
Different models for different contexts?


How sensitive is performance to parameters?

Which parameters matter most?
Are there interactions?
Stable optima or knife-edge?

R thoughts:
- best model (winner by metric definition)
- conditional winner based on exp condition and metric
- correlation of parameter columns with metric

Level 3: Parameter Space
Understanding the calibration landscape:

Where are the optima?

Best parameter combinations
Are they at boundaries? (suggests need wider range)
Clustered or scattered?


Are there plateaus or cliffs?

Smooth performance surface?
Sharp transitions?
Robust regions?


Interaction effects?

Do parameters interact?
Is param A only important when param B is high?

R thoughts:
- find optima (slice by metric and find top 10 runs)
- check the boundaries (best_params$parameter_name)
- interaction terms (lm(metric ~ param1 * param2, data=data)

Level 4: Emergent Dynamics
What does the model DO, not just how well it performs:

Convergence patterns:

How long to converge?
Stable or oscillating?
Depends on parameters?


Final states:

Consensus, clustering, or polarization?
Diversity maintained?
Realistic outcomes?


Process patterns:

Opinion trajectories
Network effects
Phase transitions?

R thoughts:
- speed of convergence
- diversity in opinion, mean_variance
- do correlations with dynamis (higher convergece cycle equate to a better mae?)

Level 5: Agent-Level (Individual Predictions)
Drilling down to individual agents:

Error distribution:

Which agents predicted well?
Which agents predicted poorly?
Patterns in errors?


Individual differences:

Do agent-level parameters matter?
Heterogeneity effects?
Who changes more?


Network positions:

Does degree predict error?
Central vs peripheral agents?
Influencers vs followers?

