open Flite_type
open Flite_type.Alert
open Lwt
open Logging
open Flite_mongo

(*{journey_id:1037105510,frequency:{$in: [8]}}*)
let get_all_alerts journey_id hour =
  let q = 
    let array_match = Bson.add_element "$in" (Bson.create_list [Bson.create_int32 (Int32.of_int hour)]) Bson.empty in
    Bson.add_element "journey_id" (Bson.create_int32 (Int32.of_int journey_id))
      (Bson.add_element "frequency" (Bson.create_doc_element array_match) Bson.empty) 
  in 
  from_mongo_all Alerts q Alert.of_bson

let get_all_alerts_simple journey_id  =
  let q = Bson.add_element "journey_id" (Bson.create_int32 (Int32.of_int journey_id)) (Bson.empty) in
  from_mongo_all Alerts q Alert.of_bson

let get_alert journey_id user = 
  let q =
    Bson.add_element "journey_id" (Bson.create_int32 (Utils.to_int32 journey_id))
      (Bson.add_element "user" (Bson.create_string user) Bson.empty) in
  from_mongo_single Alerts q Alert.of_bson

let to_mongo a =
  (get_alert a.journey_id a.user) >>=
    (fun exist -> 
      match exist with
	| None -> to_mongo Alerts [Alert.to_bson a]
	| _ -> return_unit
    )

let get_current_alerts hour =
  let q = 
    let array_match = Bson.add_element "$in" (Bson.create_list [Bson.create_int32 (Int32.of_int hour)]) Bson.empty in
      Bson.add_element "frequency" (Bson.create_doc_element array_match) Bson.empty
  in 
  from_mongo_all Alerts q Alert.of_bson
