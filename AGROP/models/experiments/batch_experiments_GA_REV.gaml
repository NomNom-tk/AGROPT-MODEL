// batch exp takes input from main.gaml

model batch_exp_GA

import "../main_4-3.gaml" // relative path back to main


// BATCH EXPERIMENTS: GENETIC ALGORITHM informed by LHS samples
// 6/8/26 step: added to every parameter. Without it GAMA's genetic method has no
// enumeration to search over and evaluates only the interval endpoints.

// Batch Consensus (Genetic)
experiment Bt_gen_cons_ndist type: batch repeat: 1 keep_seed: true until: (debate_counter >= length(m_debate_list) -1 and end_simulation = true) {
    parameter "Convergence Rate" var: convergence_rate min: 0.005 max: 0.1 step: 0.005;

    method genetic minimize: mae_mean_all pop_dim: 5 crossover_prob: 0.5 mutation_prob: 0.1
    nb_prelim_gen: 5 max_gen: 10;

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

        // experiment labels and convergence
        explicit_debates_path <- "";
        end_simulation_at_convergence <- true; // dynamic convergence - "false" is fixed cycles consideration
        selection_mode <- "filter";
        composition_scope <- "all";
    }
}

experiment Bt_gen_cons_dist type: batch repeat: 1 keep_seed: true until: (debate_counter >= length(m_debate_list) -1 and end_simulation = true) {
    parameter "Convergence Rate" var: convergence_rate min: 0.005 max: 0.1 step: 0.005;

    // agent-level params
    parameter "SD Convergence Rate" var: convergence_rate_sd min: 0.0 max: 0.02 step: 0.002;

    method genetic minimize: mae_mean_all pop_dim: 5 crossover_prob: 0.5 mutation_prob: 0.1
    nb_prelim_gen: 5 max_gen: 10;

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

        // experiment labels and convergence
        explicit_debates_path <- "";
        end_simulation_at_convergence <- true;
        selection_mode <- "filter";
        composition_scope <- "all";
    }
}

experiment Bt_gen_cons_ndist_speak type: batch repeat: 1 keep_seed: true until: (debate_counter >= length(m_debate_list) -1 and end_simulation = true) {
    parameter "Convergence Rate" var: convergence_rate min: 0.005 max: 0.1 step: 0.005;

    method genetic minimize: mae_mean_all pop_dim: 5 crossover_prob: 0.5 mutation_prob: 0.1
    nb_prelim_gen: 5 max_gen: 10;

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

        // experiment labels and convergence
        explicit_debates_path <- "";
        end_simulation_at_convergence <- true;
        selection_mode <- "filter";
        composition_scope <- "all";
    }
}

experiment Bt_gen_cons_dist_speak type: batch repeat: 1 keep_seed: true until: (debate_counter >= length(m_debate_list) -1 and end_simulation = true) {
    parameter "Convergence Rate" var: convergence_rate min: 0.005 max: 0.1 step: 0.005;

    // agent-level parameters
    parameter "SD Convergence Rate" var: convergence_rate_sd min: 0.0 max: 0.02 step: 0.002;

    method genetic minimize: mae_mean_all pop_dim: 5 crossover_prob: 0.5 mutation_prob: 0.1
    nb_prelim_gen: 5 max_gen: 10;

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

        // experiment labels and convergence
        explicit_debates_path <- "";
        end_simulation_at_convergence <- true;
        selection_mode <- "filter";
        composition_scope <- "all";
    }
}

// Batch Clustering (Genetic)
experiment Bt_gen_clst_ndist type: batch repeat: 1 keep_seed: true until: (debate_counter >= length(m_debate_list) -1 and end_simulation = true) {
    parameter "Convergence Rate" var: convergence_rate min: 0.005 max: 0.1 step: 0.005;
    parameter "Confidence Threshold" var: confidence_threshold min: 0.1 max: 0.35 step: 0.01;

    method genetic minimize: mae_mean_all pop_dim: 5 crossover_prob: 0.5 mutation_prob: 0.1
    nb_prelim_gen: 5 max_gen: 10;

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

        // experiment labels and convergence
        explicit_debates_path <- "";
        end_simulation_at_convergence <- true;
        selection_mode <- "filter";
        composition_scope <- "all";
    }
}

experiment Bt_gen_clst_dist type: batch repeat: 1 keep_seed: true until: (debate_counter >= length(m_debate_list) -1 and end_simulation = true) {
    parameter "Convergence Rate" var: convergence_rate min: 0.005 max: 0.1 step: 0.005;
    parameter "Confidence Threshold" var: confidence_threshold min: 0.1 max: 0.35 step: 0.01;

    // agent-level parameters
    parameter "SD Convergence Rate" var: convergence_rate_sd min: 0.0 max: 0.02 step: 0.002;
    parameter "SD Confidence Threshold" var: confidence_threshold_sd min: 0.05 max: 0.1 step: 0.005;

    method genetic minimize: mae_mean_all pop_dim: 5 crossover_prob: 0.5 mutation_prob: 0.1
    nb_prelim_gen: 5 max_gen: 10;

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

        // experiment labels and convergence
        explicit_debates_path <- "";
        end_simulation_at_convergence <- true;
        selection_mode <- "filter";
        composition_scope <- "all";
    }
}

experiment Bt_gen_clst_ndist_speak type: batch repeat: 1 keep_seed: true until: (debate_counter >= length(m_debate_list) -1 and end_simulation = true) {
    parameter "Convergence Rate" var: convergence_rate min: 0.005 max: 0.1 step: 0.005;
    parameter "Confidence Threshold" var: confidence_threshold min: 0.1 max: 0.6 step: 0.02;

    method genetic minimize: mae_mean_all pop_dim: 5 crossover_prob: 0.5 mutation_prob: 0.1
    nb_prelim_gen: 5 max_gen: 10;

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

        // experiment labels and convergence
        explicit_debates_path <- "";
        end_simulation_at_convergence <- true;
        selection_mode <- "filter";
        composition_scope <- "all";
    }
}

experiment Bt_gen_clst_dist_speak type: batch repeat: 1 keep_seed: true until: (debate_counter >= length(m_debate_list) -1 and end_simulation = true) {
    parameter "Convergence Rate" var: convergence_rate min: 0.005 max: 0.1 step: 0.005;
    parameter "Confidence Threshold" var: confidence_threshold min: 0.1 max: 0.6 step: 0.02;

    // agent-level parameters
    parameter "SD Convergence Rate" var: convergence_rate_sd min: 0.0 max: 0.02 step: 0.002;
    parameter "SD Confidence Threshold" var: confidence_threshold_sd min: 0.05 max: 0.1 step: 0.005;

    method genetic minimize: mae_mean_all pop_dim: 5 crossover_prob: 0.5 mutation_prob: 0.1
    nb_prelim_gen: 5 max_gen: 10;

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

        // experiment labels and convergence
        explicit_debates_path <- "";
        end_simulation_at_convergence <- true;
        selection_mode <- "filter";
        composition_scope <- "all";
    }
}

// Batch Bipolarization (Genetic)
experiment Bt_gen_bipol_ndist type: batch repeat: 1 keep_seed: true until: (debate_counter >= length(m_debate_list) -1 and end_simulation = true) {
    // ensuring that repulsion_threshold > confidence_threshold is ALWAYS TRUE
    parameter "Convergence Rate" var: convergence_rate min: 0.005 max: 0.1 step: 0.005;
    parameter "Confidence Threshold" var: confidence_threshold min: 0.1 max: 0.3 step: 0.01;
    parameter "Repulsion Strength" var: repulsion_strength min: 0.05 max: 0.2 step: 0.01;
    parameter "Repulsion Threshold" var: repulsion_threshold min: 0.55 max: 0.7 step: 0.01;

    method genetic minimize: mae_mean_all pop_dim: 5 crossover_prob: 0.5 mutation_prob: 0.1
    nb_prelim_gen: 5 max_gen: 10;

    init {
        mode_batch <- true;
        convergence_cycle <- -1;
        speaking_mode <- false;
        use_distinct_agents <- false;
        model_type <- "bipolarization";
        debug_mode <- false;
        current_experiment_id <- "bipol_ndist_nospeak";

        // experiment labels and convergence
        explicit_debates_path <- "";
        end_simulation_at_convergence <- true;
        selection_mode <- "filter";
        composition_scope <- "all";

        if repulsion_threshold <= confidence_threshold {
            infeasible_params <- true;
            end_simulation <- true;
        }
    }
}

experiment Bt_gen_bipol_dist type: batch repeat: 1 keep_seed: true until: (debate_counter >= length(m_debate_list) -1 and end_simulation = true) {
    // ensuring that repulsion_threshold > confidence_threshold is ALWAYS TRUE
    parameter "Convergence Rate" var: convergence_rate min: 0.005 max: 0.1 step: 0.005;
    parameter "Confidence Threshold" var: confidence_threshold min: 0.1 max: 0.3 step: 0.01;
    parameter "Repulsion Strength" var: repulsion_strength min: 0.05 max: 0.2 step: 0.01;
    parameter "Repulsion Threshold" var: repulsion_threshold min: 0.55 max: 0.7 step: 0.01;

    // agent-level parameters
    parameter "SD Convergence Rate" var: convergence_rate_sd min: 0.0 max: 0.02 step: 0.002;
    parameter "SD Confidence Threshold" var: confidence_threshold_sd min: 0.0 max: 0.02 step: 0.002;
    parameter "SD Repulsion Strength" var: repulsion_strength_sd min: 0.0 max: 0.02 step: 0.002;
    parameter "SD Repulsion Threshold" var: repulsion_threshold_sd min: 0.0 max: 0.03 step: 0.003;

    method genetic minimize: mae_mean_all pop_dim: 5 crossover_prob: 0.5 mutation_prob: 0.1
    nb_prelim_gen: 5 max_gen: 10;

    init {
        mode_batch <- true;
        convergence_cycle <- -1;
        speaking_mode <- false;
        use_distinct_agents <- true;
        model_type <- "bipolarization";
        debug_mode <- false;
        current_experiment_id <- "bipol_dist_nospeak";

        // experiment labels and convergence
        explicit_debates_path <- "";
        end_simulation_at_convergence <- true;
        selection_mode <- "filter";
        composition_scope <- "all";

        if repulsion_threshold <= confidence_threshold {
            infeasible_params <- true;
            end_simulation <- true;
        }
    }
}

// until: condition modified so that it fires regardless of exp init
experiment Bt_gen_bipol_ndist_speak type: batch repeat: 1 keep_seed: true until: (debate_counter >= length(m_debate_list) -1 and end_simulation = true) {
    // ensuring that repulsion_threshold > confidence_threshold is ALWAYS TRUE
    parameter "Convergence Rate" var: convergence_rate min: 0.005 max: 0.1 step: 0.005;
    parameter "Confidence Threshold" var: confidence_threshold min: 0.1 max: 0.3 step: 0.01;
    parameter "Repulsion Strength" var: repulsion_strength min: 0.05 max: 0.2 step: 0.01;
    parameter "Repulsion Threshold" var: repulsion_threshold min: 0.55 max: 0.7 step: 0.01;

    method genetic minimize: mae_mean_all pop_dim: 5 crossover_prob: 0.5 mutation_prob: 0.1
    nb_prelim_gen: 5 max_gen: 10;

    init {
        mode_batch <- true;
        convergence_cycle <- -1;
        speaking_mode <- true;
        use_distinct_agents <- false;
        model_type <- "bipolarization";
        debug_mode <- false;
        current_experiment_id <- "bipol_ndist_speak";

        // experiment labels and convergence
        explicit_debates_path <- "";
        end_simulation_at_convergence <- true;
        selection_mode <- "filter";
        composition_scope <- "all";

        if repulsion_threshold <= confidence_threshold {
            infeasible_params <- true;
            end_simulation <- true;
        }
    }
}

experiment Bt_gen_bipol_dist_speak type: batch repeat: 1 keep_seed: true until: (debate_counter >= length(m_debate_list) -1 and end_simulation = true) {
    // ensuring that repulsion_threshold > confidence_threshold is ALWAYS TRUE
    parameter "Convergence Rate" var: convergence_rate min: 0.005 max: 0.1 step: 0.005;
    parameter "Confidence Threshold" var: confidence_threshold min: 0.1 max: 0.3 step: 0.01;
    parameter "Repulsion Strength" var: repulsion_strength min: 0.05 max: 0.2 step: 0.01;
    parameter "Repulsion Threshold" var: repulsion_threshold min: 0.55 max: 0.7 step: 0.01;

    // agent-level parameters
    parameter "SD Convergence Rate" var: convergence_rate_sd min: 0.0 max: 0.02 step: 0.002;
    parameter "SD Confidence Threshold" var: confidence_threshold_sd min: 0.0 max: 0.02 step: 0.002;
    parameter "SD Repulsion Strength" var: repulsion_strength_sd min: 0.0 max: 0.02 step: 0.002;
    parameter "SD Repulsion Threshold" var: repulsion_threshold_sd min: 0.0 max: 0.03 step: 0.003;

    method genetic minimize: mae_mean_all pop_dim: 5 crossover_prob: 0.5 mutation_prob: 0.1
    nb_prelim_gen: 5 max_gen: 10;

    init {
        mode_batch <- true;
        convergence_cycle <- -1;
        speaking_mode <- true;
        use_distinct_agents <- true;
        model_type <- "bipolarization";
        debug_mode <- false;
        current_experiment_id <- "bipol_dist_speak";

        // experiment labels and convergence
        explicit_debates_path <- "";
        end_simulation_at_convergence <- true;
        selection_mode <- "filter";
        composition_scope <- "all";

        if repulsion_threshold <= confidence_threshold {
            infeasible_params <- true;
            end_simulation <- true;
        }
    }
}

// NO CHANGE EXP — no parameters to search, so no method. Runs once through all debates.
experiment Bt_gen_no_change type: batch repeat: 1 keep_seed: true until: (debate_counter >= length(m_debate_list) -1 and end_simulation = true) {

    init {
        mode_batch <- true;
        model_type <- "no_change";
        convergence_cycle <- -1;
        speaking_mode <- false;
        use_distinct_agents <- false;
        debug_mode <- false;
        current_experiment_id <- "no_change_exp";

        // experiment labels and convergence
        explicit_debates_path <- "";
        end_simulation_at_convergence <- true;
        selection_mode <- "filter";
        composition_scope <- "all";
    }
}

experiment Batch_argumentative_gen type: batch repeat: 30 keep_seed: true until: end_simulation {
    parameter "Selected debate id" var: selected_debate_id min: 1 max: 55 step: 1;
    parameter "Convergence Rate" var: convergence_rate among: [0.1, 0.2, 0.3, 0.5];

    // homophily parameter
    //parameter "Homophily Strength" var: homophily_strength among: [0.0, 0.3, 0.5, 0.7, 1.0];

    method genetic minimize: mae_mean_all pop_dim: 5 crossover_prob: 0.5 mutation_prob: 0.1
    nb_prelim_gen: 5 max_gen: 5;

    init {
        mode_batch <- true;
        model_type <- "argumentative";
        convergence_cycle <- -1;
    }
}
