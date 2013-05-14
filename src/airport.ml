open Http_client.Convenience;;

type airport = 
    {
      name : string;
      country : string;
      code : string
    }

module AirportSet = Set.Make(struct type t = airport let compare = compare end);;

let create_url c = 
  let buf = Buffer.create 256 in
  Buffer.add_string buf "http://www.lastminute.com/site/travel/flights/predictive-text-backend.html?LOCALE=en_GB&LOCATION=";
  Buffer.add_char buf c;
  Buffer.contents buf;;

let download_url = http_get;;

let parsing_airport n c = 
  (*Printf.printf "parsing %S, %S\n" n c;*)
  let name_end = (String.index n '(') in
  let name = String.sub n 0 (name_end-1) in
  (*Printf.printf "name = %S\n" name;*)
  let country = String.sub n ((String.length n)-2) 2 in
  {
    name = name;
    country = country;
    code = c
  };;

let add_airport set html =
  let xml = Xml.parse_string html in
  let new_set = Xml.fold (fun acc xml ->
      match xml with
      | Xml.Element ("LOC", attrs, _) ->
          let n = List.assoc "N" attrs
          and c = List.assoc "C" attrs
	  in 
	  (*Printf.printf "N = %S, C = %S \n" n c;*)
	  AirportSet.add (parsing_airport n c) acc
      | _ -> acc
    ) set xml 
  in 
  new_set;;

let char_inc c = Char.chr ((Char.code c)+1);;
let end_c = 'z';;

let get_all_airports () =
  let rec get_all c acc =
    if c > end_c then acc
    else begin
      (*Printf.printf "Dealing with %c\n" c;*)
      get_all (char_inc c) (add_airport acc (download_url (create_url c)))
    end 
  in 
  get_all 'a' AirportSet.empty;;

let all_set = get_all_airports();;

let _ = 
  AirportSet.iter (fun a -> Printf.printf "name = %S, country = %S, code = %S\n" a.name a.country a.code) all_set;
  Printf.printf "Totally %d airports\n" (AirportSet.cardinal all_set);;
      
