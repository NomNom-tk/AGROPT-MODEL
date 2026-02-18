/**
 * NETWORK BUILDER ACTIONS
 * Creates different network topologies
 */
 
model opinion_agent_species

import "../main-16-2-26.gaml"

species opinion_agent {
    // ========================================================================
    // CORE ATTRIBUTES
    // ========================================================================
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

    // ====
    // Agent-level attributes (heterogeneous agents)
    // ===
    float agent_convergence_rate;
    float agent_confidence_threshold;
    float agent_repulsion_threshold;
    float agent_repulsion_strength;
    
    // ========================================================================
    // SUBFACTOR STORAGE (T1 = initial, T2 = target)
    // ========================================================================
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
    
    // ========================================================================
    // REFLEX: CONSENSUS FORMATION (Assimilative Model)
    // ========================================================================
    // All agents converge toward mean opinion of neighbors
    /// FIXED: added bounds 0-1 cannot go outside of these
    // Formula: opinion_new = opinion_old + μ * (mean_neighbor_opinion - opinion_old)
    reflex consensus_formation when: model_type = "consensus" {
        if length(neighbors) > 0 {
            previous_opinion <- opinion;
            
            // Average opinion including self
            list<float> all_opinions <- [opinion] + (neighbors collect each.opinion);
            float new_opinion <- mean(all_opinions);
            opinion <- max([0.0, min([1.0, opinion + agent_convergence_rate * (new_opinion - opinion)])]); // bounds creation
            
            // Update color (blue=0, red=1)
            color <- rgb(opinion * 255, 0, (1 - opinion) * 255); // standardized color scheme
        }
    }
    
    // ========================================================================
    // REFLEX: BOUNDED CONFIDENCE (Clustering Model)
    // ========================================================================
    // Agents only influenced by similar neighbors (within confidence threshold)
    // Formula: opinion_new = opinion_old + μ * (mean_similar_opinion - opinion_old)
    reflex bounded_confidence when: model_type = "clustering" {
        if length(neighbors) > 0 {
            previous_opinion <- opinion;
            
            // Filter neighbors within confidence threshold
            list<opinion_agent> similar_neighbors <- neighbors where (
                abs(each.opinion - self.opinion) <= agent_confidence_threshold
            );
            
            if length(similar_neighbors) > 0 {
                list<float> similar_opinions <- similar_neighbors collect each.opinion;
                float avg_similar <- mean(similar_opinions);
                opinion <- max([0.0, min([1.0, opinion + agent_convergence_rate * (avg_similar - opinion)])]); // bounds creation
                color <- rgb(opinion * 255, 0, (1 - opinion) * 255); // standardized color scheme
            }
        }
    }
    
    // ========================================================================
    // REFLEX: BIPOLARIZATION (Repulsive Influence Model)
    // ========================================================================
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
                
                if difference <= agent_confidence_threshold {
                    // ATTRACTION: Move toward similar neighbors
                    attraction_force <- attraction_force + (neighbor.opinion - self.opinion);
                    attractive_count <- attractive_count + 1;
                    total_attractive_interactions <- total_attractive_interactions + 1;
                }
                else if difference >= agent_repulsion_threshold {
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
                opinion_change <- opinion_change + agent_convergence_rate * (attraction_force / attractive_count);
            }
            if repulsive_count > 0 {
                opinion_change <- opinion_change + agent_repulsion_strength * (repulsion_force / repulsive_count);
            }
            
            // Update opinion (clamped to [0,1])
            opinion <- max([0.0, min([1.0, opinion + opinion_change])]);
            
            // Update color
            color <- rgb(opinion * 255, 0, (1 - opinion) * 255); // standardized color scheme
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
