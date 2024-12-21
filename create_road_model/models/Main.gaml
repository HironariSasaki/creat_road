/**
* Name: Main
* Based on the internal empty template. 
* Author: HironariSasaki
* Tags: 
*/

//git_test/2024/10/22/17:12



model Main

import 'Parameters.gaml'
import 'Road.gaml'
import 'Building.gaml'
import 'Intersection.gaml'
import 'Vehicle.gaml'
import 'Normalcar.gaml'
import 'Mobcar.gaml'
import 'Test.gaml'
import 'Network.gaml'


global {
	
	list<point>loc_cars <- [];
	list test_node<-[16,29,30,31,32,33,37];
	init {
		create NetworkAgent;
		create road from:shape_file_road with:[
			road_id::int(read("road_id")),
			p_lane_r::int(read("planesu")),
			m_lane_r::int(read("mlanesu")),
			one_way::int(read("oneway")), 
			maxspeed::float(read("maxspeed")),
			num_lanes::int(read("lanes")),
			length::float(read("length"))
		]{  
			if p_lane_r = nil or p_lane_r = 0{
				num_lanes <- 1;
			}else {
				num_lanes <- p_lane_r;}
			if maxspeed = nil or maxspeed = 0.0{
				maxspeed <- 30.0;}
			current_ave_sp <- maxspeed;
			//one_wayがNoなら(一方通行でないなら)もう一方向向けのロードを作成
			if one_way = 0 {
				create road {
					self.location <- myself.location;
					self.shape <- polyline(reverse(myself.shape.points)); //.pointsでオブジェクト（road）を構成する点たちのリストを取得し、revereseでそれのつなぐ方向（始点と終点）のリストを反転し、polylineで再結合
					self.maxspeed <- myself.maxspeed;
					self.num_lanes <- myself.num_lanes;
					self.p_lane_r <- myself.p_lane_r;
					self.m_lane_r <- myself.m_lane_r;
					self.linked_road <- myself;
					myself.linked_road <- self;
					self.road_id <- myself.road_id ;
					self.length <- myself.length;
					self.current_ave_sp <- myself.current_ave_sp;
				}
			}
		}//road
		
		create intersection from:shape_file_node with:
			[ //signal_type::(string(read("signaltype"))),
			  signal_type::"1",
		  	  inter_num::(int(read("nodeno"))),
		 	  node_id::(int(read('node_id')))
			];
		
		road_network <- as_driving_graph(road, intersection);
		
		ask intersection {
			
			if length(roads_in)=0 and length(self.roads_out)=0 {
				do die;
			}
			
			if (is_traffic_signal = true) {
				// v_roads_inの作成
				if (length(roads_in)=4 or length(roads_in)=3) {
					loop i over: roads_in {
						add road(i) to:v_roads_in;
					}
				} else {
					loop i over: roads_in {
						if (road(i).is_thin != true) {
							add road(i) to:v_roads_in;
						}
					}
				}
				
				// 位置を計算
				if length(v_roads_in) > 2 and length(v_roads_in) < 5{
					loop i from:0 to:length(v_roads_in)-1 {
						add signal_loc_re(i) to:signal_locations;
					}
				}
				stop << [];
			}
			//stop << []; //この空のリストをstopに代入しないとjavaエラー
		}
		//do die;
		
		create mobcar number:1;
	}
	reflex when : (cycle=1){
		ask road {
			write road_id;
		}
	}
		
}

experiment create_road type:gui {
	output {
		display city_display type:3d{
			species road aspect:base;
			species intersection aspect:base;
			species mobcar aspect:base;
		}		
	}
}
