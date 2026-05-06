/**
* Name: Constants
* Based on the internal empty template. 
* Author: alfajor
* Tags: 
*/


model opinion_dynamics

global {
    
    // Runtime 
    float step <- 0.5; // time step of simulation
    int max_cycles <- 100; // max cycles for convergence
    
    // Convergence Constants
    float mae_convergence_threshold <- 0.01; // Convergence Checking re-modified 4/5/26
    // v1: mae_convergence_threshold = 0.001 (too tight, early stopping)
    // v2: mae_convergence_threshold = 0.01 (order of magnitude relaxing)
    // v3: fixed_cycles = N (no convergence check, fixed duration)
    
    // Environment

    float world_size <- 100.0; // Spatial world size for visualization
    
    int n_bins <- 50; // bins for gui viz and gif generaiton
    
    int stats_bins <- 10; // bins for logical histogram calculation
    
    
}
