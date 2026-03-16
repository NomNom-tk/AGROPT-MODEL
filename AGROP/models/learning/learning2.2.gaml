/**
* Name: NewModel
* Based on the internal empty template. 
* Author: agropt
* Tags: 
*/


model NewModel

global {
	map<string, float> trial <- ["a"::3.0, "b"::4.0, "c"::5.0];
	
	init {		
		do compu;
	}
	
	action compu {
		list<float> init_check <- trial.values;  
		write "check:" + init_check;
		
		// map of pairs where key starts with a
		map<string, float> trial_a <- [];
		
		loop p over: trial.pairs {
			if (first(p.key = "a")) {
				trial_a[p.key] <- p.value;
			}
		}
		write trial_a;
	}
}

experiment asdf type: gui{}
