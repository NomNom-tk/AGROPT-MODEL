/**
* Network Set up
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
    
    
    
    reflex speaking_turn when: length(opinion_agents) > 0 and !end_simulation {
    	//write "cycle: " + cycle + " agents: " + length(opinion_agents) + " speaking_mode: " + speaking_mode;
    	//write length(opinion_agents);
    	opinion_agent speaking_ag <- nil;
    	ask opinion_agents {
    		speak_weight <- 1.0 / (sum(recent_speech) + 1);
    	}
    	if speaking_mode {
    		list<float> weights <- opinion_agents collect each.speak_weight;
    		int chosen_index <- rnd_choice(weights);
    		speaking_ag <- (opinion_agents at chosen_index);
    		//write "Speaking agent: " + speaking_ag.agent_id + " mode: " + speaking_mode;
    		ask speaking_ag {
    			do talk_to_all;
    		}
    	}
    	ask opinion_agents where (each != speaking_ag) {
    		//write "check";
    		recent_speech <+ 0;
    		if length(recent_speech) > length(opinion_agents) {
    			remove index: 0 from: recent_speech;
    		}
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
    string debate_label;					// debate identifier for H and M
    string current_experiment_id;			// identifies type of experiment
	
	// speakign attributes
	list<int> recent_speech <- [];
	bool is_speaking <- false;
	float speak_weight <- 0.0;

    // Saturation tracking and total influence attributes (20/4/26)
    int total_influences_received <- 0;
    float retention_discount <- 1.0;
    float cumulative_opinion_change <- 0.0; // tracks direction and magnitude
    float initial_opinion_snapshot <- 0.0; // set at init and never change

    // parent species tracking extras (20/4/26), declaration here to save later and possibly reuse in simulations
    bool agent_is_saturated <- false;
    bool agent_wrong_direction <- false;
    float agent_net_change <- 0.0;
    
	
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
    
    action compute_opinion virtual: true;
    action compute_opinion_speaker (float speaker_opinion, opinion_agent sender) virtual: true;
    
    action talk_to_all {
    	float my_opinion <- opinion;
        opinion_agent me <- self; // capture sender reference before ask block
    	ask opinion_agents where (each != self) {
    		do compute_opinion_speaker speaker_opinion: my_opinion sender: me;
    	}
    	recent_speech <+ 1;
    	if length(recent_speech) > length(opinion_agents) {
    		remove index: 0 from: recent_speech;
    	}
    }
    
    reflex repeat_compute_opinion {
    	//write "computing opinion for agent " + agent_id + " opinion: " + opinion;
    	if !speaking_mode {
    	
    	do compute_opinion;
    	
        }
    }

    // update tracking reflex (27/7/26) to pass through agents and write to log File
    // 29/4/26 wrong dir points to reference point of t2 attitudes instead of relative change
    reflex update_tracking {
        agent_net_change <- opinion - initial_opinion_snapshot;
        agent_is_saturated <- retention_discount < 0.2;
        agent_wrong_direction <- (final_attitude > initial_opinion_snapshot and agent_net_change < 0)
                              or (final_attitude < initial_opinion_snapshot and agent_net_change > 0);
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

/*species argumentative_agent parent: opinion_agent {
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
	
	action compute_speaker_opinion (float speaker_opinion) {
		do argument_exchange;
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
	

}*/


// no-change agent
species no_change_agent parent: opinion_agent {
	action compute_opinion{
		// do nothing, no update
	}
	action compute_opinion_speaker (float speaker_opinion, opinion_agent sender) {
		// do nothing
        float opinion_before <- opinion;
        
        // inline tracking for log accuracry (agent_wrong dir updates one cycle too late) 28/4/26
        bool wrong_dir <- (final_attitude > initial_opinion_snapshot and (opinion - initial_opinion_snapshot) < 0)
           			   or (final_attitude < initial_opinion_snapshot  and (opinion - initial_opinion_snapshot) > 0);
		bool is_sat <- retention_discount < 0.2;

        // interaction log introduction 27/4/26
        interaction_log << string(speaking_mode) + "," + string(model_type) + "," + 
            string(current_condition) + "," + string(debate_id) + "," + 
            string(debate_label) + "," + string(current_experiment_id) + "," + 
            string(use_distinct_agents) + "," + string(seed) + "," +
            string(cycle) + "," + string(sender.agent_id) + "," + string(agent_id) + "," +
            string(speaker_opinion) + "," + string(opinion_before) + "," +
            string(opinion) + "," + string(opinion - opinion_before) + "," +
            string(is_sat) + "," + string(wrong_dir);
	}
}


// ========================================================================
// REFLEX: CONSENSUS FORMATION (Assimilative Model)
// ========================================================================
/// FIXED: added bounds 0-1 cannot go outside of these
// Formula: opinion_new = opinion_old + μ * (mean_neighbor_opinion - opinion_old)
species consensus_agent parent: opinion_agent {
    action compute_opinion {
    	//write "Agent " + agent_id + " opinion: " + opinion + " neighbors: " + length(neighbors);
        if length(neighbors) > 0 {
           // previous_opinion <- opinion;
           //write "INSIDE neighbor block, neighbors: " + length(neighbors);
            
            // Average opinion including self
            list<float> all_opinions <- [opinion] + (neighbors collect each.opinion);
            float new_opinion <- mean(all_opinions);
            opinion <- max([0.0, min([1.0, opinion + agent_convergence_rate * (new_opinion - opinion)])]); // bounds creation
            
        }
    }
    action compute_opinion_speaker (float speaker_opinion, opinion_agent sender) {
            // snapshot creation (20/4/26)
            // debug 27/4/26 interaction log not firing
            //write "LOG hit agent: " + agent_id;
            float opinion_before <- opinion;

    		//write "neighbors: " + length(neighbors) + " group_type: " + group_type;
            // Average opinion of speaker plus own
            list<float> speak_own_opi <- [opinion] + [speaker_opinion];
            float new_opinion <- mean(speak_own_opi);
            opinion <- max([0.0, min([1.0, 
                opinion + agent_convergence_rate * retention_discount * (new_opinion - opinion)])]); // bounds creation retention addition
            
            // post update opin tracking (20/4/26)
            cumulative_opinion_change <- cumulative_opinion_change + (opinion - opinion_before);
            total_influences_received <- total_influences_received + 1;
            retention_discount <- 1.0 / (1.0 + total_influences_received * 0.1);
            
            // inline tracking for log accuracry (agent_wrong dir updates one cycle too late) 28/4/26
            bool wrong_dir <- (final_attitude > initial_opinion_snapshot and (opinion - initial_opinion_snapshot) < 0)
           			       or (final_attitude < initial_opinion_snapshot  and (opinion - initial_opinion_snapshot) > 0);
			bool is_sat <- retention_discount < 0.2;

            // interaction log introduction 27/4/26
            interaction_log << string(speaking_mode) + "," + string(model_type) + "," + 
                string(current_condition) + "," + string(debate_id) + "," + 
                string(debate_label) + "," + string(current_experiment_id) + "," + 
                string(use_distinct_agents) + "," + string(seed) + "," +
                string(cycle) + "," + string(sender.agent_id) + "," + string(agent_id) + "," +
                string(speaker_opinion) + "," + string(opinion_before) + "," +
                string(opinion) + "," + string(opinion - opinion_before) + "," +
                string(is_sat) + "," + string(wrong_dir);
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
    
    action compute_opinion_speaker (float speaker_opinion, opinion_agent sender) {
            if abs(speaker_opinion - self.opinion) <= agent_confidence_threshold {

                // snapshot creation 20/4/26
                float opinion_before <- opinion;

                list<float> similar_speaker <- [opinion] + [speaker_opinion];
                float avg_similar <- mean(similar_speaker);
                opinion <- max([0.0, min([1.0, 
                    opinion + agent_convergence_rate * retention_discount * (avg_similar - opinion)])]); // bounds creation, addition of retention_discount
                color <- rgb(opinion * 255, 0, (1 - opinion) * 255); // standardized color scheme

                // post update opin tracking (20/4/26)
                cumulative_opinion_change <- cumulative_opinion_change + (opinion - opinion_before);
                total_influences_received <- total_influences_received + 1;
                retention_discount <- 1.0 / (1.0 + total_influences_received * 0.1);
                
                // inline tracking for log accuracry (agent_wrong dir updates one cycle too late) 28/4/26
	            bool wrong_dir <- (final_attitude > initial_opinion_snapshot and (opinion - initial_opinion_snapshot) < 0)
           			           or (final_attitude < initial_opinion_snapshot  and (opinion - initial_opinion_snapshot) > 0);
				bool is_sat <- retention_discount < 0.2;

                // interaction log introduction 27/4/26
                interaction_log << string(speaking_mode) + "," + string(model_type) + "," + 
                    string(current_condition) + "," + string(debate_id) + "," + 
                    string(debate_label) + "," + string(current_experiment_id) + "," + 
                    string(use_distinct_agents) + "," + string(seed) + "," +
                    string(cycle) + "," + string(sender.agent_id) + "," + string(agent_id) + "," +
                    string(speaker_opinion) + "," + string(opinion_before) + "," +
                    string(opinion) + "," + string(opinion - opinion_before) + "," +
                    string(is_sat) + "," + string(wrong_dir);
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
    
    action compute_opinion_speaker (float speaker_opinion, opinion_agent sender) {
    	float attraction_force <- 0.0;
        float repulsion_force <- 0.0;
        int attractive_count <- 0;
        int repulsive_count <- 0;
        float opinion_before <- opinion; // snapshot creation
    	
    	float speaker_diff <- abs(speaker_opinion - self.opinion);
                
                if speaker_diff <= agent_confidence_threshold {
                    // ATTRACTION: Move toward similar neighbors
                    attraction_force <- attraction_force + (speaker_opinion - self.opinion);
                    attractive_count <- attractive_count + 1;
                    total_attractive_interactions <- total_attractive_interactions + 1;
                }
                else if speaker_diff >= agent_repulsion_threshold {
                    // REPULSION: Move away from dissimilar neighbors
                    float direction <- speaker_opinion > self.opinion ? -1.0 : 1.0;
                    repulsion_force <- repulsion_force + direction;
                    repulsive_count <- repulsive_count + 1;
                    total_repulsive_interactions <- total_repulsive_interactions + 1;
                }
                else {
                    // NEUTRAL ZONE: No influence
                    total_neutral_interactions <- total_neutral_interactions + 1;
                }
    	// Apply combined forces (retention discounts for repulsion as well as attraction 20/4/26)
            float opinion_change <- 0.0;
            if attractive_count > 0 {
                opinion_change <- opinion_change + agent_convergence_rate * retention_discount * (attraction_force / attractive_count);
            }
            if repulsive_count > 0 {
                opinion_change <- opinion_change + agent_repulsion_strength * retention_discount * (repulsion_force / repulsive_count);
            }
            
            // Update opinion (clamped to [0,1])
            opinion <- max([0.0, min([1.0, opinion + opinion_change])]);
            
            // Update color
            color <- rgb(opinion * 255, 0, (1 - opinion) * 255); // standardized color scheme

            // post update opin tracking (20/4/26)
            cumulative_opinion_change <- cumulative_opinion_change + (opinion - opinion_before);
            total_influences_received <- total_influences_received + 1;
            retention_discount <- 1.0 / (1.0 + total_influences_received * 0.1);
            
            // inline tracking for log accuracry (agent_wrong dir updates one cycle too late) 28/4/26
            bool wrong_dir <- (final_attitude > initial_opinion_snapshot and (opinion - initial_opinion_snapshot) < 0)
           			       or (final_attitude < initial_opinion_snapshot  and (opinion - initial_opinion_snapshot) > 0);
			bool is_sat <- retention_discount < 0.2;

            // interaction log introduction 27/4/26
            interaction_log << string(speaking_mode) + "," + string(model_type) + "," + 
                string(current_condition) + "," + string(debate_id) + "," + 
                string(debate_label) + "," + string(current_experiment_id) + "," + 
                string(use_distinct_agents) + "," + string(seed) + "," +
                string(cycle) + "," + string(sender.agent_id) + "," + string(agent_id) + "," +
                string(speaker_opinion) + "," + string(opinion_before) + "," +
                string(opinion) + "," + string(opinion - opinion_before) + "," +
                string(is_sat) + "," + string(wrong_dir);
    }
}