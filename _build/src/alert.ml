type t =
    {
      flight_id : int;
      user : string;
      email : string;
      frequency : float; (* in hour *)
    }

let to_bson a = 
  let flight_id = Bson.create_int32 (Int32.of_int a.flight_id) in
  let user = Bson.create_string a.user in
  let email = Bson.create_string a.email in
  let frequency = Bson.create_double a.frequency in
  (Bson.add_element "flight_id" flight_id
     (Bson.add_element "user" user
	(Bson.add_element "email" email
	   (Bson.add_element "frequency" frequency Bson.empty))));;

let of_bson bs = 
  let flight_id = Bson.get_int32 (Bson.get_element "flight_id" bs) in 
  let user = Bson.get_string (Bson.get_element "user" bs) in
  let email = Bson.get_string (Bson.get_element "email" bs) in
  let frequency = Bson.get_double (Bson.get_element "frequency" bs) in 
  { 
    flight_id = Int32.to_int flight_id;
    user = user;
    email = email;
    frequency = frequency;
  };;

let to_string a = 
  string_of_int a.flight_id ^ ", "
  ^ a.user ^ ", "
  ^ a.email ^ "-"
  ^ (string_of_float a.frequency)  ^ "\n";;
