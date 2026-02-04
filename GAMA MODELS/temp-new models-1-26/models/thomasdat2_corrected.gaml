/**
* Name: thomasdat2_corrected_2025
* Based on the internal empty template. 
* Author: alfajor
* Tags: opinion dynamics, social influence, debate simulation
* 
* COMPATIBLE WITH GAMA 2025.6.4
* 
* CORRECTIONS APPLIED:
* - Fixed variable shadowing in init block (loop variable renamed i -> j)
* - Fixed variable shadowing in initialize_agents_for_debate (renamed i -> idx, j)
* - Removed string/numeric comparison inconsistencies (only use "Control")
* - Removed redundant condition checks in network creation
* - Fixed CSV parsing for GAMA 2025.6.4
* - Added comprehensive documentation
*/

/* 
 * USAGE GUIDE: THREE OPINION DYNAMICS MODELS
 * 
 * 1. CONSENSUS FORMATION (Assimilative Model):
 *    - Set model_type = "consensus"
 *    - Use complete network
 *    - Set convergence_rate = 0.1
 *    - Expected: All agents converge to moderate opinion (~0.5)
 * 
 * 2. OPINION CLUSTERING (Bounded Confidence):
 *    - Set model_type = "clustering"
 *    - Try confidence_threshold = 0.2 (small → more clusters)
 *    - Try confidence_threshold = 0.5 (large → fewer clusters)
 *    - Expected: Multiple stable opinion clusters
 * 
 * 3. BIPOLARIZATION (Repulsive Influence):
 *    - Set model_type = "bipolarization"
 *    - Set confidence_threshold = 0.2 (attract similar)
 *    - Set repulsion_threshold = 0.5 (repel dissimilar)
 *    - Set repulsion_strength = 0.1
 *    - Expected: Two extreme camps at 0.0 and 1.0
 */ 
 
model thomasdat2

global {
    // DATA IMPORT
    file text_data;
    
    // RAW DATA LISTS (loaded from CSV)
    list<string> id_group_raw;              // Group identifiers from CSV
    list<int> agent_id_list;                // Individual agent IDs
    list<string> group_type_list;           // Condition: "Homogeneous", "Heterogeneous", "Control"
    list<float> initial_attitude_list;      // T1 attitudes (DB_IndexT1)
    list<float> final_attitude_list;        // T2 attitudes (DB_IndexT2) - target values
    list<int> debate_id_list;               // Computed debate group IDs
    list<int> pro_reduction_list;           // Binary: 1=pro, 0=anti
    
    // Current experiment condition (detected at runtime)
    string current_condition <- "unknown"; // among: "homogeneous", "heterogeneous", "control"
    
    // SUBFACTOR DATA STORAGE (T1 = initial, T2 = target)
    // Efficient storage: subfactors_t1[0..4][row_index] for 5 subfactors
    list<list<float>> subfactors_t1;        // Initial subfactor values (T1)
    list<list<float>> subfactors_t2;        // Target subfactor values (T2)
    
    // SUBFACTOR WEIGHTS (experimental parameters)
    // These weights determine the contribution of each subfactor to initial opinion
    // NOTE: Weights are automatically normalized (sum doesn't need to equal 1.0)
    float weight_subfactor_1 <- 0.2 min: 0.0 max: 1.0;
    float weight_subfactor_2 <- 0.2 min: 0.0 max: 1.0;
    float weight_subfactor_3 <- 0.2 min: 0.0 max: 1.0;
    float weight_subfactor_4 <- 0.2 min: 0.0 max: 1.0;
    float weight_subfactor_5 <- 0.2 min: 0.0 max: 1.0;
    
    // Helper list for easier computation (populated in init)
    list<float> weights <- [];
    
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
    
    // RESULTS & ANALYSIS
    float mae <- 0.0;                       // Mean Absolute Error (global)
    map<int, float> mae_per_debate <- map<int, float>(map([]));
    float world_size <- 100.0;              // Spatial world size for visualization
    
    // Analysis variables
    float opinion_variance <- 0.0;          // Variance of opinions
    int num_clusters <- 0;                  // Number of opinion clusters
    float polarization_index <- 0.0;        // Measure of opinion polarization

    // INITIALIZATION
    init {
        write "=== LOADING CSV DATA ===";
        
        file text_data <- text_file("./data/data_complete_anonymised.csv");
        list<string> all_lines <- text_data.contents;
        write "Total lines in file: " + length(all_lines);
        
        // Parse header inline
        list<string> headers <- [];
        string header_line <- all_lines[0];
        string current <- "";
        
        // copy headers loop and assign to 'headers'
        loop i from: 0 to: length(header_line) - 1 {
            string char <- copy_between(header_line, i, i + 1);
            if char = "," {
                headers << current;
                current <- "";
            } else {
                current <- current + char;
            }
        }
        headers << current;
        
        write "Number of headers: " + length(headers);
        
        /*/ Load CSV file - FIXED for GAMA 2025.6.4
        text_data <- csv_file("../data/data_complete_anonymised.csv", true);
        
        // Get matrix from file
        matrix data_matrix <- matrix(text_data);
        write "Total rows in file: " + data_matrix.rows + ", cols=" + data_matrix.columns;
        
       
        // GAMA 2025: First row is header, extract it manually
        list<string> headers <- [];
        loop col from: 0 to: data_matrix.columns - 1 {
            headers << string(data_matrix[col, 0]);
        }
        
        write "Headers found: " + length(headers) + " columns";
        
        // Data starts from row 1 (row 0 is header)
        int start_row <- 1;
	*/
	
        // FIND COLUMN INDICES
        int idx_id_group <- headers index_of "ID_Group_all";
        int idx_id <- headers index_of "ID";
        int idx_db_t1 <- headers index_of "DB_IndexT1";
        int idx_db_t2 <- headers index_of "DB_IndexT2";
        int idx_condition <- headers index_of "Condition";
        int idx_pro_reduction <- headers index_of "Pro_reduction";
        
        // Subfactor column indices (5 subfactors x 2 timepoints)
        list<int> idx_sub_t1 <- list_with(5, -1);
        list<int> idx_sub_t2 <- list_with(5, -1);
        
        // FIXED: Renamed loop variable from 'i' to 'j' to avoid shadowing
        loop j from: 1 to: 5 {
            idx_sub_t1[j-1] <- headers index_of ("DBAttitudesT1.DB" + j + ".");
            idx_sub_t2[j-1] <- headers index_of ("DBAttitudesT2.DB" + j + ".");
        }

        write "Column indices found";
        
        // ERROR CHECKING: Verify all required columns exist
        if idx_id_group = -1 {
            write "ERROR: Column 'ID_Group_all' not found!";
            write "Available columns: " + headers;
            do die;
        }
        if idx_id = -1 {
            write "ERROR: Column 'ID' not found!";
            write "Available columns: " + headers;
            do die;
        }
        if idx_db_t1 = -1 {
            write "ERROR: Column 'DB_IndexT1' not found!";
            write "Available columns: " + headers;
            do die;
        }
        if idx_db_t2 = -1 {
            write "ERROR: Column 'DB_IndexT2' not found!";
            write "Available columns: " + headers;
            do die;
        }
        if idx_condition = -1 {
            write "ERROR: Column 'Condition' not found!";
            write "Available columns: " + headers;
            do die;
        }
        if idx_pro_reduction = -1 {
            write "ERROR: Column 'Pro_reduction' not found!";
            write "Available columns: " + headers;
            do die;
        }

        // Check subfactor column indices
        loop j from: 0 to: 4 {
            if idx_sub_t1[j] = -1 or idx_sub_t2[j] = -1 {
                write "ERROR: Subfactor " + (j+1) + " column not found!";
                write "Looking for: DBAttitudesT1.DB" + (j+1) + ". and DBAttitudesT2.DB" + (j+1) + ".";
                write "Available columns: " + headers;
                do die;
            }
        }
        
        /*/ INITIALIZE SUBFACTOR STORAGE - list of t1/2 subfactors with 5 rows (1 for each sub factor)
        subfactors_t1 <- list_with(5, []);
        subfactors_t2 <- list_with(5, []);
        
        // PARSE DATA ROWS
        loop row_idx from: start_row to: data_matrix.rows - 1 {
            // Basic identifiers
            id_group_raw << string(data_matrix[idx_id_group, row_idx]);
            agent_id_list << int(data_matrix[idx_id, row_idx]);

            // Attitudes (normalized from [-6, +6] to [0, 1])
            float raw_t1 <- float(data_matrix[idx_db_t1, row_idx]);
            float raw_t2 <- float(data_matrix[idx_db_t2, row_idx]);
            initial_attitude_list << (raw_t1 + 6.0) / 12.0;
            final_attitude_list << (raw_t2 + 6.0) / 12.0;

            // Group type and pro/anti classification
            group_type_list << string(data_matrix[idx_condition, row_idx]);
            pro_reduction_list << int(data_matrix[idx_pro_reduction, row_idx]);

            // Parse subfactors (normalized from [-6, +6] to [0, 1])
            loop j from: 0 to: 4 {
                float t1_val <- (float(data_matrix[idx_sub_t1[j], row_idx]) + 6.0) / 12.0;
                float t2_val <- (float(data_matrix[idx_sub_t2[j], row_idx]) + 6.0) / 12.0;
                
                subfactors_t1[j] << t1_val;
                subfactors_t2[j] << t2_val;
            }   
        }

        write "Successfully loaded " + length(agent_id_list) + " agents";
        
        // CREATE DEBATE ID MAPPING - Control gets unique ID; others -> ID_Group_all
        debate_id_list <- [];
        map<string, int> group_to_id <- map([]);
        int next_id <- 1;
        
        loop i from: 0 to: length(id_group_raw) - 1 {
            string id_group <- id_group_raw[i];
            string condition <- group_type_list[i];

            // FIXED: Only use string comparison "Control"
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

        // LOAD AGENTS FOR SELECTED DEBATE
        if mode_batch {
            write "Loading debate " + selected_debate_id + " for batch mode";
        } else {
            write "Loading debate " + selected_debate_id + " for GUI mode";
        }
        do initialize_agents_for_debate(selected_debate_id);
        
        write "Created " + length(opinion_agent) + " opinion agents";
        
        // INITIALIZE WEIGHTS HELPER LIST
        weights <- [weight_subfactor_1, weight_subfactor_2, weight_subfactor_3,
                    weight_subfactor_4, weight_subfactor_5];
        
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
        */
    }
    
    // ACTION: CREATE AGENTS FOR SPECIFIC DEBATE
    action initialize_agents_for_debate (int target_debate_id) {
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
        
        // SECOND LOOP: Create agents for this debate - loop over idx instead of i
        loop idx from: 0 to: length(debate_id_list) - 1 {
            if debate_id_list[idx] = target_debate_id {
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
                    
                    // COMPUTE INITIAL OPINION FROM WEIGHTED SUBFACTORS
                    list<float> current_subfactors <- [subfactor_1_t1, subfactor_2_t1, 
                                                       subfactor_3_t1, subfactor_4_t1, 
                                                       subfactor_5_t1]; 
                                        
                    float sum_weights <- sum(weights);
                    float weighted_sum <- 0.0;
                    
                    // FIXED: change loop var to 'k' avoid shadowing
                    loop k from: 0 to: 4 {
                        weighted_sum <- weighted_sum + weights[k] * current_subfactors[k];
                    }
                    
                    // Normalized weighted average (handles any weight sum)
                    initial_opinion <- weighted_sum / sum_weights;
                    
                    // SET UP INITIAL STATE
                    opinion <- initial_opinion;
                    previous_opinion <- initial_opinion;
                    
                    final_attitude <- final_attitude_list[idx];
                    
                    // Random spatial location for visualization
                    location <- {rnd(world_size), rnd(world_size)};
                    
                    // Color based on opinion (blue=0, red=1)
                    color <- rgb(opinion * 255, 0, (1 - opinion) * 255);
                }
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
                    neighbors <- opinion_agent where (
                        each != self and 
                        each.debate_id = self.debate_id and
                        each.group_type != "Control"
                    );
                }
            }
            
            // RANDOM NETWORK: Probabilistic connections
            match "random" {
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
                list<opinion_agent> agent_list <- list(opinion_agent where (each.group_type != "Control"));
                
                loop i from: 0 to: length(agent_list) - 1 {
                    opinion_agent current <- agent_list[i];
                    int k <- 4; // Number of nearest neighbors
                    
                    // Connect to k nearest neighbors (ring topology)
                    loop j from: 1 to: k {
                        int neighbor_index <- (i + j) mod length(agent_list);
                        if agent_list[neighbor_index].debate_id = current.debate_id {
                            current.neighbors <- current.neighbors + agent_list[neighbor_index];
                        }
                    }
                    
                    // Rewire with probability 0.1
                    if flip(0.1) {
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
                if abs(n.opinion - opinion) >= repulsion_threshold {
                    net_repulsion <- net_repulsion + (n.opinion > opinion ? -1.0 : 1.0);
                }
            }
            net_repulsions << abs(net_repulsion);
        }
        
        mean_net_repulsion_abs <- length(net_repulsions) > 0 ? mean(net_repulsions) : 0.0;
    }
    
    // ACTION: COMPUTE FINAL STATISTICS AT CONVERGENCE - overwrites periodic stats (final state)
    action compute_final_statistics {
        if final_stats_computed {
            return;
        }
        
        final_stats_computed <- true;
        
        list<float> opinions <- opinion_agent collect each.opinion;
        
        if length(opinions) > 0 {
            // Final variance
            opinion_variance <- variance(opinions);
        
            // Final number of clusters (histogram-based logic calculation)
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
        save [model_type, current_condition, selected_debate_id, pro_count, anti_count, 
              convergence_rate, confidence_threshold, repulsion_threshold, repulsion_strength,
              weight_subfactor_1, weight_subfactor_2, weight_subfactor_3, weight_subfactor_4, weight_subfactor_5, 
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
                model_type, current_condition, selected_debate_id,
                ag.agent_id, ag.pro_reduction, pro_count, anti_count,
                
                // Initial subfactors (T1)
                ag.subfactor_1_t1, ag.subfactor_2_t1, ag.subfactor_3_t1, 
                ag.subfactor_4_t1, ag.subfactor_5_t1,
                
                ag.initial_opinion, // Initial opinion (weighted)
                ag.opinion, // Simulation final opinion
                // T2 subfactors (target)
                ag.subfactor_1_t2, ag.subfactor_2_t2, ag.subfactor_3_t2, 
                ag.subfactor_4_t2, ag.subfactor_5_t2,
                
                // Target opinion (mean of T2)
                ag.final_attitude,
                mean_t2_subfactors,
                
                // Changes and errors
                opinion_change, individual_error, error_sub1, error_sub2, 
                error_sub3, error_sub4, error_sub5,
                
                // Weights used
                weight_subfactor_1, weight_subfactor_2, weight_subfactor_3, 
                weight_subfactor_4, weight_subfactor_5,
                
                // Parameters
                convergence_rate, confidence_threshold, repulsion_threshold,
                repulsion_strength, seed, convergence_cycle
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

// SPECIES: OPINION AGENT
species opinion_agent {
    // CORE ATTRIBUTES
    float previous_opinion <- 0.0;          // Opinion at previous timestep
    float opinion min: 0.0 max: 1.0;        // Current opinion [0,1]
    list<opinion_agent> neighbors <- [];    // Connected agents in network
    rgb color <- #blue;                     // Visualization color
    point location;                         // Spatial location (for viz)
    int pro_reduction;                      // 1=pro, 0=anti
    
    // Identity
    int agent_id;                           // Unique agent ID
    int debate_id;                          // Debate group ID
    string group_type;                      // "Homogeneous", "Heterogeneous", "Control"
    float initial_opinion;                  // Starting opinion (computed from T1 subfactors)
    float final_attitude;                   // Target opinion (DB_IndexT2)
    
    // SUBFACTOR STORAGE (T1 = initial, T2 = target)
    float subfactor_1_t1;
    float subfactor_2_t1;
    float subfactor_3_t1;
    float subfactor_4_t1;
    float subfactor_5_t1;
    
    float subfactor_1_t2;
    float subfactor_2_t2;
    float subfactor_3_t2;
    float subfactor_4_t2;
    float subfactor_5_t2;
    
    // REFLEX: CONSENSUS FORMATION (Assimilative Model) - All converge toward mean opinion of neighbors
    // Formula: opinion_new = opinion_old + μ * (mean_neighbor_opinion - opinion_old)
    reflex consensus_formation when: model_type = "consensus" {
        if length(neighbors) > 0 {
            previous_opinion <- opinion;
            
            // Average opinion including self
            list<float> all_opinions <- [opinion] + (neighbors collect each.opinion);
            float new_opinion <- mean(all_opinions);
            opinion <- opinion + convergence_rate * (new_opinion - opinion);
            
            // Update color (blue=0, red=1)
            color <- rgb(opinion * 255, 0, (1 - opinion) * 255);
        }
    }
    

    // REFLEX: BOUNDED CONFIDENCE (Clustering Model) - only influence by similar neighbors in conf thresh
    // Formula: opinion_new = opinion_old + μ * (mean_similar_opinion - opinion_old)
    reflex bounded_confidence when: model_type = "clustering" {
        if length(neighbors) > 0 {
            previous_opinion <- opinion;
            
            // Filter neighbors within confidence threshold
            list<opinion_agent> similar_neighbors <- neighbors where (
                abs(each.opinion - self.opinion) <= confidence_threshold
            );
            
            if length(similar_neighbors) > 0 {
                list<float> similar_opinions <- similar_neighbors collect each.opinion;
                float avg_similar <- mean(similar_opinions);
                opinion <- opinion + convergence_rate * (avg_similar - opinion);
                color <- rgb(opinion * 255, 0, (1 - opinion) * 255);
            }
        }
    }

    // REFLEX: BIPOLARIZATION (Repulsive Influence Model)
    // Similar agents attract, dissimilar agents repel
    // - |opinion_diff| <= confidence_threshold: attraction
    // - |opinion_diff| >= repulsion_threshold: repulsion
    // - Between: neutral zone (no influence)
    reflex repulsive_influence when: model_type = "bipolarization" {
        if length(neighbors) > 0 {
            previous_opinion <- opinion;
            
            float attraction_force <- 0.0;
            float repulsion_force <- 0.0;
            int attractive_count <- 0;
            int repulsive_count <- 0;
            
            loop neighbor over: neighbors {
                float difference <- abs(neighbor.opinion - self.opinion);
                
                if difference <= confidence_threshold {
                    // ATTRACTION: Move toward similar neighbors
                    attraction_force <- attraction_force + (neighbor.opinion - self.opinion);
                    attractive_count <- attractive_count + 1;
                    total_attractive_interactions <- total_attractive_interactions + 1;
                }
                else if difference >= repulsion_threshold {
                    // REPULSION: Move away from dissimilar neighbors
                    float direction <- neighbor.opinion > self.opinion ? -1.0 : 1.0;
                    repulsion_force <- repulsion_force + direction;
                    repulsive_count <- repulsive_count + 1;
                    total_repulsive_interactions <- total_repulsive_interactions + 1;
                }
                else {
                    // NEUTRAL ZONE: No influence
                    total_neutral_interactions <- total_neutral_interactions + 1;
                }
            }
            
            // Apply combined forces
            float opinion_change <- 0.0;
            if attractive_count > 0 {
                opinion_change <- opinion_change + convergence_rate * (attraction_force / attractive_count);
            }
            if repulsive_count > 0 {
                opinion_change <- opinion_change + repulsion_strength * (repulsion_force / repulsive_count);
            }
            
            // Update opinion (clamped to [0,1])
            opinion <- max([0.0, min([1.0, opinion + opinion_change])]);
            
            // Update color (gradient from blue to red)
            if opinion < 0.5 {
                color <- rgb(0, 0, 255 * (1 - opinion * 2));
            } else {
                color <- rgb(255 * ((opinion - 0.5) * 2), 0, 0);
            }
        }
    }
    
    // ASPECTS: VISUALIZATION
    aspect default {
        draw circle(1.5) color: color border: #black;
    }
    
    aspect with_links {
        draw circle(1.5) color: color border: #black;
        // Draw network connections (sampled at 10% to avoid clutter)
        if length(neighbors) > 0 and flip(0.1) {
            loop n over: neighbors {
                draw line([location, n.location]) color: #gray width: 0.3;
            }
        }
    }
}

// EXPERIMENT: GUI MODE
experiment social_influence type: gui {
    parameter "Model Type" var: model_type category: "Model Selection";
    parameter "Selected Debate ID" var: selected_debate_id category: "Data";
    parameter "Network Type" var: network_type category: "Network";
    parameter "Connection Probability (random)" var: connection_probability category: "Network";
    parameter "Convergence Rate (μ)" var: convergence_rate category: "Opinion Dynamics";
    parameter "Confidence Threshold (ε)" var: confidence_threshold category: "Opinion Dynamics";
    parameter "Repulsion Threshold" var: repulsion_threshold category: "Opinion Dynamics";
    parameter "Repulsion Strength" var: repulsion_strength category: "Opinion Dynamics";
    parameter "Max Cycles" var: max_cycles category: "Simulation";
    
    output {
        // Spatial display
        display spatial_view type: 2d {
            species opinion_agent aspect: default;
        }
        
        // Opinion distribution over time
        display opinion_timeline type: 2d refresh: every(5#cycles) {
            chart "Opinion Distribution" type: series {
                loop i from: 0 to: 9 {
                    data "Bin " + i value: opinion_agent count (
                        each.opinion >= i/10.0 and each.opinion < (i+1)/10.0
                    ) color: rgb(i*25.5, 0, 255 - i*25.5);
                }
            }
        }
        
        // Current opinion histogram
        display opinion_histogram type: 2d refresh: every(5#cycles) {
            chart "Current Opinion Distribution" type: histogram {
                loop i from: 0 to: 9 {
                    data "Bin " + i value: opinion_agent count (
                        each.opinion >= i/10.0 and each.opinion < (i+1)/10.0
                    ) color: rgb(i*25.5, 0, 255 - i*25.5);
                }
            }
        }
        
        // Opinion dynamics measures
        display statistics type: 2d refresh: every(1#cycles) {
            chart "Opinion Dynamics Measures" type: series {
                data "Opinion Variance" value: opinion_variance color: #blue;
                data "Polarization Index" value: polarization_index * 10 color: #red;
            }
        }
        
        // Monitors
        monitor "Current Cycle" value: cycle;
        monitor "Convergence Cycle" value: convergence_cycle;
        monitor "Opinion Variance" value: opinion_variance;
        monitor "Number of Clusters" value: num_clusters;
        monitor "Polarization Index" value: polarization_index;
        monitor "Mean Opinion" value: length(opinion_agent) > 0 ? mean(opinion_agent collect each.opinion) : 0.0;
        monitor "Opinion Range" value: length(opinion_agent) > 0 ? max(opinion_agent collect each.opinion) - min(opinion_agent collect each.opinion) : 0.0;
        monitor "Number of Agents" value: length(opinion_agent);
        monitor "Control Agents" value: opinion_agent count (each.group_type = "Control");
        monitor "Model Fit MAE" value: mae;
        monitor "Debates Tracked" value: mae_per_debate.keys;
    }
}

// BATCH EXPERIMENTS: EXHAUSTIVE SEARCH
// Batch Consensus (Exhaustive)
experiment Batch_consensus_exh type: batch repeat: 2 keep_seed: true until: end_simulation {
    parameter "Selected debate id" var: selected_debate_id min: 1 max: 55 step: 1;
    parameter "Convergence Rate" var: convergence_rate among: [0.1, 0.3, 0.5, 0.7, 0.9];
    parameter "Confidence Threshold" var: confidence_threshold among: [0.2, 0.4, 0.6, 0.8];
    parameter "Repulsion Threshold" var: repulsion_threshold among: [0.0, 0.2, 0.5, 0.8];
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
    parameter "Convergence Rate" var: convergence_rate among: [0.1, 0.3, 0.5, 0.7, 0.9];
    parameter "Confidence Threshold" var: confidence_threshold among: [0.2, 0.4, 0.6, 0.8];
    parameter "Repulsion Threshold" var: repulsion_threshold among: [0.0, 0.2, 0.5, 0.8];
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
    parameter "Convergence Rate" var: convergence_rate among: [0.1, 0.3, 0.5, 0.7, 0.9];
    parameter "Confidence Threshold" var: confidence_threshold among: [0.2, 0.4, 0.6, 0.8];
    parameter "Repulsion Threshold" var: repulsion_threshold among: [0.0, 0.2, 0.5, 0.8];
    parameter "Repulsion Strength" var: repulsion_strength among: [0.1, 0.2, 0.3];
   
    init {
        mode_batch <- true;
        model_type <- "bipolarization";
        convergence_cycle <- -1;
    }
}

// BATCH EXPERIMENTS: GENETIC ALGORITHM

// Batch Consensus (Genetic)
experiment Batch_consensus type: batch repeat: 2 keep_seed: true until: end_simulation {
    parameter "Selected debate id" var: selected_debate_id min: 1 max: 55 step: 1;
    parameter "Convergence Rate" var: convergence_rate among: [0.1, 0.3, 0.5, 0.7, 0.9];
    parameter "Confidence Threshold" var: confidence_threshold among: [0.2, 0.4, 0.6, 0.8];
    parameter "Repulsion Threshold" var: repulsion_threshold among: [0.0, 0.2, 0.5, 0.8];
    parameter "Repulsion Strength" var: repulsion_strength among: [0.1, 0.2, 0.3];
   
    init {
        mode_batch <- true;
        model_type <- "consensus";
        convergence_cycle <- -1;
    }
}

// Batch Clustering (Genetic)
experiment Batch_clustering type: batch repeat: 2 keep_seed: true until: end_simulation {
    parameter "Selected debate id" var: selected_debate_id min: 1 max: 55 step: 1;
    parameter "Convergence Rate" var: convergence_rate among: [0.1, 0.3, 0.5, 0.7, 0.9];
    parameter "Confidence Threshold" var: confidence_threshold among: [0.2, 0.4, 0.6, 0.8];
    parameter "Repulsion Threshold" var: repulsion_threshold among: [0.0, 0.2, 0.5, 0.8];
    parameter "Repulsion Strength" var: repulsion_strength among: [0.1, 0.2, 0.3];
   
    init {
        mode_batch <- true;
        model_type <- "clustering";
        convergence_cycle <- -1;
    }
}

// Batch Bipolarization (Genetic)
experiment Batch_bipolarization type: batch repeat: 2 keep_seed: true until: end_simulation {
    parameter "Selected debate id" var: selected_debate_id min: 1 max: 55 step: 1;
    parameter "Convergence Rate" var: convergence_rate among: [0.1, 0.3, 0.5, 0.7, 0.9];
    parameter "Confidence Threshold" var: confidence_threshold among: [0.2, 0.4, 0.6, 0.8];
    parameter "Repulsion Threshold" var: repulsion_threshold among: [0.0, 0.2, 0.5, 0.8];
    parameter "Repulsion Strength" var: repulsion_strength among: [0.1, 0.2, 0.3];
   
    init {
        mode_batch <- true;
        model_type <- "bipolarization";
        convergence_cycle <- -1;
    }
}
