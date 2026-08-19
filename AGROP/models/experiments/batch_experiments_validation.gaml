// batch exp takes input from main.gaml

model batch_exp_validation

import "../main_4-3.gaml"


// HELD-OUT VALIDATION RUN
// ---------------------------------------------------------------------------
// No parameter search. Each experiment fixes the GA-calibrated parameter set
// for its design cell and evaluates it once on the held-out debates.
//
// BEFORE RUNNING:
//   1. Parameters.gaml -> data_path must point at test_data.csv (12 debates)
//   2. Redirect output to a separate directory or filename prefix so these
//      rows do not append to the GA output
//
// NOTE: selected_debate_id is an index into whichever labels are loaded, so it
// is NOT comparable across train and test files. Join on debate_label.
//
// Calibrated values are the per-cell minimum mean MAE over 43 training debates.
// SD parameters are 0.0 in every ndist cell: those experiments declared no SD
// parameters, so the GA never varied them and they are inert when
// use_distinct_agents = false.
// ---------------------------------------------------------------------------


// ===== CONSENSUS =====

experiment Val_cons_ndist type: batch repeat: 1 keep_seed: true until: (debate_counter >= length(m_debate_list) -1 and end_simulation = true) {
    init {
        mode_batch <- true;
        convergence_cycle <- -1;
        speaking_mode <- false;
        use_distinct_agents <- false;
        model_type <- "consensus";
        debug_mode <- false;
        current_experiment_id <- "cons_ndist_nospeak";

        // GA-calibrated (train MAE 0.0428)
        convergence_rate <- 0.005;

        confidence_threshold <- 0.0;
        repulsion_threshold <- 0.0;
        repulsion_strength <- 0.0;
        convergence_rate_sd <- 0.0;
        confidence_threshold_sd <- 0.0;
        repulsion_threshold_sd <- 0.0;
        repulsion_strength_sd <- 0.0;

        explicit_debates_path <- "";
        end_simulation_at_convergence <- true;
        selection_mode <- "filter";
        composition_scope <- "ALL";
    }
}

experiment Val_cons_dist type: batch repeat: 1 keep_seed: true until: (debate_counter >= length(m_debate_list) -1 and end_simulation = true) {
    init {
        mode_batch <- true;
        convergence_cycle <- -1;
        speaking_mode <- false;
        use_distinct_agents <- true;
        model_type <- "consensus";
        debug_mode <- false;
        current_experiment_id <- "cons_dist_nospeak";

        // GA-calibrated (train MAE 0.0427)
        convergence_rate <- 0.005;
        convergence_rate_sd <- 0.002;

        confidence_threshold <- 0.0;
        repulsion_threshold <- 0.0;
        repulsion_strength <- 0.0;
        confidence_threshold_sd <- 0.0;
        repulsion_threshold_sd <- 0.0;
        repulsion_strength_sd <- 0.0;

        explicit_debates_path <- "";
        end_simulation_at_convergence <- true;
        selection_mode <- "filter";
        composition_scope <- "ALL";
    }
}

experiment Val_cons_ndist_speak type: batch repeat: 1 keep_seed: true until: (debate_counter >= length(m_debate_list) -1 and end_simulation = true) {
    init {
        mode_batch <- true;
        convergence_cycle <- -1;
        speaking_mode <- true;
        use_distinct_agents <- false;
        model_type <- "consensus";
        debug_mode <- false;
        current_experiment_id <- "cons_ndist_speak";

        // GA-calibrated (train MAE 0.0429)
        convergence_rate <- 0.015;

        confidence_threshold <- 0.0;
        repulsion_threshold <- 0.0;
        repulsion_strength <- 0.0;
        convergence_rate_sd <- 0.0;
        confidence_threshold_sd <- 0.0;
        repulsion_threshold_sd <- 0.0;
        repulsion_strength_sd <- 0.0;

        explicit_debates_path <- "";
        end_simulation_at_convergence <- true;
        selection_mode <- "filter";
        composition_scope <- "ALL";
    }
}

experiment Val_cons_dist_speak type: batch repeat: 1 keep_seed: true until: (debate_counter >= length(m_debate_list) -1 and end_simulation = true) {
    init {
        mode_batch <- true;
        convergence_cycle <- -1;
        speaking_mode <- true;
        use_distinct_agents <- true;
        model_type <- "consensus";
        debug_mode <- false;
        current_experiment_id <- "cons_dist_speak";

        // GA-calibrated (train MAE 0.0428)
        convergence_rate <- 0.01;
        convergence_rate_sd <- 0.01;

        confidence_threshold <- 0.0;
        repulsion_threshold <- 0.0;
        repulsion_strength <- 0.0;
        confidence_threshold_sd <- 0.0;
        repulsion_threshold_sd <- 0.0;
        repulsion_strength_sd <- 0.0;

        explicit_debates_path <- "";
        end_simulation_at_convergence <- true;
        selection_mode <- "filter";
        composition_scope <- "ALL";
    }
}


// ===== CLUSTERING =====

experiment Val_clst_ndist type: batch repeat: 1 keep_seed: true until: (debate_counter >= length(m_debate_list) -1 and end_simulation = true) {
    init {
        mode_batch <- true;
        convergence_cycle <- -1;
        speaking_mode <- false;
        use_distinct_agents <- false;
        model_type <- "clustering";
        debug_mode <- false;
        current_experiment_id <- "clst_ndist_nospeak";

        // GA-calibrated (train MAE 0.0426)
        convergence_rate <- 0.01;
        confidence_threshold <- 0.21;

        repulsion_threshold <- 0.0;
        repulsion_strength <- 0.0;
        convergence_rate_sd <- 0.0;
        confidence_threshold_sd <- 0.0;
        repulsion_threshold_sd <- 0.0;
        repulsion_strength_sd <- 0.0;

        explicit_debates_path <- "";
        end_simulation_at_convergence <- true;
        selection_mode <- "filter";
        composition_scope <- "ALL";
    }
}

experiment Val_clst_dist type: batch repeat: 1 keep_seed: true until: (debate_counter >= length(m_debate_list) -1 and end_simulation = true) {
    init {
        mode_batch <- true;
        convergence_cycle <- -1;
        speaking_mode <- false;
        use_distinct_agents <- true;
        model_type <- "clustering";
        debug_mode <- false;
        current_experiment_id <- "clst_dist_nospeak";

        // GA-calibrated (train MAE 0.0427)
        convergence_rate <- 0.005;
        confidence_threshold <- 0.31;
        convergence_rate_sd <- 0.0;
        confidence_threshold_sd <- 0.055;

        repulsion_threshold <- 0.0;
        repulsion_strength <- 0.0;
        repulsion_threshold_sd <- 0.0;
        repulsion_strength_sd <- 0.0;

        explicit_debates_path <- "";
        end_simulation_at_convergence <- true;
        selection_mode <- "filter";
        composition_scope <- "ALL";
    }
}

experiment Val_clst_ndist_speak type: batch repeat: 1 keep_seed: true until: (debate_counter >= length(m_debate_list) -1 and end_simulation = true) {
    init {
        mode_batch <- true;
        convergence_cycle <- -1;
        speaking_mode <- true;
        use_distinct_agents <- false;
        model_type <- "clustering";
        debug_mode <- false;
        current_experiment_id <- "clst_ndist_speak";

        // GA-calibrated (train MAE 0.0429)
        convergence_rate <- 0.01;
        confidence_threshold <- 0.32;

        repulsion_threshold <- 0.0;
        repulsion_strength <- 0.0;
        convergence_rate_sd <- 0.0;
        confidence_threshold_sd <- 0.0;
        repulsion_threshold_sd <- 0.0;
        repulsion_strength_sd <- 0.0;

        explicit_debates_path <- "";
        end_simulation_at_convergence <- true;
        selection_mode <- "filter";
        composition_scope <- "ALL";
    }
}

experiment Val_clst_dist_speak type: batch repeat: 1 keep_seed: true until: (debate_counter >= length(m_debate_list) -1 and end_simulation = true) {
    init {
        mode_batch <- true;
        convergence_cycle <- -1;
        speaking_mode <- true;
        use_distinct_agents <- true;
        model_type <- "clustering";
        debug_mode <- false;
        current_experiment_id <- "clst_dist_speak";

        // GA-calibrated (train MAE 0.0426)
        convergence_rate <- 0.055;
        confidence_threshold <- 0.14;
        convergence_rate_sd <- 0.016;
        confidence_threshold_sd <- 0.075;

        repulsion_threshold <- 0.0;
        repulsion_strength <- 0.0;
        repulsion_threshold_sd <- 0.0;
        repulsion_strength_sd <- 0.0;

        explicit_debates_path <- "";
        end_simulation_at_convergence <- true;
        selection_mode <- "filter";
        composition_scope <- "ALL";
    }
}


// ===== BIPOLARIZATION =====

experiment Val_bipol_ndist type: batch repeat: 1 keep_seed: true until: (debate_counter >= length(m_debate_list) -1 and end_simulation = true) {
    init {
        mode_batch <- true;
        convergence_cycle <- -1;
        speaking_mode <- false;
        use_distinct_agents <- false;
        model_type <- "bipolarization";
        debug_mode <- false;
        current_experiment_id <- "bipol_ndist_nospeak";

        // GA-calibrated (train MAE 0.0425)
        convergence_rate <- 0.015;
        confidence_threshold <- 0.19;
        repulsion_threshold <- 0.57;
        repulsion_strength <- 0.09;

        convergence_rate_sd <- 0.0;
        confidence_threshold_sd <- 0.0;
        repulsion_threshold_sd <- 0.0;
        repulsion_strength_sd <- 0.0;

        explicit_debates_path <- "";
        end_simulation_at_convergence <- true;
        selection_mode <- "filter";
        composition_scope <- "ALL";

        if repulsion_threshold <= confidence_threshold {
            infeasible_params <- true;
            end_simulation <- true;
        }
    }
}

experiment Val_bipol_dist type: batch repeat: 1 keep_seed: true until: (debate_counter >= length(m_debate_list) -1 and end_simulation = true) {
    init {
        mode_batch <- true;
        convergence_cycle <- -1;
        speaking_mode <- false;
        use_distinct_agents <- true;
        model_type <- "bipolarization";
        debug_mode <- false;
        current_experiment_id <- "bipol_dist_nospeak";

        // GA-calibrated (train MAE 0.0422 — best cell)
        convergence_rate <- 0.025;
        confidence_threshold <- 0.16;
        repulsion_threshold <- 0.62;
        repulsion_strength <- 0.05;
        convergence_rate_sd <- 0.0;
        confidence_threshold_sd <- 0.018;
        repulsion_threshold_sd <- 0.018;
        repulsion_strength_sd <- 0.016;

        explicit_debates_path <- "";
        end_simulation_at_convergence <- true;
        selection_mode <- "filter";
        composition_scope <- "ALL";

        if repulsion_threshold <= confidence_threshold {
            infeasible_params <- true;
            end_simulation <- true;
        }
    }
}

experiment Val_bipol_ndist_speak type: batch repeat: 1 keep_seed: true until: (debate_counter >= length(m_debate_list) -1 and end_simulation = true) {
    init {
        mode_batch <- true;
        convergence_cycle <- -1;
        speaking_mode <- true;
        use_distinct_agents <- false;
        model_type <- "bipolarization";
        debug_mode <- false;
        current_experiment_id <- "bipol_ndist_speak";

        // GA-calibrated (train MAE 0.0429)
        convergence_rate <- 0.04;
        confidence_threshold <- 0.21;
        repulsion_threshold <- 0.59;
        repulsion_strength <- 0.07;

        convergence_rate_sd <- 0.0;
        confidence_threshold_sd <- 0.0;
        repulsion_threshold_sd <- 0.0;
        repulsion_strength_sd <- 0.0;

        explicit_debates_path <- "";
        end_simulation_at_convergence <- true;
        selection_mode <- "filter";
        composition_scope <- "ALL";

        if repulsion_threshold <= confidence_threshold {
            infeasible_params <- true;
            end_simulation <- true;
        }
    }
}

experiment Val_bipol_dist_speak type: batch repeat: 1 keep_seed: true until: (debate_counter >= length(m_debate_list) -1 and end_simulation = true) {
    init {
        mode_batch <- true;
        convergence_cycle <- -1;
        speaking_mode <- true;
        use_distinct_agents <- true;
        model_type <- "bipolarization";
        debug_mode <- false;
        current_experiment_id <- "bipol_dist_speak";

        // GA-calibrated (train MAE 0.0428)
        convergence_rate <- 0.025;
        confidence_threshold <- 0.3;
        repulsion_threshold <- 0.68;
        repulsion_strength <- 0.11;
        convergence_rate_sd <- 0.014;
        confidence_threshold_sd <- 0.0;
        repulsion_threshold_sd <- 0.021;
        repulsion_strength_sd <- 0.002;

        explicit_debates_path <- "";
        end_simulation_at_convergence <- true;
        selection_mode <- "filter";
        composition_scope <- "ALL";

        if repulsion_threshold <= confidence_threshold {
            infeasible_params <- true;
            end_simulation <- true;
        }
    }
}


// ===== BASELINE =====

experiment Val_no_change type: batch repeat: 1 keep_seed: true until: (debate_counter >= length(m_debate_list) -1 and end_simulation = true) {
    init {
        mode_batch <- true;
        model_type <- "no_change";
        convergence_cycle <- -1;
        speaking_mode <- false;
        use_distinct_agents <- false;
        debug_mode <- false;
        current_experiment_id <- "no_change_exp";

        explicit_debates_path <- "";
        end_simulation_at_convergence <- true;
        selection_mode <- "filter";
        composition_scope <- "ALL";
    }
}
