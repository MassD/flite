open Http_client.Convenience;;

type airport = 
    {
      country : string;
      name : string;
      code : string;
    }

module AirportSet = 
  Set.Make(
    struct 
      type t = airport;; 
      let compare = compare 
    end
  );;

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
    country = country;
    name = String.capitalize (String.lowercase name);
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

let get_between c1 c2 =
  let rec get c acc =
    if c > c2 then acc
    else begin
      (*Printf.printf "Dealing with %c\n" c;*)
      get (char_inc c) (add_airport acc (download_url (create_url c)))
    end 
  in 
  get c1 AirportSet.empty;;

let get_all () = get_between 'a' 'z'

let to_bson ap = 
  let country_e = Bson.create_string ap.country in
  let name_e = Bson.create_string ap.name in
  let code_e = Bson.create_string ap.code in
  Bson.add_element "code" code_e 
    (Bson.add_element "name" name_e 
       (Bson.add_element "country" country_e Bson.empty));;

let of_bson bs = 
  let country = Bson.get_string (Bson.get_element "country" bs) in 
  let name = Bson.get_string (Bson.get_element "name" bs) in
  let code = Bson.get_string (Bson.get_element "country" bs) in
  {
    country = country;
    name = name;
    code = code
  };;
      
