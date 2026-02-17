// batch exp takes input from main.gaml

model batch_exp

import "../main-16-2-26.gaml" // relative path back to main


// BATCH EXPERIMENTS: EXHAUSTIVE SEARCH
// Batch Consensus (Exhaustive)
experiment Batch_consensus_exh type: batch repeat: 2 keep_seed: true until: end_simulation {
    parameter "Selected debate id" var: selected_debate_id min: 1 max: 55 step: 1;
    parameter "Convergence Rate" var: convergence_rate among: [0.1, 0.2, 0.3, 0.5];
    parameter "Confidence Threshold" var: confidence_threshold among: [0.2, 0.4, 0.5, 0.6, 0.8];
    parameter "Repulsion Threshold" var: repulsion_threshold among: [0.0, 0.2, 0.5, 0.6, 0.8];
    parameter "Repulsion Strength" var: repulsion_strength among: [0.1, 0.2, 0.3];
  
    init {
        mode_batch <- true;
        model_type <- "consensus";
        convergence_cycle <- -1;
    }
}

// Batch Clustering (Exhaustive)
experiment Batch_clustering_exh type: batch repeat: 2 keep_seed: true until: end_simulation {
    parameter "Selected debate id" var: selected_debate_id min: 1 max: 55 step: 1;
    parameter "Convergence Rate" var: convergence_rate among: [0.1, 0.2, 0.3, 0.5];
    parameter "Confidence Threshold" var: confidence_threshold among: [0.2, 0.4, 0.5, 0.6, 0.8];
    parameter "Repulsion Threshold" var: repulsion_threshold among: [0.0, 0.2, 0.5, 0.6, 0.8];
    parameter "Repulsion Strength" var: repulsion_strength among: [0.1, 0.2, 0.3];
   
    init {
        mode_batch <- true;
        model_type <- "clustering";
        convergence_cycle <- -1;
    }
}

// Batch Bipolarization (Exhaustive)
experiment Batch_bipolarization_exh type: batch repeat: 2 keep_seed: true until: end_simulation {
    parameter "Selected debate id" var: selected_debate_id min: 1 max: 55 step: 1;
    parameter "Convergence Rate" var: convergence_rate among: [0.1, 0.2, 0.3, 0.5];
    parameter "Confidence Threshold" var: confidence_threshold among: [0.2, 0.4, 0.5, 0.6, 0.8];
    parameter "Repulsion Threshold" var: repulsion_threshold among: [0.0, 0.2, 0.5, 0.6, 0.8];
    parameter "Repulsion Strength" var: repulsion_strength among: [0.1, 0.2, 0.3];
   
    init {
        mode_batch <- true;
        model_type <- "bipolarization";
        convergence_cycle <- -1;
    }
}

// BATCH EXPERIMENTS: GENETIC ALGORITHM

// Batch Consensus (Genetic)
experiment Batch_consensus_gen type: batch repeat: 30 keep_seed: true until: end_simulation {
    parameter "Selected debate id" var: selected_debate_id min: 1 max: 55 step: 1;
    parameter "Convergence Rate" var: convergence_rate among: [0.1, 0.2, 0.3, 0.5];
    parameter "Confidence Threshold" var: confidence_threshold among: [0.2, 0.4, 0.5, 0.6, 0.8];
    parameter "Repulsion Threshold" var: repulsion_threshold among: [0.0, 0.2, 0.5, 0.6, 0.8];
    parameter "Repulsion Strength" var: repulsion_strength among: [0.1, 0.2, 0.3];
    
    method genetic minimize: mae pop_dim: 5 crossover_prob: 0.5 mutation_prob: 0.1
    nb_prelim_gen: 5 max_gen: 2;
   
    init {
        mode_batch <- true;
        model_type <- "consensus";
        convergence_cycle <- -1;
    }
}

// Batch Clustering (Genetic)
experiment Batch_clustering_gen type: batch repeat: 30 keep_seed: true until: end_simulation {
    parameter "Selected debate id" var: selected_debate_id min: 1 max: 55 step: 1;
    parameter "Convergence Rate" var: convergence_rate among: [0.1, 0.2, 0.3, 0.4, 0.5];
    parameter "Confidence Threshold" var: confidence_threshold among: [0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8];
    // parameter "Repulsion Threshold" var: repulsion_threshold among: [0.0, 0.2, 0.5, 0.6, 0.8]; -- not relevant for clustering
    // parameter "Repulsion Strength" var: repulsion_strength among: [0.1, 0.2, 0.3]; -- not relevant for clustering

    method: genetic minimize: mae pop_dim: 5 crossover_prob: 0.5 mutation_prob: 0.1
    nb_prelim_gen: 5 max_gen: 5;

    init {
        mode_batch <- true;
        model_type <- "clustering";
        convergence_cycle <- -1;
    }
}

// Batch Bipolarization (Genetic)
experiment Batch_bipolarization_gen type: batch repeat: 30 keep_seed: true until: end_simulation {
    parameter "Selected debate id" var: selected_debate_id min: 1 max: 55 step: 1;
    parameter "Convergence Rate" var: convergence_rate among: [0.1, 0.2, 0.3, 0.5];
    // ensuring that repulsion_threshold > confidence_threshold is ALWAYS TRUE
    parameter "Confidence Threshold" var: confidence_threshold among: [0.2, 0.3, 0.4, 0.5];
    parameter "Repulsion Threshold" var: repulsion_threshold among: [0.4, 0.5, 0.6, 0.7, 0.8];
    parameter "Repulsion Strength" var: repulsion_strength among: [0.1, 0.2, 0.3];

    method: genetic minimize: mae pop_dim: 5 crossover_prob: 0.5 mutation_prob: 0.1
    nb_prelim_gen: 5 max_gen: 5
   
    init {
        mode_batch <- true;
        model_type <- "bipolarization";
        convergence_cycle <- -1;
    }
}
