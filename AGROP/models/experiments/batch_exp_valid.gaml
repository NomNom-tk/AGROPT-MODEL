/**
* Name: batchexpannealing
* Based on the internal empty template. 
* Author: alfajor
* Tags: 
*/


model batchexpvalid

import "../main_4-3.gaml"

// Batch Consensus (Genetic) 
experiment Bt_valid_cons_ndist type: batch repeat: 5 keep_seed: true until: end_simulation {
    parameter "Selected debate id" var: selected_debate_id among: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
    
    method exploration;
   
    init {
        mode_batch <- true;
        convergence_cycle <- -1;
        speaking_mode <- false;
        use_distinct_agents <- false;
        model_type <- "consensus";
        debug_mode <- false;
        current_experiment_id <- "cons_ndist_nospeak";
        
        // SET PARAMS FOR EXP
        convergence_rate <- 0.05;
        confidence_threshold <- 0.0;
        repulsion_threshold <- 0.0;
        repulsion_strength <- 0.0;
        confidence_threshold_sd <- 0.0;
        repulsion_threshold_sd <- 0.0;
        repulsion_strength_sd <- 0.0;
        convergence_rate_sd <- 0.0;
        
    }
}

experiment Bt_valid_cons_dist type: batch repeat: 5 keep_seed: true until: end_simulation {
    parameter "Selected debate id" var: selected_debate_id among: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
    
    method exploration;
   
    init {
        mode_batch <- true;
        convergence_cycle <- -1;
        speaking_mode <- false;
        use_distinct_agents <- true;
        model_type <- "consensus";
        debug_mode <- false;
        current_experiment_id <- "cons_dist_nospeak";
        
        // SET PARAMS FOR EXP
        convergence_rate <- 0.05;
        confidence_threshold <- 0.0;
        repulsion_threshold <- 0.0;
        repulsion_strength <- 0.0;
        confidence_threshold_sd <- 0.0;
        repulsion_threshold_sd <- 0.0;
        repulsion_strength_sd <- 0.0;
        convergence_rate_sd <- 0.0;
    }
}

experiment Bt_valid_cons_ndist_speak type: batch repeat: 5 keep_seed: true until: end_simulation {
    parameter "Selected debate id" var: selected_debate_id among: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];

    method exploration;
   
    init {
        mode_batch <- true;
        convergence_cycle <- -1;
        speaking_mode <- true;
        use_distinct_agents <- false;
        model_type <- "consensus";
        debug_mode <- false;
        current_experiment_id <- "cons_ndist_speak";
        
        // SET PARAMS FOR EXP
        convergence_rate <- 0.05;
        confidence_threshold <- 0.0;
        repulsion_threshold <- 0.0;
        repulsion_strength <- 0.0;
        confidence_threshold_sd <- 0.0;
        repulsion_threshold_sd <- 0.0;
        repulsion_strength_sd <- 0.0;
        convergence_rate_sd <- 0.0;
    }
}

experiment Bt_valid_cons_dist_speak type: batch repeat: 5 keep_seed: true until: end_simulation {
    parameter "Selected debate id" var: selected_debate_id among: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
    
    method exploration;
   
    init {
        mode_batch <- true;
        convergence_cycle <- -1;
        speaking_mode <- true;
        use_distinct_agents <- true;
        model_type <- "consensus";
        debug_mode <- false;
        current_experiment_id <- "cons_dist_speak";
        
        // SET PARAMS FOR EXP
        convergence_rate <- 0.05;
        confidence_threshold <- 0.0;
        repulsion_threshold <- 0.0;
        repulsion_strength <- 0.0;
        confidence_threshold_sd <- 0.0;
        repulsion_threshold_sd <- 0.0;
        repulsion_strength_sd <- 0.0;
        convergence_rate_sd <- 0.0;
    }
}

// Batch Clustering (Genetic)
experiment Bt_valid_clst_ndist type: batch repeat: 5 keep_seed: true until: end_simulation {
    parameter "Selected debate id" var: selected_debate_id among: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];

    method exploration;

    init {
        mode_batch <- true;
        convergence_cycle <- -1;
        speaking_mode <- false;
        use_distinct_agents <- false;
        model_type <- "clustering";
        debug_mode <- false;
        current_experiment_id <- "clst_ndist_nospeak";
        
        // SET PARAMS FOR EXP
        convergence_rate <- 0.05;
        confidence_threshold <- 0.2;
        repulsion_threshold <- 0.0;
        repulsion_strength <- 0.0;
        confidence_threshold_sd <- 0.0;
        repulsion_threshold_sd <- 0.0;
        repulsion_strength_sd <- 0.0;
        convergence_rate_sd <- 0.0;
    }
}

experiment Bt_valid_clst_dist type: batch repeat: 5 keep_seed: true until: end_simulation {
    parameter "Selected debate id" var: selected_debate_id among: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];


    method exploration;

    init {
        mode_batch <- true;
        convergence_cycle <- -1;
        speaking_mode <- false;
        use_distinct_agents <- true;
        model_type <- "clustering";
        debug_mode <- false;
        current_experiment_id <- "clst_dist_nospeak";
                
        // SET PARAMS FOR EXP
        convergence_rate <- 0.05;
        confidence_threshold <- 0.8;
        repulsion_threshold <- 0.0;
        repulsion_strength <- 0.0;
        confidence_threshold_sd <- 0.0;
        repulsion_threshold_sd <- 0.0;
        repulsion_strength_sd <- 0.0;
        convergence_rate_sd <- 0.0;
    }
}

experiment Bt_valid_clst_ndist_speak type: batch repeat: 5 keep_seed: true until: end_simulation {
    parameter "Selected debate id" var: selected_debate_id among: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];

    method exploration;

    init {
        mode_batch <- true;
        convergence_cycle <- -1;
        speaking_mode <- true;
        use_distinct_agents <- false;
        model_type <- "clustering";
        debug_mode <- false;
        current_experiment_id <- "clst_ndist_speak";
        
        // SET PARAMS FOR EXP
        convergence_rate <- 0.05;
        confidence_threshold <- 0.2;
        repulsion_threshold <- 0.0;
        repulsion_strength <- 0.0;
        confidence_threshold_sd <- 0.0;
        repulsion_threshold_sd <- 0.0;
        repulsion_strength_sd <- 0.0;
        convergence_rate_sd <- 0.0;
    }
}

experiment Bt_valid_clst_dist_speak type: batch repeat: 5 keep_seed: true until: end_simulation {
    parameter "Selected debate id" var: selected_debate_id among: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];

    method exploration;

    init {
        mode_batch <- true;
        convergence_cycle <- -1;
        speaking_mode <- true;
        use_distinct_agents <- true;
        model_type <- "clustering";
        debug_mode <- false;
        current_experiment_id <- "clst_dist_speak";
   
        // SET PARAMS FOR EXP
        convergence_rate <- 0.05;
        confidence_threshold <- 0.8;
        repulsion_threshold <- 0.0;
        repulsion_strength <- 0.0;
        confidence_threshold_sd <- 0.0;
        repulsion_threshold_sd <- 0.0;
        repulsion_strength_sd <- 0.0;
        convergence_rate_sd <- 0.0;
    }
}

// Batch Bipolarization (Genetic)
experiment Bt_valid_bipol_ndist type: batch repeat: 5 keep_seed: true until: end_simulation or (repulsion_threshold <= confidence_threshold) {
    parameter "Selected debate id" var: selected_debate_id among: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];

    method exploration;
   
    init {
        mode_batch <- true;
        convergence_cycle <- -1;
        speaking_mode <- false;
        use_distinct_agents <- false;
        model_type <- "bipolarization";
        debug_mode <- false;
        current_experiment_id <- "bipol_ndist_nospeak";
        
        // SET PARAMS FOR EXP
        convergence_rate <- 0.05;
        confidence_threshold <- 0.1;
        repulsion_threshold <- 0.8;
        repulsion_strength <- 0.3;
        confidence_threshold_sd <- 0.0;
        repulsion_threshold_sd <- 0.0;
        repulsion_strength_sd <- 0.0;
        convergence_rate_sd <- 0.0;
        
        if repulsion_threshold <= confidence_threshold {
            end_simulation <- true;
    	}
	}
}


experiment Bt_valid_bipol_dist type: batch repeat: 5 keep_seed: true until: end_simulation or (repulsion_threshold <= confidence_threshold) {
    parameter "Selected debate id" var: selected_debate_id among: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];

    method exploration;
   
    init {
        mode_batch <- true;
        convergence_cycle <- -1;
        speaking_mode <- false;
        use_distinct_agents <- true;
        model_type <- "bipolarization";
        debug_mode <- false;
        current_experiment_id <- "bipol_dist_nospeak";
        
        // SET PARAMS FOR EXP
        convergence_rate <- 0.23;
        confidence_threshold <- 0.1;
        repulsion_threshold <- 0.62;
        repulsion_strength <- 0.18;
        confidence_threshold_sd <- 0.0;
        repulsion_threshold_sd <- 0.1643168;
        repulsion_strength_sd <- 0.1095445;
        convergence_rate_sd <- 0.2464752;
        
        if repulsion_threshold <= confidence_threshold {
            end_simulation <- true;
    	}

    }
}

// until: condition modified so that it fires regardless of exp init
experiment Bt_valid_bipol_ndist_speak type: batch repeat: 5 keep_seed: true until: end_simulation or (repulsion_threshold <= confidence_threshold) {
    parameter "Selected debate id" var: selected_debate_id among: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
    

    method exploration;
   
    init {
        mode_batch <- true;
        convergence_cycle <- -1;
        speaking_mode <- true;
        use_distinct_agents <- false;
        model_type <- "bipolarization";
        debug_mode <- false;
        current_experiment_id <- "bipol_ndist_speak";
        
        // SET PARAMS FOR EXP
        convergence_rate <- 0.05;
        confidence_threshold <- 0.1;
        repulsion_threshold <- 0.8;
        repulsion_strength <- 0.3;
        confidence_threshold_sd <- 0.0;
        repulsion_threshold_sd <- 0.0;
        repulsion_strength_sd <- 0.0;
        convergence_rate_sd <- 0.0;
        
        if repulsion_threshold <= confidence_threshold {
            end_simulation <- true;
    	}
        
    }
}

experiment Bt_valid_bipol_dist_speak type: batch repeat: 5 keep_seed: true until: end_simulation or (repulsion_threshold <= confidence_threshold) {
    parameter "Selected debate id" var: selected_debate_id among: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];

    method exploration;
   
    init {
        mode_batch <- true;
        convergence_cycle <- -1;
        speaking_mode <- true;
        use_distinct_agents <- true;
        model_type <- "bipolarization";
        debug_mode <- false;
        current_experiment_id <- "bipol_dist_speak";
        
        // SET PARAMS FOR EXP
        convergence_rate <- 0.23;
        confidence_threshold <- 0.1;
        repulsion_threshold <- 0.62;
        repulsion_strength <- 0.18;
        confidence_threshold_sd <- 0.0;
        repulsion_threshold_sd <- 0.1643168;
        repulsion_strength_sd <- 0.1095445;
        convergence_rate_sd <- 0.2464752;
        
        if repulsion_threshold <= confidence_threshold {
            write "neutral zone is negative, skipping";
            end_simulation <- true;
    	}
        
    }
}

// NO CHANGE EXP
experiment Bt_valid_no_change type: batch repeat: 5 keep_seed: true until: end_simulation {
	parameter "Selected debate id" var: selected_debate_id among: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
	
	method exploration;
	
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

