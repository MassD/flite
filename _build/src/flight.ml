type t =
    { 
      dep_ap : string;
      arr_ap : string;
      
      dep_mo : string;
      dep_dy : string;
      
      ret_mo : string;
      ret_dy : string;
      
      desired_airline : string;
      flight_id : int;
    } 

let to_bson f = 
  let dep_ap = Bson.create_string f.dep_ap in
  let arr_ap = Bson.create_string f.arr_ap in
  let dep_mo = Bson.create_string f.dep_mo in
  let dep_dy = Bson.create_string f.dep_dy in
  let ret_mo = Bson.create_string f.ret_mo in
  let ret_dy = Bson.create_string f.ret_dy in
  let desired_airline = Bson.create_string f.desired_airline in
  let flight_id = Bson.create_int32 (Int32.of_int f.flight_id) in
  Bson.add_element "dep_ap" dep_ap 
    (Bson.add_element "arr_ap" arr_ap 
       (Bson.add_element "dep_mo" dep_mo
	  (Bson.add_element "dep_dy" dep_dy
	     (Bson.add_element "ret_mo" ret_mo
		(Bson.add_element "ret_dy" ret_dy
		   (Bson.add_element "desired_airline" desired_airline
			 (Bson.add_element "flight_id" flight_id Bson.empty)))))));;

let of_bson bs = 
  let dep_ap = Bson.get_string (Bson.get_element "dep_ap" bs) in 
  let arr_ap = Bson.get_string (Bson.get_element "arr_ap" bs) in
  let dep_mo = Bson.get_string (Bson.get_element "dep_mo" bs) in 
  let dep_dy = Bson.get_string (Bson.get_element "dep_dy" bs) in
  let ret_mo = Bson.get_string (Bson.get_element "ret_mo" bs) in 
  let ret_dy = Bson.get_string (Bson.get_element "ret_dy" bs) in
  let desired_airline = Bson.get_string (Bson.get_element "desired_airline" bs) in
  let flight_id = Bson.get_int32 (Bson.get_element "flight_id" bs) in
  { 
    dep_ap = dep_ap;
    arr_ap = arr_ap;

    dep_mo = dep_mo;
    dep_dy = dep_dy;

    ret_mo = ret_mo;
    ret_dy = ret_dy;
    
    desired_airline = desired_airline;

    flight_id = Int32.to_int flight_id;    
  };;

let to_string f = 
  f.dep_ap ^ ", "
  ^ f.arr_ap ^ ", "
  ^ f.dep_mo ^ "-"
  ^ f.dep_dy ^ ", "
  ^ f.ret_mo ^ "-"
  ^ f.ret_dy ^ ", "
  ^ f.desired_airline ^ ", "
  ^ string_of_int f.flight_id ^ "\n";;
