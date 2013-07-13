open Flite_type
open Flite_type.Airline
open Lwt
open Logging
open Flite_mongo

let get_airline name = 
  let q = Bson.add_element "name" (Bson.create_string name) (Bson.empty) in
  from_mongo_single Airlines q Airline.of_bson

let get_all_airlines () =
  let q = 
    let exists = Bson.add_element "$exists" (Bson.create_boolean true) Bson.empty in
    Bson.add_element "name" (Bson.create_doc_element exists) (Bson.empty)
  in 
  (*Printf.printf "airlines q json: %s\n" (Bson.to_simple_json q);*)
  from_mongo_all Airlines q Airline.of_bson
