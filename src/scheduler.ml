open Flite.Flight
open Flite.Price
open Lwt

let q_all_flights () = 
  let gt = Bson.add_element "$gt" (Bson.create_double (Unix.time())) Bson.empty in
  Bson.add_element "dep_utime" (Bson.create_doc_element gt) (Bson.empty)

let get_all_flights () =
  let mongo = Mongo.create_local_default "flite" "flights" in
  let rec get cursor acc =
    if cursor = 0L then acc
    else 
      let r = 
	if cursor = (-1L) then 
	  let q = q_all_flights () in Mongo.find_q mongo q
	else 
	  Mongo.get_more mongo cursor
      in 
      if MongoReply.get_num_returned r > 0l then
	let doc_list = MongoReply.get_document_list r in
	get (MongoReply.get_cursor r) (List.rev_append acc doc_list)
      else acc
  in 
  let f_bson_list = get (-1L) [] in
  List.map Flite.Flight.of_bson f_bson_list
     
(*let _ = print_int (List.length (get_all_flights()));;*)

let price_to_mongo pl =
  let mongo = Mongo.create_local_default "flite" "prices" in
  Mongo.insert mongo (List.map Flite.Price.to_bson pl)

let q_price f = 
  let gt = Bson.add_element "$gt" (Bson.create_double ((Unix.time()) -. 3. *. 60. *. 60.)) Bson.empty in
  let last_checked = Bson.add_element "last_checked" (Bson.create_doc_element gt) (Bson.empty) in
  Bson.add_element "flight.id" (Bson.create_int32 (Utils.to_int32 f.id)) last_checked

let check_existing_price_lwt f = 
  let mongo = Mongo.create_local_default "flite" "prices" in
  let q = q_price f in
  let r = Mongo.find_q mongo q in
  (*print_endline "checked existing_price";*)
  Lwt.return (f, r, (MongoReply.get_num_returned r))

let get_existing_price_lwt r =
  Lwt.return (Html.format_pl (List.map Flite.Price.of_bson (MongoReply.get_document_list r)))

let get_fs_price_lwt f =
  (*print_endline "begin fs";*)
  (Lastminute.fs_lwt f) >>= 
    (fun pl -> 
      print_endline "lastminute finished"; 
      price_to_mongo pl; 
      Lwt.return (Html.format_pl pl))

let get_price_html_lwt f =
  (*print_endline "begin get_price_html_lwt";*)
  (check_existing_price_lwt f) >>= 
    (fun (f, r, n) -> if n > 0l then (get_existing_price_lwt r) else (get_fs_price_lwt f))

let print_price_html_lwt f =
    (get_price_html_lwt f) >>=
      (fun ph -> Lwt_io.printf "%d\n" (String.length ph))

let rec start () = 
  (Lwt_unix.sleep 100.)  >>= 
    (fun () -> 
      print_endline "begin fs all";
      let fl = get_all_flights () in 
      Printf.printf "get %d flights\n" (List.length fl);
      (Lwt_list.iter_p print_price_html_lwt fl) >>= start )

let _ = Lwt_main.run (start()) 

