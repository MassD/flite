module Journey : sig
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
      
      airline : string;
      class_level : int; (* 0 - first class; 1 - business class; 2 - economic class *)
      stop : int; (* -1 is don't care *)
      adults : int;
      children : int;
      infants : int;
      trip_type : int; (* 0 - single; 1 - return; 2 - multihop *)

      last_checked : float;
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
      
      airline : string;
      class_level : int;
      stop : int;
      adults : int;
      children : int;
      infants : int;
      trip_type : int;

      last_checked : float;
      id : int;
    } 

  let to_bson j = 
    Bson.add_element "dep_ap" (Bson.create_string j.dep_ap)
      (Bson.add_element "arr_ap" (Bson.create_string j.arr_ap) 
	 (Bson.add_element "dep_mo" (Bson.create_string j.dep_mo)
	    (Bson.add_element "dep_dy" (Bson.create_string j.dep_dy)
	       (Bson.add_element "dep_utime" (Bson.create_double j.dep_utime)
		  (Bson.add_element "ret_mo" (Bson.create_string j.ret_mo)
		     (Bson.add_element "ret_dy" (Bson.create_string j.ret_dy)
			(Bson.add_element "ret_utime" (Bson.create_double j.ret_utime)
			   (Bson.add_element "airline" (Bson.create_string j.airline)
			      (Bson.add_element "class_level" (Bson.create_int32 (Int32.of_int j.class_level))
				 (Bson.add_element "stop" (Bson.create_int32 (Int32.of_int j.stop))
				    (Bson.add_element "adults" (Bson.create_int32 (Int32.of_int j.adults))
				       (Bson.add_element "children" (Bson.create_int32 (Int32.of_int j.children))
					  (Bson.add_element "infants" (Bson.create_int32 (Int32.of_int j.infants))
					     (Bson.add_element "trip_type" (Bson.create_int32 (Int32.of_int j.trip_type))
						(Bson.add_element "last_checked" (Bson.create_double j.last_checked)
						   (Bson.add_element "id" (Bson.create_int32 (Int32.of_int j.id)) Bson.empty))))))))))))))))

  let of_bson bs = 
    { 
      dep_ap = Bson.get_string (Bson.get_element "dep_ap" bs);
      arr_ap = Bson.get_string (Bson.get_element "arr_ap" bs);

      dep_mo = Bson.get_string (Bson.get_element "dep_mo" bs);
      dep_dy = Bson.get_string (Bson.get_element "dep_dy" bs);
      dep_utime = Bson.get_double (Bson.get_element "dep_utime" bs);

      ret_mo = Bson.get_string (Bson.get_element "ret_mo" bs);
      ret_dy = Bson.get_string (Bson.get_element "ret_dy" bs);
      ret_utime = Bson.get_double (Bson.get_element "ret_utime" bs);
      
      airline = Bson.get_string (Bson.get_element "airline" bs);
      class_level = Int32.to_int (Bson.get_int32 (Bson.get_element "class_level" bs));  
      stop = Int32.to_int (Bson.get_int32 (Bson.get_element "stop" bs));  
      adults = Int32.to_int (Bson.get_int32 (Bson.get_element "adults" bs));  
      children = Int32.to_int (Bson.get_int32 (Bson.get_element "children" bs));  
      infants = Int32.to_int (Bson.get_int32 (Bson.get_element "infants" bs));  
      trip_type = Int32.to_int (Bson.get_int32 (Bson.get_element "trip_type" bs));  

      last_checked = Bson.get_double (Bson.get_element "last_checked" bs);
      id = Int32.to_int (Bson.get_int32 (Bson.get_element "id" bs));    
    }

  let to_string j = 
    Printf.sprintf
      "%s, %s, %s-%s, %s-%s, %s, %s, %s, %s"
      j.dep_ap
      j.arr_ap
      j.dep_mo
      j.dep_dy
      j.ret_mo
      j.ret_dy
      j.airline
      (string_of_int j.class_level)
      (string_of_int j.stop)
      (string_of_int j.trip_type)
end

module Alert : sig
  type t =
      {
	journey_id : int;
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
	journey_id : int;
	user : string;
	email : string;
        frequency : int list;
      }

  let to_bson a = 
    (Bson.add_element "journey_id" (Bson.create_int32 (Int32.of_int a.journey_id))
       (Bson.add_element "user" (Bson.create_string a.user)
	  (Bson.add_element "email" (Bson.create_string a.email)
	     (Bson.add_element "frequency" 
		(Bson.create_list (List.map (fun fre -> Bson.create_int32 (Int32.of_int fre)) a.frequency)) Bson.empty))))

  let of_bson bs = 
    { 
      journey_id = Int32.to_int (Bson.get_int32 (Bson.get_element "journey_id" bs));
      user = Bson.get_string (Bson.get_element "user" bs);
      email = Bson.get_string (Bson.get_element "email" bs);
      frequency = 
	let el = Bson.get_list (Bson.get_element "frequency" bs) in List.map (fun e -> Int32.to_int (Bson.get_int32 e)) el
    }

  let to_string a = 
    Printf.sprintf "journey_id = %s, %s, %s"
      (string_of_int a.journey_id)
      a.user
      a.email
end

module Price : sig
  type t =
      {
        journey_id: int;
	airline : string;
	airline_http : string;
	actual_dep_date : string;
	actual_ret_date : string;
	price : float;
	last_checked : float;
	expired : bool;
      }

  val to_bson : t -> Bson.t
  val of_bson : Bson.t -> t
  val to_string : t -> string
end =  
struct
  type t =
      { 
        journey_id: int;
	airline : string;
	airline_http : string;
	actual_dep_date : string;
	actual_ret_date : string;
	price : float;
	last_checked : float;
	expired : bool;
      }

  let to_bson p = 
    Bson.add_element "journey_id" (Bson.create_int32 (Int32.of_int p.journey_id))
      (Bson.add_element "airline" (Bson.create_string p.airline) 
	 (Bson.add_element "airline_http" (Bson.create_string p.airline_http)
	 (Bson.add_element "actual_dep_date" (Bson.create_string p.actual_dep_date)
	    (Bson.add_element "actual_ret_date" (Bson.create_string p.actual_ret_date)
	       (Bson.add_element "price" (Bson.create_double p.price)
		  (Bson.add_element "last_checked" (Bson.create_double p.last_checked) 
		     (Bson.add_element "expired" (Bson.create_boolean p.expired) Bson.empty)))))))

  let of_bson bs = 
    { 
      journey_id = Int32.to_int (Bson.get_int32 (Bson.get_element "journey_id" bs));
      airline = Bson.get_string (Bson.get_element "airline" bs);
      airline_http = Bson.get_string (Bson.get_element "airline_http" bs);
      actual_dep_date = Bson.get_string (Bson.get_element "actual_dep_date" bs);
      actual_ret_date = Bson.get_string (Bson.get_element "actual_ret_date" bs);
      price = Bson.get_double (Bson.get_element "price" bs);
      last_checked = Bson.get_double (Bson.get_element "last_checked" bs);
      expired = Bson.get_boolean (Bson.get_element "expired" bs);
    }

  let to_string p = 
    Printf.sprintf "Journey_id = [%d], %s, %s, %s, %s, %s, %s"
    p.journey_id
    p.airline
    p.airline_http
    p.actual_dep_date
    p.actual_ret_date
    (string_of_float p.price)
    (Utils.string_of_utime p.last_checked)
end

module Airline : sig
  type t =
      {
	name : string;
	code : string;
	http : string
      }

  val to_bson : t -> Bson.t
  val of_bson : Bson.t -> t
end =  
struct
  type t = 
      {
	name : string;
	code : string;
	http : string
      }
	
  let to_bson a = 
    Bson.add_element "name" (Bson.create_string a.name) 
      (Bson.add_element "code" (Bson.create_string a.code) 
	 (Bson.add_element "http" (Bson.create_string a.http) Bson.empty));;

  let of_bson bs = 
    {
      name = Bson.get_string (Bson.get_element "name" bs) ;
      code = Bson.get_string (Bson.get_element "code" bs) ;
      http = Bson.get_string (Bson.get_element "http" bs) 
    }
end
