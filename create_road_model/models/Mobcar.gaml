/**
* Name: Mobcar
* Based on the internal empty template. 
* Author: HironariSasaki
* Tags: 
*/


model Mobcar

import 'Main.gaml'
import 'Vehicle.gaml'


species mobcar parent:vehicle {
	
	point o;
	point d;
	path current_path;
	intersection o_node ;
	intersection d_node;
	int o_id;
	int d_id;		
	
	agent drived;
	float start_time;//道路に入った時間
	float end_time;//道路から抜けた時間
	int current_road_id;
	float drived_speed;
	rgb color<-#black;
	
	init {
		drive_ov <-true;
		vehicle_length <- 3.4;
		max_speed <- 60 #km/#h;
		max_acceleration <- 3.5;
		//o <- one_of(intersection where (each.node_id in test_node)).location;
		o <- one_of(intersection where (each.node_id = 30)).location;
		location <- o;
		loop while:true{
			d <- one_of(intersection where (each.node_id in test_node)).location;
			if d != o {
				break;				
				}
		}
		//d <- one_of(intersection where (each.node_id = 31)).location;
		loop while:true{
			current_path <- compute_path(graph:road_network,target:intersection(d));
			if current_path != nil {
				break;
			}
		}
		
	}
	
	reflex   {
		
		if final_target != nil {
			do drive();
		} else if final_target = nil{
			o <- d;
			loop while:true {
				d <- one_of(intersection where (each.node_id in test_node)).location;
				if d != o {
					break;
				}
			}
			loop while:true {
				current_path <- compute_path(graph:road_network,target:intersection(d));
				if current_path != nil {
					break;
				}
			}
			do drive();
		}
		
	}
		
	aspect base {
		draw sphere(7#m) color:color;
	}
	
}

