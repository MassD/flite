open Flite_type
open Flite_type.Journey
open Flite_type.Price
open Flite_type.Alert

let get_all collection q of_bson_f =
  let mongo = Mongo.create_local_default "flite" collection in
  let rec get cursor acc =
    if cursor = 0L then acc
    else 
      let r = 
	if cursor = (-1L) then 
	  Mongo.find_q mongo q
	else 
	  Mongo.get_more mongo cursor
      in 
      if MongoReply.get_num_returned r > 0l then
	let doc_list = MongoReply.get_document_list r in
	get (MongoReply.get_cursor r) (List.rev_append acc doc_list)
      else acc
  in 
  let bson_list = get (-1L) [] in
  Mongo.destory mongo;
  List.map of_bson_f bson_list

(* Reg journey *)

let get_journey journey_id =
  let q = Bson.add_element "id" (Bson.create_int32 (Utils.to_int32 journey_id)) (Bson.empty) in
  let jl = get_all "journeys" q Journey.of_bson in
  if jl = [] then None
  else Some (List.nth jl 0)

let query_alert a = 
  let journey_id = Bson.create_int32 (Utils.to_int32 a.journey_id) in
  let user = Bson.create_string a.user in
  Bson.add_element "journey_id" journey_id
    (Bson.add_element "user" user Bson.empty)

let get_alert journey_id user = 
  let q =
    Bson.add_element "journey_id" (Bson.create_int32 (Utils.to_int32 journey_id))
      (Bson.add_element "user" (Bson.create_string user) Bson.empty) in
  let al = get_all "alerts" q Alert.of_bson in
  if al = [] then None
  else Some (List.nth al 0)
  
let journey_to_mongo j a =
  let to_mongo exist collection to_bson =
    match exist with
      | None -> 
	let mongo = Mongo.create_local_default "flite" collection in
	Mongo.insert mongo [(to_bson ())]; 
	Mongo.destory mongo
      | _ -> ()
  in 
  let j_to_bson () = Journey.to_bson j in
  to_mongo (get_journey j.id) "journeys" j_to_bson;
  let a_to_bson () = Alert.to_bson a in
  to_mongo (get_alert j.id a.user) "alerts" a_to_bson

(* Journeys *)

let get_all_journeys () = 
  let q = 
    let gt = Bson.add_element "$gt" (Bson.create_double (Unix.time())) Bson.empty in
    Bson.add_element "dep_utime" (Bson.create_doc_element gt) (Bson.empty)
  in
  get_all "journeys" q Journey.of_bson

(* Alerts *)

(*{journey_id:1037105510,frequency:{$in: [8]}}*)

let get_all_alerts journey_id hour =
  let q = 
    let array_match = Bson.add_element "$in" (Bson.create_list [Bson.create_int32 (Int32.of_int hour)]) Bson.empty in
    Bson.add_element "journey_id" (Bson.create_int32 (Int32.of_int journey_id))
      (Bson.add_element "frequency" (Bson.create_doc_element array_match) Bson.empty) 
  in 
  get_all "alerts" q Alert.of_bson


let get_all_alerts_simple journey_id  =
  let q = Bson.add_element "journey_id" (Bson.create_int32 (Int32.of_int journey_id)) (Bson.empty) in
  get_all "alerts" q Alert.of_bson


(* Prices *)

let prices_to_mongo pl =
  let mongo = Mongo.create_local_default "flite" "prices" in
  Mongo.insert mongo (List.map Price.to_bson pl);
  Mongo.destory mongo

let q_price f = 
  let gt = Bson.add_element "$gt" (Bson.create_double ((Unix.time()) -. 30. *. 60.)) Bson.empty in
  let last_checked = Bson.add_element "last_checked" (Bson.create_doc_element gt) (Bson.empty) in
  Bson.add_element "flight.id" (Bson.create_int32 (Utils.to_int32 f.id)) last_checked

let get_all_prices f = 
  let q = 
    let gt = Bson.add_element "$gt" (Bson.create_double ((Unix.time()) -. 30. *. 60.)) Bson.empty in
    let last_checked = Bson.add_element "last_checked" (Bson.create_doc_element gt) (Bson.empty) in
    Bson.add_element "flight.id" (Bson.create_int32 (Utils.to_int32 f.id)) last_checked
  in 
  get_all "prices" q Price.of_bson
