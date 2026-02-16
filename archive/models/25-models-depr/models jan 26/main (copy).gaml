// Central Structuring file for models of social influence

model opinion_dynamics_main

import "config/parameters.gaml" // pulls all modifiable parameters
import "species/opinion_agent.gaml" // import opinion agent species
import "species/data_manager.gaml" // within species dir import data_loader (CSV utilities)
import "actions/network_builder.gaml" // within action dir import network_builder
import "actions/statistics.gaml" // import calculations
import "actions/file_io.gaml" // output saving to file
import "experiments/gui_experiments.gaml" // gui mode experiments
import "experiments/batch_experiments.gaml" // batch experiments for param optimization

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
    
    // initialization ONLY for orchestration
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
    
    // INITIAL DIAGNOSTICS
    action compute_initial_diagnostics {
        // Initial opinion clustering (count non-empty bins)
        list<int> init_hist <- list_with(10, 0);
        loop o over: opinion_agent collect each.initial_opinion {
            int b <- min([9, int(o * 10)]);
            init_hist[b] <- init_hist[b] + 1;
        }
        initial_num_clusters <- init_hist count (each > 0);
        
        // Structural diagnostic for bipolarization model
        neutral_zone_width <- repulsion_threshold - confidence_threshold;
    }
    
    // REFLEXES: PRO/ANTI STATS
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
    
    // REFLEXES: STATISTICS (delegated to statistics.gaml)
    reflex compute_statistics when: every(10#cycle) {
        do compute_opinion_statistics;
    }
    
    // REFLEXES: CONVERGENCE CHECK
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
    
    // REFLEXES: MAX CYCLES FALLBACK
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
    
    // REFLEXES: STOP GUI
    reflex stop_gui when: cycle >= max_cycles and !mode_batch {
        do pause;
    }
}
