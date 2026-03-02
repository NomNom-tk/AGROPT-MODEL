/**
* Name: NewModel
* Based on the internal empty template. 
* Author: agropt
* Tags: 
*/


model NewModel

global {
	map<string, float> trial <- ['a'::3, 'b'::4, 'c'::5];
	
	init {		
		do compu;
	}
	
	action compu {
		list<float> init_check <- trial.values;  
		write "check:" + init_check;
		
		// map of pairs where key starts with a
		map<string, float> trial_a <- [];
		
		loop p over: trial.pairs {
			if (p.key starts_with: "a") {
				trial_a[p.key] <- p.value;
			}
		}
		
	}
}

experiment asdf type: gui{}
