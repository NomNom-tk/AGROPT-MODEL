/**
* Name: Parameters
* Parameters of the social-influence model 
* Author: alfajor
* Tags: 
*/


model opinion_dynamics

global {
	
    // =====
    // INPUT PARAMS
    // =====

 	int max_cycles <- 100; // max cycles for convergence
    bool end_simulation_at_convergence <- true;
    // Convergence Constants
    float mae_convergence_threshold <- 0.01; // Convergence Checking re-modified 4/5/26
    // v1: mae_convergence_threshold = 0.001 (too tight, early stopping)
    // v2: mae_convergence_threshold = 0.01 (order of magnitude relaxing)
    // v3: fixed_cycles = N (no convergence check, fixed duration)
    
    // =====
    // Environment
	// =====
    
    float world_size <- 100.0; // Spatial world size for visualization
    int n_bins <- 50; // bins for gui viz and gif generaiton
    int stats_bins <- 10; // bins for logical histogram calculation
    
    
    // Simulation Control
    int selected_debate_id <- 1;            // Which debate to simulate
    list<int> m_debate_list <- []; // debate list populated based on composition_scope or selection_mode 21/5/26
    string model_type <- "consensus" among: ["consensus", "clustering", "bipolarization", 
    "argumentative", "no_change"];
    bool use_distinct_agents <- true; // default: heterogeneous
    bool mode_batch <- false; // Batch mode vs GUI mode
    bool speaking_mode <- false; // speaking flag
    bool debug_mode <- false; // show debug?
    map<string, int> stable_group_map <- map<string, int>([]); // persistent group mapping for reproducibility
    list<string> interaction_log <- [];

    // Opinion dynamics
    float convergence_rate <- 0.2 min: 0.0 max: 1.0;        // μ: Speed of opinion change
    float confidence_threshold <- 0.5 min: 0.0 max: 1.0;    // ε: Similarity for attraction
    float repulsion_threshold <- 0.6 min: 0.0 max: 1.0;     // Dissimilarity for repulsion
    float repulsion_strength <- 0.1 min: 0.0 max: 0.5;      // Strength of repulsive force

    // Distinct Agents SDs (heterogeneity)
    float convergence_rate_sd <- 0.05 min: 0.0 max: 0.2;
    float confidence_threshold_sd <- 0.1 min: 0.0 max: 0.3;
    float repulsion_threshold_sd <- 0.1 min: 0.0 max: 0.3;
    float repulsion_strength_sd <- 0.05 min: 0.0 max: 0.2;

    // argumentation parameters
    int argument_pool_size <- 30;
    int agent_arg <- 10 min: 5 max: 15;
    int argument_id;
    int relev_arg <- 3 min: 1 max: 10;

    // =====
    // Runtime state (Detected or computed during sim)
    // =====

    string current_condition <- "unknown";  // among: "homogeneous", "heterogeneous", "control"
    bool end_simulation <- false;           // Convergence flag
    int convergence_cycle <- -1;            // Cycle when convergence achieved
    bool final_stats_computed <- false;     // Guard for final statistics
    string current_experiment_id <- "";		// type of experiment for each batch 
    string selection_mode <- "explicit" among: ["filter", "explicit"]; // run debates based on xml or composition_scope 21/5/26
    string composition_scope <- "M" among: ["H", "M", "ALL"]; // filtering debate mapping, hetero, homo or all debates 21/5/26
    string explicit_debates_path <- ""; // empty path to be populated in experiments for external debates list 21/5/26

    // =====
    // Raw Data Storage
    // =====

    list<list<float>> subfactors_t1;        // Initial subfactor values (T1) [0..4][row_index] for 5 subfactors
    list<list<float>> subfactors_t2;        // Target subfactor values (T2)
    list<float> weights <- [];              // helper list for computation pop in init
    list<string> id_group_raw;              // Group identifiers from CSV
    list<int> agent_id_list;                // Individual agent IDs
    list<string> group_type_list;           // Condition: "Homogeneous", "Heterogeneous", "Control"
    list<float> initial_attitude_list;      // T1 attitudes (DB_IndexT1)
    list<float> final_attitude_list;        // T2 attitudes (DB_IndexT2) - target values
    list<int> debate_id_list;               // Computed debate group IDs
    list<int> pro_reduction_list;           // Binary: 1=pro, 0=anti

    // =====
    // Output Vars - computed results and DIAGNOSTICS

    // Model Fit
    float mae <- 0.0;                       // Mean Absolute Error (global)
    map<int, float> mae_per_debate <- map<int, float>(map([]));

    // Opinion Stats
    float opinion_variance <- 0.0;          // Variance of opinions
    float initial_variance;                 // variance of opin at init
    int num_clusters <- 0;                  // Number of opinion clusters
    float polarization_index <- 0.0;        // Measure of opinion polarization
    int initial_num_clusters <- 0;          // Opinion clusters at start

    // PRO/ANTI REDUCTION METRICS
    int num_pro_agents <- 0;                // Count of pro-reduction agents
    int num_anti_agents <- 0;               // Count of anti-reduction agents
    float mean_opinion_pro <- 0.0;          // Mean opinion of pro agents
    float mean_opinion_anti <- 0.0;         // Mean opinion of anti agents
    int pro_count <- 0;                     // Count of pro-reduc agents for save logic
    int anti_count <- 0;                    // Count of anti-reduc agents for save logic
    
    // BIPOLARIZATION DIAGNOSTICS
    
    int total_attractive_interactions <- 0; // Count of attractive interactions
    int total_repulsive_interactions <- 0;  // Count of repulsive interactions
    int total_neutral_interactions <- 0;    // Count of neutral zone interactions
    float neutral_zone_width <- 0.0;        // Width of neutral zone (repulsion - confidence)
    float mean_net_repulsion_abs <- 0.0;    // Mean absolute net repulsion force

    // Not used anymore
    //float homophily_strength <- 0.5 min: 0.0 max: 1.0; // Strength of neighbor attraction
}

