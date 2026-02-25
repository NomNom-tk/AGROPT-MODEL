/**
* Name: Parameters
* Parameters of the social-influence model 
* Author: alfajor
* Tags: 
*/


model opinion_dynamics

global {
	
	// Current experiment condition (detected at runtime)
    string current_condition <- "unknown"; // among: "homogeneous", "heterogeneous", "control"
	
	// SUBFACTOR DATA STORAGE (T1 = initial, T2 = target)
    // Efficient storage: subfactors_t1[0..4][row_index] for 5 subfactors
    list<list<float>> subfactors_t1;        // Initial subfactor values (T1)
    list<list<float>> subfactors_t2;        // Target subfactor values (T2)

    // Helper list for easier computation (populated in init)
    list<float> weights <- [];
    
     // RAW DATA LISTS (loaded from CSV)
    list<string> id_group_raw;              // Group identifiers from CSV
    list<int> agent_id_list;                // Individual agent IDs
    list<string> group_type_list;           // Condition: "Homogeneous", "Heterogeneous", "Control"
    list<float> initial_attitude_list;      // T1 attitudes (DB_IndexT1)
    list<float> final_attitude_list;        // T2 attitudes (DB_IndexT2) - target values
    list<int> debate_id_list;               // Computed debate group IDs
    list<int> pro_reduction_list;           // Binary: 1=pro, 0=anti

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
    float homophily_strength <- 0.5 min: 0.0 max: 1.0; // Strength of neighbor attraction
    
    // Control flags
    bool mode_batch <- false; // Batch mode vs GUI mode
    bool end_simulation <- false; // Convergence flag
    int convergence_cycle <- -1; // Cycle when convergence achieved
    bool final_stats_computed <- false; // Guard for final statistics
    
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
    float mae <- 0.0; // Mean Absolute Error (global)
    map<int, float> mae_per_debate <- map<int, float>(map([]));
    
    // Analysis variables
    float opinion_variance <- 0.0; // Variance of opinions
    int num_clusters <- 0; // Number of opinion clusters
    float polarization_index <- 0.0; // Measure of opinion polarization
    
    
    
	
}

