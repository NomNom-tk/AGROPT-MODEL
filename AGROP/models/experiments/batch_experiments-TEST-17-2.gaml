// batch exp takes input from main.gaml

model batch_exp_GA

import "../main_4-3.gaml" // relative path back to main


// BATCH EXPERIMENTS: GENETIC ALGORITHM

// Batch Consensus (Genetic) 
experiment Bt_gen_cons_ndist type: batch repeat: 15 keep_seed: true until: end_simulation {
    parameter "Selected debate id" var: selected_debate_id min: 1 max: 100 step: 1;
    parameter "Convergence Rate" var: convergence_rate among: [0.1, 0.2, 0.3, 0.5];
    
    method genetic minimize: mae pop_dim: 5 crossover_prob: 0.5 mutation_prob: 0.1
    nb_prelim_gen: 5 max_gen: 2;
   
    init {
        mode_batch <- true;
        convergence_cycle <- -1;
        speaking_mode <- false;
        use_distinct_agents <- false;
        model_type <- "consensus";
        debug_mode <- false;
        current_experiment_id <- "cons_ndist_nospeak";
        
        // zero value params not used for consensus
        confidence_threshold <- 0.0;
        repulsion_threshold <- 0.0;
        repulsion_strength <- 0.0;
    }
}

experiment Bt_gen_cons_dist type: batch repeat: 15 keep_seed: true until: end_simulation {
    parameter "Selected debate id" var: selected_debate_id min: 1 max: 100 step: 1;
    parameter "Convergence Rate" var: convergence_rate among: [0.1, 0.2, 0.3, 0.5];
    
    // agent-level params
    parameter "SD Convergence Rate" var: convergence_rate_sd among: [0.0, 0.05, 0.1, 0.2];
    
    method genetic minimize: mae pop_dim: 5 crossover_prob: 0.5 mutation_prob: 0.1
    nb_prelim_gen: 5 max_gen: 2;
   
    init {
        mode_batch <- true;
        convergence_cycle <- -1;
        speaking_mode <- false;
        use_distinct_agents <- true;
        model_type <- "consensus";
        debug_mode <- false;
        current_experiment_id <- "cons_dist_nospeak";
        
        // zero value params not used for consensus
        confidence_threshold <- 0.0;
        repulsion_threshold <- 0.0;
        repulsion_strength <- 0.0;
        confidence_threshold_sd <- 0.0;
        repulsion_threshold_sd <- 0.0;
        repulsion_strength_sd <- 0.0;
    }
}

experiment Bt_gen_cons_ndist_speak type: batch repeat: 15 keep_seed: true until: end_simulation {
    parameter "Selected debate id" var: selected_debate_id min: 1 max: 100 step: 1;
    parameter "Convergence Rate" var: convergence_rate among: [0.1, 0.2, 0.3, 0.5];

    method genetic minimize: mae pop_dim: 5 crossover_prob: 0.5 mutation_prob: 0.1
    nb_prelim_gen: 5 max_gen: 2;
   
    init {
        mode_batch <- true;
        convergence_cycle <- -1;
        speaking_mode <- true;
        use_distinct_agents <- false;
        model_type <- "consensus";
        debug_mode <- false;
        current_experiment_id <- "cons_ndist_speak";
        
        // zero value params not used for consensus
        confidence_threshold <- 0.0;
        repulsion_threshold <- 0.0;
        repulsion_strength <- 0.0;
    }
}

experiment Bt_gen_cons_dist_speak type: batch repeat: 15 keep_seed: true until: end_simulation {
    parameter "Selected debate id" var: selected_debate_id min: 1 max: 100 step: 1;
    parameter "Convergence Rate" var: convergence_rate among: [0.1, 0.2, 0.3, 0.5];

    // agent-level parameters
    parameter "SD Convergence Rate" var: convergence_rate_sd among: [0.0, 0.05, 0.1, 0.2];
    
    method genetic minimize: mae pop_dim: 5 crossover_prob: 0.5 mutation_prob: 0.1
    nb_prelim_gen: 5 max_gen: 2;
   
    init {
        mode_batch <- true;
        convergence_cycle <- -1;
        speaking_mode <- true;
        use_distinct_agents <- true;
        model_type <- "consensus";
        debug_mode <- false;
        current_experiment_id <- "cons_dist_speak";
        
        // zero value params not used for consensus
        confidence_threshold <- 0.0;
        repulsion_threshold <- 0.0;
        repulsion_strength <- 0.0;
        confidence_threshold_sd <- 0.0;
        repulsion_threshold_sd <- 0.0;
        repulsion_strength_sd <- 0.0;
    }
}

// Batch Clustering (Genetic)
experiment Bt_gen_clst_ndist type: batch repeat: 15 keep_seed: true until: end_simulation {
    parameter "Selected debate id" var: selected_debate_id min: 1 max: 100 step: 1;
    parameter "Convergence Rate" var: convergence_rate among: [0.1, 0.2, 0.3, 0.4, 0.5];
    parameter "Confidence Threshold" var: confidence_threshold among: [0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8];

    method genetic minimize: mae pop_dim: 5 crossover_prob: 0.5 mutation_prob: 0.1
    nb_prelim_gen: 5 max_gen: 5;

    init {
        mode_batch <- true;
        convergence_cycle <- -1;
        speaking_mode <- false;
        use_distinct_agents <- false;
        model_type <- "clustering";
        debug_mode <- false;
        current_experiment_id <- "clst_ndist_nospeak";
        
        // zero value params not used for clustering
        repulsion_threshold <- 0.0;
        repulsion_strength <- 0.0;
    }
}

experiment Bt_gen_clst_dist type: batch repeat: 15 keep_seed: true until: end_simulation {
    parameter "Selected debate id" var: selected_debate_id min: 1 max: 100 step: 1;
    parameter "Convergence Rate" var: convergence_rate among: [0.1, 0.2, 0.3, 0.4, 0.5];
    parameter "Confidence Threshold" var: confidence_threshold among: [0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8];
        
    // agent-level parameters
    parameter "SD Convergence Rate" var: convergence_rate_sd among: [0.0, 0.05, 0.1, 0.2];
    parameter "SD Confidence Threshold" var: confidence_threshold_sd among: [0.0, 0.1, 0.2, 0.3];

    method genetic minimize: mae pop_dim: 5 crossover_prob: 0.5 mutation_prob: 0.1
    nb_prelim_gen: 5 max_gen: 5;

    init {
        mode_batch <- true;
        convergence_cycle <- -1;
        speaking_mode <- false;
        use_distinct_agents <- true;
        model_type <- "clustering";
        debug_mode <- false;
        current_experiment_id <- "clst_dist_nospeak";
                
        // zero value params not used for clustering
        repulsion_threshold <- 0.0;
        repulsion_strength <- 0.0;
        repulsion_threshold_sd <- 0.0;
        repulsion_strength_sd <- 0.0;
    }
}

experiment Bt_gen_clst_ndist_speak type: batch repeat: 15 keep_seed: true until: end_simulation {
    parameter "Selected debate id" var: selected_debate_id min: 1 max: 100 step: 1;
    parameter "Convergence Rate" var: convergence_rate among: [0.1, 0.2, 0.3, 0.4, 0.5];
    parameter "Confidence Threshold" var: confidence_threshold among: [0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8];  

    method genetic minimize: mae pop_dim: 5 crossover_prob: 0.5 mutation_prob: 0.1
    nb_prelim_gen: 5 max_gen: 5;

    init {
        mode_batch <- true;
        convergence_cycle <- -1;
        speaking_mode <- true;
        use_distinct_agents <- false;
        model_type <- "clustering";
        debug_mode <- false;
        current_experiment_id <- "clst_ndist_speak";
        
        // zero value params not used for clustering
        repulsion_threshold <- 0.0;
        repulsion_strength <- 0.0;
    }
}

experiment Bt_gen_clst_dist_speak type: batch repeat: 15 keep_seed: true until: end_simulation {
    parameter "Selected debate id" var: selected_debate_id min: 1 max: 100 step: 1;
    parameter "Convergence Rate" var: convergence_rate among: [0.1, 0.2, 0.3, 0.4, 0.5];
    parameter "Confidence Threshold" var: confidence_threshold among: [0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8];
       
    // agent-level parameters
    parameter "SD Convergence Rate" var: convergence_rate_sd among: [0.0, 0.05, 0.1, 0.2];
    parameter "SD Confidence Threshold" var: confidence_threshold_sd among: [0.0, 0.1, 0.2, 0.3];

    method genetic minimize: mae pop_dim: 5 crossover_prob: 0.5 mutation_prob: 0.1
    nb_prelim_gen: 5 max_gen: 5;

    init {
        mode_batch <- true;
        convergence_cycle <- -1;
        speaking_mode <- true;
        use_distinct_agents <- true;
        model_type <- "clustering";
        debug_mode <- false;
        current_experiment_id <- "clst_dist_speak";
   
        // zero value params not used for clustering
        repulsion_threshold <- 0.0; 
        repulsion_strength <- 0.0;
        repulsion_threshold_sd <- 0.0;
        repulsion_strength_sd <- 0.0;
    }
}

// Batch Bipolarization (Genetic)
experiment Bt_gen_bipol_ndist type: batch repeat: 15 keep_seed: true until: end_simulation or (repulsion_threshold <= confidence_threshold) {
    parameter "Selected debate id" var: selected_debate_id min: 1 max: 100 step: 1;
    parameter "Convergence Rate" var: convergence_rate among: [0.1, 0.2, 0.3, 0.5];
    // ensuring that repulsion_threshold > confidence_threshold is ALWAYS TRUE
    parameter "Confidence Threshold" var: confidence_threshold among: [0.2, 0.3, 0.4, 0.5];
    parameter "Repulsion Threshold" var: repulsion_threshold among: [0.4, 0.5, 0.6, 0.7, 0.8];
    parameter "Repulsion Strength" var: repulsion_strength among: [0.1, 0.2, 0.3];

    method genetic minimize: mae pop_dim: 5 crossover_prob: 0.5 mutation_prob: 0.1
    nb_prelim_gen: 5 max_gen: 5;
   
    init {
        mode_batch <- true;
        convergence_cycle <- -1;
        speaking_mode <- false;
        use_distinct_agents <- false;
        model_type <- "bipolarization";
        debug_mode <- false;
        current_experiment_id <- "bipol_ndist_nospeak";
        
        if repulsion_threshold <= confidence_threshold {
            end_simulation <- true;
    	}
	}
}


experiment Bt_gen_bipol_dist type: batch repeat: 15 keep_seed: true until: end_simulation or (repulsion_threshold <= confidence_threshold) {
    parameter "Selected debate id" var: selected_debate_id min: 1 max: 100 step: 1;
    parameter "Convergence Rate" var: convergence_rate among: [0.1, 0.2, 0.3, 0.5];
    // ensuring that repulsion_threshold > confidence_threshold is ALWAYS TRUE
    parameter "Confidence Threshold" var: confidence_threshold among: [0.2, 0.3, 0.4, 0.5];
    parameter "Repulsion Threshold" var: repulsion_threshold among: [0.4, 0.5, 0.6, 0.7, 0.8];
    parameter "Repulsion Strength" var: repulsion_strength among: [0.1, 0.2, 0.3];
    
    // agent-level parameters
    parameter "SD Convergence Rate" var: convergence_rate_sd among: [0.0, 0.05, 0.1, 0.2];
    parameter "SD Confidence Threshold" var: confidence_threshold_sd among: [0.0, 0.1, 0.2, 0.3];
    parameter "SD Repulsion Threshold" var: repulsion_threshold_sd among: [0.0, 0.1, 0.2, 0.3];
    parameter "SD Repulsion Strength" var: repulsion_strength_sd among: [0.0, 0.05, 0.1, 0.2];


    method genetic minimize: mae pop_dim: 5 crossover_prob: 0.5 mutation_prob: 0.1
    nb_prelim_gen: 5 max_gen: 5;
   
    init {
        mode_batch <- true;
        convergence_cycle <- -1;
        speaking_mode <- false;
        use_distinct_agents <- true;
        model_type <- "bipolarization";
        debug_mode <- false;
        current_experiment_id <- "bipol_dist_nospeak";
        
        if repulsion_threshold <= confidence_threshold {
            end_simulation <- true;
    	}

    }
}

// until: condition modified so that it fires regardless of exp init
experiment Bt_gen_bipol_ndist_speak type: batch repeat: 15 keep_seed: true until: end_simulation or (repulsion_threshold <= confidence_threshold) {
    parameter "Selected debate id" var: selected_debate_id min: 1 max: 100 step: 1;
    parameter "Convergence Rate" var: convergence_rate among: [0.1, 0.2, 0.3, 0.5];
    // ensuring that repulsion_threshold > confidence_threshold is ALWAYS TRUE
    parameter "Confidence Threshold" var: confidence_threshold among: [0.2, 0.3, 0.4, 0.5];
    parameter "Repulsion Threshold" var: repulsion_threshold among: [0.4, 0.5, 0.6, 0.7, 0.8];
    parameter "Repulsion Strength" var: repulsion_strength among: [0.1, 0.2, 0.3];
    

    method genetic minimize: mae pop_dim: 5 crossover_prob: 0.5 mutation_prob: 0.1
    nb_prelim_gen: 5 max_gen: 5;
   
    init {
        mode_batch <- true;
        convergence_cycle <- -1;
        speaking_mode <- true;
        use_distinct_agents <- false;
        model_type <- "bipolarization";
        debug_mode <- false;
        current_experiment_id <- "bipol_ndist_speak";
        
        if repulsion_threshold <= confidence_threshold {
            end_simulation <- true;
    	}
        
    }
}

experiment Bt_gen_bipol_dist_speak type: batch repeat: 15 keep_seed: true until: end_simulation or (repulsion_threshold <= confidence_threshold) {
    parameter "Selected debate id" var: selected_debate_id min: 1 max: 100 step: 1; // set to 100 to consider more debates
    parameter "Convergence Rate" var: convergence_rate among: [0.1, 0.2, 0.3, 0.5];
    // ensuring that repulsion_threshold > confidence_threshold is ALWAYS TRUE
    parameter "Confidence Threshold" var: confidence_threshold among: [0.2, 0.3, 0.4, 0.5];
    parameter "Repulsion Threshold" var: repulsion_threshold among: [0.4, 0.5, 0.6, 0.7, 0.8];
    parameter "Repulsion Strength" var: repulsion_strength among: [0.1, 0.2, 0.3];
    
    // agent-level parameters
    parameter "SD Convergence Rate" var: convergence_rate_sd among: [0.0, 0.05, 0.1, 0.2];
    parameter "SD Confidence Threshold" var: confidence_threshold_sd among: [0.0, 0.1, 0.2, 0.3];
    parameter "SD Repulsion Threshold" var: repulsion_threshold_sd among: [0.0, 0.1, 0.2, 0.3];
    parameter "SD Repulsion Strength" var: repulsion_strength_sd among: [0.0, 0.05, 0.1, 0.2];

    method genetic minimize: mae pop_dim: 5 crossover_prob: 0.5 mutation_prob: 0.1
    nb_prelim_gen: 5 max_gen: 5;
   
    init {
        mode_batch <- true;
        convergence_cycle <- -1;
        speaking_mode <- true;
        use_distinct_agents <- true;
        model_type <- "bipolarization";
        debug_mode <- false;
        current_experiment_id <- "bipol_dist_speak";
        
        if repulsion_threshold <= confidence_threshold {
            write "neutral zone is negative, skipping";
            end_simulation <- true;
    	}
        
    }
}

// NO CHANGE EXP
experiment Bt_gen_no_change type: batch repeat: 15 keep_seed: true until: end_simulation {
	parameter "Selected debate id" var: selected_debate_id min: 1 max: 100 step: 1;
	
	method genetic minimize: mae pop_dim: 5 crossover_prob: 0.5 mutation_prob: 0.1
    nb_prelim_gen: 5 max_gen: 5;
	
	init {
		mode_batch <- true;
		model_type <- "no_change";
		convergence_cycle <- -1;
		speaking_mode <- false;
		use_distinct_agents <- false;
		debug_mode <- false;
		current_experiment_id <- "no_change_exp";
		
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
