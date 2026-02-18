// Central Structuring file for models of social influence

model opinion_dynamics_main

import "actions/data_loader (copy).gaml" // reads csv, parsers and fill raw data lists (declared in global)
import "species/opinion_agent.gaml" // import opinion agent species

global {
    // DATA IMPORT
    //file text_data;
    
    // REMOVED VAR DECLARATIONS -> declared and populated by data_loader
    
    // Current experiment condition (detected at runtime)
    string current_condition <- "unknown"; // among: "homogeneous", "heterogeneous", "control"
    
    // SUBFACTOR DATA STORAGE (T1 = initial, T2 = target)
    // Efficient storage: subfactors_t1[0..4][row_index] for 5 subfactors
    list<list<float>> subfactors_t1;        // Initial subfactor values (T1)
    list<list<float>> subfactors_t2;        // Target subfactor values (T2)

    // Helper list for easier computation (populated in init)
    list<float> weights <- [];

    // Network type parameters
    int small_world_k <- 4 min: 2 max: 6; //parameter: "Small world K neighbors" category: "Network" 
    float small_world_rewire <- 0.1 min: 0.0 max: 0.3; //parameter: "Small world rewiring probability" category: "Network" 
    
    // PRO/ANTI REDUCTION METRICS
    int num_pro_agents <- 0;                // Count of pro-reduction agents
    int num_anti_agents <- 0;               // Count of anti-reduction agents
    float mean_opinion_pro <- 0.0;          // Mean opinion of pro agents
    float mean_opinion_anti <- 0.0;         // Mean opinion of anti agents
    
    // BIPOLARIZATION DIAGNOSTICS
    int initial_num_clusters <- 0;          // Opinion clusters at start
    int total_attractive_interactions <- 0; // Count of attractive interactions
    int total_repulsive_interactions <- 0;  // Count of repulsive interactions
    int total_neutral_interactions <- 0;    // Count of neutral zone interactions
    float neutral_zone_width <- 0.0;        // Width of neutral zone (repulsion - confidence)
    float mean_net_repulsion_abs <- 0.0;    // Mean absolute net repulsion force
    
    // SIMULATION CONTROL
    int selected_debate_id <- 1;            // Which debate to simulate
    string model_type <- "consensus" among: ["consensus", "clustering", "bipolarization"];
    string network_type <- "complete" among: ["complete", "random", "small_world"];
    float connection_probability <- 0.3 min: 0.0 max: 1.0;
    
    // Timing
    float step <- 0.5;
    int max_cycles <- 100;
    
    // Control flags
    bool mode_batch <- false;               // Batch mode vs GUI mode
    bool end_simulation <- false;           // Convergence flag
    int convergence_cycle <- -1;            // Cycle when convergence achieved
    bool final_stats_computed <- false;     // Guard for final statistics
    
    // Convergence parameters
    float mae_convergence_threshold <- 0.001 min: 0.0 max: 1.0;

    // OPINION DYNAMICS PARAMETERS
    float convergence_rate <- 0.2 min: 0.0 max: 1.0;        // μ: Speed of opinion change
    float confidence_threshold <- 0.5 min: 0.0 max: 1.0;    // ε: Similarity for attraction
    float repulsion_threshold <- 0.6 min: 0.0 max: 1.0;     // Dissimilarity for repulsion
    float repulsion_strength <- 0.1 min: 0.0 max: 0.5;      // Strength of repulsive force

    // opinion dynamics parameters Extension
    float convergence_rate_sd <- 0.05 min: 0.0 max: 0.2;
    float confidence_threshold_sd <- 0.1 min: 0.0 max: 0.3;
    float repulsion_threshold_sd <- 0.1 min: 0.0 max: 0.3;
    float repulsion_strength_sd <- 0.05 min: 0.0 max: 0.2;

    // RESULTS & ANALYSIS
    float mae <- 0.0;                       // Mean Absolute Error (global)
    map<int, float> mae_per_debate <- map<int, float>(map([]));
    float world_size <- 100.0;              // Spatial world size for visualization
    
    // Analysis variables
    float opinion_variance <- 0.0;          // Variance of opinions
    int num_clusters <- 0;                  // Number of opinion clusters
    float polarization_index <- 0.0;        // Measure of opinion polarization
    // initialization ONLY for orchestration
    init {
    	// call data loader with file path parameter
    	do load_csv_data("../data/data_complete_anonymised.csv");
    	
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
    	
    	//
    	
    	// check whether lists are populated so they can be used
    	write "Loaded " + length(agent_id_list) + " agents";

        // VALIDATION: Check if computed initial_opinion matches DB_IndexT1
        write "=== VALIDATION CHECK ===";

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
    
            write "Agent " + i + ": computed=" + computed_normalized + ", empirical=" + empirical_attitude + ", diff=" + difference;
    
            if difference > 0.01 {
                write "WARNING: Large discrepancy!";
            }
        }
        //
        
        // CREATE DEBATE ID MAPPING
        // Control agents get unique IDs, others grouped by ID_Group_all
        debate_id_list <- [];
        map<string, int> group_to_id <- map([]);
        int next_id <- 1;
        
        loop i from: 0 to: length(id_group_raw) - 1 {
            string id_group <- id_group_raw[i];
            string condition <- group_type_list[i];

            // FIXED: Only use string comparison "Control" (removed numeric "3")
            if condition = "Control" {
                // Each control agent gets a unique debate_id
                string unique_control_id <- "Control_" + agent_id_list[i];
                if not (group_to_id.keys contains unique_control_id) {
                    group_to_id[unique_control_id] <- next_id;
                    next_id <- next_id + 1;
                }
                debate_id_list << group_to_id[unique_control_id];
            }
            else {
                // Regular groups use ID_Group_all
                if not (group_to_id.keys contains id_group) {
                    group_to_id[id_group] <- next_id;
                    next_id <- next_id + 1;
                }
                debate_id_list << group_to_id[id_group];
            }
        }

        write "Total debates (including control agents): " + length(remove_duplicates(debate_id_list));
        

        // REPORT DEBATE DISTRIBUTION
        list<int> unique_debates <- remove_duplicates(debate_id_list);
        write "Found " + length(unique_debates) + " unique debates";

        loop debate over: unique_debates {
            int count <- debate_id_list count (each = debate);
            write "Debate " + debate + ": " + count + " agents";
        }
        
        // CRITICAL: initialize weights BEFORE creating agents
        // INITIALIZE WEIGHTS HELPER LIST
        //weights <- [weight_subfactor_1, weight_subfactor_2, weight_subfactor_3,
        //            weight_subfactor_4, weight_subfactor_5];

        // LOAD AGENTS FOR SELECTED DEBATE
        if mode_batch {
            write "Loading debate " + selected_debate_id + " for batch mode";
            do initialize_agents_for_debate(selected_debate_id);
        } else {
            write "Loading debate " + selected_debate_id + " for GUI mode";
            do initialize_agents_for_debate(selected_debate_id);
        }
        
        write "Created " + length(opinion_agent) + " opinion agents";
        
        
        // CREATE NETWORK
        do create_network;
        
        // INITIAL DIAGNOSTICS
        // Initial opinion clustering (count non-empty bins)
        list<int> init_hist <- list_with(10, 0);
        loop o over: opinion_agent collect each.initial_opinion {
            int b <- min([9, int(o * 10)]);
            init_hist[b] <- init_hist[b] + 1;
        }
        initial_num_clusters <- init_hist count (each > 0);
        
        // Structural diagnostic for bipolarization model
        neutral_zone_width <- repulsion_threshold - confidence_threshold;
        
        // Guard for final stats
        final_stats_computed <- false;
    }
    
    // ACTION: CREATE AGENTS FOR SPECIFIC DEBATE
    action initialize_agents_for_debate(int target_debate_id) {
        bool condition_detected <- false;
        
        // FIRST LOOP: Detect condition type for this debate
        loop i from: 0 to: length(debate_id_list) - 1 {
            if debate_id_list[i] = target_debate_id and !condition_detected {
                string group_type_val <- group_type_list[i];
                write "DEBUG: group_type_val for debate " + target_debate_id + ": " + group_type_val;
                
                // FIXED: Only use string comparisons (removed numeric "1", "2", "3")
                if group_type_val = "Homogeneous" {
                    current_condition <- "homogeneous";
                } else if group_type_val = "Heterogeneous" {
                    current_condition <- "heterogeneous"; 
                } else if group_type_val = "Control" {
                    current_condition <- "control";
                } else {
                    write "Warning: unknown condition type '" + group_type_val + "'";
                }
                condition_detected <- true;
                write "DEBUG: detected condition = " + current_condition;
            }
        }
        
        // SECOND LOOP: Create agents for this debate
        // FIXED: Renamed loop variable from 'i' to 'idx' to avoid shadowing
        loop idx from: 0 to: length(debate_id_list) - 1 {
            if debate_id_list[idx] = target_debate_id {
            
            write "=== Creating agent from row " + idx + " ===";
        
            // Test each access BEFORE create block
            write "Test 1: agent_id = " + agent_id_list[idx];
            write "Test 2: group_type = " + group_type_list[idx];
            write "Test 3: pro_reduction = " + pro_reduction_list[idx];
            write "Test 4: subfactor_1_t1 = " + subfactors_t1[0][idx];
            write "Test 5: final_attitude = " + final_attitude_list[idx];
            write "Test 6: weights list = " + weights;

            
                create opinion_agent {
                    // Basic identifiers
                    agent_id <- agent_id_list[idx];
                    debate_id <- target_debate_id;
                    group_type <- group_type_list[idx];
                    pro_reduction <- pro_reduction_list[idx];
                    
                    // ASSIGN SUBFACTORS (T1 - initial)
                    subfactor_1_t1 <- subfactors_t1[0][idx];
                    subfactor_2_t1 <- subfactors_t1[1][idx];
                    subfactor_3_t1 <- subfactors_t1[2][idx];
                    subfactor_4_t1 <- subfactors_t1[3][idx];
                    subfactor_5_t1 <- subfactors_t1[4][idx];
                
                    // ASSIGN TARGET SUBFACTORS (T2)
                    subfactor_1_t2 <- subfactors_t2[0][idx];
                    subfactor_2_t2 <- subfactors_t2[1][idx];
                    subfactor_3_t2 <- subfactors_t2[2][idx];
                    subfactor_4_t2 <- subfactors_t2[3][idx];
                    subfactor_5_t2 <- subfactors_t2[4][idx];

                    // Agent level parameter sampling
                    agent_convergence_rate <- max([0.01, min([0.99,
                        gauss(convergence_rate, convergence_rate_sd)
                    ])]);

                    agent_confidence_threshold <- max([0.01, min([0.99,
                        gauss(confidence_threshold, confidence_threshold_sd)
                    ])]);

                    agent_repulsion_strength <- max([0.01, min([0.99,
                        gauss(repulsion_strength, repulsion_strength_sd)
                    ])]);

                    agent_repulsion_threshold <- max([0.01, min([0.99,
                        gauss(repulsion_threshold, repulsion_threshold_sd)
                    ])]);
                    
                    // COMPUTE INITIAL OPINION FROM WEIGHTED SUBFACTORS
                    // use DB_index formula mean(F1,F2) - mean(F3,F4,F5)
                    float pro_mean <- (subfactor_1_t1 + subfactor_2_t1) / 2.0;
                    float contra_mean <- (subfactor_3_t1 + subfactor_4_t1 + subfactor_5_t1) / 3.0;

                    // denormalize to [1,7] scale
                    float pro_denorm <- pro_mean * 6.0 + 1.0;
                    float contra_denorm <- contra_mean * 6.0 + 1.0;

                    // compute raw difference
                    float db_index_raw <- pro_denorm - contra_denorm;

                    // normalize back to [0,1]
                    initial_opinion <- (db_index_raw + 6.0) / 12.0;

                    // SET UP INITIAL STATE
                    opinion <- initial_opinion;
                    previous_opinion <- initial_opinion;
                    
                    final_attitude <- final_attitude_list[idx];
                    
                    // Random spatial location for visualization
                    location <- {rnd(world_size), rnd(world_size)};
                    
                    // Color based on opinion (blue=0, red=1)
                    color <- rgb(opinion * 255, 0, (1 - opinion) * 255);
                }

                write "=== AGENT PARAMETER DISTRIBUTION CHECK ===";
                list<float> agent_conv_rates <- opinion_agent collect each.agent_convergence_rate;
                write "Convergence rate - Mean: " + mean(agent_conv_rates) + 
                      ", SD: " + standard_deviation(agent_conv_rates) +
                      ", Min: " + min(agent_conv_rates) +
                      ", Max: " + max(agent_conv_rates);
                write "Target mean: " + convergence_rate + ", Target SD: " + convergence_rate_sd;

            }
        }
        
        write "Debate " + target_debate_id + " condition: " + current_condition;
    }
    
    // ACTION: CREATE NETWORK STRUCTURE
    action create_network {
        // Reset all neighbors
        ask opinion_agent {
            neighbors <- [];
        }

        switch network_type {
            // COMPLETE NETWORK: Everyone connected to everyone (except control)
            match "complete" {
                ask opinion_agent {
                    // FIXED: Removed redundant self.group_type check and numeric "3"
                    neighbors <- opinion_agent where (
                        each != self and 
                        each.debate_id = self.debate_id and
                        each.group_type != "Control"
                    );
                }
            }
            
            // RANDOM NETWORK: Probabilistic connections
            match "random" {
                // FIXED: Removed numeric "3" comparison
                ask opinion_agent where (each.group_type != "Control") {
                    neighbors <- opinion_agent where (
                        each != self and 
                        each.debate_id = self.debate_id and
                        each.group_type != "Control" and
                        flip(connection_probability)
                    );
                }
            }
            
            // SMALL WORLD NETWORK: Local clusters with random rewiring
            match "small_world" {
                // FIXED: Removed numeric "3" comparison
                list<opinion_agent> agent_list <- list(opinion_agent where (each.group_type != "Control"));
                
                loop i from: 0 to: length(agent_list) - 1 {
                    opinion_agent current <- agent_list[i];
                    int k <- small_world_k; // Number of nearest neighbors
                    
                    // Connect to k nearest neighbors (ring topology)
                    loop j from: 1 to: k {
                        int neighbor_index <- (i + j) mod length(agent_list);
                        if agent_list[neighbor_index].debate_id = current.debate_id {
                            current.neighbors <- current.neighbors + agent_list[neighbor_index];
                        }
                    }
                    
                    // Rewire with probability 0.1
                    if flip(small_world_rewire) {
                        // FIXED: Removed numeric "3" comparison
                        opinion_agent random_neighbor <- one_of(
                            opinion_agent where (
                                each != current and 
                                each.debate_id = current.debate_id and
                                each.group_type != "Control"
                            )
                        );
                        if random_neighbor != nil {
                            current.neighbors <- current.neighbors + random_neighbor;
                        }
                    }
                }
            }
        }
    }

    // REFLEX: COMPUTE PRO/ANTI STATS (every 10 cycles for heterogeneous)
    reflex compute_pro_anti_stats when: every(10#cycle) and current_condition = "heterogeneous" {
        list<opinion_agent> pro_agents <- opinion_agent where (each.pro_reduction = 1);
        list<opinion_agent> anti_agents <- opinion_agent where (each.pro_reduction = 0);
        
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
    reflex compute_statistics when: every(10#cycle) {
        list<float> opinions <- opinion_agent collect each.opinion;
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
            list<float> pairwise_distances <- [];
            loop a1 over: opinion_agent {
                loop a2 over: opinion_agent {
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
                polarization_index <- variance_distance / (length(pairwise_distances) * (1.0 ^ 2));
            }
        }
    }
    
    // REFLEX: CHECK FOR CONVERGENCE (every 5 cycles after cycle 10)
    reflex check_convergence when: cycle > 10 and every(5#cycle) and !end_simulation {
        list<float> opinion_changes <- [];
        ask opinion_agent {
            opinion_changes << abs(opinion - previous_opinion);
        }
        
        if length(opinion_changes) > 0 {
            float max_change <- max(opinion_changes);
            
            if mode_batch {
                write "Cycle " + cycle + " | Max change: " + max_change;
            }
            
            // Check if converged
            if max_change < mae_convergence_threshold {
                convergence_cycle <- cycle;
                write "Converged at cycle " + convergence_cycle;
                end_simulation <- true;
                
                do compute_fit;
                do compute_final_statistics;
                
                if mode_batch {
                    do save_batch_results;
                }
            }
        }
    }
    
    // REFLEX: FALLBACK - STOP AT MAX_CYCLES
    reflex max_cycles_reached when: cycle >= max_cycles and !end_simulation {
        convergence_cycle <- max_cycles;
        write "Reached max_cycles without convergence";
        end_simulation <- true;
        
        do compute_fit;
        do compute_final_statistics;
        
        if mode_batch {
            do save_batch_results;
        }
    }
    
    // ACTION: COMPUTE MODEL FIT (MAE)
    action compute_fit {
        write "=== Computing Fit at Cycle " + cycle + " ===";
        
        mae_per_debate <- map<int, float>(map([]));
        list<int> debates <- remove_duplicates(opinion_agent collect each.debate_id);
        list<float> all_errors <- [];
        
        // Compute MAE per debate
        loop d over: debates {
            list<opinion_agent> agents_d <- opinion_agent where (each.debate_id = d);
            
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
        
        write "Global MAE: " + mae;
        write "Per-debate MAE: " + mae_per_debate;
        
        // Compute mean absolute net repulsion (cluster stability measure)
        list<float> net_repulsions <- [];
        
        ask opinion_agent {
            float net_repulsion <- 0.0;
            loop n over: neighbors {
                if abs(n.opinion - opinion) >= agent_repulsion_threshold {
                    net_repulsion <- net_repulsion + (n.opinion > opinion ? -1.0 : 1.0);
                }
            }
            net_repulsions << abs(net_repulsion);
        }
        
        mean_net_repulsion_abs <- length(net_repulsions) > 0 ? mean(net_repulsions) : 0.0;
    }
    
    // ACTION: COMPUTE FINAL STATISTICS AT CONVERGENCE
    // This overwrites periodic statistics with exact convergence values
    action compute_final_statistics {
        if final_stats_computed {
            return;
        }
        
        final_stats_computed <- true;
        
        list<float> opinions <- opinion_agent collect each.opinion;
        
        if length(opinions) > 0 {
            // Final variance
            opinion_variance <- variance(opinions);
        
            // Final number of clusters (histogram-based)
            int num_bins <- 10;
            list<int> histogram <- list_with(num_bins, 0);
        
            loop op over: opinions {
                int bin <- min([num_bins - 1, int(op * num_bins)]);
                histogram[bin] <- histogram[bin] + 1;
            }
            num_clusters <- histogram count (each > 0);
        
            // Final polarization index (pairwise variance)
            list<float> pairwise_distances <- [];
            loop a1 over: opinion_agent {
                loop a2 over: opinion_agent {
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
                
                polarization_index <- variance_distance / (length(pairwise_distances) * (1.0 ^ 2));
            }
        }
    }
    
    // ACTION: SAVE BATCH RESULTS
    action save_batch_results {
        write "=== Saving Results ===";
        write "MAE: " + mae;
        write "Condition: " + current_condition;
        write "Debates: " + mae_per_debate.keys;
        
        int pro_count <- opinion_agent count (each.pro_reduction = 1);
        int anti_count <- opinion_agent count (each.pro_reduction = 0);
        
        // Save summary statistics
        // removed subfactor weights as they are fixed by initial computation equation
        save [model_type, current_condition, selected_debate_id, pro_count, anti_count, 
              convergence_rate, confidence_threshold, repulsion_threshold, repulsion_strength, 
              seed, convergence_cycle, mae, opinion_variance, polarization_index, num_clusters, initial_num_clusters,
              neutral_zone_width, mean_net_repulsion_abs]
        to: "outputs/batch_summary.csv" rewrite: false;
        
        do save_agent_results;
        
        write "Results saved successfully";
    }
    
    // ACTION: SAVE PER-AGENT RESULTS
    action save_agent_results {
        write "=== Saving Per-Agent Results ===";
        
        int pro_count <- opinion_agent count (each.pro_reduction = 1);
        int anti_count <- opinion_agent count (each.pro_reduction = 0);
        
        loop ag over: opinion_agent {
            float individual_error <- abs(ag.opinion - ag.final_attitude);
            float opinion_change <- ag.opinion - ag.initial_opinion;
            
            // Calculate mean of T2 subfactors for comparison
            float mean_t2_subfactors <- (ag.subfactor_1_t2 + ag.subfactor_2_t2 +
                                         ag.subfactor_3_t2 + ag.subfactor_4_t2 + 
                                         ag.subfactor_5_t2) / 5.0; 
        
            // Calculate individual subfactor errors
            float error_sub1 <- abs(ag.opinion - ag.subfactor_1_t2);
            float error_sub2 <- abs(ag.opinion - ag.subfactor_2_t2);
            float error_sub3 <- abs(ag.opinion - ag.subfactor_3_t2);
            float error_sub4 <- abs(ag.opinion - ag.subfactor_4_t2);
            float error_sub5 <- abs(ag.opinion - ag.subfactor_5_t2);
            
            save [
                model_type,
                current_condition,
                selected_debate_id,
                ag.agent_id,
                ag.pro_reduction,
                pro_count,
                anti_count,
                
                // Initial subfactors (T1)
                ag.subfactor_1_t1, ag.subfactor_2_t1, ag.subfactor_3_t1, 
                ag.subfactor_4_t1, ag.subfactor_5_t1,
                
                // Initial opinion (weighted)
                ag.initial_opinion,
                
                // Simulation final opinion
                ag.opinion,
                
                // T2 subfactors (target)
                ag.subfactor_1_t2, ag.subfactor_2_t2, ag.subfactor_3_t2, 
                ag.subfactor_4_t2, ag.subfactor_5_t2,
                
                // Target opinion (mean of T2)
                ag.final_attitude,
                mean_t2_subfactors,
                
                // Changes and errors
                opinion_change,
                individual_error,
                error_sub1, error_sub2, error_sub3, 
                error_sub4, error_sub5,
                
                // agent-level parameters
                ag.agent_convergence_rate,
                ag.agent_confidence_threshold,
                ag.agent_repulsion_threshold,
                ag.agent_repulsion_strength,
                
                // Parameters
                convergence_rate,
                confidence_threshold,
                repulsion_threshold,
                repulsion_strength,
                seed,
                convergence_cycle
            ]
            to: "outputs/agent_level_results.csv" rewrite: false;
        }
        
        write "Saved " + length(opinion_agent) + " agent records";
    }
    
    // REFLEX: STOP GUI AT MAX_CYCLES
    reflex stop_gui when: cycle >= max_cycles and !mode_batch {
        do pause;
    }
}
