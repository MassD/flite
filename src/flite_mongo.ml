open Flite.Flight
open Flite.Price
open Flite.Alert

let get_all collection q of_bson_f =
  let mongo = Mongo.create_local_default "flite" collection in
  let rec get cursor acc =
    if cursor = 0L then acc
    else 
      let r = 
	if cursor = (-1L) then 
	  let q = q() in Mongo.find_q mongo q
	else 
	  Mongo.get_more mongo cursor
      in 
      if MongoReply.get_num_returned r > 0l then
	let doc_list = MongoReply.get_document_list r in
	get (MongoReply.get_cursor r) (List.rev_append acc doc_list)
      else acc
  in 
  let bson_list = get (-1L) [] in
  List.map of_bson_f bson_list


(* Flights *)

let q_all_flights () = 
  let gt = Bson.add_element "$gt" (Bson.create_double (Unix.time())) Bson.empty in
  Bson.add_element "dep_utime" (Bson.create_doc_element gt) (Bson.empty)

let get_all_flights () = get_all "flights" q_all_flights Flite.Flight.of_bson

(* Alerts *)

(*{flight_id:1037105510,frequency:{$in: [8]}}*)
let q_alerts flight_id hour = 
  let array_match = Bson.add_element "$in" (Bson.create_list [Bson.create_int32 (Int32.of_int hour)]) Bson.empty in
  let b = Bson.add_element "flight_id" (Bson.create_int32 (Int32.of_int flight_id))
    (Bson.add_element "frequency" (Bson.create_doc_element array_match) Bson.empty)
  in 
  print_endline (Bson.to_simple_json b);
  b

let get_all_alerts flight_id hour =
  let q () = q_alerts flight_id hour in
  get_all "alerts" q Flite.Alert.of_bson


(* Prices *)

let prices_to_mongo pl =
  let mongo = Mongo.create_local_default "flite" "prices" in
  Mongo.insert mongo (List.map Flite.Price.to_bson pl)

let q_price f = 
  let gt = Bson.add_element "$gt" (Bson.create_double ((Unix.time()) -. 30. *. 60.)) Bson.empty in
  let last_checked = Bson.add_element "last_checked" (Bson.create_doc_element gt) (Bson.empty) in
  Bson.add_element "flight.id" (Bson.create_int32 (Utils.to_int32 f.id)) last_checked

let get_all_prices f = 
  let mongo = Mongo.create_local_default "flite" "prices" in
  let q = q_price f in
  let r = Mongo.find_q mongo q in
  let num = MongoReply.get_num_returned r in
  if num = 0l then []
  else 
    List.map Flite.Price.of_bson (MongoReply.get_document_list r)
