open Flite_type
open Flite_type.Alert
open Lwt
open Logging
open Flite_mongo

let fresh_price_q journey_id = 
  Bson.add_element "journey_id" (Bson.create_int32 (Utils.to_int32 journey_id)) 
       (Bson.add_element "expired" (Bson.create_boolean false) (Bson.empty))

let get_all_fresh_prices journey_id = from_mongo_all Prices (fresh_price_q journey_id) Price.of_bson

let to_mongo pl = to_mongo Prices (List.map Price.to_bson pl)

let spoil_prices journey_id =
  let u = 
    Bson.add_element "$set" 
      (Bson.create_doc_element 
	 (Bson.add_element "expired" (Bson.create_boolean true) Bson.empty)
      )
      Bson.empty
  in 
  update_mongo Prices (fresh_price_q journey_id) u
