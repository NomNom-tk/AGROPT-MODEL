/**
 * NETWORK BUILDER ACTIONS
 * Creates different network topologies
 */
 
model opinion_agent_species

import "../Parameters.gaml"
import "../Constants.gaml"

global {
	list<opinion_agent> opinion_agents -> {agents of_generic_species opinion_agent};
	
	 action argument_pool {
    	create argument_ number: argument_pool_size {
    		position <- flip(0.5) ? -1:1; // pro or con [-1,1]
    	}
    }
    
    reflex update_prev_opinion {
    	ask opinion_agents {
    		previous_opinion <- opinion;
    	}
    }
    	
}

species opinion_agent virtual: true  {
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
    
    // for parent species, take out all common attributes for social influence models
    // then create 'child' species that inherit from these attributes and have their own dynamics
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
    
    action compute_opinion virtual: true;
    
    reflex repeat_compute_opinion {
    	
    	do compute_opinion;
    	
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
        	// Update color (blue=0, red=1)
    		color <- rgb(opinion * 255, 0, (1 - opinion) * 255); // standardized color scheme
        }
          
    }

}

species argument_ {
	int position;  // whether pro [1] or con [-1]
	int argument_id; // identifier for each argument
}

// to include in every child agent: schedules: [shuffle(opinion_agent)]

species argumentative_agent parent: opinion_agent {
	map<argument_, int> my_arguments;
	float opinion min: -1.0 max: 1.0; // Current opinion [-1,1]
	init {
		if empty(argument_) {
			ask world {
				do argument_pool;
			}

		}

		list<argument_> agent_list <- (agent_arg among argument_);
		loop i from: 0 to: agent_arg - 1 {
			my_arguments[agent_list at i] <- i + relev_arg - agent_arg + 1;
		}
		do intermediary_opinion;

	}

	action compute_opinion {
		if length(neighbors) > 0 {
			do argument_exchange;
			
		}

	}

	action intermediary_opinion {
	// list arguments and calculate opinion
		float numerator <- 0.0;
		float denominator <- 0.0;
		loop arg1 over: my_arguments.keys where (my_arguments[each] > 0) {
			numerator <- numerator + (my_arguments[arg1] * arg1.position);
			denominator <- denominator + my_arguments[arg1];
		}

		opinion <- numerator / denominator; // value of [-1,+1]
		opinion <- (opinion + 1.0) / 2.0; /// could normalize to [0,1]
	}
	
	action argument_exchange {
		argument_ first_arg <- one_of(my_arguments.keys);
		ask neighbors as:argumentative_agent{
			
			
			my_arguments[first_arg] <- relev_arg + 1;
			my_arguments <- my_arguments.keys as_map(each::my_arguments[each] - 1);
			do intermediary_opinion;
		} 
	}
	

}



// ========================================================================
// REFLEX: CONSENSUS FORMATION (Assimilative Model)
// ========================================================================
/// FIXED: added bounds 0-1 cannot go outside of these
// Formula: opinion_new = opinion_old + μ * (mean_neighbor_opinion - opinion_old)
species consensus_agent parent: opinion_agent {
    action compute_opinion {
        if length(neighbors) > 0 {
           // previous_opinion <- opinion;
            
            // Average opinion including self
            list<float> all_opinions <- [opinion] + (neighbors collect each.opinion);
            float new_opinion <- mean(all_opinions);
            opinion <- max([0.0, min([1.0, opinion + agent_convergence_rate * (new_opinion - opinion)])]); // bounds creation
            
        }
    }
}

// ========================================================================
// REFLEX: BOUNDED CONFIDENCE (Clustering Model)
// ========================================================================
// Agents only influenced by similar neighbors (within confidence threshold)
// Formula: opinion_new = opinion_old + μ * (mean_similar_opinion - opinion_old)
species clustering_agent parent: opinion_agent {
    action compute_opinion {
        if length(neighbors) > 0 {
           // previous_opinion <- opinion;
            
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
} 
    
// ========================================================================
// REFLEX: BIPOLARIZATION (Repulsive Influence Model)
// ========================================================================
// Similar agents attract, dissimilar agents repel
// - |opinion_diff| <= confidence_threshold: attraction
// - |opinion_diff| >= repulsion_threshold: repulsion
// - Between: neutral zone (no influence)    
species bipolarization_agent parent: opinion_agent {
    
    action compute_opinion {
        if length(neighbors) > 0 {
           // previous_opinion <- opinion;
            
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
}

