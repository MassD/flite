open Airport;;

let all_set = get_all();;

let _ = 
  AirportSet.iter (fun a -> Printf.printf " country = %S, name = %S, code = %S\n" a.country a.name a.code) all_set;
  Printf.printf "Totally %d airports\n" (AirportSet.cardinal all_set);;

let m = Mongo.create_local_default "db" "airports";;

let airport_bson_list = 
  AirportSet.fold (fun ap acc -> (to_bson ap)::acc) all_set [];;

let _ = Mongo.insert m airport_bson_list;;
