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
	list test_node<-[16,29,30,31,32,33,37, 1000,1001];
//list test_node <- [1000,31];
	init {
		create NetworkAgent;
		
//		create road {
//			shape<-polyline([{106.8333341870457,222.22222400037572,0.0},{145.47222338430583,303.66666909633204,0.0}]);
//			
//			road_id <-10000;
//			maxspeed <- 60.0;
//			one_way <- 0;
//			if one_way = 0 {
//				create road {
//					self.location <- myself.location;
//					self.shape <- polyline(reverse(myself.shape.points)); //.pointsでオブジェクト（road）を構成する点たちのリストを取得し、revereseでそれのつなぐ方向（始点と終点）のリストを反転し、polylineで再結合
//					self.maxspeed <- myself.maxspeed;
//					self.linked_road <- myself;
//					myself.linked_road <- self;
//					self.road_id <- myself.road_id+1 ;
//				}
//			}
//		}
//		create intersection{
//			shape<-{106.8333341870457,222.22222400037572,0.0} as geometry;
//			//roads_out <- road where (each.road_id=10000);
//			//roads_in <- road where (each.road_id=10001);
//			node_id <-1000;
//			
//		}
//		create intersection{
//			shape<-{145.47222338430583,303.66666909633204,0.0} as geometry;
//			node_id<-1001;
//			//roads_out <- road where (each.road_id=10001);
//			//roads_in <- road where (each.road_id=10000);
//		}
		
		create road from:shape_file_road with:[
			road_id::int(read("road_id")),
			p_lane_r::int(read("planesu")),
			m_lane_r::int(read("mlanesu")),
			one_way::int(read("oneway")), 
			maxspeed::float(read("maxspeed")),
			num_lanes::int(read("lanes")),
			length::float(read("length"))
			//road_location::read("coordinates")
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
			[ signal_type::(string(read("signaltype"))),
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
	
	
	reflex when:(cycle=100){
//	action creater {
		ask mobcar {
			do die;
		}
		// 真ん中のやつ
		create road {
			shape<-polyline([{106.8333341870457,222.22222400037572,0.0},{145.47222338430583,303.66666909633204,0.0}]);
			road_id <-10000;
			maxspeed <- 60.0;
			one_way <- 0;
			if one_way = 0 {
				create road {
					self.location <- myself.location;
					self.shape <- polyline(reverse(myself.shape.points)); //.pointsでオブジェクト（road）を構成する点たちのリストを取得し、revereseでそれのつなぐ方向（始点と終点）のリストを反転し、polylineで再結合
					self.maxspeed <- myself.maxspeed;
					self.linked_road <- myself;
					myself.linked_road <- self;
					self.road_id <- myself.road_id+1 ;
				}
			}
		}
		create intersection{
			shape<-{106.8333341870457,222.22222400037572,0.0} as geometry;
			node_id <-1000;
			signal_type <- "1";
		}
		create intersection{
			shape<-{145.47222338430583,303.66666909633204,0.0} as geometry;
			node_id<-1001;
			signal_type <- "1";
		}
		
		intersection no1000 <- one_of(intersection where (each.node_id=1000)); 
		intersection no1001 <- one_of(intersection where (each.node_id=1001)); 
		
		ask road where (each.index=72){
			int new_oneway <- one_way;
			intersection s_n <- intersection(source_node); // 始点
			intersection t_n <- intersection(target_node); // 終点
			road_network <- road_network add_edge (no1000.location::point(s_n.location));
			road_network <- road_network add_edge (point(s_n.location)::no1000.location);
			road_network <- road_network add_edge (no1000.location::point(t_n.location));
			road_network <- road_network add_edge (point(t_n.location)::no1000.location);

		}

		ask road where (each.index=66){
			int new_oneway <- one_way;
			intersection s_n <- intersection(source_node);
			intersection t_n <- intersection(target_node);
			road_network <- road_network add_edge (no1001.location::point(s_n.location));
			road_network <- road_network add_edge (point(s_n.location)::no1001.location);
			road_network <- road_network add_edge (no1001.location::point(t_n.location));
			road_network <- road_network add_edge (point(t_n.location)::no1001.location);
		}
		
		road_network <- road_network add_node no1000;
		road_network <- road_network add_node no1001;
		road_network <- as_driving_graph(road, intersection);
		write road_network;

		
		
		

	}


	
	reflex when:(cycle=110){
		create mobcar number:1;
		ask road where (each.road_id=161){
			write road_id;
		}
	}
	

}



experiment traffic_change_tenma type:gui {
	output {
		display city_display type:3d{
			species road aspect:base;
			species intersection aspect:base;
			species mobcar aspect:base;
		}		
	}
}
