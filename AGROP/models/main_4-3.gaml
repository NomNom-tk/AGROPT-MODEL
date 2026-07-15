// Central Structuring file for models of social influence

model opinion_dynamics

import "actions/data_loader (copy)2_3.gaml" // reads csv, parsers and fill raw data lists (declared in global)
import "species/opinion_agent-2_3.gaml" // import opinion agent species
import "Parameters.gaml"
import "Constants.gaml"

global { 
    // initialization ONLY for orchestration
    init {
    	// call data loader with file path parameter
    	do load_csv_data("../data-dictionary/exp-dat/train_data.csv");
    	//do load_csv_data("/home/agropt/Gama_Workspace_new/thomas-social/models/data-dictionary/exp-dat/train_data.csv");
    	
        // debate mapping from data loader
        do build_debate_id_map;

        // debate selection call
        do build_debate_selection;
        debate_counter <- 0;
        selected_debate_id <- m_debate_list[0];
        
        
        // REPORT DEBATE DISTRIBUTION
        do debate_distribution;
        
        // LOAD AGENTS FOR SELECTED DEBATE
        do initialize_agents_for_debate(selected_debate_id);
        
        //write "Created " + length(opinion_agents) + " opinion agents"; // creation loop check
        
        // debug for init_agent creation
        if debug_mode = true {
        	// debug check for index computation
        	do debug_init;
        	
        	do debug_init_agents;
        }
        
        // CREATE NETWORK
        // COMMENT OUT FOR ARUGMENTATION
        do create_network;
        if debug_mode = true{
        	ask opinion_agents {
    		write "Agent " + agent_id + " group_type: " + group_type + " neighbors: " + length(neighbors);

            // debug check for debate MAPPING
            write "Successfully loaded " + length(agent_id_list) + " agents";
            write "id_group_raw[0]: " + id_group_raw[0];
            write "id_group_raw[1]: " + id_group_raw[1];
            // ADD THESE
            write "id_group_raw as int sample: " + int(id_group_raw[0]) + ", " + int(id_group_raw[1]) + ", " + int(id_group_raw[2]);
            write "unique group count: " + length(remove_duplicates(id_group_raw));
			}
		}
        
        // INITIAL DIAGNOSTICS
        do initial_diagnostics;
        
    }
    
action debate_distribution {
    list<int> unique_debates <- remove_duplicates(debate_id_list);
    //write "Found " + length(unique_debates) + " unique debates";

    loop debate over: unique_debates {
        int count <- debate_id_list count (each = debate);
        //write "Debate " + debate + ": " + count + " agents";
    }
}
    
action initial_diagnostics {
    list<int> init_hist <- list_with(10, 0);
    loop o over: opinion_agents collect each.initial_opinion {
        int b <- min([9, int(o * 10)]);
        init_hist[b] <- init_hist[b] + 1;
    }
    initial_num_clusters <- init_hist count (each > 0);
    
    // Structural diagnostic for bipolarization model
    neutral_zone_width <- repulsion_threshold - confidence_threshold;

    // initial variance for comparison
    list<float> init_opinions <- opinion_agents collect each.initial_opinion;
    initial_variance <- variance(init_opinions);
    
    // Guard for final stats
    final_stats_computed <- false;
}

action reset_debate_globals { // reset of globals for each debate 21/5/26
    mae <- 0.0;                       // Mean Absolute Error (global)
    mae_per_debate <- map<int, float>(map([]));

    // Opinion Stats
    opinion_variance <- 0.0;          // Variance of opinions
    initial_variance <- 0.0;                 // variance of opin at init
    num_clusters <- 0;                  // Number of opinion clusters
    polarization_index <- 0.0;        // Measure of opinion polarization
    initial_num_clusters <- 0;          // Opinion clusters at start
    convergence_cycle <- -1;            // Cycle when convergence achieved

    // PRO/ANTI REDUCTION METRICS
    num_pro_agents <- 0;                // Count of pro-reduction agents
    num_anti_agents <- 0;               // Count of anti-reduction agents
    mean_opinion_pro <- 0.0;          // Mean opinion of pro agents
    mean_opinion_anti <- 0.0;         // Mean opinion of anti agents
    pro_count <- 0;                     // Count of pro-reduc agents for save logic
    anti_count <- 0;                    // Count of anti-reduc agents for save logic
    
    // BIPOLARIZATION DIAGNOSTICS
    
    total_attractive_interactions <- 0; // Count of attractive interactions
    total_repulsive_interactions <- 0;  // Count of repulsive interactions
    total_neutral_interactions <- 0;    // Count of neutral zone interactions
    neutral_zone_width <- 0.0;        // Width of neutral zone (repulsion - confidence)
    mean_net_repulsion_abs <- 0.0;    // Mean absolute net repulsion force

    final_stats_computed <- false;
    end_simulation <- false;
}
    
action debug_init {
    if debug_mode = true {
    // ✅ CHECK WHAT WAS ACTUALLY LOADED
    write "=== DATA LOADER VERIFICATION ===";
    write "agent_id_list length: " + length(agent_id_list);
    write "id_group_raw length: " + length(id_group_raw);
    write "subfactors_t1 length: " + length(subfactors_t1);

    if length(subfactors_t1) > 0 {
        write "subfactors_t1[0] length: " + length(subfactors_t1[0]);
        write "subfactors_t1[1] length: " + length(subfactors_t1[1]);
        write "subfactors_t1[2] length: " + length(subfactors_t1[2]);
        write "subfactors_t1[3] length: " + length(subfactors_t1[3]);
        write "subfactors_t1[4] length: " + length(subfactors_t1[4]);
        
    }

    if length(subfactors_t2) > 0 {
        write "subfactors_t2[0] length: " + length(subfactors_t2[0]);
    }
    
    // data computation for initial subfactors for check
    loop i from: 0 to: min([10, length(agent_id_list)]) - 1 {
        // Compute what initial opinion SHOULD be from subfactors
        float f1 <- subfactors_t1[0][i];
        float f2 <- subfactors_t1[1][i];
        float f3 <- subfactors_t1[2][i];
        float f4 <- subfactors_t1[3][i];
        float f5 <- subfactors_t1[4][i];

        // Original formula (denormalized to [-6, +6])
        float denorm_f1 <- f1 * 6.0 + 1.0;
        float denorm_f2 <- f2 * 6.0 + 1.0;
        float denorm_f3 <- f3 * 6.0 + 1.0;
        float denorm_f4 <- f4 * 6.0 + 1.0;
        float denorm_f5 <- f5 * 6.0 + 1.0;

        float computed_index <- (denorm_f1 + denorm_f2) / 2.0 - (denorm_f3 + denorm_f4 + denorm_f5) / 3.0;
        float computed_normalized <- (computed_index + 6.0) / 12.0;

        float empirical_attitude <- initial_attitude_list[i];
        float difference <- abs(computed_normalized - empirical_attitude);
    
    // check whether lists are populated so they can be used
    write "Loaded " + length(agent_id_list) + " agents";

    // VALIDATION: Check if computed initial_opinion matches DB_IndexT1
    write "=== VALIDATION CHECK ===";


        write "Agent " + i + ": computed=" + computed_normalized + ", empirical=" + empirical_attitude + ", diff=" + difference;

        if difference > 0.01 {
            write "WARNING: Large discrepancy!";
        }
    }
    write "Total debates (including control agents): " + length(remove_duplicates(debate_id_list));
    }
    
}
    
// ACTION: CREATE AGENTS FOR SPECIFIC DEBATE
action initialize_agents_for_debate (int target_debate_id) {
bool condition_detected <- false;
string exp_id <- current_experiment_id; // pulls from gloal in params.gaml 

// guard for skipping invalid debate IDs
if !(debate_id_list contains target_debate_id) {
    write "Debate " + target_debate_id + "not found, skipping";
    end_simulation <- true;
    return;
}

// FIRST LOOP: Detect condition type for this debate
loop i from: 0 to: length(debate_id_list) - 1 {
    if debate_id_list[i] = target_debate_id and !condition_detected {
        string group_type_val <- group_type_list[i];

        // FIXED: Only use string comparisons (removed numeric "1", "2", "3")
        if group_type_val = "Homogeneous" {
            current_condition <- "homogeneous";
        } else if group_type_val = "Heterogeneous" {
            current_condition <- "heterogeneous";
        } else if group_type_val = "Control" {
            current_condition <- "control";
        } else {
        }

        condition_detected <- true;
        if debug_mode = true {
        // group type detection
            write "DEBUG: group_type_val for debate " + target_debate_id + ": " + group_type_val;

            // unkown condition check
            write "Warning: unknown condition type '" + group_type_val + "'";

            // condition detection check
            write "DEBUG: detected condition = " + current_condition;
        } 
    } 
}

// SECOND LOOP: Create agents for this debate
// FIXED: Renamed loop variable from 'i' to 'idx' to avoid shadowing
loop idx from: 0 to: length(debate_id_list) - 1 {
    if debate_id_list[idx] = target_debate_id {

    /*
        write "=== Creating agent from row " + idx + " ===";
    
        // Test each access BEFORE create block
        write "Test 1: agent_id = " + agent_id_list[idx];
        write "Test 2: group_type = " + group_type_list[idx];
        write "Test 3: pro_reduction = " + pro_reduction_list[idx];
        write "Test 4: subfactor_1_t1 = " + subfactors_t1[0][idx];
        write "Test 5: final_attitude = " + final_attitude_list[idx];
        write "Test 6: weights list = " + weights;
        */
        create species<opinion_agent>(model_type + "_agent") {
        // ALWAYS SET THESE (outside if/else)
            agent_id <- agent_id_list[idx];
            debate_id <- target_debate_id;
            group_type <- group_type_list[idx];
            pro_reduction <- pro_reduction_list[idx];
            debate_label <- id_group_raw[idx];
            current_experiment_id <- exp_id; // modif to pull from global in params.gaml

            // SUBFACTORS (ALWAYS)
            subfactor_1_t1 <- subfactors_t1[0][idx];
            subfactor_2_t1 <- subfactors_t1[1][idx];
            subfactor_3_t1 <- subfactors_t1[2][idx];
            subfactor_4_t1 <- subfactors_t1[3][idx];
            subfactor_5_t1 <- subfactors_t1[4][idx];
            subfactor_1_t2 <- subfactors_t2[0][idx];
            subfactor_2_t2 <- subfactors_t2[1][idx];
            subfactor_3_t2 <- subfactors_t2[2][idx];
            subfactor_4_t2 <- subfactors_t2[3][idx];
            subfactor_5_t2 <- subfactors_t2[4][idx];

            // PARAMETERS (if/else for use individual (heterogeneous agents))
            // modif to constrain SD to gaussian with seed + idx for debate 13/7/26
            if use_distinct_agents {
                // bind draw to global seed + unique loop index 
                int local_agent_seed <- int(seed + idx)

                agent_convergence_rate <- max([0.01, min([0.99, gauss({convergence_rate, convergence_rate_sd}, local_agent_seed)])]);
                agent_confidence_threshold <- max([0.01, min([0.99, gauss({confidence_threshold, confidence_threshold_sd}, local_agent_seed + 1)])]);
                agent_repulsion_strength <- max([0.01, min([0.99, gauss({repulsion_strength, repulsion_strength_sd}, local_agent_seed + 2)])]);
                agent_repulsion_threshold <- max([0.01, min([0.99, gauss({repulsion_threshold, repulsion_threshold_sd}, local_agent_seed + 3)])]);
                agent_repulsion_threshold <- max([agent_confidence_threshold + 0.05, agent_repulsion_threshold]);
            } else {
                agent_convergence_rate <- convergence_rate;
                agent_confidence_threshold <- confidence_threshold;
                agent_repulsion_strength <- repulsion_strength;
                agent_repulsion_threshold <- repulsion_threshold;
            }

            // OPINION CALCULATION (ALWAYS)
            float pro_mean <- (subfactor_1_t1 + subfactor_2_t1) / 2.0;
            float contra_mean <- (subfactor_3_t1 + subfactor_4_t1 + subfactor_5_t1) / 3.0;
            float pro_denorm <- pro_mean * 6.0 + 1.0;
            float contra_denorm <- contra_mean * 6.0 + 1.0;
            float db_index_raw <- pro_denorm - contra_denorm;
            initial_opinion <- (db_index_raw + 6.0) / 12.0;
            opinion <- initial_opinion;
            previous_opinion <- initial_opinion;
            final_attitude <- final_attitude_list[idx];
            location <- {rnd(world_size), rnd(world_size)};
            color <- rgb(opinion * 255, 0, (1 - opinion) * 255);
            initial_opinion_snapshot <- opinion; // introduce in 20/4/26 pre and post update tracking
        }
    }
}

//write "Debate " + target_debate_id + " condition: " + current_condition;
}

action debug_init_agents {
	if debug_mode = true {
		write "=== AGENT PARAMETER DISTRIBUTION CHECK ===";
		list<float> agent_conv_rates <- opinion_agents collect each.agent_convergence_rate;
		write
		"Convergence rate - Mean: " + mean(agent_conv_rates) + ", SD: " + standard_deviation(agent_conv_rates) + ", Min: " + min(agent_conv_rates) + ", Max: " + max(agent_conv_rates);
		write "Target mean: " + convergence_rate + ", Target SD: " + convergence_rate_sd;
	}
}
    
    
// ACTION: CREATE NETWORK STRUCTURE
// steps: reset all neighbors, enforce undirected connections
action create_network {
    // Reset all neighbors
    ask opinion_agents {
        neighbors <- [];
    }
    
    // complete network (all agents connected each other)
    ask opinion_agents {
        neighbors <- opinion_agents where (
            each != self and each.debate_id = self.debate_id
        );
    }

    // ensure undirected connections (only affects speaking_mode <- false)
    ask opinion_agents {
        loop n over: neighbors {
            if !(n.neighbors contains self) {
                n.neighbors <- n.neighbors + self;
            }
        }
    }
}

// REFLEX: COMPUTE PRO/ANTI STATS (every 10 cycles for heterogeneous)
reflex compute_pro_anti_stats when: ((cycle - debate_start_cycle) mod 10 = 0) and current_condition = "heterogeneous" {
    list<opinion_agent> pro_agents <- opinion_agents where (each.pro_reduction = 1);
    list<opinion_agent> anti_agents <- opinion_agents where (each.pro_reduction = 0);
    
    num_pro_agents <- length(pro_agents);
    num_anti_agents <- length(anti_agents);
    
    if num_pro_agents > 0 {
        mean_opinion_pro <- mean(pro_agents collect each.opinion);
    }
    if num_anti_agents > 0 {
        mean_opinion_anti <- mean(anti_agents collect each.opinion);
    }
}

// REFLEX: COMPUTE STATISTICS (every 10 cycles)
reflex compute_statistics when: ((cycle - debate_start_cycle) mod 10 = 0) { // 22/5/26 change to debate_start_cycle, mod -- cycle divisible by 10
    list<float> opinions <- opinion_agents collect each.opinion;
    if length(opinions) > 0 {
        float mean_opinion <- mean(opinions);
        opinion_variance <- variance(opinions);

        // Count opinion clusters using histogram
        int num_bins <- 10;
        list<int> histogram <- list_with(num_bins, 0);
        loop op over: opinions {
            int bin <- min([num_bins - 1, int(op * num_bins)]);
            histogram[bin] <- histogram[bin] + 1;
        }
        num_clusters <- histogram count (each > 0);

        // Compute polarization index (variance of pairwise distances)
        do compute_pairwise_polarization;
    }
}

// REFLEX: CHECK FOR CONVERGENCE (every 5 cycles after cycle 10)
reflex check_convergence when: end_simulation_at_convergence and ((cycle - debate_start_cycle) > 10) and ((cycle - debate_start_cycle) mod 5 = 0) and !end_simulation { // 22/5/526 change to debate_start_cycle
    list<float> opinion_changes <- [];
    ask opinion_agents {
        opinion_changes << abs(opinion - previous_opinion);
    }
    
    if length(opinion_changes) > 0 {
        float max_change <- max(opinion_changes);
        
        if mode_batch and debug_mode {
            write "Cycle " + cycle + " | Max change: " + max_change;
        }
        
        // Check if converged
        if max_change < mae_convergence_threshold {
            convergence_cycle <- cycle - debate_start_cycle;
            if debug_mode = true {
                write "Converged at cycle " + convergence_cycle;
            } 
            end_simulation <- true;
            
            do compute_fit;
            do compute_final_statistics;
            
            if mode_batch {
                do save_batch_results;
            }
            
            // modif 21/5/26 implement sequential counter
		    if debate_counter < length(m_debate_list) - 1 {
		        debate_counter <- debate_counter + 1;
		        selected_debate_id <- m_debate_list[debate_counter];
                ask opinion_agents {do die;}
                write "remaining after die: " + length(opinion_agents);
		        do init_debate;
		    } else {
		        end_simulation <- true;
		    }
    	}
	}
}

reflex update_prev_opinion {
    ask opinion_agents {
        previous_opinion <- opinion;
    }
}
    
// NETWORK update ONLY for argumentation
// STATIC NETWORK FOR SOCIAL INFLUENCE
/*reflex update_network {
    
    list<opinion_agent> active_agents <- opinion_agents where (each.group_type != "Control");
    ask active_agents {
        list<opinion_agent> potential_neighbors <- active_agents where (
            each != self and
            each.debate_id = self.debate_id );
        list<float> proba_select <- potential_neighbors collect (0.5 * (2 - abs(each.opinion - opinion)));
        neighbors <- [potential_neighbors[rnd_choice(proba_select)]];
    }
    
}*/

// REFLEX: FALLBACK - STOP AT MAX_CYCLES
reflex max_cycles_reached when: (cycle - debate_start_cycle) >= max_cycles and !end_simulation {
    convergence_cycle <- cycle - debate_start_cycle; // record actual convergence cycle regardless of termination 4/5/26
    write "Reached max_cycles without convergence";
    end_simulation <- true;
    
    do compute_fit;
    do compute_final_statistics;
    
    if mode_batch {
        do save_batch_results;
    }

    // modif 21/5/26
    if debate_counter < length(m_debate_list) - 1 {
        debate_counter <- debate_counter + 1;
        selected_debate_id <- m_debate_list[debate_counter];
        ask opinion_agents {do die;}
        write "remaining after die: " + length(opinion_agents);
        do init_debate;
    } else {
        end_simulation <- true;
    }
}

// ACTION: COMPUTE MODEL FIT (MAE)
action compute_fit {
    mae_per_debate <- map<int, float>(map([]));
    list<int> debates <- remove_duplicates(opinion_agents collect each.debate_id);
    list<float> all_errors <- [];
    
    // Compute MAE per debate
    loop d over: debates {
        list<opinion_agent> agents_d <- opinion_agents where (each.debate_id = d);
        
        if length(agents_d) > 0 {
            list<float> errors_d <- [];
            
            ask agents_d {
                float real <- final_attitude;
                float err <- abs(opinion - real);
                errors_d << err;
                all_errors << err;
            }
            
            if length(errors_d) > 0 {
                mae_per_debate[d] <- mean(errors_d);
            }
        }
    }
    
    // Global MAE
    mae <- length(all_errors) > 0 ? mean(all_errors) : 0.0;
    
    // Compute mean absolute net repulsion (cluster stability measure)
    list<float> net_repulsions <- [];
    
    ask opinion_agents {
        float net_repulsion <- 0.0;
        loop n over: neighbors {
            if abs(n.opinion - opinion) >= agent_repulsion_threshold {
                net_repulsion <- net_repulsion + (n.opinion > opinion ? -1.0 : 1.0);
            }
        }
        net_repulsions << abs(net_repulsion);
    }
    
    mean_net_repulsion_abs <- length(net_repulsions) > 0 ? mean(net_repulsions) : 0.0;
    
    if debug_mode = true {
            write "=== Computing Fit at Cycle " + cycle + " ===";
            
            // mae calc check
            write "Global MAE: " + mae;
            write "Per-debate MAE: " + mae_per_debate;
        }
}

// Action ot compute pro-anti agents
action compute_pro_anti_counts {
     pro_count <- opinion_agents count (each.pro_reduction = 1);
     anti_count <- opinion_agents count (each.pro_reduction = 0);
}

// Action for pairwise polarization
action compute_pairwise_polarization {
    list<float> pairwise_distances <- [];
    loop a1 over: opinion_agents {
        loop a2 over: opinion_agents {
            if a1 != a2 {
                pairwise_distances << abs(a1.opinion - a2.opinion);
            }
        }
    }
    if length(pairwise_distances) > 0 {
        float mean_distance <- mean(pairwise_distances);
        float variance_distance <- 0.0;
        loop d over: pairwise_distances {
            variance_distance <- variance_distance + (d - mean_distance) ^ 2;
        }
        polarization_index <- variance_distance / 
            (length(pairwise_distances) * (1.0 ^ 2));
    }
}
    
// ACTION: COMPUTE FINAL STATISTICS AT CONVERGENCE
// This overwrites periodic statistics with exact convergence values
action compute_final_statistics {
    if final_stats_computed {
        return;
    }
    
    do compute_pairwise_polarization;
    final_stats_computed <- true;
    
    list<float> opinions <- opinion_agents collect each.opinion;
    
}

// resets the globals for each debate when cycling between debates 21/5/26
action init_debate {
    do reset_debate_globals;
    debate_start_cycle <- cycle; // 22/5/26 introduce local debate cycle count
    do initialize_agents_for_debate(selected_debate_id);
    do create_network;
    do initial_diagnostics;
}

// ACTION: Interaction log 27/4/26
action save_interaction_log {
	if debug_mode {
		write "Saving interaction log for debate: " + selected_debate_id + ", size: " + length(interaction_log); 
	}
	
	if !file_exists("outputs/interaction_log.csv") { // if file doesn't exist create headers and save
    	save "speaking_mode,model_type,current_condition,selected_debate_id," +
    	"debate_label,current_experiment_id,use_distinct_agents,seed,cycle,sender_id,receiver_id," +
    	"sender_opinion,opinion_before,opinion_after,delta,agent_is_saturated,agent_wrong_direction, max_cycles" 
    	to: "outputs/interaction_log.csv" rewrite: false;
	}
    
    loop row over: interaction_log {
        save row to: "outputs/interaction_log.csv" rewrite: false;
    }
    
    // trial before header insertion problem
    /*list<string> log_with_header <- [header] + interaction_log;
    save log_with_header to: "outputs/interaction_log.csv" rewrite: true;
    */
    
    interaction_log <- []; // reset after saving for next run
}
    
// ACTION: SAVE BATCH RESULTS
action save_batch_results {
    do compute_pro_anti_counts;
    string debate_label <- first(opinion_agents).debate_label;
    
    if model_type = "bipolarization" {
        neutral_zone_width <- repulsion_threshold - confidence_threshold;
        
        // mean net repulsion abs calc
        list<float> net_repulsions <- [];
        ask opinion_agents {
            float net_repulsion <- 0.0;
            loop n over: neighbors {
                if abs(n.opinion - opinion) >= agent_repulsion_threshold {
                    net_repulsion <- net_repulsion + (n.opinion > opinion ? -1.0: 1.0);
                }
            }
            net_repulsions << abs(net_repulsion);
        }
        mean_net_repulsion_abs <- length(net_repulsions) > 0 ? mean(net_repulsions) :
        0.0;
    } else {
        neutral_zone_width <- 0.0;
        mean_net_repulsion_abs <- 0.0;
    }
    
    // Save summary statistics
    save [model_type, current_condition, selected_debate_id, debate_label, current_experiment_id, max_cycles, use_distinct_agents,
            speaking_mode, seed, pro_count, anti_count, convergence_rate, confidence_threshold, repulsion_threshold, 
            repulsion_strength, convergence_rate_sd, confidence_threshold_sd, repulsion_threshold_sd, repulsion_strength_sd, 
            convergence_cycle, initial_variance, mae, opinion_variance, polarization_index, num_clusters, 
            initial_num_clusters, neutral_zone_width, mean_net_repulsion_abs]
    to: "outputs/batch_summary.csv" rewrite: false;
    
    if debug_mode = true {
        write "=== Saving Results ===";
        write "MAE: " + mae;
        write "Condition: " + current_condition;
        //write "Debates: " + mae_per_debate.keys;
    } else {
        write "Results saved successfully for debate:" + selected_debate_id;
    }
    
    do save_agent_results;

    do save_interaction_log; // call for interaction log save
    
}
    
// ACTION: SAVE PER-AGENT RESULTS
action save_agent_results {
    do compute_pro_anti_counts;
    
    // could the error be due to subfactors not being declard in opinion_agent
    ask opinion_agents {
        float individual_error <- abs(opinion - final_attitude);
        float opinion_change <- opinion - initial_opinion;
        
        // derived opinion values 20/4/26
        agent_net_change <- opinion - initial_opinion_snapshot;
        agent_wrong_direction <- (pro_reduction = 1 and agent_net_change < 0)
                                    or (pro_reduction = 0 and agent_net_change > 0);
        agent_is_saturated <- retention_discount < 0.2;

        
        // Calculate mean of T2 subfactors for comparison
        float mean_t2_subfactors <- (subfactor_1_t2 + subfactor_2_t2 +
                                        subfactor_3_t2 + subfactor_4_t2 + 
                                        subfactor_5_t2) / 5.0; 
    
        // Calculate individual subfactor errors
        float error_sub1 <- abs(opinion - subfactor_1_t2);
        float error_sub2 <- abs(opinion - subfactor_2_t2);
        float error_sub3 <- abs(opinion - subfactor_3_t2);
        float error_sub4 <- abs(opinion - subfactor_4_t2);
        float error_sub5 <- abs(opinion - subfactor_5_t2);
        
        /*/ TODO modify recent speech conversion to string (use strsplit in R for analysis)
        string recent_speech_str <- "";
        loop val over: recent_speech {
            string val_str <- string(val) + ";";
            recent_speech_str <- string(recent_speech_str + val_str);
        }*/
        
        save [
            model_type,
            current_condition,
            selected_debate_id,
            debate_label,
            current_experiment_id,
            max_cycles, // change max_cycles in constants when running sim 15/5/26
            use_distinct_agents,
            speaking_mode,
            seed,
            agent_id,
            pro_reduction,
            pro_count,
            anti_count,
            
            // Initial subfactors (T1)
            subfactor_1_t1, subfactor_2_t1, subfactor_3_t1, 
            subfactor_4_t1, subfactor_5_t1,
            
            // Initial opinion (weighted)
            initial_opinion,
            initial_variance,
            
            // Simulation final opinion
            opinion,
            
            // T2 subfactors (target)
            subfactor_1_t2, subfactor_2_t2, subfactor_3_t2, 
            subfactor_4_t2, subfactor_5_t2,
            
            // Target opinion (mean of T2)
            final_attitude,
            mean_t2_subfactors,
            
            // Changes and errors
            opinion_change,
            individual_error,
            error_sub1, error_sub2, error_sub3, 
            error_sub4, error_sub5,
            
            // agent-level parameters
            agent_convergence_rate,
            agent_confidence_threshold,
            agent_repulsion_threshold,
            agent_repulsion_strength,
            
            // speech
            //recent_speech_str,
            total_influences_received,
            retention_discount,
            cumulative_opinion_change,
            agent_net_change,
            agent_wrong_direction,
            agent_is_saturated,
            
            // Parameters
            convergence_rate,
            confidence_threshold,
            repulsion_threshold,
            repulsion_strength,
            convergence_cycle 
        ]
        to: "outputs/agent_level_results.csv" rewrite: false;
    }
    
    if debug_mode = false {
        write "=== Saving Per-Agent Results ==="; // fires when not debugging
    } else {
        write "Saved " + length(opinion_agents) + " agent records" + "for debate:" + selected_debate_id;
    }
}
    
// REFLEX: STOP GUI AT MAX_CYCLES
reflex stop_gui when: end_simulation and !mode_batch {
    do pause;
    }
}
