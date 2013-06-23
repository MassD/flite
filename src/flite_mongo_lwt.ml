open Flite_type
open Flite_type.Journey
open Flite_type.Price
open Flite_type.Alert
open Flite_type.Airline
open Lwt

exception Mongo_collection_not_found of string
exception Mongo_wrong_collection of string

(* Pool **)

let pool collection = 
  Lwt_pool.create 
    10
    (*~check: (fun m f -> f (Utils.is_alive (Mongo.get_file_descr m)))
    ~validate:(fun m -> return (Utils.is_alive (Mongo.get_file_descr m)))*)
    (fun () -> return (Mongo.create_local_default "flite" collection))

let journeys_pool = pool "journeys"
let alerts_pool = pool "alerts"
let prices_pool = pool "prices"
let airlines_pool = pool "airlines"

let get_all collection q of_bson_f =
  let pool = 
    match collection with
      | "journeys" -> journeys_pool
      | "alerts" -> alerts_pool
      | "prices" -> prices_pool
      | "airlines" -> airlines_pool
      | _ -> raise (Mongo_collection_not_found collection) in
  let rec get m cursor acc =
    if cursor = 0L then acc
    else 
      let r = 
	if cursor = (-1L) then 
	  Mongo.find_q m q
	else 
	  Mongo.get_more m cursor
      in 
      if MongoReply.get_num_returned r > 0l then
	let doc_list = MongoReply.get_document_list r in
	get m (MongoReply.get_cursor r) (List.rev_append acc doc_list)
      else acc
  in 
  Lwt_pool.use pool (fun m -> return (List.map of_bson_f (get m (-1L) [])))

let get_single collection q of_bson_f =
  (get_all collection q of_bson_f) >>=
    (fun l -> 
      if l = [] then return None
      else return (Some (List.nth l 0))
    )


(* Reg journey *)

let get_journey journey_id =
  let q = Bson.add_element "id" (Bson.create_int32 (Utils.to_int32 journey_id)) (Bson.empty) in
  get_single "journeys" q Journey.of_bson

let get_alert journey_id user = 
  let q =
    Bson.add_element "journey_id" (Bson.create_int32 (Utils.to_int32 journey_id))
      (Bson.add_element "user" (Bson.create_string user) Bson.empty) in
  get_single "alerts" q Alert.of_bson

(* Public *)
let journey_to_mongo j a =
  let to_mongo exist collection to_bson =
    let pool = 
      match collection with
      | "journeys" -> journeys_pool
      | "alerts" -> alerts_pool
      | _ -> raise (Mongo_collection_not_found (Printf.sprintf "%s cannot be used in journey_to_mongo" collection)) in
    let insert m = return 
      (
	match exist with
	  | None -> 
	    Printf.printf "inserting to %s, %s\n" collection (Bson.to_simple_json (to_bson()));
	    Mongo.insert m [(to_bson ())]
	  | _ -> ()
      )
    in 
    Lwt_pool.use pool insert
  in 
  lwt exist_j = get_journey j.id and exist_a = get_alert j.id a.user in
lwt a = to_mongo exist_j "journeys" (fun () -> Journey.to_bson j) and b = to_mongo exist_a "alerts" (fun () -> Alert.to_bson a) in
return ()
 (*(get_journey j.id) >>=
      (fun exist -> 
	(to_mongo exist "journeys" (fun () -> Journey.to_bson j)) >>=
	  (fun () -> 
	    (get_alert j.id a.user) >>=
	      (fun exist ->
		to_mongo exist "alerts" (fun () -> Alert.to_bson a)
	      )
	  )
      )*)

(* Journeys *)

(* Public *)
let get_all_journeys () = 
  let q = 
    let gt = Bson.add_element "$gt" (Bson.create_double (Unix.time())) Bson.empty in
    Bson.add_element "dep_utime" (Bson.create_doc_element gt) (Bson.empty)
  in
  get_all "journeys" q Journey.of_bson


(* Alerts *)

(* Public *)
(*{journey_id:1037105510,frequency:{$in: [8]}}*)
let get_all_alerts journey_id hour =
  let q = 
    let array_match = Bson.add_element "$in" (Bson.create_list [Bson.create_int32 (Int32.of_int hour)]) Bson.empty in
    Bson.add_element "journey_id" (Bson.create_int32 (Int32.of_int journey_id))
      (Bson.add_element "frequency" (Bson.create_doc_element array_match) Bson.empty) 
  in 
  get_all "alerts" q Alert.of_bson

(* Public *)
let get_all_alerts_simple journey_id  =
  let q = Bson.add_element "journey_id" (Bson.create_int32 (Int32.of_int journey_id)) (Bson.empty) in
  get_all "alerts" q Alert.of_bson


(* Prices *)

(* Public *)
let prices_to_mongo pl =
  Lwt_pool.use prices_pool (fun m -> return (Mongo.insert m (List.map Price.to_bson pl)))

(* Public *)
let get_all_prices f = 
  let q = 
    let gt = Bson.add_element "$gt" (Bson.create_double ((Unix.time()) -. 30. *. 60.)) Bson.empty in
    let last_checked = Bson.add_element "last_checked" (Bson.create_doc_element gt) (Bson.empty) in
    Bson.add_element "flight.id" (Bson.create_int32 (Utils.to_int32 f.id)) last_checked
  in 
  get_all "prices" q Price.of_bson

(* Airlines *)

let get_airline name = 
  let q = Bson.add_element "name" (Bson.create_string name) (Bson.empty) in
  get_single "airlines" q Airline.of_bson

let get_all_airlines () =
  let q = 
    let exists = Bson.add_element "$exists" (Bson.create_boolean true) Bson.empty in
    Bson.add_element "name" (Bson.create_doc_element exists) (Bson.empty)
  in 
  get_all "airlines" q Airline.of_bson
