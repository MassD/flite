(*open Core.Std*)
open Flite.Flight
open Flite.Alert

(* A very basic command-line program, using Command, Core's Command line
   parsing library.  *)

let query_flight f = Bson.add_element "id" (Bson.create_int32 (Utils.to_int32 f.id)) (Bson.empty)

let query_alert a = 
  let flight_id = Bson.create_int32 (Utils.to_int32 a.flight_id) in
  let user = Bson.create_string a.user in
  Bson.add_element "flight_id" flight_id
    (Bson.add_element "user" user Bson.empty)

let put_to_mongo f a =
  let mongo = Mongo.create_local_default "flite" "flights" in
  let rf = Mongo.find_q_one mongo (query_flight f) in
  (* if flight already exists, then do nothing *)
  if MongoReply.get_num_returned rf = 0l then begin
    let bson = Flite.Flight.to_bson f in
    Mongo.insert mongo [bson];
  end;
  Mongo.destory mongo;
  let mongo_a = Mongo.create_local_default "flite" "alerts" in
  let qa = query_alert a in
  let ra = Mongo.find_q_one mongo_a qa in
  (* if alert.user and alert.flight_id exist, remove them and insert new as a kind of update *)
  if MongoReply.get_num_returned ra <> 0l then 
    Mongo.delete_all mongo_a qa;
  Mongo.insert mongo_a [(Flite.Alert.to_bson a)];
  Mongo.destory mongo_a;
  
let register dep_ap arr_ap dep_mo dep_dy ret_mo ret_dy desired_airline user email frequency  () =
  let f = 
    { 
    dep_ap = dep_ap;
    arr_ap = arr_ap;

    dep_mo = dep_mo;
    dep_dy = dep_dy;
    dep_utime = Utils.to_utime (dep_mo^"-"^dep_dy);

    ret_mo = ret_mo;
    ret_dy = ret_dy;
    ret_utime = Utils.to_utime (ret_mo^"-"^ret_dy);
    
    desired_airline = desired_airline;

    id = 
	Hashtbl.hash 
	  (
	    dep_ap ^ ", "
	    ^ arr_ap ^ ", "
	    ^ dep_mo ^ "-"
	    ^ dep_dy ^ ", "
	    ^ ret_mo ^ "-"
	    ^ ret_dy ^ ", "
	    ^ desired_airline
	  )
  } in
  let a = 
    {
      flight_id = f.id;
      user = user;
      email = email;
      frequency = 
	let splits = Str.split (Str.regexp_string "::") frequency in
	List.map int_of_string splits;
    }
  in 
  print_endline (Flite.Flight.to_string f);
  print_endline (Flite.Alert.to_string a);
  put_to_mongo f a(*;
  let price_list = Lastminute.fs_flex f in
  Printf.printf "Got %d prices\n" (List.length price_list)*)



let command =
  (* [Command.basic] is used for creating a command.  Every command takes a text
     summary and a command line spec *)
  Core.Std.Command.basic
    ~summary:"Register a flight alert"
    (* Command line specs are built up component by component, using a small
       combinator library whose operators are contained in [Command.Spec] *)
    Core.Std.Command.Spec.(
      empty
      +> flag "-dep-ap" (required string) 
        ~doc:" The departure airport code"
      +> flag "-arr-ap" (required string)
        ~doc:" The arrival airport code"
      +> flag "-dep-mo" (required string) 
        ~doc:" The departure month, e.g., 2013-9"
      +> flag "-dep-dy" (required string) 
        ~doc:" The departure day, e.g., 20"
      +> flag "-ret-mo" (required string) 
        ~doc:" The return month, e.g., 2013-10"
      +> flag "-ret-dy" (required string) 
        ~doc:" The return day, e.g., 2013-10"
      +> flag "-desired-airline" (optional_with_default "N/A" string) 
        ~doc:" The desired airline, e.g. KLM, "
      +> flag "-user" (required string) 
        ~doc:" The username for the alert, e.g., 'xinuo'"
      +> flag "-email" (required string) 
        ~doc:" The email to receive the alert, e.g., 'iamindcs@gmail.com;jennyindcs@gmail.com'"
      +> flag "-frequency" (required string) 
        ~doc:" The list of clock hours at which prices needed to be sent, e.g., 12::14::23"
      
    )
    (* The command-line spec determines the argument to this function, which
       show up in an order that matches the spec. *)
    register

let () = Core.Std.Command.run command
