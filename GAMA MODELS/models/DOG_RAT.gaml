/**
* Name: DOGRAT
* Based on the internal empty template. 
* Author: alfajor
* Tags: 
*/


model DOGRAT

global {
    // Environment files 
    file shape_file_buildings <- file("../data/GIS//building.shp");
	file shape_file_roads <- file("../data/GIS/road.shp");
	file shape_file_bounds <- file("../data/GIS/bounds.shp");
    // Simulation parameters
    int nb_rats <- 100;
    int nb_dogs <- 10;
	
    float step <- 1#s;
    
    // Environment parameters
    geometry shape <- envelope(shape_file_bounds);
    
     init {
        write "=== Starting Initialization ===";
        write "Bounds file exists: " + shape_file_bounds.exists;
        write "Buildings file exists: " + shape_file_buildings.exists;
        write "Roads file exists: " + shape_file_roads.exists;
        write "World shape: " + shape;
        
        // Create buildings only if file exists
        if (shape_file_buildings.exists) {
            write "Loading buildings from: " + shape_file_buildings.path;
            create building from: shape_file_buildings;
            write "Buildings created: " + length(building);
        } else {
            write "WARNING: Buildings file not found, skipping...";
        }
        
        // Create roads only if file exists
        if (shape_file_roads.exists) {
            write "Loading roads from: " + shape_file_roads.path;
            create road from: shape_file_roads;
            write "Roads created: " + length(road);
        } else {
            write "WARNING: Roads file not found, skipping...";
        }
        
        // Create rats - use roads if available, otherwise spawn randomly
        write "Creating rats...";
        if (length(road) > 0) {
            create rat number: nb_rats {
                location <- any_location_in(one_of(road));
            }
        } else {
            write "No roads found, spawning rats randomly in world";
            create rat number: nb_rats {
                location <- {rnd(shape.width), rnd(shape.height)};
            }
        }
        write "Rats created: " + length(rat);
        
        // Create dogs - use roads if available, otherwise spawn randomly
        write "Creating dogs...";
        if (length(road) > 0) {
            create dog number: nb_dogs {
                location <- any_location_in(one_of(road));
            }
        } else {
            write "No roads found, spawning dogs randomly in world";
            create dog number: nb_dogs {
                location <- {rnd(shape.width), rnd(shape.height)};
            }
        }
        write "Dogs created: " + length(dog);
        write "=== Initialization Complete ===";
    }
}

// Building species - obstacles and hiding places
species building {
    // Building attributes
    list<rat> rats_inside <- [];
    int max_hiding_capacity <- 5;
    
    // Check if rat can enter
    bool can_enter {
        return length(rats_inside) < max_hiding_capacity;
    }
    
    // Rat enters building
    action rat_enters(rat r) {
        rats_inside << r;
    }
    
    // Rat leaves building
    action rat_leaves(rat r) {
        rats_inside >- r;
    }
    
    aspect default {
        draw shape color: #gray border: #black;
        // Show number of rats hiding
        if (length(rats_inside) > 0) {
            draw string(length(rats_inside)) size: 5 color: #white at: location;
        }
    }
}

// Road species - movement areas
species road {
    aspect default {
        draw shape color: #lightgray;
    }
}

// Rat species
species rat skills: [moving] {
    // Physical attributes
    float size <- 0.3#m;
    float speed <- 2.0#km/#h;
    float vision_range <- 10.0#m;
    
    // Behavioral attributes
    float fear_level <- 0.0 min: 0.0 max: 1.0;
    float energy <- 100.0 min: 0.0 max: 100.0;
    bool is_hiding <- false;
    building current_building <- nil;
    
    // Rat-specific advantages
    float agility <- 0.8; // Rats are agile (0-1), helps with evasion
    float building_affinity <- 0.7; // Propensity to seek buildings (0-1)
    
    // Perception
    list<dog> nearby_dogs <- [];
    list<building> nearby_buildings <- [];
    
    reflex perceive {
        nearby_dogs <- dog at_distance vision_range;
        nearby_buildings <- building at_distance (vision_range * 1.5);
        fear_level <- length(nearby_dogs) > 0 ? 1.0 : max([0.0, fear_level - 0.1]);
    }
    
    reflex seek_building when: length(nearby_dogs) > 0 and !is_hiding and 
                                 flip(building_affinity) and energy > 5.0 {
        // Rats prioritize hiding in buildings when threatened
        list<building> available_buildings <- nearby_buildings where (each.can_enter());
        
        if (length(available_buildings) > 0) {
            building target_building <- available_buildings closest_to self;
            do goto target: target_building speed: speed * (1 + fear_level);
            energy <- energy - 0.3;
            
            // Enter building if close enough
            if (self distance_to target_building < 2#m) {
                is_hiding <- true;
                current_building <- target_building;
                ask current_building {
                    do rat_enters(myself);
                }
                location <- any_location_in(current_building);
            }
        }
    }
    
    reflex flee when: length(nearby_dogs) > 0 and !is_hiding and 
                      length(nearby_buildings) = 0 and energy > 10.0 {
        // Flee in open when no buildings nearby
        dog nearest_dog <- nearby_dogs closest_to self;
        
        // Rats have higher evasion - more erratic movement
        float evasion_bonus <- rnd(0.0, agility);
        do wander amplitude: 60.0 + (evasion_bonus * 90.0) speed: speed * (1 + fear_level + evasion_bonus);
        energy <- energy - 0.5;
    }
    
    reflex hide_in_building when: is_hiding and current_building != nil {
        // Stay hidden, slowly regain energy
        energy <- min([100.0, energy + 0.8]);
        fear_level <- max([0.0, fear_level - 0.2]);
        
        // Check if any dogs are nearby
        if (length(nearby_dogs) = 0 and energy > 60.0 and flip(0.3)) {
            // Leave building when safe
            is_hiding <- false;
            ask current_building {
                do rat_leaves(myself);
            }
            location <- any_location_in(one_of(road));
            current_building <- nil;
        }
    }
    
    reflex wander when: length(nearby_dogs) = 0 and !is_hiding and energy > 0.0 {
        // Random wandering when no threats
        do wander speed: speed * 0.5;
        energy <- min([100.0, energy + 0.1]);
    }
    
    aspect default {
        // Visible rats are brown, hiding rats are darker/greyed out
        if (is_hiding) {
            draw circle(size * 0.7) color: #darkgray border: #black;
        } else {
            draw circle(size) color: #saddlebrown border: #black;
        }
    }
}

// Dog species
species dog skills: [moving] {
    // Physical attributes
    float size <- 1.0#m;
    float speed <- 8.0#km/#h;
    float vision_range <- 20.0#m;
    float catch_range <- 1.5#m;
    
    // Behavioral attributes
    float energy <- 100.0 min: 0.0 max: 100.0;
    float excitement <- 0.0 min: 0.0 max: 1.0;
    rat target_rat <- nil;
    int catches <- 0;
    int failed_catches <- 0;
    
    // Dog limitations
    float building_entry_chance <- 0.3; // Dogs less likely to enter buildings
    
    // Perception
    list<rat> nearby_rats <- [];
    list<building> nearby_buildings <- [];
    
    reflex perceive {
        nearby_rats <- rat at_distance vision_range where (!each.is_hiding);
        nearby_buildings <- building at_distance (vision_range * 0.8);
        excitement <- length(nearby_rats) > 0 ? 1.0 : max([0.0, excitement - 0.05]);
    }
    
    reflex select_target when: target_rat = nil and length(nearby_rats) > 0 {
        target_rat <- nearby_rats closest_to self;
    }
    
    reflex chase when: target_rat != nil and energy > 10.0 {
        // Check if target is still visible
        if (target_rat.is_hiding or dead(target_rat) or self distance_to target_rat > vision_range) {
            // Target escaped
            if (target_rat.is_hiding) {
                failed_catches <- failed_catches + 1;
            }
            target_rat <- nil;
        } else {
            // Check if rat is near a building - they might escape
            list<building> rat_nearby_buildings <- building at_distance (target_rat distance_to self + 5#m);
            
            do goto target: target_rat speed: speed * (1 + excitement * 0.5);
            energy <- energy - 0.3;
            
            // Check if caught - rats have chance to evade based on agility
            if (self distance_to target_rat <= catch_range) {
                float evasion_roll <- rnd(0.0, 1.0);
                if (evasion_roll > target_rat.agility) {
                    // Successful catch
                    ask target_rat {
                        do die;
                    }
                    catches <- catches + 1;
                    target_rat <- nil;
                    excitement <- 0.5;
                } else {
                    // Rat evaded!
                    failed_catches <- failed_catches + 1;
                    target_rat <- nil;
                    excitement <- 0.3;
                }
            }
        }
    }
    
    reflex check_buildings when: excitement > 0.5 and flip(building_entry_chance) {
        // Dogs sometimes check buildings but less frequently than rats hide
        list<building> buildings_with_rats <- nearby_buildings where (length(each.rats_inside) > 0);
        
        if (length(buildings_with_rats) > 0) {
            building target_building <- one_of(buildings_with_rats);
            do goto target: target_building speed: speed * 0.5;
            energy <- energy - 0.2;
        }
    }
    
    reflex patrol when: target_rat = nil and energy > 10.0 {
        // Random patrol when no target
        do wander speed: speed * 0.3;
        energy <- min([100.0, energy + 0.05]);
    }
    
    reflex rest when: energy <= 10.0 {
        energy <- min([100.0, energy + 0.3]);
    }
    
    aspect default {
        draw circle(size) color: excitement > 0.5 ? #red : #orange border: #black;
        // Draw vision range when excited
        if (excitement > 0.7) {
            draw circle(vision_range) color: #red border: #red;
        }
    }
}

experiment main type: gui {
    parameter "Number of rats" var: nb_rats min: 1 max: 100;
    parameter "Number of dogs" var: nb_dogs min: 1 max: 20;
    
    output {
        display map type: 2d {
            species building aspect: default;
            species road aspect: default;
            species rat aspect: default;
            species dog aspect: default;
        }
        
        monitor "Rats alive" value: length(rat);
        monitor "Rats hiding" value: length(rat where each.is_hiding);
        monitor "Total catches" value: sum(dog collect each.catches);
        monitor "Failed catches (escapes)" value: sum(dog collect each.failed_catches);
        monitor "Average dog energy" value: mean(dog collect each.energy);
        monitor "Average rat fear" value: length(rat) > 0 ? mean(rat collect each.fear_level) : 0.0;
    }
}