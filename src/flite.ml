module Flight : sig
  type t =
    { 
      dep_ap : string;
      arr_ap : string;
      
      dep_mo : string;
      dep_dy : string;
      dep_utime : float;
      
      ret_mo : string;
      ret_dy : string;
      ret_utime : float;
      
      desired_airline : string;
      id : int;
    }

  val to_bson : t -> Bson.t
  val of_bson : Bson.t -> t
  val to_string : t -> string
end = 
struct
  type t =
    { 
      dep_ap : string;
      arr_ap : string;
      
      dep_mo : string;
      dep_dy : string;
      dep_utime : float;
      
      ret_mo : string;
      ret_dy : string;
      ret_utime : float;
      
      desired_airline : string;
      id : int;
    } 

  let to_bson f = 
    let dep_ap = Bson.create_string f.dep_ap in
    let arr_ap = Bson.create_string f.arr_ap in
    let dep_mo = Bson.create_string f.dep_mo in
    let dep_dy = Bson.create_string f.dep_dy in
    let dep_utime = Bson.create_double f.dep_utime in
    let ret_mo = Bson.create_string f.ret_mo in
    let ret_dy = Bson.create_string f.ret_dy in
    let ret_utime = Bson.create_double f.ret_utime in
    let desired_airline = Bson.create_string f.desired_airline in
    let id = Bson.create_int32 (Int32.of_int f.id) in
    Bson.add_element "dep_ap" dep_ap 
      (Bson.add_element "arr_ap" arr_ap 
	 (Bson.add_element "dep_mo" dep_mo
	    (Bson.add_element "dep_dy" dep_dy
	       (Bson.add_element "dep_utime" dep_utime
		  (Bson.add_element "ret_mo" ret_mo
		     (Bson.add_element "ret_dy" ret_dy
			(Bson.add_element "ret_utime" ret_utime
			   (Bson.add_element "desired_airline" desired_airline
			      (Bson.add_element "id" id Bson.empty)))))))))

  let of_bson bs = 
    let dep_ap = Bson.get_string (Bson.get_element "dep_ap" bs) in 
    let arr_ap = Bson.get_string (Bson.get_element "arr_ap" bs) in
    let dep_mo = Bson.get_string (Bson.get_element "dep_mo" bs) in 
    let dep_dy = Bson.get_string (Bson.get_element "dep_dy" bs) in
    let dep_utime = Bson.get_double (Bson.get_element "dep_utime" bs) in
    let ret_mo = Bson.get_string (Bson.get_element "ret_mo" bs) in 
    let ret_dy = Bson.get_string (Bson.get_element "ret_dy" bs) in
    let ret_utime = Bson.get_double (Bson.get_element "ret_utime" bs) in
    let desired_airline = Bson.get_string (Bson.get_element "desired_airline" bs) in
    let id = Bson.get_int32 (Bson.get_element "id" bs) in
    { 
      dep_ap = dep_ap;
      arr_ap = arr_ap;

      dep_mo = dep_mo;
      dep_dy = dep_dy;
      dep_utime = dep_utime;

      ret_mo = ret_mo;
      ret_dy = ret_dy;
      ret_utime = ret_utime;
      
      desired_airline = desired_airline;

      id = Int32.to_int id;    
    }

  let to_string f = 
    f.dep_ap ^ ", "
    ^ f.arr_ap ^ ", "
    ^ f.dep_mo ^ "-"
    ^ f.dep_dy ^ ", "
    ^ string_of_float f.dep_utime ^ ", "
    ^ f.ret_mo ^ "-"
    ^ f.ret_dy ^ ", "
    ^ string_of_float f.ret_utime ^ ", "
    ^ f.desired_airline ^ ", "
    ^ "id = " ^ string_of_int f.id ^ "\n"
end

module Alert : sig
  type t =
      {
	flight_id : int;
	user : string;
	email : string;
	frequency : int list; (* list of hour, e.g., [12;13;24] *)
      }

  val to_bson : t -> Bson.t
  val of_bson : Bson.t -> t
  val to_string : t -> string
end = 
struct
  type t =
      {
	flight_id : int;
	user : string;
	email : string;
        frequency : int list;
      }

  let to_bson a = 
    let flight_id = Bson.create_int32 (Int32.of_int a.flight_id) in
    let user = Bson.create_string a.user in
    let email = Bson.create_string a.email in
    let frequency = Bson.create_list (List.map (fun fre -> Bson.create_int32 (Int32.of_int fre)) a.frequency) in 
    (*let frequency = Bson.create_double a.frequency in*)
    (Bson.add_element "flight_id" flight_id
       (Bson.add_element "user" user
	  (Bson.add_element "email" email
	     (Bson.add_element "frequency" frequency Bson.empty))))

  let of_bson bs = 
    let flight_id = Bson.get_int32 (Bson.get_element "flight_id" bs) in 
    let user = Bson.get_string (Bson.get_element "user" bs) in
    let email = Bson.get_string (Bson.get_element "email" bs) in
    let frequency = let el = Bson.get_list (Bson.get_element "frequency" bs) in List.map (fun e -> Int32.to_int (Bson.get_int32 e)) el in
    (*let frequency = Bson.get_double (Bson.get_element "frequency" bs) in*)
    { 
      flight_id = Int32.to_int flight_id;
      user = user;
      email = email;
      frequency = frequency;
    }

  let to_string a = 
    "flight_id = " ^ string_of_int a.flight_id ^ ", "
    ^ a.user ^ ", "
    ^ a.email (*^ ", "
    ^ (string_of_float a.frequency)  *)^ "\n"
end

module Price : sig
  type t =
      {
        flight: Flight.t;
	airline : string;
	airline_http : string;
	actual_dep_date : string;
	actual_ret_date : string;
	price : float;
	last_checked : float;
      }

  val to_bson : t -> Bson.t
  val of_bson : Bson.t -> t
  val to_string : t -> string
end =  
struct
  type t =
      { 
	flight: Flight.t;
	airline : string;
	airline_http : string;
	actual_dep_date : string;
	actual_ret_date : string;
	price : float;
	last_checked : float;
      }

  let to_bson p = 
    let flight = Bson.create_doc_element (Flight.to_bson p.flight) in
    let airline = Bson.create_string p.airline in
    let airline_http = Bson.create_string p.airline_http in
    let actual_dep_date = Bson.create_string p.actual_dep_date in
    let actual_ret_date = Bson.create_string p.actual_ret_date in
    let price = Bson.create_double p.price in
    let last_checked = Bson.create_double p.last_checked in
    Bson.add_element "flight" flight 
      (Bson.add_element "airline" airline 
	 (Bson.add_element "airline_http" airline_http
	 (Bson.add_element "actual_dep_date" actual_dep_date
	    (Bson.add_element "actual_ret_date" actual_ret_date
	       (Bson.add_element "price" price
		  (Bson.add_element "last_checked" last_checked Bson.empty))))))

  let of_bson bs = 
    let flight = Flight.of_bson (Bson.get_doc_element (Bson.get_element "flight" bs)) in 
    let airline = Bson.get_string (Bson.get_element "airline" bs) in
    let airline_http = Bson.get_string (Bson.get_element "airline_http" bs) in
    let actual_dep_date = Bson.get_string (Bson.get_element "actual_dep_date" bs) in 
    let actual_ret_date = Bson.get_string (Bson.get_element "actual_ret_date" bs) in
    let price = Bson.get_double (Bson.get_element "price" bs) in 
    let last_checked = Bson.get_double (Bson.get_element "last_checked" bs) in
    { 
      flight = flight;
      airline = airline;
      airline_http = airline_http;
      actual_dep_date = actual_dep_date;
      actual_ret_date = actual_ret_date;
      price = price;
      last_checked = last_checked;
    }

  let to_string p = 
    (Flight.to_string p.flight) ^ "; "
    ^ p.airline ^ ", "
    ^ p.airline_http ^ ", "
    ^ p.actual_dep_date ^ "-"
    ^ p.actual_ret_date ^ ", "
    ^ string_of_float p.price ^ "-"
    ^ Utils.string_of_utime p.last_checked ^ "\n"
end
