type t = 
    {
      name : string;
      code : string;
      http : string
    }

let to_bson a = 
  let name = Bson.create_string a.name in
  let code = Bson.create_string a.code in
  let http = Bson.create_string a.http in
  Bson.add_element "name" name 
    (Bson.add_element "code" code 
       (Bson.add_element "http" http Bson.empty));;

let of_bson bs = 
  {
    name = Bson.get_string (Bson.get_element "name" bs) ;
    code = Bson.get_string (Bson.get_element "code" bs) ;
    http = Bson.get_string (Bson.get_element "http" bs) 
  }

let query_name a_name = Bson.add_element "name" (Bson.create_string a_name) (Bson.empty)

let get_http_from_name a_name = 
  let mongo = Mongo.create_local_default "flite" "airlines" in
  let rf = Mongo.find_q_one mongo (query_name a_name) in
  if MongoReply.get_num_returned rf = 0l then 
    "n/a"
  else 
    let doc_list = MongoReply.get_document_list rf in
    let a = of_bson (List.nth doc_list 0) in
    Mongo.destory mongo;
    a.http

let get_all_airlines () =
  let mongo = Mongo.create_local_default "flite" "airlines" in
  let rec get cursor acc =
    if cursor = 0L then acc
    else 
      let r = 
	if cursor = (-1L) then 
	  Mongo.find mongo
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
  List.map of_bson bson_list
  


