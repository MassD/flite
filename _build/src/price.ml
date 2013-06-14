open Flight;;

type t =
    { 
      flight: Flight.t;
      airline : string;
      actual_dep_date : string;
      actual_ret_date : string;
      price : float;
      last_checked : float;
    }

let to_bson p = 
  let flight = Bson.create_doc_element (Flight.to_bson p.flight) in
  let airline = Bson.create_string p.airline in
  let actual_dep_date = Bson.create_string p.actual_dep_date in
  let actual_ret_date = Bson.create_string p.actual_ret_date in
  let price = Bson.create_double p.price in
  let last_checked = Bson.create_double p.last_checked in
  Bson.add_element "flight" flight 
    (Bson.add_element "airline" airline 
       (Bson.add_element "actual_dep_date" actual_dep_date
	  (Bson.add_element "actual_ret_date" actual_ret_date
	     (Bson.add_element "price" price
		(Bson.add_element "last_checked" last_checked Bson.empty)))));;

let of_bson bs = 
  let flight = Flight.of_bson (Bson.get_doc_element (Bson.get_element "flight" bs)) in 
  let airline = Bson.get_string (Bson.get_element "airline" bs) in
  let actual_dep_date = Bson.get_string (Bson.get_element "actual_dep_date" bs) in 
  let actual_ret_date = Bson.get_string (Bson.get_element "actual_ret_date" bs) in
  let price = Bson.get_double (Bson.get_element "price" bs) in 
  let last_checked = Bson.get_double (Bson.get_element "last_checked" bs) in
  { 
    flight = flight;
    airline = airline;
    actual_dep_date = actual_dep_date;
    actual_ret_date = actual_ret_date;
    price = price;
    last_checked = last_checked;
  };;

let to_string p = 
  (Flight.to_string p.flight) ^ "; "
  ^ p.airline ^ ", "
  ^ p.actual_dep_date ^ "-"
  ^ p.actual_ret_date ^ ", "
  ^ string_of_float p.price ^ "-"
  ^ Utils.string_of_utime p.last_checked ^ "\n";;
