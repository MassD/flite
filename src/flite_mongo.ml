open Flite_type
open Flite_type.Journey
open Flite_type.Price
open Flite_type.Alert
open Flite_type.Airline
open Lwt
open Logging

exception Mongo_collection_not_found of string
exception Mongo_wrong_collection of string

type collection =
  | Journeys
  | Alerts
  | Prices
  | Airlines

let clt_to_string = function 
  | Journeys -> "journeys"
  | Alerts -> "alerts"
  | Prices -> "prices"
  | Airlines -> "airlines"

let create_mongo = Mongo.create "127.0.0.1" 27017

(* Pool **)

let pool clt = 
  let clt_str = clt_to_string clt in
  Lwt_pool.create 
    10
    (*~check: (fun m f -> f (Utils.is_alive (Mongo.get_file_descr m)))
    ~validate:(fun m -> return (Utils.is_alive (Mongo.get_file_descr m)))*)
    (fun () -> flite_notice "create pool: %s" clt_str;return (create_mongo "flite" clt_str))

let journeys_pool = pool Journeys
let alerts_pool = pool Alerts
let prices_pool = pool Prices
let airlines_pool = pool Airlines

let from_mongo_all clt q of_bson_f =
  let pool = 
    match clt with
      | Journeys -> journeys_pool
      | Alerts -> alerts_pool
      | Prices -> prices_pool
      | Airlines -> airlines_pool
  in 
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
	try(get m (MongoReply.get_cursor r) (List.rev_append acc doc_list)) with
	  | exn -> mongo_error ~exn:exn "Cannot from_mongo_all, collection=%s, q=%s" (clt_to_string clt) (Bson.to_simple_json q);[]
      else acc
  in 
  Lwt_pool.use pool (fun m -> return (List.map of_bson_f (get m (-1L) [])))

let from_mongo_single clt q of_bson_f =
  (from_mongo_all clt q of_bson_f) >>=
    (fun l -> 
      if l = [] then return None
      else return (Some (List.nth l 0))
    )

let to_mongo clt bson_list =
  let pool = 
    match clt with
      | Journeys -> journeys_pool
      | Alerts -> alerts_pool
      | Prices -> prices_pool
      | Airlines -> airlines_pool
  in 
  Lwt_pool.use pool 
    (fun m -> 
      (try (Mongo.insert m bson_list) with
      | exn -> mongo_error ~exn:exn "Cannot write to collection=%s, bson_list_len=%d" (clt_to_string clt) (List.length bson_list));
      return_unit
    )

let update_mongo clt q u =
  let pool = 
    match clt with
      | Journeys -> journeys_pool
      | Alerts -> alerts_pool
      | Prices -> prices_pool
      | Airlines -> airlines_pool
  in 
  Lwt_pool.use pool 
    (fun m -> 
      (try (Mongo.update_all m (q,u)) with
      | exn -> mongo_error ~exn:exn "Cannot update to collection=%s, q=%s, u=%s" (clt_to_string clt) (Bson.to_simple_json q) (Bson.to_simple_json u));
      return_unit
    )

  
