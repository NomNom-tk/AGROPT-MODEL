// batch exp takes input from main.gaml

model batch_exp

import "../main_4-3.gaml" // relative path back to main


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

// Batch Consensus (Genetic) NEW IWTH HOMOPHILY
experiment Bt_gen_cons_ndist type: batch repeat: 15 keep_seed: true until: end_simulation {
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
        use_distinct_agents <- false;
        speaking_mode <- false;
    }
}

experiment Bt_gen_cons_dist type: batch repeat: 15 keep_seed: true until: end_simulation {
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
        use_distinct_agents <- true;
        speaking_mode <- false;
    }
}

experiment Bt_gen_cons_ndist_speak type: batch repeat: 15 keep_seed: true until: end_simulation {
    parameter "Selected debate id" var: selected_debate_id min: 1 max: 55 step: 1;
    parameter "Convergence Rate" var: convergence_rate among: [0.1, 0.2, 0.3, 0.5];
    parameter "Confidence Threshold" var: confidence_threshold among: [0.2, 0.4, 0.5, 0.6, 0.8];
    parameter "Repulsion Threshold" var: repulsion_threshold among: [0.0, 0.2, 0.5, 0.6, 0.8];
    parameter "Repulsion Strength" var: repulsion_strength among: [0.1, 0.2, 0.3];
    parameter "Speaking Mode" var: speaking_mode <- true;

    // agent-level parameters
    parameter "SD Convergence Rate" var: convergence_rate_sd among: [0.0, 0.05, 0.1, 0.2];
    parameter "SD Confidence Threshold" var: confidence_threshold_sd among: [0.0, 0.1, 0.2, 0.3];
    parameter "SD Repulsion Threshold" var: repulsion_threshold_sd among: [0.0, 0.1, 0.2, 0.3];
    parameter "SD Repulsion Strength" var: repulsion_strength_sd among: [0.0, 0.05, 0.1, 0.2];
    
    method genetic minimize: mae pop_dim: 5 crossover_prob: 0.5 mutation_prob: 0.1
    nb_prelim_gen: 5 max_gen: 2;
   
    init {
        mode_batch <- true;
        model_type <- "consensus";
        convergence_cycle <- -1;
        use_distinct_agents <- false;
    }
}

experiment Bt_gen_cons_dist_speak type: batch repeat: 15 keep_seed: true until: end_simulation {
    parameter "Selected debate id" var: selected_debate_id min: 1 max: 55 step: 1;
    parameter "Convergence Rate" var: convergence_rate among: [0.1, 0.2, 0.3, 0.5];
    parameter "Confidence Threshold" var: confidence_threshold among: [0.2, 0.4, 0.5, 0.6, 0.8];
    parameter "Repulsion Threshold" var: repulsion_threshold among: [0.0, 0.2, 0.5, 0.6, 0.8];
    parameter "Repulsion Strength" var: repulsion_strength among: [0.1, 0.2, 0.3];

    // agent-level parameters
    parameter "SD Convergence Rate" var: convergence_rate_sd among: [0.0, 0.05, 0.1, 0.2];
    parameter "SD Confidence Threshold" var: confidence_threshold_sd among: [0.0, 0.1, 0.2, 0.3];
    parameter "SD Repulsion Threshold" var: repulsion_threshold_sd among: [0.0, 0.1, 0.2, 0.3];
    parameter "SD Repulsion Strength" var: repulsion_strength_sd among: [0.0, 0.05, 0.1, 0.2];
    
    method genetic minimize: mae pop_dim: 5 crossover_prob: 0.5 mutation_prob: 0.1
    nb_prelim_gen: 5 max_gen: 2;
   
    init {
        mode_batch <- true;
        model_type <- "consensus";
        convergence_cycle <- -1;
        use_distinct_agents <- true;
        speaking_mode <- true;
    }
}

// Batch Clustering (Genetic)
experiment Bt_gen_clst_ndist type: batch repeat: 15 keep_seed: true until: end_simulation {
    parameter "Selected debate id" var: selected_debate_id min: 1 max: 55 step: 1;
    parameter "Convergence Rate" var: convergence_rate among: [0.1, 0.2, 0.3, 0.4, 0.5];
    parameter "Confidence Threshold" var: confidence_threshold among: [0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8];
    parameter "Repulsion Threshold" var: repulsion_threshold among: [0.0, 0.2, 0.5, 0.6, 0.8]; //-- not relevant for clustering
    parameter "Repulsion Strength" var: repulsion_strength among: [0.1, 0.2, 0.3]; //-- not relevant for clustering
    
    // agent-level parameters
    parameter "SD Convergence Rate" var: convergence_rate_sd among: [0.0, 0.05, 0.1, 0.2];
    parameter "SD Confidence Threshold" var: confidence_threshold_sd among: [0.0, 0.1, 0.2, 0.3];
    //parameter "SD Repulsion Threshold" var: repulsion_threshold_sd among: [0.0, 0.1, 0.2, 0.3];
    //parameter "SD Repulsion Strength" var: repulsion_strength_sd among: [0.0, 0.05, 0.1, 0.2];

    method genetic minimize: mae pop_dim: 5 crossover_prob: 0.5 mutation_prob: 0.1
    nb_prelim_gen: 5 max_gen: 5;

    init {
        mode_batch <- true;
        model_type <- "clustering";
        convergence_cycle <- -1;
        use_distinct_agents <- false;
        speaking_mode <- false;
    }
}

experiment Bt_gen_clst_dist type: batch repeat: 15 keep_seed: true until: end_simulation {
    parameter "Selected debate id" var: selected_debate_id min: 1 max: 55 step: 1;
    parameter "Convergence Rate" var: convergence_rate among: [0.1, 0.2, 0.3, 0.4, 0.5];
    parameter "Confidence Threshold" var: confidence_threshold among: [0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8];
    parameter "Repulsion Threshold" var: repulsion_threshold among: [0.0, 0.2, 0.5, 0.6, 0.8]; //-- not relevant for clustering
    parameter "Repulsion Strength" var: repulsion_strength among: [0.1, 0.2, 0.3]; //-- not relevant for clustering
    
    // agent-level parameters
    parameter "SD Convergence Rate" var: convergence_rate_sd among: [0.0, 0.05, 0.1, 0.2];
    parameter "SD Confidence Threshold" var: confidence_threshold_sd among: [0.0, 0.1, 0.2, 0.3];
    //parameter "SD Repulsion Threshold" var: repulsion_threshold_sd among: [0.0, 0.1, 0.2, 0.3];
    //parameter "SD Repulsion Strength" var: repulsion_strength_sd among: [0.0, 0.05, 0.1, 0.2];

    method genetic minimize: mae pop_dim: 5 crossover_prob: 0.5 mutation_prob: 0.1
    nb_prelim_gen: 5 max_gen: 5;

    init {
        mode_batch <- true;
        model_type <- "clustering";
        convergence_cycle <- -1;
        use_distinct_agents <- true;
        speaking_mode <- false;
    }
}

experiment Bt_gen_clst_ndist_speak type: batch repeat: 15 keep_seed: true until: end_simulation {
    parameter "Selected debate id" var: selected_debate_id min: 1 max: 55 step: 1;
    parameter "Convergence Rate" var: convergence_rate among: [0.1, 0.2, 0.3, 0.4, 0.5];
    parameter "Confidence Threshold" var: confidence_threshold among: [0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8];
    parameter "Repulsion Threshold" var: repulsion_threshold among: [0.0, 0.2, 0.5, 0.6, 0.8]; //-- not relevant for clustering
    parameter "Repulsion Strength" var: repulsion_strength among: [0.1, 0.2, 0.3]; //-- not relevant for clustering
    
    // agent-level parameters
    parameter "SD Convergence Rate" var: convergence_rate_sd among: [0.0, 0.05, 0.1, 0.2];
    parameter "SD Confidence Threshold" var: confidence_threshold_sd among: [0.0, 0.1, 0.2, 0.3];
    //parameter "SD Repulsion Threshold" var: repulsion_threshold_sd among: [0.0, 0.1, 0.2, 0.3];
    //parameter "SD Repulsion Strength" var: repulsion_strength_sd among: [0.0, 0.05, 0.1, 0.2];

    method genetic minimize: mae pop_dim: 5 crossover_prob: 0.5 mutation_prob: 0.1
    nb_prelim_gen: 5 max_gen: 5;

    init {
        mode_batch <- true;
        model_type <- "clustering";
        convergence_cycle <- -1;
        use_distinct_agents <- false;
        speaking_mode <- true;
    }
}

experiment Bt_gen_clst_dist_speak type: batch repeat: 15 keep_seed: true until: end_simulation {
    parameter "Selected debate id" var: selected_debate_id min: 1 max: 55 step: 1;
    parameter "Convergence Rate" var: convergence_rate among: [0.1, 0.2, 0.3, 0.4, 0.5];
    parameter "Confidence Threshold" var: confidence_threshold among: [0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8];
    parameter "Repulsion Threshold" var: repulsion_threshold among: [0.0, 0.2, 0.5, 0.6, 0.8]; //-- not relevant for clustering
    parameter "Repulsion Strength" var: repulsion_strength among: [0.1, 0.2, 0.3]; //-- not relevant for clustering
    
    // agent-level parameters
    parameter "SD Convergence Rate" var: convergence_rate_sd among: [0.0, 0.05, 0.1, 0.2];
    parameter "SD Confidence Threshold" var: confidence_threshold_sd among: [0.0, 0.1, 0.2, 0.3];
    //parameter "SD Repulsion Threshold" var: repulsion_threshold_sd among: [0.0, 0.1, 0.2, 0.3];
    //parameter "SD Repulsion Strength" var: repulsion_strength_sd among: [0.0, 0.05, 0.1, 0.2];

    method genetic minimize: mae pop_dim: 5 crossover_prob: 0.5 mutation_prob: 0.1
    nb_prelim_gen: 5 max_gen: 5;

    init {
        mode_batch <- true;
        model_type <- "clustering";
        convergence_cycle <- -1;
        use_distinct_agents <- true;
        speaking_mode <- true;
    }
}

// Batch Bipolarization (Genetic)
experiment Bt_gen_bipol_ndist type: batch repeat: 15 keep_seed: true until: end_simulation {
    parameter "Selected debate id" var: selected_debate_id min: 1 max: 55 step: 1;
    parameter "Convergence Rate" var: convergence_rate among: [0.1, 0.2, 0.3, 0.5];
    // ensuring that repulsion_threshold > confidence_threshold is ALWAYS TRUE
    parameter "Confidence Threshold" var: confidence_threshold among: [0.2, 0.3, 0.4, 0.5];
    parameter "Repulsion Threshold" var: repulsion_threshold among: [0.4, 0.5, 0.6, 0.7, 0.8];
    parameter "Repulsion Strength" var: repulsion_strength among: [0.1, 0.2, 0.3];

    method genetic minimize: mae pop_dim: 5 crossover_prob: 0.5 mutation_prob: 0.1
    nb_prelim_gen: 5 max_gen: 5;
   
    init {
        mode_batch <- true;
        model_type <- "bipolarization";
        convergence_cycle <- -1;
        use_distinct_agents <- false;
        speaking_mode <- false;
        
        if repulsion_threshold <= confidence_threshold {
        	write "SKIP: invalid parameters (p <= E)";
        	do die; // skip this parameter combination
        }
    }
}

experiment Bt_gen_bipol_dist type: batch repeat: 15 keep_seed: true until: end_simulation {
    parameter "Selected debate id" var: selected_debate_id min: 1 max: 55 step: 1;
    parameter "Convergence Rate" var: convergence_rate among: [0.1, 0.2, 0.3, 0.5];
    // ensuring that repulsion_threshold > confidence_threshold is ALWAYS TRUE
    parameter "Confidence Threshold" var: confidence_threshold among: [0.2, 0.3, 0.4, 0.5];
    parameter "Repulsion Threshold" var: repulsion_threshold among: [0.4, 0.5, 0.6, 0.7, 0.8];
    parameter "Repulsion Strength" var: repulsion_strength among: [0.1, 0.2, 0.3];

    method genetic minimize: mae pop_dim: 5 crossover_prob: 0.5 mutation_prob: 0.1
    nb_prelim_gen: 5 max_gen: 5;
   
    init {
        mode_batch <- true;
        model_type <- "bipolarization";
        convergence_cycle <- -1;
        use_distinct_agents <- true;
        speaking_mode <- false;
        
        if repulsion_threshold <= confidence_threshold {
        	write "SKIP: invalid parameters (p <= E)";
        	do die; // skip this parameter combination
        }
    }
}

experiment Bt_gen_bipol_ndist_speak type: batch repeat: 15 keep_seed: true until: end_simulation {
    parameter "Selected debate id" var: selected_debate_id min: 1 max: 55 step: 1;
    parameter "Convergence Rate" var: convergence_rate among: [0.1, 0.2, 0.3, 0.5];
    // ensuring that repulsion_threshold > confidence_threshold is ALWAYS TRUE
    parameter "Confidence Threshold" var: confidence_threshold among: [0.2, 0.3, 0.4, 0.5];
    parameter "Repulsion Threshold" var: repulsion_threshold among: [0.4, 0.5, 0.6, 0.7, 0.8];
    parameter "Repulsion Strength" var: repulsion_strength among: [0.1, 0.2, 0.3];

    method genetic minimize: mae pop_dim: 5 crossover_prob: 0.5 mutation_prob: 0.1
    nb_prelim_gen: 5 max_gen: 5;
   
    init {
        mode_batch <- true;
        model_type <- "bipolarization";
        convergence_cycle <- -1;
        use_distinct_agents <- false;
        speaking_mode <- true;
        
        if repulsion_threshold <= confidence_threshold {
        	write "SKIP: invalid parameters (p <= E)";
        	do die; // skip this parameter combination
        }
    }
}

experiment Bt_gen_bipol_dist_speak type: batch repeat: 15 keep_seed: true until: end_simulation {
    parameter "Selected debate id" var: selected_debate_id min: 1 max: 55 step: 1;
    parameter "Convergence Rate" var: convergence_rate among: [0.1, 0.2, 0.3, 0.5];
    // ensuring that repulsion_threshold > confidence_threshold is ALWAYS TRUE
    parameter "Confidence Threshold" var: confidence_threshold among: [0.2, 0.3, 0.4, 0.5];
    parameter "Repulsion Threshold" var: repulsion_threshold among: [0.4, 0.5, 0.6, 0.7, 0.8];
    parameter "Repulsion Strength" var: repulsion_strength among: [0.1, 0.2, 0.3];

    method genetic minimize: mae pop_dim: 5 crossover_prob: 0.5 mutation_prob: 0.1
    nb_prelim_gen: 5 max_gen: 5;
   
    init {
        mode_batch <- true;
        model_type <- "bipolarization";
        convergence_cycle <- -1;
        use_distinct_agents <- true;
        speaking_mode <- true;
        
        if repulsion_threshold <= confidence_threshold {
        	write "SKIP: invalid parameters (p <= E)";
        	do die; // skip this parameter combination
        }
    }
}

// NO CHANGE EXP
experiment Bt_gen_no_change type: batch repeat: 15 keep_seed: true until: end_simulation {
	parameter "Selected debate id" var: selected_debate_id min: 1 max: 55 step: 1;
	
	method genetic minimize: mae pop_dim: 5 crossover_prob: 0.5 mutation_prob: 0.1
    nb_prelim_gen: 5 max_gen: 5;
	
	init {
		mode_batch <- true;
		model_type <- "no_change";
		convergence_cycle <- -1;
		debug_mode <- false;
		
	}
}

experiment Batch_argumentative_gen type: batch repeat: 30 keep_seed: true until: end_simulation {
    parameter "Selected debate id" var: selected_debate_id min: 1 max: 55 step: 1;
    parameter "Convergence Rate" var: convergence_rate among: [0.1, 0.2, 0.3, 0.5];

    // homophily parameter
    //parameter "Homophily Strength" var: homophily_strength among: [0.0, 0.3, 0.5, 0.7, 1.0];
 
    method genetic minimize: mae pop_dim: 5 crossover_prob: 0.5 mutation_prob: 0.1
    nb_prelim_gen: 5 max_gen: 5;
   
    init {
        mode_batch <- true;
        model_type <- "argumentative";
        convergence_cycle <- -1;
    }
}
