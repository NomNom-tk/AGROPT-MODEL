/**
 * GUI EXPERIMENTS
 * Interactive visualization mode
 */
model gui_experiments

import "../main-16-2-26-homophily fix.gaml"

experiment social_influence type: gui {
	float minimum_cycle_duration <- 0.1;
	
    parameter "Model Type" var: model_type category: "Model Selection";
    parameter "Selected Debate ID" var: selected_debate_id category: "Data";
    //parameter "Network Type" var: network_type category: "Network";
    //parameter "Connection Probability (random)" var: connection_probability category: "Network";
    parameter "Homophily Strength" var: homophily_strength category: "Network"; 
    parameter "Convergence Rate (μ)" var: convergence_rate category: "Opinion Dynamics";
    parameter "Confidence Threshold (ε)" var: confidence_threshold category: "Opinion Dynamics";
    parameter "Repulsion Threshold" var: repulsion_threshold category: "Opinion Dynamics";
    parameter "Repulsion Strength" var: repulsion_strength category: "Opinion Dynamics";
    parameter "Max Cycles" var: max_cycles category: "Simulation";
    parameter "Debug" var: debug_mode <- true category: "Debugging";
    
    output {
        // Spatial display
        display spatial_view type: 2d {
            agents value:opinion_agents aspect: default;
        }
        
        // Opinion distribution over time
        display opinion_timeline type: 2d refresh: every(5#cycles) {
            chart "Opinion Distribution" type: series {
                loop i from: 0 to: 9 {
                    data "Bin " + i value: opinion_agents count (
                        each.opinion >= i/10.0 and each.opinion < (i+1)/10.0
                    ) color: rgb(i*25.5, 0, 255 - i*25.5);
                }
            }
        }
        
        // Current opinion histogram
        display opinion_histogram type: 2d refresh: every(5#cycles) {
            chart "Current Opinion Distribution" type: histogram {
                loop i from: 0 to: 9 {
                    data "Bin " + i value: opinion_agents count (
                        each.opinion >= i/10.0 and each.opinion < (i+1)/10.0
                    ) color: rgb(i*25.5, 0, 255 - i*25.5);
                }
            }
        }
        
        // Opinion dynamics measures
        display statistics type: 2d refresh: every(1#cycles) {
            chart "Opinion Dynamics Measures" type: series {
                data "Opinion Variance" value: opinion_variance color: #blue;
                data "Polarization Index" value: polarization_index * 10 color: #red;
            }
        }
        
        // Monitors
        monitor "Current Cycle" value: cycle;
        monitor "Convergence Cycle" value: convergence_cycle;
        monitor "Opinion Variance" value: opinion_variance;
        monitor "Number of Clusters" value: num_clusters;
        monitor "Polarization Index" value: polarization_index;
        monitor "Mean Opinion" value: length(opinion_agents) > 0 ? mean(opinion_agents collect each.opinion) : 0.0;
        monitor "Opinion Range" value: length(opinion_agents) > 0 ? max(opinion_agents collect each.opinion) - min(opinion_agent collect each.opinion) : 0.0;
        monitor "Number of Agents" value: length(opinion_agents);
        monitor "Control Agents" value: opinion_agents count (each.group_type = "Control");
        monitor "Model Fit MAE" value: mae;
        monitor "Debates Tracked" value: mae_per_debate.keys;
    }
}
