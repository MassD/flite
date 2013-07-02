open Flite_type
open Flite_type.Journey
open Lwt
open Logging
open Flite_mongo

let get_all_journeys () = 
  let q = 
    let gt = Bson.add_element "$gt" (Bson.create_double (Unix.time())) Bson.empty in
    Bson.add_element "dep_utime" (Bson.create_doc_element gt) (Bson.empty)
  in
  from_mongo_all Journeys q Journey.of_bson

let get_journey journey_id =
  let q = Bson.add_element "id" (Bson.create_int32 (Utils.to_int32 journey_id)) (Bson.empty) in
  from_mongo_single Journeys q Journey.of_bson

let to_mongo j =
  (get_journey j.id) >>=
    (fun exist -> 
      match exist with
	| None -> to_mongo Journeys [Journey.to_bson j]
	| _ -> return_unit
    )

let update_last_fsed journey_id utime =
  let q = Bson.add_element "id" (Bson.create_int32 (Utils.to_int32 journey_id)) (Bson.empty) in
  let u = Bson.add_element "$set" 
      (Bson.create_doc_element 
	 (Bson.add_element "last_fsed" (Bson.create_double utime) Bson.empty)
      )
      Bson.empty
  in 
  update_mongo Journeys q u
