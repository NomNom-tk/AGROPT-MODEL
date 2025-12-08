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

model thomasdat1

global {
    // Model selection
    string model_type <- "consensus" among: ["consensus", "clustering", "bipolarization"];

    // Opinion dynamics parameters
    float convergence_rate <- 0.2 min: 0.0 max: 1.0;
    float confidence_threshold <- 0.5 min: 0.0 max: 1.0;
    float repulsion_threshold <- 0.6 min: 0.0 max: 1.0;
    float repulsion_strength <- 0.1 min: 0.0 max: 0.5;
    
    // Network structure
    string network_type <- "complete" among: ["complete", "random", "small_world"];
    float connection_probability <- 0.3 min: 0.0 max: 1.0;
    
    // Simulation control
    float step <- 0.5;
    int max_cycles <- 500;
    
    // mean absolute error (ref for later)
    float mae <- 0.0;
    
    // Population parameters
    float world_size <- 100.0;
    
    // CSV data parameters
    int selected_debate_id <- 1; // Which debate to simulate
    
    // Import values from CSV
    file opin_data <- csv_file("/home/alfajor/AGROTECH/test_csv_1.csv", ",", true); // true = skip header
    matrix dat_matx <- matrix(opin_data);
    list<int> debate_id_list <- dat_matx column_at 0;
    list<int> agent_id_list <- dat_matx column_at 1;
    list<int> initial_attitude_list <- dat_matx column_at 2;
    list<int> final_attitude_list <- dat_matx column_at 3;
    list<int> group_type_list <- dat_matx column_at 4;
    
    // Analysis variables
    float opinion_variance <- 0.0;
    int num_clusters <- 0;
    float polarization_index <- 0.0;
    
    // Simulation setup
    init {
        // Create agents from CSV for selected debate
        do initialize_agents_for_debate(selected_debate_id);
        
        // Create network structure
        do create_network;
    }
    
    // Agent creation from debate_id
    action initialize_agents_for_debate(int target_debate_id) {
        // Loop through CSV data
        loop i from: 0 to: length(debate_id_list) - 1 {
            // Only create agents for the selected debate
            if debate_id_list[i] = target_debate_id {
                create opinion_agent {
                    // Set agent attributes from CSV
                    agent_id <- agent_id_list[i];
                    debate_id <- target_debate_id;
                    group_type <- group_type_list[i];
                    
                    // Convert Likert scale (1-7) to opinion scale (0-1)
                    initial_opinion <- (initial_attitude_list[i] - 1) / 6.0;
                    opinion <- initial_opinion;
                    
                    // Store final attitude for later comparison
                    final_attitude <- final_attitude_list[i];
                    
                    // Set location and color
                    location <- {rnd(world_size), rnd(world_size)};
                    color <- rgb(opinion * 255, 0, (1 - opinion) * 255);
                }
            }
        }
    }
    
    // Create network 
    action create_network {
        ask opinion_agent {
            neighbors <- [];
        }

        switch network_type {
            match "complete" {
                // Complete network: all non-control agents connected
                ask opinion_agent {
                    // Only connect to agents in same debate who are NOT control (group_type != 3)
                    neighbors <- opinion_agent where (
                        each != self and 
                        each.debate_id = self.debate_id and
                        each.group_type != 3 and
                        self.group_type != 3
                    );
                }
            }
            match "random" {
                ask opinion_agent where (each.group_type != 3) {
                    neighbors <- opinion_agent where (
                        each != self and 
                        each.debate_id = self.debate_id and
                        each.group_type != 3 and
                        flip(connection_probability)
                    );
                }
            }
            match "small_world" {
                list<opinion_agent> agent_list <- list(opinion_agent where (each.group_type != 3));
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
                                each.group_type != 3
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

    // Compute statistics reflex 
    reflex compute_statistics {
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
                        pairwise_distances <- pairwise_distances + abs(a1.opinion - a2.opinion);
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

    // Stop simulation after max_cycles
    reflex stop_simulation when: cycle >= max_cycles {
        do pause;
    }
    
    // reflex compute fit of simualted final and real final
    reflex compute_fit when: cycle = max_cycles {
    	// get final simul values
    	list<float> simulated_finals <- opinion_agent collect each.opinion;
    	
    	// get real final values
    	list<float> real_finals <- opinion_agent collect ((each.final_attitude -1) / 6.0);
    	
    	// get and compute errors
    	list<float> errors <- [];
    	loop i from: 0 to: length(simulated_finals) - 1 {
    		float error <- abs(simulated_finals[i] - real_finals[i]);
    		errors <- errors + error;
    	}
    	
    	// mean absolute error calc
    	mae <- mean(errors);
    	write "Mean Absolute Error: " + mae;
    }
    
}

species opinion_agent {
    // Core attributes
    float opinion min: 0.0 max: 1.0;
    list<opinion_agent> neighbors <- [];
    rgb color <- #blue;
    point location;
    
    // CSV-loaded attributes
    int agent_id;
    int debate_id;
    int group_type; // 1=pro_reduction, 2=pro_meat, 3=control
    float initial_opinion;
    int final_attitude; // Store for comparison
    
    // Reflexes for dynamic opinion change 
    
    // Consensus formation (assimilative influence)
    reflex consensus_formation when: model_type = "consensus" {
        if length(neighbors) > 0 {
            list<float> all_opinions <- [opinion] + (neighbors collect each.opinion);
            float new_opinion <- mean(all_opinions);
            opinion <- opinion + convergence_rate * (new_opinion - opinion);
            color <- rgb(opinion * 255, 0, (1 - opinion) * 255);
        }
    }
    
    // Bounded confidence (opinion clustering)
    reflex bounded_confidence when: model_type = "clustering" {
        if length(neighbors) > 0 {
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
    
    // Bipolarization (repulsive influence)
    reflex repulsive_influence when: model_type = "bipolarization" {
        if length(neighbors) > 0 {
            float opinion_change <- 0.0;
            
            loop neighbor over: neighbors {
                float difference <- abs(neighbor.opinion - self.opinion);
                
                // Assimilative given that opinions are similar
                if difference <= confidence_threshold {
                    opinion_change <- opinion_change + convergence_rate * (neighbor.opinion - self.opinion);
                }
                // Repulsive influence if opinions are dissimilar
                else if difference >= repulsion_threshold {
                    float direction <- neighbor.opinion > self.opinion ? -1.0 : 1.0;
                    opinion_change <- opinion_change + repulsion_strength * direction;
                }
            }
            
            // Update opinion (bounded 0-1)
            opinion <- max([0.0, min([1.0, opinion + opinion_change / length(neighbors)])]);
            
            // Update color
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
    // Parameters organized by category
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
        // Spatial visualization
        display spatial_view type: 2d {
            species opinion_agent aspect: default;
        }
        
        // Opinion distribution over time
        display opinion_timeline refresh: every(5#cycles) {
            chart "Opinion Distribution" type: series {
                loop i from: 0 to: 9 {
                    data "Bin " + i value: opinion_agent count (
                        each.opinion >= i/10.0 and each.opinion < (i+1)/10.0
                    ) color: rgb(i*25.5, 0, 255 - i*25.5);
                }
            }
        }
        
        // Opinion histogram
        display opinion_histogram refresh: every(5#cycles) {
            chart "Current Opinion Distribution" type: histogram {
                loop i from: 0 to: 9 {
                    data "Bin " + i value: opinion_agent count (
                        each.opinion >= i/10.0 and each.opinion < (i+1)/10.0
                    ) color: rgb(i*25.5, 0, 255 - i*25.5);
                }
            }
        }
        
        // Aggregate statistics
        display statistics refresh: every(1#cycles) {
            chart "Opinion Dynamics Measures" type: series {
                data "Opinion Variance" value: opinion_variance color: #blue;
                data "Polarization Index" value: polarization_index * 10 color: #red;
            }
        }
        
        // Monitors
        monitor "Current Cycle" value: cycle;
        monitor "Opinion Variance" value: opinion_variance;
        monitor "Number of Clusters" value: num_clusters;
        monitor "Polarization Index" value: polarization_index;
        monitor "Mean Opinion" value: length(opinion_agent) > 0 ? mean(opinion_agent collect each.opinion) : 0.0;
        monitor "Opinion Range" value: length(opinion_agent) > 0 ? max(opinion_agent collect each.opinion) - min(opinion_agent collect each.opinion) : 0.0;
        monitor "Number of Agents" value: length(opinion_agent);
        monitor "Control Agents" value: opinion_agent count (each.group_type = 3);
        monitor "Control Agent Opinions" value: length(opinion_agent where (each.group_type = 3)) > 0 ? 
            opinion_agent where (each.group_type = 3) collect each.opinion : [];
        monitor "Model Fit MAE" value: mae;
    }
}

/* batch exp, might need to re-write to accomodate for multiple debates instead of per debate exploration
 * */

experiment Batch_deb_1 type: batch repeat: 1 keep_seed: true until: cycle = max_cycles {
	// selecting debate 1
	parameter "Selected Debate" var: selected_debate_id <- 1;
	
	// model type and parameters
	parameter "Model Type" var: model_type among: ["consensus", "clustering", "bipolarization"];
	
	// parameter variation
	parameter "Convergence Rate" var: convergence_rate among: [0.1, 0.3, 0.5, 0.7, 0.9];
	parameter "Confidence Threshold" var: confidence_threshold among: [0.2, 0.4, 0.6, 0.8];
	parameter "Repulsion Threshold" var: repulsion_threshold among: [0, 0.2, 0.5, 0.8];
	parameter "Repulsion Strength" var: repulsion_strength among: [0.1, 0.2, 0.3];
	
	/* float convergence_rate <- 0.2 min: 0.0 max: 1.0;
    float confidence_threshold <- 0.5 min: 0.0 max: 1.0;
    float repulsion_threshold <- 0.6 min: 0.0 max: 1.0;
    float repulsion_strength <- 0.1 min: 0.0 max: 0.5;
	*/
	
	// outputs to save
	float mae <- 0.0;
	float opinion_variance <- 0.0;
	float polarization_index <- 0.0;
	
	// save to csv / could try and save individual initial and final attitude (simul and real)
	reflex save_results {
		ask simulations {
			save [convergence_rate, confidence_threshold, repulsion_threshold, repulsion_strength, mae, opinion_variance, polarization_index]
			to: "results.csv" header: true;
		}
	}
	
}