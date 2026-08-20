/**
* Name: batchexpannealing
* Based on the internal empty template. 
* Author: alfajor
* Tags: 
*/


model batchexpannealing

import "../main_4-3.gaml"

// Batch Consensus (Genetic) 
experiment Bt_anneal_cons_ndist type: batch repeat: 5 keep_seed: true until: end_simulation {
    parameter "Selected debate id" var: selected_debate_id min: 1 max: 44 step: 1;
    parameter "Convergence Rate" var: convergence_rate min: 0.05 max: 0.5;
    
    method annealing minimize: mae nb_iter_cst_temp: 10 temp_decrease: 0.7 temp_init: 1.0
    temp_end: 0.05;
   
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

experiment Bt_anneal_cons_dist type: batch repeat: 5 keep_seed: true until: end_simulation {
    parameter "Selected debate id" var: selected_debate_id min: 1 max: 44 step: 1;
    parameter "Convergence Rate" var: convergence_rate min: 0.05 max: 0.5;
    
    // agent level params
    parameter "SD Convergence Rate" var: convergence_rate_sd min: 0.0 max: 0.2;
    
    method annealing minimize: mae nb_iter_cst_temp: 10 temp_decrease: 0.7 temp_init: 1.0
    temp_end: 0.05;
   
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

experiment Bt_anneal_cons_ndist_speak type: batch repeat: 5 keep_seed: true until: end_simulation {
    parameter "Selected debate id" var: selected_debate_id min: 1 max: 44 step: 1;
    parameter "Convergence Rate" var: convergence_rate min: 0.05 max: 0.5;

    method annealing minimize: mae nb_iter_cst_temp: 10 temp_decrease: 0.7 temp_init: 1.0
    temp_end: 0.05;
   
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

experiment Bt_anneal_cons_dist_speak type: batch repeat: 5 keep_seed: true until: end_simulation {
    parameter "Selected debate id" var: selected_debate_id min: 1 max: 44 step: 1;
    parameter "Convergence Rate" var: convergence_rate min: 0.05 max: 0.5;
    
    // agent level params
    parameter "SD Convergence Rate" var: convergence_rate_sd min: 0.0 max: 0.2;
    
    method annealing minimize: mae nb_iter_cst_temp: 10 temp_decrease: 0.7 temp_init: 1.0
    temp_end: 0.05;
   
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
experiment Bt_anneal_clst_ndist type: batch repeat: 5 keep_seed: true until: end_simulation {
    parameter "Selected debate id" var: selected_debate_id min: 1 max: 44 step: 1;
    parameter "Convergence Rate" var: convergence_rate min: 0.05 max: 0.5;
    parameter "Confidence Threshold" var: confidence_threshold min: 0.2 max: 0.8;

    method annealing minimize: mae nb_iter_cst_temp: 10 temp_decrease: 0.7 temp_init: 1.0
    temp_end: 0.05;

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

experiment Bt_anneal_clst_dist type: batch repeat: 5 keep_seed: true until: end_simulation {
    parameter "Selected debate id" var: selected_debate_id min: 1 max: 44 step: 1;
    parameter "Convergence Rate" var: convergence_rate min: 0.05 max: 0.5;
    parameter "Confidence Threshold" var: confidence_threshold min: 0.2 max: 0.8;
    
    // agent level parameters
    parameter "SD Convergence Rate" var: convergence_rate_sd min: 0.0 max: 0.2;
    parameter "SD Confidence Threshold" var: confidence_threshold_sd min: 0.0 max: 0.3;

    method annealing minimize: mae nb_iter_cst_temp: 10 temp_decrease: 0.7 temp_init: 1.0
    temp_end: 0.05;

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

experiment Bt_anneal_clst_ndist_speak type: batch repeat: 5 keep_seed: true until: end_simulation {
    parameter "Selected debate id" var: selected_debate_id min: 1 max: 44 step: 1;
    parameter "Convergence Rate" var: convergence_rate min: 0.05 max: 0.5;
    parameter "Confidence Threshold" var: confidence_threshold min: 0.2 max: 0.8;

    method annealing minimize: mae nb_iter_cst_temp: 10 temp_decrease: 0.7 temp_init: 1.0
    temp_end: 0.05;

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

experiment Bt_anneal_clst_dist_speak type: batch repeat: 5 keep_seed: true until: end_simulation {
    parameter "Selected debate id" var: selected_debate_id min: 1 max: 44 step: 1;
    parameter "Convergence Rate" var: convergence_rate min: 0.05 max: 0.5;
    parameter "Confidence Threshold" var: confidence_threshold min: 0.2 max: 0.8;
    
    // agent level parameters
    parameter "SD Convergence Rate" var: convergence_rate_sd min: 0.0 max: 0.2;
    parameter "SD Confidence Threshold" var: confidence_threshold_sd min: 0.0 max: 0.3;

    method annealing minimize: mae nb_iter_cst_temp: 10 temp_decrease: 0.7 temp_init: 1.0
    temp_end: 0.05;

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
experiment Bt_anneal_bipol_ndist type: batch repeat: 5 keep_seed: true until: end_simulation or (repulsion_threshold <= confidence_threshold) {
    parameter "Selected debate id" var: selected_debate_id min: 1 max: 44 step: 1;
    // ensuring that repulsion_threshold > confidence_threshold is ALWAYS TRUE
    parameter "Convergence Rate" var: convergence_rate min: 0.05 max: 0.5;
    parameter "Confidence Threshold" var: confidence_threshold min: 0.1 max: 0.4;
    parameter "Repulsion Strength" var: repulsion_strength min: 0.1 max: 0.2;
    parameter "Repulsion Threshold" var: repulsion_threshold min: 0.5 max: 0.8;

    method annealing minimize: mae nb_iter_cst_temp: 10 temp_decrease: 0.7 temp_init: 1.0
    temp_end: 0.05;
   
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


experiment Bt_anneal_bipol_dist type: batch repeat: 5 keep_seed: true until: end_simulation or (repulsion_threshold <= confidence_threshold) {
    parameter "Selected debate id" var: selected_debate_id min: 1 max: 44 step: 1;
    // ensuring that repulsion_threshold > confidence_threshold is ALWAYS TRUE
    parameter "Convergence Rate" var: convergence_rate min: 0.05 max: 0.5;
    parameter "Confidence Threshold" var: confidence_threshold min: 0.1 max: 0.4;
    parameter "Repulsion Strength" var: repulsion_strength min: 0.1 max: 0.2;
    parameter "Repulsion Threshold" var: repulsion_threshold min: 0.5 max: 0.8;
    
    // agent level parameters
    parameter "SD Convergence Rate" var: convergence_rate_sd min: 0.0 max: 0.2;
    parameter "SD Confidence Threshold" var: confidence_threshold_sd min: 0.0 max: 0.3;
    parameter "SD Repulsion Strength" var: repulsion_strength_sd min: 0.0 max: 0.2;
    parameter "SD Repulsion Threshold" var: repulsion_threshold_sd min: 0.0 max: 0.3;


    method annealing minimize: mae nb_iter_cst_temp: 10 temp_decrease: 0.7 temp_init: 1.0
    temp_end: 0.05;
   
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
experiment Bt_anneal_bipol_ndist_speak type: batch repeat: 5 keep_seed: true until: end_simulation or (repulsion_threshold <= confidence_threshold) {
    parameter "Selected debate id" var: selected_debate_id min: 1 max: 44 step: 1;
    // ensuring that repulsion_threshold > confidence_threshold is ALWAYS TRUE
    parameter "Convergence Rate" var: convergence_rate min: 0.05 max: 0.5;
    parameter "Confidence Threshold" var: confidence_threshold min: 0.1 max: 0.4;
    parameter "Repulsion Strength" var: repulsion_strength min: 0.1 max: 0.2;
    parameter "Repulsion Threshold" var: repulsion_threshold min: 0.5 max: 0.8;
    

    method annealing minimize: mae nb_iter_cst_temp: 10 temp_decrease: 0.7 temp_init: 1.0
    temp_end: 0.05;
   
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

experiment Bt_anneal_bipol_dist_speak type: batch repeat: 5 keep_seed: true until: end_simulation or (repulsion_threshold <= confidence_threshold) {
    parameter "Selected debate id" var: selected_debate_id min: 1 max: 44 step: 1;
    // ensuring that repulsion_threshold > confidence_threshold is ALWAYS TRUE
    parameter "Convergence Rate" var: convergence_rate min: 0.05 max: 0.5;
    parameter "Confidence Threshold" var: confidence_threshold min: 0.1 max: 0.4;
    parameter "Repulsion Strength" var: repulsion_strength min: 0.1 max: 0.2;
    parameter "Repulsion Threshold" var: repulsion_threshold min: 0.5 max: 0.8;
    
    // agent level parameters
    parameter "SD Convergence Rate" var: convergence_rate_sd min: 0.0 max: 0.2;
    parameter "SD Confidence Threshold" var: confidence_threshold_sd min: 0.0 max: 0.3;
    parameter "SD Repulsion Strength" var: repulsion_strength_sd min: 0.0 max: 0.2;
    parameter "SD Repulsion Threshold" var: repulsion_threshold_sd min: 0.0 max: 0.3;

    method annealing minimize: mae nb_iter_cst_temp: 10 temp_decrease: 0.7 temp_init: 1.0
    temp_end: 0.05;
   
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
experiment Bt_anneal_no_change type: batch repeat: 5 keep_seed: true until: end_simulation {
	parameter "Selected debate id" var: selected_debate_id min: 1 max: 44 step: 1;
	
	method annealing minimize: mae nb_iter_cst_temp: 10 temp_decrease: 0.7 temp_init: 1.0
    temp_end: 0.05;
	
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

