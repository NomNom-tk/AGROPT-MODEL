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
    csv_file opin_data <- csv_file("data/test_debates_10.csv", ",", true);   
    matrix dat_matx <- matrix(opin_data);
    list<int> debate_id_list <- list<int>(dat_matx column_at 0);
    list<int> agent_id_list <- list<int>(dat_matx column_at 1);
    list<int> initial_attitude_list <- list<int>(dat_matx column_at 2);
    list<int> final_attitude_list <- list<int>(dat_matx column_at 3);
    list<int> group_type_list <- list<int>(dat_matx column_at 4);
    
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
    int convergence_cycle <- -1; // -1 meaning there is not yet a convergence
    
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
        if mode_batch {
            // Batch mode: load only selected debate
            do initialize_agents_for_debate(selected_debate_id);
        } else {
            // GUI mode: load all debates
            list<int> unique_debates <- remove_duplicates(debate_id_list);
            loop debate over: unique_debates {
                do initialize_agents_for_debate(debate);
            }
        }
        
        do create_network;
    }
    
    // Create agents for specific debate
    action initialize_agents_for_debate(int target_debate_id) {
        loop i from: 0 to: length(debate_id_list) - 1 {
            if debate_id_list[i] = target_debate_id {
                create opinion_agent {
                    agent_id <- agent_id_list[i];
                    debate_id <- target_debate_id;
                    group_type <- group_type_list[i];
                    
                    initial_opinion <- (initial_attitude_list[i] - 1) / 6.0;
                    opinion <- initial_opinion;
                    previous_opinion <- initial_opinion;
                    
                    final_attitude <- final_attitude_list[i];
                    
                    location <- {rnd(world_size), rnd(world_size)};
                    color <- rgb(opinion * 255, 0, (1 - opinion) * 255);
                }
            }
        }
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
            	convergence_cycle <- cycle; // store convergence cycle in 
                write "Converged at cycle " + convergence_cycle;
                end_simulation <- true;
                
                do compute_fit;
                
                if mode_batch {
                    do save_batch_results;
                }
            }
        }
    }
    
    // Fallback: stop at max_cycles if not converged
    reflex max_cycles_reached when: cycle >= max_cycles and !end_simulation {
        convergence_cycle <- max_cycles; // reached max cycle without convergence
        write "Reached max_cycles without convergence";
        end_simulation <- true;
        
        do compute_fit;
        
        if mode_batch {
            do save_batch_results;
        }
    }
    
    // Compute MAE
    action compute_fit {
        write "=== Computing Fit at Cycle " + cycle + " ===";
        
        // Reset containers
        mae_per_debate <- map<int, float>(map([]));
        list<int> debates <- remove_duplicates(opinion_agent collect each.debate_id);
        list<float> all_errors <- [];
        
        // Calculate errors per debate
        loop d over: debates {
            list<opinion_agent> agents_d <- opinion_agent where (each.debate_id = d);
            
            if length(agents_d) > 0 {
                list<float> errors_d <- [];
                
                ask agents_d {
                    float real <- (final_attitude - 1) / 6.0;
                    float err <- abs(opinion - real);
                    errors_d << err;
                    all_errors << err;
                }
                
                if length(errors_d) > 0 {
                    mae_per_debate[d] <- mean(errors_d);
                }
            }
        }
        
        // Calculate global MAE (AFTER loop!)
        mae <- length(all_errors) > 0 ? mean(all_errors) : 0.0;
        
        write "Global MAE: " + mae;
        write "Per-debate MAE: " + mae_per_debate;
    }
    
    // Save batch results
    action save_batch_results {
        write "=== Saving Results ===";
        write "MAE: " + mae;
        write "Debates: " + mae_per_debate.keys;
        
        // Summary file
        save [model_type, selected_debate_id, convergence_rate, confidence_threshold,
              repulsion_threshold, repulsion_strength, seed, convergence_cycle,
              mae, opinion_variance, polarization_index]
        to: "outputs/batch_summary.csv" rewrite: false;
        
        // Details file
        loop debate_id over: mae_per_debate.keys {
            save [model_type, convergence_rate, confidence_threshold,
                  repulsion_threshold, repulsion_strength, seed, convergence_cycle,
                  debate_id, mae_per_debate[debate_id]]
            to: "outputs/batch_debate_details.csv" rewrite: false;
        }
        
        write "Results saved successfully";
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
    
    int agent_id;
    int debate_id;
    int group_type;
    float initial_opinion;
    int final_attitude;
    
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
            
            float opinion_change <- 0.0;
            
            loop neighbor over: neighbors {
                float difference <- abs(neighbor.opinion - self.opinion);
                
                if difference <= confidence_threshold {
                    opinion_change <- opinion_change + convergence_rate * (neighbor.opinion - self.opinion);
                }
                else if difference >= repulsion_threshold {
                    float direction <- neighbor.opinion > self.opinion ? -1.0 : 1.0;
                    opinion_change <- opinion_change + repulsion_strength * direction;
                }
            }
            
            opinion <- max([0.0, min([1.0, opinion + opinion_change / length(neighbors)])]);
            
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
        monitor "Control Agents" value: opinion_agent count (each.group_type = 3);
        monitor "Model Fit MAE" value: mae;
        monitor "Debates Tracked" value: mae_per_debate.keys;
    }
}

experiment Batch_consensus type: batch repeat: 2 keep_seed: true until: end_simulation {
    parameter "Selected debate id" var: selected_debate_id among: remove_duplicates(debate_id_list);
    parameter "Convergence Rate" var: convergence_rate among: [0.1, 0.3, 0.5, 0.7, 0.9];
    parameter "Confidence Threshold" var: confidence_threshold among: [0.2, 0.4, 0.6, 0.8];
    parameter "Repulsion Threshold" var: repulsion_threshold among: [0.0, 0.2, 0.5, 0.8];
    parameter "Repulsion Strength" var: repulsion_strength among: [0.1, 0.2, 0.3];
    
    method genetic pop_dim: 5 crossover_prob: 0.7 mutation_prob: 0.1 
        improve_sol: true stochastic_sel: false 
        nb_prelim_gen: 5 max_gen: 20 minimize: mae;
    
    init {
        mode_batch <- true;
        model_type <- "consensus";
    }
}

experiment Batch_clustering type: batch repeat: 2 keep_seed: true until: end_simulation {
    parameter "Selected debate id" var: selected_debate_id among: remove_duplicates(debate_id_list);
    parameter "Convergence Rate" var: convergence_rate among: [0.1, 0.3, 0.5, 0.7, 0.9];
    parameter "Confidence Threshold" var: confidence_threshold among: [0.2, 0.4, 0.6, 0.8];
    parameter "Repulsion Threshold" var: repulsion_threshold among: [0.0, 0.2, 0.5, 0.8];
    parameter "Repulsion Strength" var: repulsion_strength among: [0.1, 0.2, 0.3];
    
    method genetic pop_dim: 5 crossover_prob: 0.7 mutation_prob: 0.1 
        improve_sol: true stochastic_sel: false 
        nb_prelim_gen: 5 max_gen: 20 minimize: mae;
    
    init {
        mode_batch <- true;
        model_type <- "clustering";
        convergence_cycle <- -1; // reset per simulation
    }
}

experiment Batch_bipolarization type: batch repeat: 2 keep_seed: true until: end_simulation {
    parameter "Selected debate id" var: selected_debate_id among: remove_duplicates(debate_id_list);
    parameter "Convergence Rate" var: convergence_rate among: [0.1, 0.3, 0.5, 0.7, 0.9];
    parameter "Confidence Threshold" var: confidence_threshold among: [0.2, 0.4, 0.6, 0.8];
    parameter "Repulsion Threshold" var: repulsion_threshold among: [0.0, 0.2, 0.5, 0.8];
    parameter "Repulsion Strength" var: repulsion_strength among: [0.1, 0.2, 0.3];
    
    method genetic pop_dim: 5 crossover_prob: 0.7 mutation_prob: 0.1 
        improve_sol: true stochastic_sel: false 
        nb_prelim_gen: 5 max_gen: 20 minimize: mae;
    
    init {
        mode_batch <- true;
        model_type <- "bipolarization";
        convergence_cycle <- -1; // reset per simulation
    }
}
