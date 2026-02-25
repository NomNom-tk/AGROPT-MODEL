/**
* Name: Constants
* Based on the internal empty template. 
* Author: alfajor
* Tags: 
*/


model opinion_dynamics

global {
    float step <- 0.5; // time step of simulation
    
    int max_cycles <- 100; // max cycles for convergence
    
    float mae_convergence_threshold <- 0.001 min: 0.0 max: 1.0; // Convergence Checking
    
    float world_size <- 100.0; // Spatial world size for visualization
}
