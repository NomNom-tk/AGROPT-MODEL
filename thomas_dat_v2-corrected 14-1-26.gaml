/**
* Name: thomasdat1
* Based on the internal empty template. 
* Author: alfajor
* Tags: 
*/

/* 
 * USAGE GUIDE:
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
    // Import CSV data
    file text_data;
    
    // Declaring list
    list<string> id_group_raw;
    list<int> agent_id_list;
    list<string> group_type_list;
    string current_condition <- "unknown"; // among hetero, homo and control 
    
    // Pro reduction metrics
    list<int> pro_reduction_list;
    int num_pro_agents <- 0;
    int num_anti_agents <- 0;
    float mean_opinion_pro <- 0.0;
    float mean_opinion_anti <- 0.0;
    
    list<float> initial_attitude_list;
    list<float> final_attitude_list;
    list<int> debate_id_list;
    
    // bipolarization diagnostics
    int initial_num_clusters <- 0;
    int total_attractive_interactions <- 0;
    int total_repulsive_interactions <- 0;
    int total_neutral_interactions <- 0 ;
    float neutral_zone_width <- 0.0;
    float mean_net_repulsion_abs <- 0.0;
    
    // final stats comp check
    bool final_stats_computed <- false;

    // Simulation parameters
    int selected_debate_id <- 1;
    string model_type <- "consensus" among: ["consensus", "clustering", "bipolarization"];
    string network_type <- "complete" among: ["complete", "random", "small_world"];
    float connection_probability <- 0.3 min: 0.0 max: 1.0;
    
    // Timing
    float step <- 0.5;
    int max_cycles <- 100;
    
    // Control flags
    bool mode_batch <- false;
    bool end_simulation <- false;
    int convergence_cycle <- -1;
    
    // Convergence parameters
    float mae_convergence_threshold <- 0.001 min: 0.0 max: 1.0;

    // Opinion dynamics parameters
    float convergence_rate <- 0.2 min: 0.0 max: 1.0;
    float confidence_threshold <- 0.5 min: 0.0 max: 1.0;
    float repulsion_threshold <- 0.6 min: 0.0 max: 1.0;
    float repulsion_strength <- 0.1 min: 0.0 max: 0.5;
    
    // Results
    float mae <- 0.0;
    map<int, float> mae_per_debate <- map<int, float>(map([]));
    float world_size <- 100.0;
    
    // Analysis variables
    float opinion_variance <- 0.0;
    int num_clusters <- 0;
    float polarization_index <- 0.0;
    
    // Initialization
    init {
        write "=== loading csv data===";
        
        file text_data <- text_file("./data/data_complete_anonymised.csv");
        list<string> all_lines <- text_data.contents;
        write "Total lines in file: " + length(all_lines);
        
        // Parse header inline
        list<string> headers <- [];
        string header_line <- all_lines[0];
        string current <- "";
        
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
        
        // Find column indices
        int idx_id_group <- headers index_of "ID_Group_all";
        int idx_id <- headers index_of "ID";
        int idx_db_t1 <- headers index_of "DB_IndexT1";
        int idx_db_t2 <- headers index_of "DB_IndexT2";
        int idx_condition <- headers index_of "Condition";
        int idx_pro_reduction <- headers index_of "Pro_reduction";
        
        write "Column indices found";
        
        if idx_id_group = -1 or idx_id = -1 or idx_db_t1 = -1 or idx_db_t2 = -1 or idx_condition = -1 or idx_pro_reduction = -1 {
            write "ERROR: Column not found!";
            return;
        }
        
        int max_idx <- max([idx_id_group, idx_id, idx_db_t1, idx_db_t2, idx_condition, idx_pro_reduction]);
        
        // Parse data rows inline
        int skipped_rows <- 0;
        int processed_rows <- 0;
        
        loop i from: 1 to: length(all_lines) - 1 {
            string line <- all_lines[i];
            
            if length(line) < 10 {
                skipped_rows <- skipped_rows + 1;
                continue;
            }
            
            // Parse line inline
            list<string> row <- [];
            current <- "";
            
            loop j from: 0 to: length(line) - 1 {
                string char <- copy_between(line, j, j + 1);
                if char = "," {
                    row << current;
                    current <- "";
                } else {
                    current <- current + char;
                }
            }
            row << current;
            
            if length(row) > max_idx {
                id_group_raw << string(row[idx_id_group]);
                agent_id_list << int(row[idx_id]);
                
                float raw_t1 <- float(row[idx_db_t1]);
                float raw_t2 <- float(row[idx_db_t2]);
                initial_attitude_list << (raw_t1 + 6.0) / 12.0;
                final_attitude_list << (raw_t2 + 6.0) / 12.0;
                
                group_type_list << string(row[idx_condition]);
                pro_reduction_list << int(row[idx_pro_reduction]);
                processed_rows <- processed_rows + 1;
            } else {
                skipped_rows <- skipped_rows + 1;
            }
        }
        
        write "Processed rows: " + processed_rows;
        write "Skipped rows: " + skipped_rows;
        write "Successfully loaded " + length(agent_id_list) + " agents";
        
        // FILTER OUT CORRUPTED DATA
        write "=== FILTERING CORRUPTED DATA ===";
        int original_count <- length(id_group_raw);
        
        list<int> valid_indices <- [];
        loop i from: 0 to: length(id_group_raw) - 1 {
            string group_id <- id_group_raw[i];
            string first_char <- copy_between(group_id, 0, 1);
            if first_char in ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", 
                              "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"] {
                valid_indices << i;
            }
        }
        
        // Filter all lists
        list<string> filtered_id_group <- [];
        list<int> filtered_agent_id <- [];
        list<float> filtered_initial <- [];
        list<float> filtered_final <- [];
        list<string> filtered_group_type <- [];
        list<int> filtered_pro_reduction <- [];
        
        loop idx over: valid_indices {
            filtered_id_group << id_group_raw[idx];
            filtered_agent_id << agent_id_list[idx];
            filtered_initial << initial_attitude_list[idx];
            filtered_final << final_attitude_list[idx];
            filtered_group_type << group_type_list[idx];
            filtered_pro_reduction << pro_reduction_list[idx];
        }
        
        // Replace original lists
        id_group_raw <- filtered_id_group;
        agent_id_list <- filtered_agent_id;
        initial_attitude_list <- filtered_initial;
        final_attitude_list <- filtered_final;
        group_type_list <- filtered_group_type;
        pro_reduction_list <- filtered_pro_reduction;
        
        write "Filtered from " + original_count + " to " + length(id_group_raw) + " valid agents";
        
        // Create debate_id mapping
        debate_id_list <- [];
        map<string, int> group_to_id <- map([]);
        int next_id <- 1;
        
        loop id_group over: id_group_raw {
            if not (group_to_id.keys contains id_group) {
                group_to_id[id_group] <- next_id;
                next_id <- next_id + 1;
            }
            debate_id_list << group_to_id[id_group];
        }
        
        // Find unique debates
        list<int> unique_debates <- remove_duplicates(debate_id_list);
        write "Found " + length(unique_debates) + " unique debates";

        loop debate over: unique_debates {
            int count <- debate_id_list count (each = debate);
            write "Debate " + debate + ": " + count + " agents";
        }

        // Load agents based on mode
        if mode_batch {
            write "Loading debate " + selected_debate_id + " for batch mode";
            do initialize_agents_for_debate(selected_debate_id);
        } else {
            write "Loading debate " + selected_debate_id + " for GUI mode";
            do initialize_agents_for_debate(selected_debate_id);
        }
        
        write "Created " + length(opinion_agent) + " opinion agents";
        
        do create_network;
        
        // initial opinion clustering (diagnostic)
        list<int> init_hist <- list_with(10, 0);
        loop o over: opinion_agent collect each.initial_opinion {
        	int b <- min([9, int(o * 10)]);
        	init_hist[b] <- init_hist[b] + 1;
        }
        initial_num_clusters <- init_hist count (each > 0);
        
        // structural diagnostic
        neutral_zone_width <- repulsion_threshold - confidence_threshold;
        
        // guard for final stats
        final_stats_computed <- false;
        
    }
    
    // Create agents for specific debate
    action initialize_agents_for_debate(int target_debate_id) {
        bool condition_detected <- false;
        
        // FIRST LOOP: Detect condition
        loop i from: 0 to: length(debate_id_list) - 1 {
            if debate_id_list[i] = target_debate_id and !condition_detected {
                string group_type_val <- group_type_list[i];
                write "DEBUG group_type_val for debate" + target_debate_id + group_type_val;
				
				// match against text values from csv
				if group_type_val = "Homogeneous" or group_type_val = "1" {
					current_condition <- "homogeneous";
				} else if group_type_val = "Heterogeneous" or group_type_val = "2" {
					current_condition <- "heterogeneous"; 
                } else if group_type_val = "Control" or group_type_val = "3" {
                    current_condition <- "control";
                } else {
                	write "Warning unkown condition type";
                }
                condition_detected <- true;
                write "DEBUG: detected condition = " + current_condition;
            }
        }
        
        // SECOND LOOP: Create agents
        loop i from: 0 to: length(debate_id_list) - 1 {
            if debate_id_list[i] = target_debate_id {
                create opinion_agent {
                    agent_id <- agent_id_list[i];
                    debate_id <- target_debate_id;
                    group_type <- group_type_list[i];
                    pro_reduction <- pro_reduction_list[i];
                    
                    initial_opinion <- initial_attitude_list[i];
                    opinion <- initial_opinion;
                    previous_opinion <- initial_opinion;
                    
                    final_attitude <- final_attitude_list[i];
                    
                    location <- {rnd(world_size), rnd(world_size)};
                    color <- rgb(opinion * 255, 0, (1 - opinion) * 255);
                }
            }
        }
        
        write "Debate " + target_debate_id + " condition: " + current_condition;
    }
    
    // Network creation
    action create_network {
        ask opinion_agent {
            neighbors <- [];
        }

        switch network_type {
            match "complete" {
                ask opinion_agent {
                    neighbors <- opinion_agent where (
                        each != self and 
                        each.debate_id = self.debate_id and
                        each.group_type != "Control" and
                        self.group_type != "Control" 
                    );
                }
            }
            match "random" {
                ask opinion_agent where (each.group_type != "Control" and each.group_type != "3") {
                    neighbors <- opinion_agent where (
                        each != self and 
                        each.debate_id = self.debate_id and
                        each.group_type != "Control" and
                        each.group_type != "3" and
                        flip(connection_probability)
                    );
                }
            }
            match "small_world" {
                list<opinion_agent> agent_list <- list(opinion_agent where (each.group_type != "Control" and each.group_type != "3"));
                loop i from: 0 to: length(agent_list) - 1 {
                    opinion_agent current <- agent_list[i];
                    int k <- 4;
                    loop j from: 1 to: k {
                        int neighbor_index <- (i + j) mod length(agent_list);
                        if agent_list[neighbor_index].debate_id = current.debate_id {
                            current.neighbors <- current.neighbors + agent_list[neighbor_index];
                        }
                    }
                    if flip(0.1) {
                        opinion_agent random_neighbor <- one_of(
                            opinion_agent where (
                                each != current and 
                                each.debate_id = current.debate_id and
                                each.group_type != "Control" and each.group_type != "3"
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

    // Anti and pro reduction stats computation (every 10 cycles)
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

    // Statistics computation (every 10 cycles)
    reflex compute_statistics when: every(10#cycle) {
        list<float> opinions <- opinion_agent collect each.opinion;
        if length(opinions) > 0 {
            float mean_opinion <- mean(opinions);
            opinion_variance <- variance(opinions);

            int num_bins <- 10;
            list<int> histogram <- list_with(num_bins, 0);
            loop op over: opinions {
                int bin <- min([num_bins - 1, int(op * num_bins)]);
                histogram[bin] <- histogram[bin] + 1;
            }
            num_clusters <- histogram count (each > 0);

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
    
    // Check for convergence (every 5 cycles after cycle 10)
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
    
    // Fallback: stop at max_cycles if not converged
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
    
    // Compute MAE
    action compute_fit {
        write "=== Computing Fit at Cycle " + cycle + " ===";
        
        mae_per_debate <- map<int, float>(map([]));
        list<int> debates <- remove_duplicates(opinion_agent collect each.debate_id);
        list<float> all_errors <- [];
        
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
        
        mae <- length(all_errors) > 0 ? mean(all_errors) : 0.0;
        
        write "Global MAE: " + mae;
        write "Per-debate MAE: " + mae_per_debate;
        
        // mean absolute net repulsion (cluster stability)
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
    
    // final stats computation --> comp final opinion var, cluster num, polarization index at exact convergence
    // does not replace periodic computation, only overwrites at the end 
    action compute_final_statistics {
    	if final_stats_computed {
    		return;
    	}
    	
    	final_stats_computed <- true;
    	
    	list<float> opinions <- opinion_agent collect each.opinion;
    	
    	if length(opinions) > 0{
    		// final variance
    		opinion_variance <- variance(opinions);
    	
    		//final number of clusters, based on histogram computation
    		int num_bins <- 10;
    		list<int> histogram <- list_with(num_bins, 0);
    	
    		loop op over: opinions {
    			int bin <- min([num_bins - 1, int(op * num_bins)]);
    			histogram[bin] <- histogram[bin] + 1;
    	}
    	num_clusters <- histogram count (each > 0);
    	
    	// final polarizatio nindex (pairwise variance)
    	list<float> pairwise_distances <- [];
    	loop a1 over: opinion_agent{
    		loop a2 over: opinion_agent{
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
    
    
    // Save batch results
    action save_batch_results {
        write "=== Saving Results ===";
        write "MAE: " + mae;
        write "Condition: " + current_condition;
        write "Debates: " + mae_per_debate.keys;
        
        int pro_count <- opinion_agent count (each.pro_reduction = 1);
        int anti_count <- opinion_agent count (each.pro_reduction = 0);
        
        save [model_type, current_condition, selected_debate_id, pro_count, anti_count, 
              convergence_rate, confidence_threshold, repulsion_threshold, repulsion_strength, 
              seed, convergence_cycle, mae, opinion_variance, polarization_index, num_clusters, initial_num_clusters,
              neutral_zone_width, mean_net_repulsion_abs]
        to: "outputs/batch_summary.csv" rewrite: false;
        
        do save_agent_results;
        
        write "Results saved successfully";
    }
    
    // Save agent results
    action save_agent_results {
        write "=== Saving Per-Agent Results ===";
        
        int pro_count <- opinion_agent count (each.pro_reduction = 1);
        int anti_count <- opinion_agent count (each.pro_reduction = 0);
        
        loop ag over: opinion_agent {
            float individual_error <- abs(ag.opinion - ag.final_attitude);
            float opinion_change <- ag.opinion - ag.initial_opinion;
            
            save [
                model_type,
                current_condition,
                selected_debate_id,
                ag.agent_id,
                ag.pro_reduction,
                pro_count,
                anti_count,
                ag.initial_opinion,
                ag.opinion,
                ag.final_attitude,
                opinion_change,
                individual_error,
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
    
    // GUI stop
    reflex stop_gui when: cycle >= max_cycles and !mode_batch {
        do pause;
    }
}

species opinion_agent {
    // Attributes
    float previous_opinion <- 0.0;
    float opinion min: 0.0 max: 1.0;
    list<opinion_agent> neighbors <- [];
    rgb color <- #blue;
    point location;
    int pro_reduction;
    
    int agent_id;
    int debate_id;
    string group_type;
    float initial_opinion;
    float final_attitude;
    
    // Consensus formation
    reflex consensus_formation when: model_type = "consensus" {
        if length(neighbors) > 0 {
            previous_opinion <- opinion;
            
            list<float> all_opinions <- [opinion] + (neighbors collect each.opinion);
            float new_opinion <- mean(all_opinions);
            opinion <- opinion + convergence_rate * (new_opinion - opinion);
            color <- rgb(opinion * 255, 0, (1 - opinion) * 255);
        }
    }
    
    // Bounded confidence
    reflex bounded_confidence when: model_type = "clustering" {
        if length(neighbors) > 0 {
            previous_opinion <- opinion;
            
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
    
    // Bipolarization
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
                	// attraction
                    attraction_force <- attraction_force + (neighbor.opinion - self.opinion);
                    attractive_count <- attractive_count + 1;
                    total_attractive_interactions <- total_attractive_interactions + 1;
                }
                else if difference >= repulsion_threshold {
                	// repulsion
                    float direction <- neighbor.opinion > self.opinion ? -1.0 : 1.0;
                    repulsion_force <- repulsion_force + direction;
                    repulsive_count <- repulsive_count + 1;
                    total_repulsive_interactions <- total_repulsive_interactions + 1;
                }
            	else {
            		//neutral zone
            		total_neutral_interactions <- total_neutral_interactions + 1;
            	}
            }
            
            float opinion_change <- 0.0;
            if attractive_count > 0 {
                opinion_change <- opinion_change + convergence_rate * (attraction_force / attractive_count);
            }
            if repulsive_count > 0 {
                opinion_change <- opinion_change + repulsion_strength * (repulsion_force / repulsive_count);
            }
            
            opinion <- max([0.0, min([1.0, opinion + opinion_change])]);
            
            if opinion < 0.5 {
                color <- rgb(0, 0, 255 * (1 - opinion * 2));
            } else {
                color <- rgb(255 * ((opinion - 0.5) * 2), 0, 0);
            }
        }
    }
    
    aspect default {
        draw circle(1.5) color: color border: #black;
    }
    
    aspect with_links {
        draw circle(1.5) color: color border: #black;
        if length(neighbors) > 0 and flip(0.1) {
            loop n over: neighbors {
                draw line([location, n.location]) color: #gray width: 0.3;
            }
        }
    }
}

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
        display spatial_view type: 2d {
            species opinion_agent aspect: default;
        }
        
        display opinion_timeline type: 2d refresh: every(5#cycles) {
            chart "Opinion Distribution" type: series {
                loop i from: 0 to: 9 {
                    data "Bin " + i value: opinion_agent count (
                        each.opinion >= i/10.0 and each.opinion < (i+1)/10.0
                    ) color: rgb(i*25.5, 0, 255 - i*25.5);
                }
            }
        }
        
        display opinion_histogram type: 2d refresh: every(5#cycles) {
            chart "Current Opinion Distribution" type: histogram {
                loop i from: 0 to: 9 {
                    data "Bin " + i value: opinion_agent count (
                        each.opinion >= i/10.0 and each.opinion < (i+1)/10.0
                    ) color: rgb(i*25.5, 0, 255 - i*25.5);
                }
            }
        }
        
        display statistics type: 2d refresh: every(1#cycles) {
            chart "Opinion Dynamics Measures" type: series {
                data "Opinion Variance" value: opinion_variance color: #blue;
                data "Polarization Index" value: polarization_index * 10 color: #red;
            }
        }
        
        monitor "Current Cycle" value: cycle;
        monitor "Convergence Cycle" value: convergence_cycle;
        monitor "Opinion Variance" value: opinion_variance;
        monitor "Number of Clusters" value: num_clusters;
        monitor "Polarization Index" value: polarization_index;
        monitor "Mean Opinion" value: length(opinion_agent) > 0 ? mean(opinion_agent collect each.opinion) : 0.0;
        monitor "Opinion Range" value: length(opinion_agent) > 0 ? max(opinion_agent collect each.opinion) - min(opinion_agent collect each.opinion) : 0.0;
        monitor "Number of Agents" value: length(opinion_agent);
        monitor "Control Agents" value: opinion_agent count (each.group_type = "Control" or each.group_type = 3);
        monitor "Model Fit MAE" value: mae;
        monitor "Debates Tracked" value: mae_per_debate.keys;
    }
}

// Batch Exp exhaustive
/// Batch Consensus exh
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

/// Batch Clustering
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

/// Batch Bipolarization
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

// Batch Exp Genetic 
/// Batch Consensus
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

/// Batch Clustering
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

/// Batch Clustering
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
