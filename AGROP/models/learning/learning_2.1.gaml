/**
* Name: learning21
* Based on the internal empty template. 
* Author: agropt
* Tags: 
*/


model learning21

global {
	int nb_agents <- 10;
	
	map<float, float> asdf <- [];
	
	init {
		create people number: nb_agents;
		
	}
	
	reflex calculations {
		list<people> energ_cal <- people where (each.energy > 5);
		write "people with energy greater than 5:" + energ_cal;
		
		// list of 3 random people
		list<people> randos <- 3 among people;
		write "list of randos: " + randos;
		
		// people with max energy and min of money
		people max_en <- people with_max_of(each.energy);
		people min_en <- people with_min_of(each.money);
		
		map<string, people> result <- ["max_energy":: people with_max_of(each.energy), "min_money":: people with_min_of(each.money)];
		write "max energy:" + result["max_energy"] + "min money:" + result["min_money"];
		
		// maximum value of money, minimum value of energy among people
		float max_mon <- people max_of (each.money);
		write "max money in people" + max_mon;
		
		float min_ener <- people min_of (each.energy);
		write "min energy among people" + min_ener;
		
		// list of all energy values
		list<float> energ_list <- people collect (each.energy);
		write "list of all energy" + energ_list;
		
		// list of people sorted by money
		list<people> money_sort <- people sort_by (-each.money);
		write "people sorted by money:" + money_sort;
		
		// list of people with energy greayter than 3 and lower than 6
		list<people> energy_bounds <- (people where ((each.energy > 3) and (each.energy < 6)));
		write "energy bounds:" + energy_bounds;
		
		// people with lowest money among people with energy > 2
		people trip_1 <- (people where ((each.energy > 2))  with_min_of(each.money));
		
		// bool of people with money greater than 9
		bool check <- not empty(people where (each.money > 9));
		
	
	
	}
	
}



species people {
	float money <- rnd(10.0);
	float energy <- rnd(10.0);
}

experiment test type: gui{
	
}