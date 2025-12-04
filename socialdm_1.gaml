/**
* Name: socialdm1
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
 * 
 * KEY INSIGHTS FROM FLACHE ET AL 2017:
 * - Small confidence threshold → fragmentation into many clusters
 * - Large confidence threshold → consensus
 * - Repulsive influence + assimilation → bipolarization
 * - Network structure affects speed but often not final outcome
 */

model socialdm1

global {
    // Model selection
    string model_type <- "consensus" among: ["consensus", "clustering", "bipolarization"];
    
    // Population parameters
    int nb_agents <- 6;
    float world_size <- 100.0;
    
    // Opinion dynamics parameters
    float convergence_rate <- 0.2 min: 0.0 max: 1.0; // μ in literature
    float confidence_threshold <- 0.5 min: 0.0 max: 1.0; // ε for bounded confidence
    float repulsion_threshold <- 0.6 min: 0.0 max: 1.0; // for bipolarization
    float repulsion_strength <- 0.1 min: 0.0 max: 0.5;
    
    // Network structure
    string network_type <- "complete" among: ["complete", "random", "small_world"];
    float connection_probability <- 0.3 min: 0.0 max: 1.0;
    
    // Simulation control
    float step <- 1.5;
    int max_cycles <- 500;
    
    // Analysis variables
    float opinion_variance <- 0.0;
    int num_clusters <- 0;
    float polarization_index <- 0.0;
    
    init {
        // Create agents with random initial opinions
        create opinion_agent number: nb_agents {
            location <- {rnd(world_size), rnd(world_size)};
            opinion <- rnd(0.0, 1.0); // Uniform random [0,1] /// need to link to csv
            color <- rgb(opinion * 255, 0, (1 - opinion) * 255);
        }
        
        // Create network structure
        do create_network;
    }
    
    action create_network {
        ask opinion_agent {
            neighbors <- [];
        }
        
        switch network_type {
            match "complete" {
                // All agents connected to all others
                ask opinion_agent {
                    neighbors <- opinion_agent - self;
                }
            }
            match "random" {
                // Random network (Erdős-Rényi)
                ask opinion_agent {
                    neighbors <- opinion_agent where (each != self and flip(connection_probability));
                }
            }
            match "small_world" {
                // Simple ring lattice with random rewiring
                list<opinion_agent> agent_list <- list(opinion_agent);
                loop i from: 0 to: length(agent_list) - 1 {
                    opinion_agent current <- agent_list[i];
                    // Connect to nearest neighbors
                    int k <- 4; // degree
                    loop j from: 1 to: k {
                        int neighbor_index <- (i + j) mod length(agent_list);
                        current.neighbors <- current.neighbors + agent_list[neighbor_index];
                    }
                    // Random rewiring with small probability
                    if flip(0.1) {
                        current.neighbors <- current.neighbors + one_of(opinion_agent - current - current.neighbors);
                    }
                }
            }
        }
    }
    
    reflex compute_statistics {
        // Compute opinion variance
        list<float> opinions <- opinion_agent collect each.opinion;
        float mean_opinion <- mean(opinions);
        opinion_variance <- variance(opinions);
        
        // Estimate number of clusters (simple binning approach)
        int num_bins <- 10;
        list<int> histogram <- list_with(num_bins, 0);
        loop op over: opinions {
            int bin <- min([num_bins - 1, int(op * num_bins)]);
            histogram[bin] <- histogram[bin] + 1;
        }
        num_clusters <- histogram count (each > 0);
        
        // Compute bipolarization index (variance of pairwise distances)
        list<float> pairwise_distances <- [];
        loop a1 over: opinion_agent {
            loop a2 over: opinion_agent {
                if a1 != a2 {
                    pairwise_distances <- pairwise_distances + abs(a1.opinion - a2.opinion);
                }
            }
        }
        float mean_distance <- mean(pairwise_distances);
        float variance_distance <- 0.0;
        loop d over: pairwise_distances {
            variance_distance <- variance_distance + (d - mean_distance) ^ 2;
        }
        polarization_index <- variance_distance / (length(pairwise_distances) * (1.0 ^ 2));
    }
    
    reflex stop_simulation when: cycle >= max_cycles {
        do pause;
    }
}

species opinion_agent {
    float opinion <- 0.5 min: 0.0 max: 1.0;
    list<opinion_agent> neighbors <- [];
    rgb color <- #blue;
    
    // MODEL 1: CONSENSUS FORMATION (Assimilative Influence)
    // Classic weighted averaging - all agents converge to moderate consensus
    reflex consensus_formation when: model_type = "consensus" {
        if length(neighbors) > 0 {
            // Average own opinion with neighbors' opinions
            list<float> all_opinions <- [opinion] + (neighbors collect each.opinion);
            float new_opinion <- mean(all_opinions);
            
            // Gradual convergence (weighted average with convergence rate μ)
            opinion <- opinion + convergence_rate * (new_opinion - opinion);
            
            // Update color
            color <- rgb(opinion * 255, 0, (1 - opinion) * 255);
        }
    }
    
    // MODEL 2: OPINION CLUSTERING (Bounded Confidence Model)
    // Agents only influenced by similar others - creates multiple opinion clusters
    reflex bounded_confidence when: model_type = "clustering" {
        if length(neighbors) > 0 {
            // Only interact with agents within confidence threshold
            list<opinion_agent> similar_neighbors <- neighbors where (abs(each.opinion - self.opinion) <= confidence_threshold);
            
            if length(similar_neighbors) > 0 {
                // Average with similar neighbors only
                list<float> similar_opinions <- similar_neighbors collect each.opinion;
                float avg_similar <- mean(similar_opinions);
                
                // Move toward average of similar neighbors
                opinion <- opinion + convergence_rate * (avg_similar - opinion);
                
                // Update color
                color <- rgb(opinion * 255, 0, (1 - opinion) * 255);
            }
        }
    }
    
    // MODEL 3: BIPOLARIZATION (Repulsive Influence)
    // Assimilation with similar, repulsion from dissimilar - creates two extreme camps
    reflex repulsive_influence when: model_type = "bipolarization" {
        if length(neighbors) > 0 {
            float opinion_change <- 0.0;
            
            loop neighbor over: neighbors {
                float difference <- abs(neighbor.opinion - self.opinion);
                
                // Assimilative influence: similar opinions attract
                if difference <= confidence_threshold {
                    opinion_change <- opinion_change + convergence_rate * (neighbor.opinion - self.opinion);
                }
                // Repulsive influence: very different opinions repel
                else if difference >= repulsion_threshold {
                    // Move away from dissimilar neighbor
                    float direction <- neighbor.opinion > self.opinion ? -1.0 : 1.0;
                    opinion_change <- opinion_change + repulsion_strength * direction;
                }
                // Middle range: no influence
            }
            
            // Update opinion (bounded to [0,1])
            opinion <- max([0.0, min([1.0, opinion + opinion_change / length(neighbors)])]);
            
            // Update color (extremes are more saturated)
            if opinion < 0.5 {
                color <- rgb(0, 0, 255 * (1 - opinion * 2)); // Blue for low
            } else {
                color <- rgb(255 * ((opinion - 0.5) * 2), 0, 0); // Red for high
            }
        }
    }
    
    aspect default {
        draw circle(1.5) color: color border: #black;
    }
    
    aspect with_links {
        draw circle(1.5) color: color border: #black;
        // Draw links to neighbors (only for visualization)
        if length(neighbors) > 0 and flip(0.5) { // Show only 10% of links to avoid clutter
            loop n over: neighbors {
                draw line([location, n.location]) color: #gray width: 0.3;
            }
        }
    }
}

experiment social_influence type: gui {
    // Parameters organized by category
    parameter "Model Type" var: model_type category: "Model Selection";
    
    parameter "Number of Agents" var: nb_agents min: 10 max: 500 category: "Population";
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
                    data "Bin " + i value: opinion_agent count (each.opinion >= i/10.0 and each.opinion < (i+1)/10.0) color: rgb(i*25.5, 0, 255 - i*25.5);
                }
            }
        }
        
        // Opinion histogram
        display opinion_histogram refresh: every(5#cycles) {
            chart "Current Opinion Distribution" type: histogram {
                loop i from: 0 to: 9 {
                    data "Bin " + i value: opinion_agent count (each.opinion >= i/10.0 and each.opinion < (i+1)/10.0) color: rgb(i*25.5, 0, 255 - i*25.5);
                }
            }
        }
        
        // Aggregate statistics
        display statistics refresh: every(1#cycles) {
            chart "Opinion Dynamics Measures" type: series {
                data "Opinion Variance" value: opinion_variance color: #blue;
                data "Polarization Index" value: polarization_index * 10 color: #red; // scaled for visibility
            }
        }
        
        // Monitors
        monitor "Current Cycle" value: cycle;
        monitor "Opinion Variance" value: opinion_variance;
        monitor "Number of Clusters" value: num_clusters;
        monitor "Polarization Index" value: polarization_index;
        monitor "Mean Opinion" value: mean(opinion_agent collect each.opinion);
        monitor "Opinion Range" value: max(opinion_agent collect each.opinion) - min(opinion_agent collect each.opinion);
    }
}



