/**
* Name: Network
* Based on the internal empty template. 
* Author: HironariSasaki
* Tags: 
*/


model Network

import 'Main.gaml'

global {
	int port <- 5000;
	string url <- "localhost";
	int a <- 0;
	map current_data;
	int new_node_id <- 100;
	int new_road_id <- 1100;
	map<string,list> new_road_data<-["delete_road"::[],"add_road"::[]];
	}

species NetworkAgent skills:[network]{
	
	
	
	init{
		do connect to:url protocol:"http" port:port raw:true;
	}

	reflex when:every(5 #second) {
		do send to:"/get_createRoadData" contents:["GET"];
		
//		loop while: !has_more_message(){
//			do fetch_message_from_network;
//		}
		loop while: has_more_message(){
			message mess <- fetch_message();
			map body <- from_json(mess.contents['BODY']);
			//write body;
			if body != current_data and length(body) != 0 and body["status"]="new_road" {
				write 'body';
				write body;
				//map(['s_xy'::[491.5,496],'s_id'::22,'t_xy'::[503.5,393],'t_id'::158])
				//クリックした座標とGAMA上の座標を合わせる。縮小率が１なためx,yから引くだけでいい
				//新たに作成した始点node座標
				point s <- body['s_xy'];
				float s_x <- s.x - 166.96956176683307;
				float s_y <- 610.0832631918602 - s.y;
				//新たに作成した終点node座標
				point t <- body['t_xy'];
				float t_x <- t.x - 166.96956176683307;
				float t_y <- 610.0832631918602 - t.y;
				//始点と終点に接するroadエージェントのroad_id
				int s_road_id <- int(body['s_id']);
				int t_road_id <- int(body['t_id']);
				add s_road_id to:new_road_data["delete_road"];
				add t_road_id to:new_road_data["delete_road"];
				
				ask mobcar{
					do die;
				}
				write s_x;
				create road  {
					shape <- polyline([{s_x,s_y,0.0},{t_x,t_y,0.0}]);
					maxspeed <- 60.0;
					road_id <- new_road_id;
					one_way <- 0;
					if one_way = 0 {
						create road {
							self.location <- myself.location;
							self.shape <- polyline(reverse(myself.shape.points)); //.pointsでオブジェクト（road）を構成する点たちのリストを取得し、revereseでそれのつなぐ方向（始点と終点）のリストを反転し、polylineで再結合
							self.maxspeed <- myself.maxspeed;
							self.linked_road <- myself;
							myself.linked_road <- self;
							self.road_id <- myself.road_id ;
						}
					}
					
					map nr_info<-nil;
					nr_info["coordinates"]<-[[s_x+13556331.969561767,3481612.083408448-s_y],[t_x+13556331.969561767,3481612.083408448-t_y]];
					nr_info["properties"]<-["road_id"::road_id,"maxspeed"::maxspeed,"oneway"::one_way];
					add nr_info to:new_road_data["add_road"];
					new_road_id <- new_road_id + 1;
				}
				
				create intersection {
					shape<-{s_x,s_y,0.0} as geometry;
					node_id <- new_node_id;
					signal_type <- "1";
					add node_id to:test_node;
				}
				new_node_id <- new_node_id +1;
				create intersection {
					shape<-{t_x,t_y,0.0} as geometry;
					node_id <- new_node_id;
					signal_type <- "1";
					add node_id to:test_node;
				}
				new_node_id <- new_node_id +1;
								
				ask road where (each.road_id = s_road_id) {
					int new_oneway <- one_way;
					intersection snr <- intersection(source_node);
					intersection tnr <- intersection(target_node);
					is_deleated <- true;
					create road {
						shape<-polyline([{snr.location.x,snr.location.y,0.0},{s_x,s_y,0.0}]);
						road_id<-new_road_id;
						maxspeed<-60.0;
						one_way<-new_oneway;
						//new_road_id<-new_road_id+1;
						is_deleated <- false;
						if one_way = 0 {
							create road {
							self.location <- myself.location;
							self.shape <- polyline(reverse(myself.shape.points)); //.pointsでオブジェクト（road）を構成する点たちのリストを取得し、revereseでそれのつなぐ方向（始点と終点）のリストを反転し、polylineで再結合
							self.maxspeed <- myself.maxspeed;
							self.linked_road <- myself;
							myself.linked_road <- self;
							self.road_id <- myself.road_id ;
							self.is_deleated <- myself.is_deleated;
							}
						}
						map nr_info<-nil;
						nr_info["coordinates"]<-[[snr.location.x+13556331.969561767,3481612.083408448-snr.location.y],[s_x+13556331.969561767,3481612.083408448-s_y]];
						nr_info["properties"]<-["road_id"::road_id,"maxspeed"::maxspeed,"oneway"::one_way];
						add nr_info to:new_road_data["add_road"];
						
						new_road_id <- new_road_id + 1;
					}	
				}//ask s_road
				
				ask road where (each.road_id = t_road_id) {
					int new_oneway <- one_way;
					intersection snr <- intersection(source_node);
					intersection tnr <- intersection(target_node);
					is_deleated <- true;
					create road {
						shape<-polyline([{snr.location.x,snr.location.y,0.0},{t_x,t_y,0.0}]);
						road_id<-new_road_id;
						maxspeed<-60.0;
						one_way<-new_oneway;
						//new_road_id<-new_road_id+1;
						is_deleated <- false;
						if one_way = 0 {
							create road {
								self.location <- myself.location;
								self.shape <- polyline(reverse(myself.shape.points)); //.pointsでオブジェクト（road）を構成する点たちのリストを取得し、revereseでそれのつなぐ方向（始点と終点）のリストを反転し、polylineで再結合
								self.maxspeed <- myself.maxspeed;
								self.linked_road <- myself;
								myself.linked_road <- self;
								self.road_id <- myself.road_id ;
								self.is_deleated<-myself.is_deleated;
							}
						}
						map nr_info<-nil;
						nr_info["coordinates"]<-[[snr.location.x+13556331.969561767,3481612.083408448-snr.location.y],[t_x+13556331.969561767,3481612.083408448-t_y]];
						nr_info["properties"]<-["road_id"::road_id,"maxspeed"::maxspeed,"oneway"::one_way];
						add nr_info to:new_road_data["add_road"];
						
						new_road_id<-new_road_id+1;
					}	
				}//ask t_road
				//道路ネットワークの更新
				road_network <- nil;
				list<road> new_road_list <- road where (each.is_deleated=false);
				road_network <- as_driving_graph(new_road_list , intersection);
				current_data <- body;
				do send to:"/new_road_data_from_gama" contents:["POST",to_json(new_road_data),["Content-Type"::"application/json"]];
				new_road_data<-["delete_road"::[],"add_road"::[]];
				create mobcar number:2;
			}//if body != current_data and length(body) != 0
		}//loop while: has_more_message()
	}//reflex
	
}