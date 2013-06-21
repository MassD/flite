open Flite_type
open Flite_type.Journey
open Flite_type.Alert
open Lwt

let register_journey dep_ap arr_ap dep_mo dep_dy ret_mo ret_dy airline trip_type user email frequency  () =
  let j_tmp = 
    { 
    dep_ap = dep_ap;
    arr_ap = arr_ap;

    dep_mo = dep_mo;
    dep_dy = dep_dy;
    dep_utime = Utils.to_utime (dep_mo^"-"^dep_dy);

    ret_mo = ret_mo;
    ret_dy = ret_dy;
    ret_utime = Utils.to_utime (ret_mo^"-"^ret_dy);
    
    airline = airline;
    class_level = 2;
    stop = -1;
    adults = 1;
    children = 0;
    infants = 0;
    trip_type = trip_type;

    last_checked = -1.;
    id = -1
  } in
  let j = {j_tmp with id = Hashtbl.hash (Journey.to_string j_tmp)} in
  let a = 
    {
      journey_id = j.id;
      user = user;
      email = email;
      frequency = 
	let splits = Str.split (Str.regexp_string "::") frequency in
	List.map int_of_string splits;
    }
  in 
  print_endline (Journey.to_string j);
  print_endline (Alert.to_string a);
  (*Flite_mongo.journey_to_mongo j a*)
  Lwt_main.run (Flite_mongo_lwt.journey_to_mongo j a)




