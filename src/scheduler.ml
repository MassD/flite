let q () = 
  let gt = Bson.add_element "$gt" (Bson.create_double (Unix.time())) Bson.empty in
  Bson.add_element "dep_utime" (Bson.create_doc_element gt) (Bson.empty)

let get_all_flights () =
  let mongo = Mongo.create_local_default "flite" "flights" in
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
  get (-1L) [];;
     
let _ = print_int (List.length (get_all_flights()));;

(*let rec start () = 
    Lwt.bind (Lwt_unix.sleep 1.) 
       (fun () -> print_endline "Hello, world !"; start ())
let _ = start ()
let _ = Lwt.async (start)
let _ = Lwt_main.run (start());;*)
